require 'uri/generic'
require_relative 'file-uri/common'

module URI
  class CoreFile < Generic
    include FileCommon

    def initialize(scheme,
                   userinfo, host, port, registry,
                   path, opaque,
                   query,
                   fragment,
                   parser = DEFAULT_PARSER,
                   arg_check = false)
      # detect UNC-type paths ("file:////server/Share/dir/file.ext")
      if !host && path && path =~ %r[\A//+]
        path = path.sub(%r[\A/+], DBL_SLASH)
        host = ''
      # ...urgh
      elsif path && path =~ %r[\A/+]
        path = path.sub(%r[\A/+], SLASH)
      end
      super(scheme, userinfo, host, port, registry, path, opaque, query, fragment, parser, arg_check)
    end

  end

  @@schemes['FILE'] = CoreFile

end
