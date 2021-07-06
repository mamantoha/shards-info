require "cmark"

require "noir"
require "noir/lexers/crystal"
require "noir/lexers/css"
require "noir/lexers/html"
require "noir/lexers/javascript"
require "noir/lexers/json"
require "noir/lexers/yaml"

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
      out "<div class='table-responsive'>"
      out "<table class='table table-bordered table-striped'"
      sourcepos node
      out ">"
      @table_needs_closing_table_body = false
    else
      if @table_needs_closing_table_body
        cr
        out "</tbody>"
        cr
      end

      @table_needs_closing_table_body = false
      cr
      out "</table>"
      out "</div>"
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

  def code_block(node)
    cr
    out %(<pre class="code")
    sourcepos node
    fence_info = node.fence_info

    if fence_info.bytesize.zero?
      out "><code>"
      out escape_html(node.literal)
    else
      tags = fence_info.split(' ', remove_empty: true)
      language_name = tags[0]

      if @options.github_pre_lang?
        out %( lang="#{escape_html(tags.shift)})
        tags.each { |tag| out %(" data-meta="#{escape_html(tag)}) } if @options.full_info_string?
        out %("><code class="highlight">)
      else
        out %(><code class="highlight language-#{escape_html(tags.shift)})
        tags.each { |tag| out %(" data-meta="#{escape_html(tag)}) } if @options.full_info_string?
        out %(">)
      end

      formatter_out : IO = IO::Memory.new

      if lexer = Noir.find_lexer(language_name)
        Noir.highlight(
          node.literal,
          lexer: lexer,
          formatter: Noir::Formatters::HTML.new(formatter_out)
        )
        out formatter_out.to_s
      else
        Log.info { "Lexer for '#{language_name}' not found." }
        out escape_html(node.literal)
      end
    end

    out "</code></pre>\n"
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
