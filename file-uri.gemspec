# encoding: UTF-8

Gem::Specification.new do |s|
  s.name     = 'file-uri'
  s.version  = '1.3.1-dev'
  s.date     = '2019-02-07'
  s.summary  = %(file-uri – the "file" URI Scheme)
  s.description = <<EOS
== file-uri – the "file" URI Scheme

Adds explicit handling for 'file' URIs to the 'uri' library.

See the documentation at http://phluid61.github.io/file-uri/
EOS
  s.authors  = ['Matthew Kerwin'.freeze]
  s.email    = ['matthew@kerwin.net.au'.freeze]
  s.files    = Dir['lib/**/*.rb']
  s.test_files=Dir['test/*.rb']
  s.homepage = 'http://phluid61.github.com/file-uri'.freeze
  s.license  = 'ISC'.freeze
end
