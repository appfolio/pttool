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
      pttool projects [--sort=<key>] [--num_members]
      pttool sync PROJECT... [--force] [--dryrun]
      pttool -h | --help
      pttool --version

    Options:
      --dryrun       Do a dry run of the sync, printing out end result
                     [default: false].
      --force        Do not prompt for confirmation [default: false].
      --num_members  Output the number of members for each project
                     [default: false].
      --sort=<key>   Sort output by name or id [default: name].
      -h --help      Show this information.
      --version      Show the pttool version (#{VERSION}).
    DOC

    def initialize
      @exit_status = 0
    end

    def cmd_projects(num_members, sort)
      valid = %w(name id)
      raise Docopt::Exit, 'invalid sort option' unless valid.include?(sort)
      PTTool.client.projects.sort_by { |k| k.send(sort) }.each do |project|
        member_extra = " (#{project.memberships.size} members)" if num_members
        puts format("%8s: #{project.name}#{member_extra}", project.id)
      end
    end

    def cmd_sync(projects, dryrun, force)
      if projects.size < 2
        raise Docopt::Exit, 'must list at least two projects'
      end

      require 'set'
      all_people = Set.new
      by_project = {}

      PTTool.client.projects.each do |project|
        next unless projects.include?(project.name)
        projects.delete(project.name)
        all_people.merge(
          by_project[project] = project.memberships.map(&:person))
      end

      puts "Could not match: #{projects.join(', ')}" unless projects.empty?
      raise Error, 'too few matching projects' if by_project.size < 2

      if dryrun
        puts "\nThe following would become members on all projects:"
        all_people.sort_by(&:name).each { |person| display_person(person) }

        by_project.each do |project, people|
          next if (new = all_people - people).empty?
          puts "\nNew members for #{project.name}:"
          new.sort_by(&:name).each { |person| display_person(person) }
        end
        return
      end

      by_project.each do |project, people|
        to_add = all_people - people
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

    def display_person(person)
      puts person.email ? "#{person.name} (#{person.email})" : person.name
    end

    def exit_with_status(msg, condition = true)
      puts msg
      @exit_status == 0 && condition ? 1 : @exit_status
    end

    def handle_args(options)
      if options['projects']
        cmd_projects(options['--num_members'], options['--sort'])
      elsif options['sync']
        cmd_sync(options['PROJECT'], options['--dryrun'], options['--force'])
      else
        commands = options.find_all { |x| x[1] == true }.map { |x| x[0] }
        puts "Unhandled command(s): #{commands}"
        @exit_status = 2
      end
      @exit_status
    end
  end
end
