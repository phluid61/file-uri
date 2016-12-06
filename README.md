# file-uri -- the "file" URI scheme

Adds explicit handling for 'file' URIs to the `uri` library.

**Example**

~~~ruby
require 'uri'
require 'file-uri'

uri = URI.parse("file:///path/to/file.txt")
~~~

Also includes a Windows-specific version, which has extra handling for
drive letters at the start of paths.

~~~ruby
require 'uri'
require 'file-uri/win'

uri = URI.parse("file:c:/windows/path.txt")
~~~

## URI::File

### `local? localhost: true`

Returns +true+ if this file URI is local.

`localhost`:

 * true  => "file://localhost/" is local, "file://example.com/" is non-local
 * false => "file://localhost/" is non-local

### `to_unc localhost: true`

Returns a UNC filespace selector string for this file URI.

Raises a RuntimeError if this is a local URI (see `#local?`)

`localhost`:

 * true  => "file://localhost/" is local, "file://example.com/" is non-local
 * false => "file://localhost/" is non-local

### `to_file_path localhost: true`

Returns a file pathfor this file URI.

Raises a RuntimeError if this is not a local URI (see `#local?`)

`localhost`:

 * true  => "file://localhost/" is local, "file://example.com/" is non-local
 * false => "file://localhost/" is non-local

