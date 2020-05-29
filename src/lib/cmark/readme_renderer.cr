require "cmark"

class ReadmeRenderer < Cmark::HTMLRenderer
  def initialize(@options = Option::None, @extensions = Extension::None, @base_url : String? = nil)
    super(@options, @extensions)
  end

  def block_quote(node, entering)
    if entering
      out "<blockquote class='blockquote'"
      sourcepos node
      out ">\n"
    else
      cr
      out "</blockquote>\n"
    end
  end

  def link(node, entering)
    if entering
      url = node.url
      title = node.title
      out %(<a href=")
      if @options.unsafe? || !(UNSAFE_URL_REGEX === url)
        out raw_url(url) unless url.nil?
      end
      unless title.try &.empty?
        out %(" title=")
        out escape_html(title)
      end
      out %(">)
    else
      out "</a>"
    end
  end

  def image(node, entering)
    if entering
      url = node.url
      out %(<img src=")
      if @options.unsafe? || !(UNSAFE_URL_REGEX === url)
        out raw_url(url)
      end
      out %(" alt=")
    else
      title = node.title
      out %(" title="#{title}) unless title.empty?
      out %(" />)
    end
  end

  def table(node, entering)
    if entering
      cr
      out "<table class='table table-bordered table-striped table-responsive'"
      sourcepos node
      out ">"
      @table_needs_closing_table_body = false
    else
      if @table_needs_closing_table_body
        cr
        out "</tbody>"
        cr
        out "</table>"
        cr
      end
      @table_needs_closing_table_body = false
      cr
    end
  end

  def html_block(node)
    cr
    if !@options.unsafe?
      out "<!-- raw HTML omitted -->"
    elsif @extensions.tagfilter?
      out change_html(filter_tags(node.literal))
    else
      out change_html(node.literal)
    end
    cr
  end

  def html_inline(node)
    if !@options.unsafe?
      out "<!-- raw HTML omitted -->"
    elsif @extensions.tagfilter?
      out change_html(filter_tags(node.literal))
    else
      out change_html(node.literal)
    end
  end

  private def change_html(html : String) : String
    html
      .gsub(/<img.*?src=('|")([^"']+)\1/) { |m| m.gsub($2, raw_url($2)) }
      .gsub(/<a.*?href=('|")([^"']+)\1/) { |m| m.gsub($2, raw_url($2)) }
  end

  private def raw_url(url : String) : String
    uri = URI.parse(url)

    if base_url = @base_url
      if uri.relative?
        url = File.join(base_url, "raw/master", uri.path)
      end
    end

    url
  end
end
