require_relative 'lib/pttool/version'

Gem::Specification.new do |s|
  s.author = 'Bryce Boe'
  s.email = 'bryce.boe@appfolio.com'
  s.executables = %w{pttool}
  s.files = Dir.glob('{bin,lib}/**/*') + %w{LICENSE.txt README.md}
  s.homepage = 'https://github.com/bboe/pttool'
  s.license = 'Simplified BSD'
  s.name = 'pttool'
  s.post_install_message = 'Thanks for installing!'
  s.summary = 'Command line tool that interfaces with pivotaltracker'
  s.version = PTTool::VERSION

  s.add_runtime_dependency 'docopt', '~> 0.5'
  s.add_runtime_dependency 'tracker_api', '~> 0.2'
end
