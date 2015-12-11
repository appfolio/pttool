require_relative 'error'

module PTTool
  # Module for helper functions.
  module Helper
    def self.prompt(msg = 'Do you want to continue?')
      print("#{msg} [(y)es|(N)o|(a)bort] ")
      response = STDIN.gets.strip.downcase
      raise Error, 'aborted' if %w(a abort).include?(response)
      %w(y yes true 1).include?(response)
    end

    def self.add_membership(project, person, role = 'member')
      project.add_membership(person_id: person.id, role: role)
    end
  end
end
