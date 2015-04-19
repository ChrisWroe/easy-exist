Gem::Specification.new do |s|
  s.name        = 'easy-exist'
  s.version     = '0.4.0'
  s.date        = Date.today.to_s
  s.summary     = "eXist-db made easy!"
  s.description = "An easy to use gem to interact with eXist-db via its REST API."
  s.authors     = ["Tom Cass"]
  s.email       = 'easy.exist.gem@gmail.com'
  s.files       = Dir['lib/**/*', 'README*', 'LICENSE*']
  s.homepage    = 'http://casst01.github.io/easy-exist'
  s.license     = 'MIT'

  s.add_runtime_dependency 'httparty', '~> 0.13', '>= 0.13.3'
  s.add_runtime_dependency 'nokogiri', '~> 1.6', '>= 1.6.6.2'

  s.add_development_dependency 'rspec', '~> 3.1', '>= 3.1.0'
  s.add_development_dependency 'rack-test', '~> 0.6', '>= 0.6.3'
  s.add_development_dependency 'shoulda-matchers', '~> 2.7', '>= 2.7.0'
  s.add_development_dependency 'pry-debugger', '~> 0.2', '>= 0.2.3'

end
