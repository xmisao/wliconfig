Gem::Specification.new do |s|
  s.name        = 'wliconfig'
  s.license     = 'MIT'
  s.version     = '1.0.0'
  s.date        = '2016-03-12'
  s.summary     = "The 3rd party configuration cli for BUFFALO INC wireless lan adapters are called 'WLI' series."
  s.description = <<DESCRIPTION
wliconfig is tiny utility that change connect wireless lan network by scraping configuration page of 'WLI' terminal.

Supported 'WLI' terminals:
* WLI-UTX-AG300
DESCRIPTION
  s.authors     = ["xmisao"]
  s.email       = 'mail@xmisao.com'
  s.files       = ["bin/wliconfig", "lib/wliconfig.rb"]
  s.homepage    = 'https://github.com/xmisao/wliconfig'
	s.executables << 'wliconfig'
  s.add_dependency('mechanize', '~> 2.7')
end
