require 'docopt'
require_relative 'error'
require_relative 'helper'
require_relative 'version'

module PTTool
  # The command line interface to PTTool
  class Application
    DOC = <<-DOC
    pttool: A tool that interfaces with pivotal tracker.

    Usage:
      pttool projects [--sort=<key>] [--members]
      pttool sync PROJECT... [--force]
      pttool -h | --help
      pttool --version

    Options:
      --force       Do not prompt for confirmation [default: false].
      --members     Output the number of members [default: false].
      --sort=<key>  Sort output by name or id [default: name].
      -h --help     Show this information.
      --version     Show the pttool version (#{VERSION}).
    DOC

    def initialize
      @exit_status = 0
    end

    def cmd_projects(members, sort)
      valid = %w(name id)
      raise Docopt::Exit, 'invalid sort option' unless valid.include?(sort)
      PTTool.client.projects.sort_by { |k| k.send(sort) }.each do |project|
        member_extra = " (#{project.memberships.size} members)" if members
        puts format("%8s: #{project.name}#{member_extra}", project.id)
      end
    end

    def cmd_sync(projects, force)
      raise Docopt::Exit, 'must list at least two projects' if projects.size < 2

      require 'set'
      all_people_ids = Set.new
      by_project = {}

      PTTool.client.projects.each do |project|
        next unless projects.include?(project.name)
        projects.delete(project.name)

        all_people_ids.merge(
          # tracker_api doesn't properly compare People objects so we'll only
          # use their id (for now)
          by_project[project] = project.memberships.map(&:person).map(&:id))
      end

      puts "Could not match: #{projects.join(', ')}" unless projects.empty?
      raise Error, 'too few matching projects' if by_project.size < 2

      by_project.each do |project, people_ids|
        to_add = all_people_ids - people_ids
        next if to_add.empty? || (!force && !Helper.prompt(
          "Do you want to add #{to_add.size} people to #{project.name}?"))
        to_add.each { |person_id| Helper.add_membership(project, person_id) }
      end
    end

    def run
      handle_args(Docopt.docopt(DOC, version: VERSION))
    rescue Docopt::Exit => exc
      exit_with_status(exc.message, exc.class.usage != '')
    rescue Error => exc
      exit_with_status(exc.message)
    end

    private

    def exit_with_status(msg, condition = true)
      puts msg
      @exit_status == 0 && condition ? 1 : @exit_status
    end

    def handle_args(options)
      if options['projects']
        cmd_projects(options['--members'], options['--sort'])
      elsif options['sync']
        cmd_sync(options['PROJECT'], options['--force'])
      else
        commands = options.find_all { |x| x[1] == true }.map { |x| x[0] }
        puts "Unhandled command(s): #{commands}"
        @exit_status = 2
      end
      @exit_status
    end
  end
end
