require "cmark"

require "cadmium_transliterator"

require "noir"
require "noir/lexers/crystal"
require "noir/lexers/css"
require "noir/lexers/html"
require "noir/lexers/xml"
require "noir/lexers/javascript"
require "noir/lexers/json"
require "noir/lexers/yaml"
require "noir/lexers/sql"

class ReadmeRenderer < Cmark::HTMLRenderer
  VIDEO_EXTENSIONS = [".webm", ".mp4", ".mov"]

  def initialize(@options = Option::None, @extensions = Extension::None, *, @repository : Repository)
    super(@options, @extensions)
  end

  def heading(node, entering)
    title = nil

    if (first_child = node.first_child) && first_child.type.text?
      title = Cadmium::Transliterator.parameterize(first_child.literal)
    end

    if entering
      cr
      out "<h#{node.heading_level}"
      sourcepos node
      out ">"

      if title
        out "<a id=\"#{title}\" class=\"anchor\" href=\"##{title}\"><svg class=\"octicon octicon-link\" viewBox=\"0 0 16 16\" version=\"1.1\" width=\"16\" height=\"16\" aria-hidden=\"true\"><path fill-rule=\"evenodd\" d=\"M7.775 3.275a.75.75 0 001.06 1.06l1.25-1.25a2 2 0 112.83 2.83l-2.5 2.5a2 2 0 01-2.83 0 .75.75 0 00-1.06 1.06 3.5 3.5 0 004.95 0l2.5-2.5a3.5 3.5 0 00-4.95-4.95l-1.25 1.25zm-4.69 9.64a2 2 0 010-2.83l2.5-2.5a2 2 0 012.83 0 .75.75 0 001.06-1.06 3.5 3.5 0 00-4.95 0l-2.5 2.5a3.5 3.5 0 004.95 4.95l1.25-1.25a.75.75 0 00-1.06-1.06l-1.25 1.25a2 2 0 01-2.83 0z\"></path></svg></a>"
      end
    else
      out "</h#{node.heading_level}"
      out ">\n"
    end
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
    is_video = node.url.ends_with?(Regex.union(VIDEO_EXTENSIONS))

    if is_video
      render_video_link(node, entering)
    else
      render_link(node, entering)
    end
  end

  private def render_link(node, entering)
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

  private def render_video_link(node, entering)
    if entering
      url = node.url
      title = node.title
      out %(<video controls="controls" muted="muted" src=")
      if @options.unsafe? || !(UNSAFE_URL_REGEX === url)
        out raw_url(url)
      end
      unless title.try &.empty?
        out %(" title=")
        out escape_html(title)
      end
      out %(">)
    else
      out "</video>"
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

  def tasklist_item_inner(node, entering)
    if entering
      if node.tasklist_item_checked?
        out %(<input type="checkbox" class="form-check-input" checked="" disabled="" /> )
      else
        out %(<input type="checkbox" class="form-check-input" disabled="" /> )
      end
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

    @repository.try do |repository|
      if uri.relative?
        url = File.join(repository.decorate.provider_url, "raw/#{repository.default_branch}", uri.path)
      end
    end

    url
  end
end
