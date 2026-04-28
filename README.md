# file-uri – the "file" URI scheme

[![Gem Version](https://badge.fury.io/rb/file-uri.png)](http://badge.fury.io/rb/file-uri)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v3.0%20adopted-ff69b4.svg)](code_of_conduct.md)

Adds explicit handling for 'file' URIs to the `uri` library.

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

The `localhost` parameter instructs the library how to interpret
special values in the host field, to retain compatibility with various
other libraries and programs out there:

| URI                   | :any  | true      | false     |
| --------------------- | ----- | --------- | --------- |
| "file://localhost/"   | local | local     | non-local |
| "file://example.com/" | local | non-local | non-local |


### `to_unc( localhost: true )`

Returns a UNC filespace selector string for this file URI.

Raises a RuntimeError if this is a local URI (see `#local?`)


### `to_file_path( localhost: true )`

Returns a file path for this file URI.

Raises a RuntimeError if this is not a local URI (see `#local?`)


### `open( [mode [, perm]] [, opt]) → io or nil`
### `open( [mode [, perm]] [, opt]) {|io| block } → obj`

See `Kernel#open`, `URI::File#to_file_path`


## Contributing

We require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.


## Contributor Code of Conduct

This repository is subject to a [Contributor Code of Conduct](code_of_conduct.md)
adapted from the [Contributor Covenant][cc], version 3.0, available at
<https://www.contributor-covenant.org/version/3/0/>


[cc]: https://www.contributor-covenant.org


## Licence

This project is licensed under the ISC licence. See [LICENSE](LICENSE)
for details
