require "file_utils"

class Builder
  @logger : Logger
  @markdown : Markdown
  @build_dir : String

  def initialize
    @logger = Logger.new
    @markdown = Markdown.new
    @build_dir = ".amethyst"
  end

  def generate(path)
    Dir.entries(path).each do |entry|
      next if entry == "." || entry == ".."

      full_path = Path[path, entry]

      if File.directory?(full_path)
        generate(full_path)
      else
        if full_path.to_s.ends_with?(".md")
          @logger.info "    * generating: #{full_path}"

          markdown_content = File.read(full_path)
          html_body = @markdown.generate_html(markdown_content)

          styles = get_styles_for_page(full_path.to_s)

          generated = create_html_with_styles(html_body, styles)

          relative_path = full_path.to_s.gsub(/^site\//, "")
          output_path = Path[@build_dir, relative_path.gsub(".md", ".html")]

          FileUtils.mkdir_p(Path[output_path].dirname)
          File.write(output_path, generated)
        else
          next if full_path.to_s.ends_with?(".css")

          @logger.info "    * copying: #{full_path}"
          content = File.read(full_path)
          relative_path = full_path.to_s.gsub(/^look\//, "")
          output_path = Path[@build_dir, relative_path]

          FileUtils.mkdir_p(Path[output_path].dirname)
          File.write(output_path, content)
        end
      end
    end
  rescue ex : Exception
    @logger.err "! error accessing #{path}: #{ex.message}"
  end

  private def get_styles_for_page(md_path : String) : String
    styles : String = ""

    global_css_path = "look/global.css"
    if File.exists?(global_css_path)
      styles += File.read(global_css_path)
    end

    page_name = Path[md_path].basename.gsub(".md", "")
    page_css_path = "look/#{page_name}.css"

    if File.exists?(page_css_path)
      styles += "\n" + File.read(page_css_path)
    end

    styles
  end

  private def create_html_with_styles(body : String, styles : String) : String
    html = "<!DOCTYPE html>\n<html>\n<head>\n<meta charset=\"utf-8\">\n"
    html += "<link href=\"/assets/favicon.ico\" rel=\"icon\">\n"

    unless styles.empty?
      html += "<style>\n#{styles}\n</style>\n"
    end

    html += "</head>\n<body>\n#{body}\n</body>\n</html>"
    html
  end

  def run
    @logger.info "+ building for production..."
    if !File.exists?(@build_dir)
      FileUtils.mkdir(@build_dir)
    end

    @logger.info "+ generating static pages..."
    generate("site")
    generate("look")
    generate("assets")

    @logger.info "+ done!"
  end
end
