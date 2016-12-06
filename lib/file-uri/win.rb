# encoding: UTF-8

require 'uri/generic'
require_relative '../file-uri-common'

module URI
  class WinFile < Generic
    include File

    def fixup path
      path.gsub(%r[\A/([A-Z]):?(?=/|\z)]i, '/\1:')
    end
    private :fixup

    def scrub path
      path.gsub(%r[\A/?([A-Z]):?(?=/|\z)|:]i) {|m| $1 ? "#{$1}:" : SPECIAL }
    end
    private :scrub

    def initialize(scheme,
                   userinfo, host, port, registry,
                   path, opaque,
                   query,
                   fragment,
                   parser = DEFAULT_PARSER,
                   arg_check = false)
      # detect Windows drive letter absolute paths ("file:c:/dir/file.ext")
      if !path && opaque && opaque =~ %r[\A[A-Z]:?(?=\z|/)]i
        path = fixup(SLASH + opaque)
        path += SLASH if path.length == 3
        opaque = nil
      # detect Windows-style drive letter authorities ("file://c:/dir/file.ext")
      elsif host && host =~ %r[\A[A-Z]\z]i
        path = SLASH + host + COLON + fixup(path)
        host = nil
      # detect UNC-type paths ("file:////server/Share/dir/file.ext")
      elsif !host && path && path =~ %r[\A//+]
        path = path.sub(%r[\A/+], DBL_SLASH).gsub(COLON, SPECIAL)
        host = ''
      # ...urgh
      elsif path && path =~ %r[\A//+]
        path = fixup(path.sub(%r[\A//+], SLASH))
      else
        path = fixup(path) if path
      end
      super(scheme, userinfo, host, port, registry, path, opaque, query, fragment, parser, arg_check)
    end

    ##
    # localhost:
    #
    #  * true  => 'file://localhost/' is local, 'file://example.com/' is non-local
    #  * false => 'file://localhost/' is non-local
    #
    def to_file_path localhost: true
      raise "no local path for non-local URI #{to_s}" unless local?(localhost: localhost)
      path = scrub(@path)
      #path = path.gsub(SLASH, File::SEPARATOR)
      path
    end

    SPECIAL = "\u{F03A}".freeze

  end

  @@schemes['FILE'] = WinFile

end
