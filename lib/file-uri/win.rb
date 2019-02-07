# encoding: UTF-8

require 'uri/generic'
require_relative 'common'

module URI
  class WinFile < Generic
    include FileCommon

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

    #
    # == Args
    #
    # +oth+::
    #    URI or String
    #
    # == Description
    #
    # Merges two URI's.
    #
    # == Usage
    #
    #   require 'uri'
    #
    #   uri = URI.parse("http://my.example.com")
    #   p uri.merge("/main.rbx?page=1")
    #   # =>  #<URI::HTTP:0x2021f3b0 URL:http://my.example.com/main.rbx?page=1>
    #
    def merge(oth)
      rel = parser.send(:convert_to_uri, oth)

      if rel.absolute?
        #raise BadURIError, "both URI are absolute" if absolute?
        # hmm... should return oth for usability?
        return rel
      end

      unless self.absolute?
        raise BadURIError, "both URI are relative"
      end

      base = self.dup

      authority = rel.userinfo || rel.host || rel.port

      # RFC2396, Section 5.2, 2)
      if (rel.path.nil? || rel.path.empty?) && !authority && !rel.query
        base.fragment=(rel.fragment) if rel.fragment
        return base
      end

      base.query = nil
      base.fragment=(nil)

      # RFC2396, Section 5.2, 4)
      if !authority
        # Difference from URI::Generic -- handle drive letter
        base_path = base.path
        rel_path = rel.path
        if base_path && rel_path
          if rel_path =~ %r[\A(\.\.(?=/|\z)|/(?![A-Z]:(/|\z)))]i && base_path.sub!(%r[\A/?[A-Z]:(?=/|\z)]i, '')
            base.set_path($~[0] + merge_path(base_path, rel_path))
          else
            base.set_path(merge_path(base_path, rel_path))
          end
        end
      else
        # RFC2396, Section 5.2, 4)
        base.set_path(rel.path) if rel.path
      end

      # RFC2396, Section 5.2, 7)
      base.set_userinfo(rel.userinfo) if rel.userinfo
      base.set_host(rel.host)         if rel.host
      base.set_port(rel.port)         if rel.port
      base.query = rel.query       if rel.query
      base.fragment=(rel.fragment) if rel.fragment

      return base
    end # merge
    alias + merge

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
