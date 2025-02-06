[![Actions Status](https://github.com/lizmat/Ecosystem-Cache/actions/workflows/linux.yml/badge.svg)](https://github.com/lizmat/Ecosystem-Cache/actions) [![Actions Status](https://github.com/lizmat/Ecosystem-Cache/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/Ecosystem-Cache/actions) [![Actions Status](https://github.com/lizmat/Ecosystem-Cache/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/Ecosystem-Cache/actions)

NAME
====

Ecosystem::Cache - maintain a local cache of an ecosystem

SYNOPSIS
========

```raku
use Ecosystem::Cache;

my $ec = Ecosystem::Cache.new;  # defaults to REA

$ec.update;  # make sure all distributions are up-to-date
```

DESCRIPTION
===========

The `Ecosystem::Cache` distribution provides the logic to maintain a local cache of the most recent distributions in a Raku ecosystem.

Its use is mainly intended to serve as an area in which searches can be performed, such as with [`App::Rak`](https://raku.land/zef:lizmat/App::Rak).

SCRIPTS
=======

    $ update-ecosystem-cache

The `update-ecosystem-cache` script will update the `REA` cache and output any statistics when appropriate.

MAIN METHODS
============

new
---

```raku
use Ecosystem::Cache;

my $ec = Ecosystem::Cache.new(:update);  # defaults to REA
```

The `new` method instantiates the `Ecosystem::Cache` object, and optionally refreshes the information about the ecosystem (instead of using the information already cached by `zef`). It takes the following named arguments:

### :ecosystem

Optional. The [`Ecosystem`](https://raku.land/zef:lizmat/Ecosystem) object for which to set up / update a cache. Defaults to whatever ecosystem in instantiated with `Ecosystem.new`.

After instantion, the `Ecosystem` object used can be obtained by the `ecosystem` method.

### :cache

Optional. An `IO::Path` indicating the directory where distribution files should be stored. From there, a directory will be added with the ecosystem name.

Defaults to what is either specified by:

  * the `RAKU_ECOSYSTEM_CACHE` environment variable

  * the subdirectory `.ecosystem/cache` in `$*HOME`

  * the subdirectory `.ecosystem/cache` in `$*TMPDIR`

In the most common case, this will default to `~/.ecosystem/cache`.

After instantion, the `IO::Path` used can be obtained by the `cache` method.

### :update

Optional. If specified with a true value, will call the `.update` method on the underlying `Ecosystem` object, causing the meta list of the ecosystem to be fetched from the Internet (rather than using the meta list cached by `zef`).

update
------

```raku
$ec.update(my @new, my @gone, my %erred);
say "Added @new.elems(), removed @gone.elems(), failed %erred.elems()";
```

The `update` method updates the cache with the latest distributions of that ecosystem. If this is the first call to this method for a given cache, it may take quite some time before it is done (at the moment of this writing more than 2200 distributions, totalling to 1.1 GB will be downloaded and handled then). Any calls later will only update new distributions and remove any distributions that are no longer the latest.

The `update` method takes 3 optional positional arguments:

  * an array for storing the identities that were added

  * an array for storing the identities that were removed

  * a hash for storing the identities that had a failure message, keyed to the identity

HELPER METHODS
==============

name
----

```raku
say $ec.name;
```

Returns the name of the ecosystem to which this cache applies.

archive-URL
-----------

```raku
say $ec.archive-URL($identity);
```

Returns the URL for downloading the distribution of the given identity.

cache
-----

```raku
say $ec.cache;             # root dir of cache info

say $ec.cache($identity);  # dir of given identity
```

Returns the `IO::Path` object for the directory of the given identity in the cache, or the `IO::Path` object for the root directory of the cache if no identity was given.

provides
--------

```raku
say $ec.provides;             # IO of paths to files that are provided

.say for $ec.provides.lines;  # list all provided files
```

Returns an `IO::Path` object for the file that contains all of the absolute paths of the files that occurred in the `"provides"` section of the META information of all the distributions.

tests
-----

```raku
say $ec.tests;             # IO of paths to test-files

.say for $ec.tests.lines;  # list all provided test-files
```

Returns an `IO::Path` object for the file that contains all of the absolute paths of the test-files (as defined by either having the `".t"` or `".rakutest` extension, inside of a `"t"` or `"xt"` directory).

scripts
-------

```raku
say $ec.scripts;             # IO of paths to scripts

.say for $ec.scripts.lines;  # list all provided scripts
```

Returns an `IO::Path` object for the file that contains all of the absolute paths of the scripts (files inside a `"bin"` directory).

code
----

```raku
say $ec.code;             # IO of paths to files with Raku code

.say for $ec.code.lines;  # list all provided files with Raku code
```

Returns an `IO::Path` object for the file that contains all of the absolute paths of the files that contain Raku code (the summation of the files in `provides`, `tests` and `scripts`.

update-identity
---------------

```raku
say $ec.update-identity($identity);
```

Updates the given identity in the cache. Returns either:

  * `True` if identity was not yet in the cache, and successfully fetched

  * `Nil` if identity was already in the cache

  * `Str` error message if fetching identity failed

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

COPYRIGHT AND LICENSE
=====================

Copyright 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

