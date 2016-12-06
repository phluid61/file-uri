require 'uri/generic'
require_relative '../file-uri-common'

module URI
  class WinFile < Generic
    include FileCommon

    def scrub path
      path.gsub(%r[\A/([A-Z]):?(?=/|\z)|:]i) {|m| $1 ? "/#{$1}:" : SPECIAL }
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
        path = scrub(SLASH + opaque)
        path += SLASH if path.length == 3
        opaque = nil
      # detect Windows-style drive letter authorities ("file://c:/dir/file.ext")
      elsif host && host =~ %r[\A[A-Z]\z]i
        path = SLASH + host + COLON + scrub(path)
        host = nil
      # detect UNC-type paths ("file:////server/Share/dir/file.ext")
      elsif !host && path && path =~ %r[\A//+]
        path = path.sub(%r[\A/+], DBL_SLASH).gsub(COLON, SPECIAL)
        host = ''
      # ...urgh
      elsif path && path =~ %r[\A//+]
        path = scrub(path.sub(%r[\A//+], SLASH))
      else
        path = scrub(path) if path
      end
      super(scheme, userinfo, host, port, registry, path, opaque, query, fragment, parser, arg_check)
    end

    SPECIAL = "\u{F03A}".freeze

  end

  @@schemes['FILE'] = WinFile

end
