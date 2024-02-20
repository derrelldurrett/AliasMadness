# truncate_log.rb
def process_args
  require 'getoptlong'

  opts = GetoptLong.new(
    ['--help', '-h', GetoptLong::NO_ARGUMENT],
    ['--log', GetoptLong::OPTIONAL_ARGUMENT]
  );

  opts.each do |opt, arg|
    case opt
    when '--help'
      puts <<-EOF
truncate_log [OPTION] ...

-h, --help:
   show help

--log [<name>]
   The name of the log to truncate: <name>.log.
   Assumes a path relative to the root of the running script, unless an absolute path
   is given. REQUIRED
      EOF
    when '--log'
      @name = (arg.empty? ? ENV['RAILS_ENV'] : arg) + '.log'
      unless File.exist? @name
        raise NoSuchFileError, "File '#{@name}' not found.\n"
      end
    else
      raise StandardError, "no option selected!\n"
    end
    @name.nil? and raise NoSuchFileError, "--log not specified.\n"
  end
end

class NoSuchFileError < RuntimeError
end

process_args
(File.truncate @name, 0) and puts "File '#{@name}' truncated"
