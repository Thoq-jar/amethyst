require "./logging"
require "./build"
require "http/server"
require "file_utils"

class Dev
  @logger : Logger
  @build : Builder
  @server : HTTP::Server
  @last_modified : Hash(String, Time)

  def initialize
    @logger = Logger.new
    @build = Builder.new
    @last_modified = Hash(String, Time).new
    @server = HTTP::Server.new do |context|
      serve_file(context)
    end
  end

  def serve_file(context)
    path = context.request.path
    path = "/index.html" if path == "/"

    file_path = ".amethyst#{path}"

    if File.exists?(file_path)
      if path.ends_with?(".html")
        context.response.content_type = "text/html"
      elsif path.ends_with?(".css")
        context.response.content_type = "text/css"
      elsif path.ends_with?(".js")
        context.response.content_type = "application/javascript"
      end

      context.response.print File.read(file_path)
    else
      context.response.status_code = 404
      context.response.print "404 Not Found"
    end
  end

  def clear_screen
    print "\033[2J\033[H"
  end

  def collect_files(dir : String, extensions : Array(String)) : Array(String)
    files = [] of String

    return files unless Dir.exists?(dir)

    Dir.entries(dir).each do |entry|
      next if entry == "." || entry == ".."

      full_path = File.join(dir, entry)

      if File.directory?(full_path)
        files.concat(collect_files(full_path, extensions))
      elsif extensions.any? { |ext| entry.ends_with?(ext) }
        files << full_path
      end
    end

    files
  end

  def files_changed? : Bool
    watch_dirs = ["src", "demo", "site", "look", "assets"]
    extensions = [".cr", ".md", ".html", ".css", ".js"]

    changed = false

    watch_dirs.each do |dir|
      next unless Dir.exists?(dir)

      files = collect_files(dir, extensions)
      files.each do |file|
        if File.exists?(file)
          mtime = File.info(file).modification_time
          if @last_modified.has_key?(file)
            if @last_modified[file] != mtime
              @last_modified[file] = mtime
              changed = true
            end
          else
            @last_modified[file] = mtime
          end
        end
      end
    end

    changed
  end

  def build_project
    @logger.info "rebuilding project..."
    @build.run
    @logger.info "build complete"
  end

  def initialize_file_tracking
    watch_dirs = ["src", "demo", "site", "look", "assets"]
    extensions = [".cr", ".md", ".html", ".css", ".js"]

    watch_dirs.each do |dir|
      next unless Dir.exists?(dir)

      files = collect_files(dir, extensions)
      files.each do |file|
        if File.exists?(file)
          mtime = File.info(file).modification_time
          @last_modified[file] = mtime
        end
      end
    end
  end

  def start_server
    spawn do
      @server.bind_tcp(9595)
      @logger.info "dev server running at http://localhost:9595"
      @server.listen
    end
  end

  def run
    clear_screen
    @logger.info "amethyst dev server starting..."
    build_project
    initialize_file_tracking

    start_server

    @logger.info "watching for file changes..."
    @logger.info "press Ctrl+C to stop"

    loop do
      sleep(500.milliseconds)

      if files_changed?
        clear_screen
        @logger.info "file changes detected"
        build_project
        @logger.info "watching for file changes..."
      end
    end
  rescue ex : Exception
    @logger.err "error in dev server: #{ex.message}"
  end
end
