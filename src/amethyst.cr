require "./logging"
require "./markdown"
require "./build"
require "./server"
require "./dev"

module Amethyst
  VERSION = "0.1.0"

  class Main
    @logger : Logger
    @markdown : Markdown
    @build : Builder
    @server : Server
    @dev : Dev

    def initialize
      @logger = Logger.new
      @markdown = Markdown.new
      @build = Builder.new
      @server = Server.new
      @dev = Dev.new
    end

    def show_help
      @logger.info "usage: amethyst <command>"
      @logger.info "tip: run `amethyst build` to build the site then `amethyst serve [port]` to serve it!"
      exit 1
    end

    def check_build
      if !File.exists?(".amethyst")
        @logger.err("please build the project before running!")
        show_help
      end
    end

    def main(args)
      arg_size = args.size
      if arg_size < 1
        show_help
      end

      command = args[0]
      case command
      when "serve"
        if arg_size >= 2
          begin
            port = args[1].to_i16
          rescue ArgumentError
            @logger.err "invalid port number: #{args[1]}"
            show_help
          end
        else
          port = 9595_i16
        end

        check_build
        @server.serve(port)
      when "build"
        @build.run
      when "dev"
        @dev.run
      else
        show_help
      end
    end
  end
end

amethyst = Amethyst::Main.new
amethyst.main(ARGV)
