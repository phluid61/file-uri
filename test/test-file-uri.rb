# encoding: UTF-8
require 'test/unit'
require 'tempfile'
$VERBOSE = true


require_relative '../lib/file-uri'
class Test_file_uri < Test::Unit::TestCase

  # 'file' URIs that are valid and are always treated as local
  def test_valid_local_uris
    [
      ['file:///path/to/file',     '/path/to/file'],
      ['file:/short/path/to/file', '/short/path/to/file'],
    ].each do |str, path|
      uri = URI.parse(str)
      assert_kind_of( URI::FileCommon, uri )
      assert_equal( path,  uri.path )
      # these depend on it being a URI::FileCommon object
      assert_equal( true, uri.local? )
      assert_equal( path, uri.to_file_path )
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
      assert_kind_of( URI::FileCommon, uri )
      assert_equal( path, uri.path )

      assert_equal( false, uri.local?(localhost: false) )
      assert_equal( false, uri.local?(localhost: true) )
      assert_equal( false, uri.local? )
      assert_equal( false, uri.local?(localhost: :any) )

      assert_raise(RuntimeError) { uri.to_file_path(localhost: false) }
      assert_raise(RuntimeError) { uri.to_file_path(localhost: true) }
      assert_raise(RuntimeError) { uri.to_file_path }
      assert_raise(RuntimeError) { uri.to_file_path(localhost: :any) }

      assert_equal( unc, uri.to_unc(localhost: false) )
      assert_equal( unc, uri.to_unc(localhost: true) )
      assert_equal( unc, uri.to_unc )
      assert_equal( unc, uri.to_unc(localhost: :any) )
    end
  end

  # 'file' URIs that are valid and non-local
  def test_valid_nonlocal_uris
    [
      ['file://example.com/Share/dir/file.ext', 'example.com', '/Share/dir/file.ext', '\\\\example.com\\Share\\dir\\file.ext'],
      ['file://example.com/Share/dir/file.ext', 'example.com', '/Share/dir/file.ext', '\\\\example.com\\Share\\dir\\file.ext'],
    ].each do |str, host, path, unc|
      uri = URI.parse(str)
      assert_kind_of( URI::FileCommon, uri )
      assert_equal( path, uri.path )
      assert_equal( host, uri.host )

      assert_equal( false, uri.local?(localhost: false) )
      assert_equal( false, uri.local?(localhost: true) )
      assert_equal( false, uri.local? )
      assert_equal( true,  uri.local?(localhost: :any) )

      assert_raise(RuntimeError) { uri.to_file_path(localhost: false) }
      assert_raise(RuntimeError) { uri.to_file_path(localhost: true) }
      assert_raise(RuntimeError) { uri.to_file_path }
      assert_equal( path, uri.to_file_path(localhost: :any) )

      assert_equal( unc, uri.to_unc(localhost: false) )
      assert_equal( unc, uri.to_unc(localhost: true) )
      assert_equal( unc, uri.to_unc )
      assert_raise(RuntimeError) { uri.to_unc(localhost: :any) }
    end
  end

  # 'file' URIs that are valid and use the "localhost" authority
  # (i.e. sometimes local, sometimes non-local)
  def test_valid_localhost_uris
    [
      ['file://localhost/path/to/file', '/path/to/file', '\\\\localhost\\path\\to\\file'],
    ].each do |str, path, unc|
      uri = URI.parse(str)
      assert_kind_of( URI::FileCommon, uri )
      assert_equal( path, uri.path )

      assert_equal( false, uri.local?(localhost: false) )
      assert_equal( true,  uri.local?(localhost: true) )
      assert_equal( true,  uri.local? )
      assert_equal( true,  uri.local?(localhost: :any) )

      assert_raise(RuntimeError) { uri.to_file_path(localhost: false) }
      assert_equal( path, uri.to_file_path(localhost: true) )
      assert_equal( path, uri.to_file_path )
      assert_equal( path, uri.to_file_path(localhost: :any) )

      assert_equal( unc, uri.to_unc(localhost: false) )
      assert_raise(RuntimeError) { uri.to_unc(localhost: true) }
      assert_raise(RuntimeError) { uri.to_unc }
      assert_raise(RuntimeError) { uri.to_unc(localhost: :any) }
    end
  end

  def test_open
    input = "abcde"
    tmp = Tempfile.new('file-uri')
    begin
      path = tmp.path
      tmp.write(input)
      tmp.close

      uri = URI.parse('file:' + path)
      assert_kind_of( URI::FileCommon, uri )
      assert_equal( input, uri.open('r') {|io| io.read } )
    ensure
      tmp.unlink
    end
  end

end
