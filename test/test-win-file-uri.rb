require 'test/unit'
$VERBOSE = true


require_relative '../lib/file-uri/win'
class Test_win_file_uri < Test::Unit::TestCase

  # 'file' URIs that are valid and are always treated as local
  def test_valid_local_uris
    [
      # POSIX-style
      ['file:///path/to/file',     '/path/to/file',      '/path/to/file'],
      ['file:/short/path/to/file', '/short/path/to/file','/short/path/to/file'],
      # drive letter
      ['file:///c:/path/to/file',  '/c:/path/to/file',   'c:/path/to/file'],
      ['file:///c/path/to/file',   '/c:/path/to/file',   'c:/path/to/file'],
      # no slash
      ['file:c:/path/to/file',     '/c:/path/to/file',   'c:/path/to/file'],
      ['file:c/path/to/file',      '/c:/path/to/file',   'c:/path/to/file'],
      # cheeky authority
      ['file://c:/path/to/file',   '/c:/path/to/file',   'c:/path/to/file'],
      ['file://c/path/to/file',    '/c:/path/to/file',   'c:/path/to/file'],
      # stinky colon
      ['file:///c:/path:to/file',  '/c:/path:to/file',   "c:/path\u{F03A}to/file"],
    ].each do |str, path, file|
      uri = URI.parse(str)
      assert_kind_of( URI::File, uri )
      assert_equal( path,  uri.path )
      # these depend on it being a URI::File object
      assert_equal( true, uri.local? )
      assert_equal( file, uri.to_file_path )
    end
  end

  # 'file' URIs that are valid and encode UNC strings in the path
  # (i.e. non-local)
  def test_valid_unc_uris
    [
      ['file:////example.com/Share/dir/file.ext',  '//example.com/Share/dir/file.ext', '\\\\example.com\\Share\\dir\\file.ext'],
      ['file://///example.com/Share/dir/file.ext', '//example.com/Share/dir/file.ext', '\\\\example.com\\Share\\dir\\file.ext'],

      ['file:////localhost/Share/dir/file.ext',    '//localhost/Share/dir/file.ext',   '\\\\localhost\\Share\\dir\\file.ext'],
      ['file://///localhost/Share/dir/file.ext',   '//localhost/Share/dir/file.ext',   '\\\\localhost\\Share\\dir\\file.ext'],
    ].each do |str, path, unc|
      uri = URI.parse(str)
      assert_kind_of( URI::File, uri )
      assert_equal( path, uri.path )

      assert_equal( false, uri.local?(localhost: false) )
      assert_equal( false, uri.local?(localhost: true) )
      assert_equal( false, uri.local? )

      assert_raise(RuntimeError) { uri.to_file_path(localhost: false) }
      assert_raise(RuntimeError) { uri.to_file_path(localhost: true) }
      assert_raise(RuntimeError) { uri.to_file_path }

      assert_equal( unc, uri.to_unc(localhost: false) )
      assert_equal( unc, uri.to_unc(localhost: true) )
      assert_equal( unc, uri.to_unc )
    end
  end

  # 'file' URIs that are valid and non-local
  def test_valid_nonlocal_uris
    [
      ['file://example.com/Share/dir/file.ext', 'example.com', '/Share/dir/file.ext', '\\\\example.com\\Share\\dir\\file.ext'],
      ['file://example.com/Share/dir/file.ext', 'example.com', '/Share/dir/file.ext', '\\\\example.com\\Share\\dir\\file.ext'],
    ].each do |str, host, path, unc|
      uri = URI.parse(str)
      assert_kind_of( URI::File, uri )
      assert_equal( path, uri.path )
      assert_equal( host, uri.host )

      assert_equal( false, uri.local?(localhost: false) )
      assert_equal( false, uri.local?(localhost: true) )
      assert_equal( false, uri.local? )

      assert_raise(RuntimeError) { uri.to_file_path(localhost: false) }
      assert_raise(RuntimeError) { uri.to_file_path(localhost: true) }
      assert_raise(RuntimeError) { uri.to_file_path }

      assert_equal( unc, uri.to_unc(localhost: false) )
      assert_equal( unc, uri.to_unc(localhost: true) )
      assert_equal( unc, uri.to_unc )
    end
  end

  # 'file' URIs that are valid and use the "localhost" authority
  # (i.e. sometimes local, sometimes non-local)
  def test_valid_localhost_uris
    [
      ['file://localhost/path/to/file',    '/path/to/file',    '\\\\localhost\\path\\to\\file',     '/path/to/file'],
      ['file://localhost/c:/path/to/file', '/c:/path/to/file', '\\\\localhost\\c:\\path\\to\\file', 'c:/path/to/file'], # FIXME - bad spec in UNC
      ['file://localhost/path/to:file',    '/path/to:file',    '\\\\localhost\\path\\to:file',      "/path/to\u{F03A}file"],
    ].each do |str, path, unc, file|
      uri = URI.parse(str)
      assert_kind_of( URI::File, uri )
      assert_equal( path, uri.path )

      assert_equal( false, uri.local?(localhost: false) )
      assert_equal( true,  uri.local?(localhost: true) )
      assert_equal( true,  uri.local? )

      assert_raise(RuntimeError) { uri.to_file_path(localhost: false) }
      assert_equal( file, uri.to_file_path(localhost: true) )
      assert_equal( file, uri.to_file_path )

      assert_equal( unc, uri.to_unc(localhost: false) )
      assert_raise(RuntimeError) { uri.to_unc(localhost: true) }
      assert_raise(RuntimeError) { uri.to_unc }
    end
  end

end
