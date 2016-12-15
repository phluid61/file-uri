# file-uri – the "file" URI scheme

Adds explicit handling for 'file' URIs to the `uri` library.

[![Build Status](https://secure.travis-ci.org/phluid61/file-uri.png)](http://travis-ci.org/phluid61/file-uri)
[![Gem Version](https://badge.fury.io/rb/file-uri.png)](http://badge.fury.io/rb/file-uri)

**Example**

~~~ruby
require 'uri'
require 'file-uri'

uri = URI.parse("file:///path/to/file.txt")
#=> #<URI::CoreFile file:/path/to/file.txt>
~~~

Also includes a Windows-specific version, which has extra handling for
drive letters at the start of paths.

~~~ruby
require 'uri'
require 'file-uri/win'

uri = URI.parse("file:c:/windows/path.txt")
#=> #<URI::WinFile file:/c:/windows/path.txt>

uri + "/absolute/path.txt"
#=> #<URI::WinFile file:/c:/absolute/path.txt>
~~~

## URI::File

### `local?( localhost: true )`

Returns `true` if this file URI is local.

`localhost`:

| URI                   | :any  | true      | false     |
| --------------------- | ----- | --------- | --------- |
| "file://localhost/"   | local | local     | non-local |
| "file://example.com/" | local | non-local | non-local |

### `to_unc( localhost: true )`

Returns a UNC filespace selector string for this file URI.

Raises a RuntimeError if this is a local URI (see `#local?`)

`localhost`:

| URI                   | :any  | true      | false     |
| --------------------- | ----- | --------- | --------- |
| "file://localhost/"   | local | local     | non-local |
| "file://example.com/" | local | non-local | non-local |

### `to_file_path( localhost: true )`

Returns a file path for this file URI.

Raises a RuntimeError if this is not a local URI (see `#local?`)

`localhost`:

| URI                   | :any  | true      | false     |
| --------------------- | ----- | --------- | --------- |
| "file://localhost/"   | local | local     | non-local |
| "file://example.com/" | local | non-local | non-local |


### `open( [mode [, perm]] [, opt]) → io or nil`
### `open( [mode [, perm]] [, opt]) {|io| block } → obj`

See `Kernel#open`, `URI::File#to_file_path`
