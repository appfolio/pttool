require 'docopt'
require_relative 'version'

module PTTool
  class Application
    DOC = %Q{
    pttool: A tool that interfaces with pivotal tracker.

    Usage:
      pttool projects
      pttool -h | --help
      pttool --version

    Options:
      -h --help    Show this information.
      --version    Show the pttool version (#{VERSION}).
    }

    def initialize
      @exit_status = 0
    end

    def cmd_projects
      puts 'obtaining list of PT projects'
    end

    def run
      opt = Docopt::docopt(DOC, version: VERSION)
      if opt['projects']
        cmd_projects
      else
        commands = opt.find_all{ |x| x[1] == true }.map{ |x| x[0] }
        puts "Unhandled command(s): #{commands}"
        @exit_status = 2
      end
      @exit_status
    rescue Docopt::Exit => exc
      puts exc.message
      @exit_status = 1 if @exit_status == 0 && exc.class.usage != ''
      @exit_status
    end
  end
end
