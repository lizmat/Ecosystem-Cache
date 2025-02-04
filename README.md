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

METHODS
=======

new
---

update
------

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

COPYRIGHT AND LICENSE
=====================

Copyright 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

