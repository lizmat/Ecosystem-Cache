[![Actions Status](https://github.com/lizmat/Ecosystem-Cache/actions/workflows/linux.yml/badge.svg)](https://github.com/lizmat/Ecosystem-Cache/actions) [![Actions Status](https://github.com/lizmat/Ecosystem-Cache/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/Ecosystem-Cache/actions) [![Actions Status](https://github.com/lizmat/Ecosystem-Cache/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/Ecosystem-Cache/actions)

NAME
====

Ecosystem::Cache - maintain a local cache of an ecosystem

SYNOPSIS
========

```raku
use Ecosystem::Cache;

my $cache = Ecosystem::Cache.new;  # defaults to REA

$cache.update;  # make sure all distributions are up-to-date
```

DESCRIPTION
===========

The `Ecosystem::Cache` distribution provides the logic to maintain a local cache of the most recent distributions in a Raku ecosystem.

It's use is mainly intended to serve as an area in which searches can be performed, such as with [`App::Rak`](https://raku.land/zef:lizmat/App::Rak).

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

my $cache = Ecosystem::Cache.new(:update);  # defaults to REA
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
$cache.update(my @new, my @gone, my %erred);
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
say $cache.name;
```

Returns the name of the ecosystem to which this cache applies.

archive-URL
-----------

```raku
say $cache.archive-URL($identity);
```

Returns the URL for downloading the distribution of the given identity.

cache-IO
--------

```raku
say $cache.cache-IO($identity);
```

Returns the `IO::Path` object for the directory of the given identity in the cache.

cache-identity
--------------

```raku
say $cache.cache-identity($identity);
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

