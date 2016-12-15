require 'uri/generic'

module URI
  module File

    COMPONENT = %i[
      scheme
      userinfo host port
      path
      query
      fragment
    ]

    def self.build(args)
      tmp = Util.make_components_hash(self, args)
      super(tmp)
    end

    ##
    # localhost:
    #
    #  * :any  => any non-empty host is local
    #  * true  => 'file://localhost/' is local, 'file://example.com/' is non-local
    #  * false => 'file://localhost/' is non-local
    #
    def local? localhost: true
      if host && !host.empty?
        return true if localhost == :any
        return localhost && (host.downcase == LOCALHOST)
      elsif path.start_with? DBL_SLASH
        return false
      end
      true
    end

    ##
    # localhost:
    #
    #  * :any  => any non-empty host is local
    #  * true  => 'file://localhost/' is local, 'file://example.com/' is non-local
    #  * false => 'file://localhost/' is non-local
    #
    def to_file_path localhost: true
      raise "no local path for non-local URI #{to_s}" unless local?(localhost: localhost)
      path
    end

    ##
    # localhost:
    #
    #  * :any  => any non-empty host is local
    #  * true  => 'file://localhost/' is local, 'file://example.com/' is non-local
    #  * false => 'file://localhost/' is non-local
    #
    def to_unc localhost: true
      if host && !host.empty?
        if localhost != :any && (!localhost || (host.downcase != LOCALHOST))
          unc = DBL_BACKSLASH + host
          unc += COLON + port if port
          unc += path.gsub(%r[/], BACKSLASH)
          return unc
        end
      elsif path.start_with? DBL_SLASH
        return path.gsub(%r[/], BACKSLASH)
      end
      raise "no UNC conversion for local URI #{to_s}"
    end

    COLON = ?:.freeze
    SLASH = ?/.freeze
    DBL_SLASH     = '//'.freeze
    BACKSLASH     = '\\'.freeze
    DBL_BACKSLASH = '\\\\'.freeze
    LOCALHOST     = 'localhost'.freeze

  end
end
