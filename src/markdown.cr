class Markdown
  def generate_html(markdown : String) : String
    html = ""
    in_code_block = false

    markdown.each_line do |line|
      line.strip

      case line
      when ""
        html += "<br>"
      when /^\#+/
        html += convert_header(line)
      when /^\*\*(.*?)\*\*$/
        html += convert_bold(line)
      when /^\*(.*?)\*$/
        html += convert_italic(line)
      when /^!\[.*\]\(.*\)$/
        html += convert_image(line)
      when /^\[.*\]\(.*\)$/
        html += convert_link(line)
      when /^>/
        html += convert_blockquote(line)
      when /^(\-|\+|\*)\s/
        html += convert_unordered_list(line)
      when /^\d+\.\s/
        html += convert_ordered_list(line)
      when /~~~|```/
        in_code_block = !in_code_block
        html += in_code_block ? "<pre><code>" : "</code></pre>"
      when /^---|^\*\*\*$/
        html += "<hr>"
      when /~~(.*?)~~/
        html += convert_strikethrough(line)
      else
        html += convert_paragraph(line)
      end
    end
    html
  end

  def convert_header(line : String) : String
    level = line.count("#")
    text = line.sub(/^#+\s*/, "").strip
    "<h#{level}>#{text}</h#{level}>"
  end

  def convert_bold(line : String) : String
    text = line.sub(/^\*\*(.*?)\*\*$/, "\\1")
    "<strong>#{text}</strong>"
  end

  def convert_italic(line : String) : String
    text = line.sub(/^\*(.*?)\*$/, "\\1")
    "<em>#{text}</em>"
  end

  def convert_link(line : String) : String
    matches = line.match(/\[([^\]]+)\]\(([^)]+)\)/)
    if matches
      href = matches[2].gsub(/\.md$/, ".html")
      "<a href=\"#{href}\">#{matches[1]}</a>"
    else
      ""
    end
  end

  def convert_image(line : String) : String
    matches = line.match(/!\[([^\]]*)\]\(([^)]+)\)/)
    if matches
      "<img src=\"#{matches[2]}\" alt=\"#{matches[1]}\" />"
    else
      ""
    end
  end

  def convert_blockquote(line : String) : String
    text = line.sub(/^>\s*/, "")
    "<blockquote>#{text}</blockquote>"
  end

  def convert_unordered_list(line : String) : String
    "<ul><li>#{line.sub(/^[\*\-\+]\s*/, "")}</li></ul>"
  end

  def convert_ordered_list(line : String) : String
    "<ol><li>#{line.sub(/^\d+\.\s*/, "")}</li></ol>"
  end

  def convert_paragraph(line : String) : String
    "<p>#{line}</p>"
  end

  def convert_strikethrough(line : String) : String
    text = line.sub(/^~~(.*?)~~$/, "\\1")
    "<del>#{text}</del>"
  end
end
