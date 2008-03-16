require File.dirname(__FILE__) + '/../haml'
require 'optparse'

module Haml
  # This module contains code for working with the
  # haml, sass, and haml2html executables,
  # such as command-line parsing stuff.
  # It shouldn't need to be invoked by client code.
  module Exec # :nodoc:
    # A class that encapsulates the executable code
    # for all three executables.
    class Generic # :nodoc:
      def initialize(args)
        @args = args
        @options = {}
      end

      def parse!
        begin
          @opts = OptionParser.new(&method(:set_opts))
          @opts.parse!(@args)

          process_result
          
          @options
        rescue Exception => e
          raise e if e.is_a? SystemExit

          $stderr.print "#{e.class} on line #{get_line e}: " if @options[:trace]
          $stderr.puts e.message

          e.backtrace[1..-1].each { |t| $stderr.puts "  #{t}" } if @options[:trace]

          exit 1
        end
        exit 0
      end

      def to_s
        @opts.to_s
      end

      protected

      def get_line(exception)
        exception.backtrace[0].scan(/:(\d+)/)[0]
      end
      
      private

      def set_opts(opts)
        opts.on('-s', '--stdin', :NONE, 'Read input from standard input instead of an input file') do
          @options[:input] = $stdin
        end

        opts.on('--trace', :NONE, 'Show a full traceback on error') do
          @options[:trace] = true
        end

        opts.on_tail("-?", "-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on_tail("-v", "--version", "Print version") do
          puts("Haml " + File.read(File.dirname(__FILE__) + '/../../VERSION'))
          exit
        end
      end

      def process_result
        input, output = @options[:input], @options[:output]
        input_file, output_file = if input
                                    [nil, open_file(ARGV[0], 'w')]
                                  else
                                    [open_file(ARGV[0]), open_file(ARGV[1], 'w')]
                                  end

        input  ||= input_file
        output ||= output_file
        input  ||= $stdin
        output ||= $stdout

        @options[:input], @options[:output] = input, output
      end

      def open_file(filename, flag = 'r')
        return if filename.nil?
        File.open(filename, flag)
      end
    end

    # A class encapsulating the executable functionality
    # specific to Haml and Sass.
    class HamlSass < Generic # :nodoc:
      def initialize(args)
        super
        @options[:for_engine] = {}
      end

      private

      def set_opts(opts)
        opts.banner = <<END
Usage: #{@name.downcase} [options] [INPUT] [OUTPUT]

Description:
  Uses the #{@name} engine to parse the specified template
  and outputs the result to the specified file.

Options:
END
       
        opts.on('--rails RAILS_DIR', "Install Haml and Sass from the Gem to a Rails project") do |dir|
          original_dir = dir

          dir = File.join(dir, 'vendor', 'plugins')

          unless File.exists?(dir)
            puts "Directory #{dir} doesn't exist"
            exit
          end

          dir = File.join(dir, 'haml')

          if File.exists?(dir)
            puts "Directory #{dir} already exists."
            exit
          end

          begin
            Dir.mkdir(dir)
          rescue SystemCallError
            puts "Cannot create #{dir}"
            exit
          end

          File.open(File.join(dir, 'init.rb'), 'w') do |file|
            file.puts "require 'rubygems'"
            file << File.read(File.dirname(__FILE__) + "/../../init.rb")
          end

          puts "Haml plugin added to #{original_dir}"
          exit
        end

        opts.on('-c', '--check', "Just check syntax, don't evaluate.") do
          @options[:check_syntax] = true
          @options[:output] = StringIO.new
        end

        super
      end

      def process_result
        super
        require File.dirname(__FILE__) + "/../#{@name.downcase}"
      end
    end

    # A class encapsulating executable functionality
    # specific to Sass.
    class Sass < HamlSass # :nodoc:
      def initialize(args)
        super
        @name = "Sass"
      end

      def set_opts(opts)
        super

        opts.on('-t', '--style NAME',
                'Output style. Can be nested (default), compact, or expanded.') do |name|
          @options[:for_engine][:style] = name.to_sym
        end
      end

      def process_result
        super
        input = @options[:input]
        output = @options[:output]

        template = input.read()
        input.close() if input.is_a? File

        begin
          # We don't need to do any special handling of @options[:check_syntax] here,
          # because the Sass syntax checking happens alongside evaluation
          # and evaluation doesn't actually evaluate any code anyway.
          result = ::Sass::Engine.new(template, @options[:for_engine]).render
        rescue ::Sass::SyntaxError => e
          raise e if @options[:trace]
          raise "Syntax error on line #{get_line e}: #{e.message}"
        end

        output.write(result)
        output.close() if output.is_a? File
      end
    end

    # A class encapsulating executable functionality
    # specific to Haml.
    class Haml < HamlSass # :nodoc:
      def initialize(args)
        super
        @name = "Haml"
      end

      def set_opts(opts)
        super

        opts.on('-t', '--style NAME',
                'Output style. Can be indented (default) or ugly.') do |name|
          @options[:for_engine][:ugly] = true if name.to_sym == :ugly
        end

        opts.on('-f', '--format NAME',
                'Output format. Can be xhtml (default), html4, or html5.') do |name|
          @options[:for_engine][:format] = name.to_sym
        end
      end

      def process_result
        super
        input = @options[:input]
        output = @options[:output]

        template = input.read()
        input.close() if input.is_a? File

        begin
          engine = ::Haml::Engine.new(template, @options[:for_engine])
          if @options[:check_syntax]
            puts "Syntax OK"
            return
          end
          result = engine.to_html
        rescue Exception => e
          raise e if @options[:trace]

          case e
          when ::Haml::SyntaxError; raise "Syntax error on line #{get_line e}: #{e.message}"
          when ::Haml::HamlError;   raise "Haml error on line #{get_line e}: #{e.message}"
          else raise "Exception on line #{get_line e}: #{e.message}\n  Use --trace for backtrace."
          end
        end

        output.write(result)
        output.close() if output.is_a? File
      end
    end

    # A class encapsulating executable functionality
    # specific to the html2haml executable.
    class HTML2Haml < Generic # :nodoc:
      def initialize(args)
        super

        @module_opts = {}

        begin
          require 'haml/html'
        rescue LoadError => err
          dep = err.message.scan(/^no such file to load -- (.*)/)[0]
          puts "Required dependency #{dep} not found!"
          exit 1
        end
      end

      def set_opts(opts)
        opts.banner = <<END
Usage: html2haml [options] [INPUT] [OUTPUT]

Description: Transforms an HTML file into corresponding Haml code.

Options:
END

        opts.on('-r', '--rhtml', 'Parse RHTML tags.') do
          @module_opts[:rhtml] = true
        end

        opts.on('-x', '--xhtml', 'Parse the input using the more strict XHTML parser.') do
          @module_opts[:xhtml] = true
        end

        super
      end

      def process_result
        super

        input = @options[:input]
        output = @options[:output]

        output.write(::Haml::HTML.new(input, @module_opts).render)
      end
    end

    # A class encapsulating executable functionality
    # specific to the css2sass executable.
    class CSS2Sass < Generic # :nodoc:
      def initialize(args)
        super

        require 'sass/css'
      end

      def set_opts(opts)
        opts.banner = <<END
Usage: css2sass [options] [INPUT] [OUTPUT]

Description: Transforms a CSS file into corresponding Sass code.

Options:
END

        super
      end

      def process_result
        super

        input = @options[:input]
        output = @options[:output]

        output.write(::Sass::CSS.new(input).render)
      end
    end
  end
end
