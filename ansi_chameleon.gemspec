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

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
end
