require "http/server"
require "./logging"

class Server
  @logger : Logger
  @build_dir : String

  def initialize
    @logger = Logger.new
    @build_dir = ".amethyst"
  end

  def serve(port : Int16)
    server = HTTP::Server.new do |context|
      path = sanitize_path(context.request.path)

      if path == "/"
        path = "/index.html"
      elsif !path.ends_with?(".html") && !path.includes?(".")
        path = "#{path}.html"
      end

      file_path = File.join(@build_dir, path.lchop('/'))

      begin
        if File.exists?(file_path) && File.file?(file_path)
          data = File.read(file_path)
          context.response.content_type = get_content_type(file_path)
          context.response.print data
        else
          context.response.status_code = 404
          context.response.content_type = "text/html"
          context.response.print "<h1>404 Not Found</h1><p>The requested page could not be found.</p>"
          @logger.warn "not found: #{path}"
        end
      rescue ex
        context.response.status_code = 500
        context.response.content_type = "text/html"
        context.response.print "<h1>500 Internal Server Error</h1>"
        @logger.err "error serving #{path}: #{ex.message}"
      end
    end

    address = server.bind_tcp(port)
    @logger.info "listening on http://#{address}"

    server.listen
  end

  private def sanitize_path(path : String) : String
    path = path.gsub(/\.\.\//, "")
    path = path.gsub(/\.\.\\/, "")

    path = "/" + path unless path.starts_with?("/")

    path
  end

  private def get_content_type(file_path : String) : String
    case File.extname(file_path).downcase
    when ".html", ".htm"
      "text/html"
    when ".css"
      "text/css"
    when ".js"
      "application/javascript"
    when ".json"
      "application/json"
    when ".png"
      "image/png"
    when ".jpg", ".jpeg"
      "image/jpeg"
    when ".gif"
      "image/gif"
    when ".svg"
      "image/svg+xml"
    when ".ico"
      "image/x-icon"
    else
      "text/plain"
    end
  end
end
