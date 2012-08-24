$LOAD_PATH << File.join(File.dirname(__FILE__), "lib")
require "ansi_chameleon/version"

Gem::Specification.new do |s|
  s.name          = "ansi_chameleon"
  s.version       = AnsiChameleon::VERSION
  s.author        = "Jacek Mikrut"
  s.email         = "jacekmikrut.software@gmail.com"
  s.homepage      = "http://github.com/jacekmikrut/ansi_chameleon"
  s.summary       = "Text terminal output coloring tool."
  s.description   = "Colorizes text terminal output by converting custom HTML-like tags into color ANSI escape sequences."

  s.files         = Dir["lib/**/*", "README*", "LICENSE*", "Changelog*"]
  s.require_path  = "lib"

  s.add_runtime_dependency "simple_style_sheet", "~> 0.0"

  s.add_development_dependency "rspec", "~> 2.0"
end
