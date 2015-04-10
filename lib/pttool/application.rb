require 'docopt'
require_relative 'error'
require_relative 'version'

module PTTool
  # The command line interface to PTTool
  class Application
    DOC = <<-DOC
    pttool: A tool that interfaces with pivotal tracker.

    Usage:
      pttool projects [--sort=<key>] [--members]
      pttool -h | --help
      pttool --version

    Options:
      --members     Output the number of members [default: false].
      --sort=<key>  Sort output by name or id [default: name].
      -h --help     Show this information.
      --version     Show the pttool version (#{VERSION}).
    DOC

    def initialize
      @exit_status = 0
    end

    def cmd_projects(members, sort)
      unless %w(name id).include?(sort)
        raise Docopt::Exit, 'invalid sort option'
      end
      PTTool.client.projects.sort_by { |k| k.send(sort) }.each do |project|
        member_extra = " (#{project.memberships.size} members)" if members
        puts format("%8s: #{project.name}#{member_extra}", project.id)
      end
    end

    def run
      opt = Docopt.docopt(DOC, version: VERSION)
      if opt['projects']
        cmd_projects(opt['--members'], opt['--sort'])
      else
        commands = opt.find_all { |x| x[1] == true }.map { |x| x[0] }
        puts "Unhandled command(s): #{commands}"
        @exit_status = 2
      end
      @exit_status
    rescue Docopt::Exit => exc
      exit_with_status(exc.message, exc.class.usage != '')
    rescue => exc
      exit_with_status(exc.message)
    end

    private

    def exit_with_status(msg, condition = true)
      puts msg
      @exit_status == 0 && condition ? 1 : @exit_status
    end
  end
end
