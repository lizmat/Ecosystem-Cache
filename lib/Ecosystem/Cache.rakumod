use Ecosystem:ver<0.0.29+>:auth<zef:lizmat>;
use Identity::Utils:ver<0.0.18+>:auth<zef:lizmat> <short-name>;
use String::Utils:ver<0.0.32+>:auth<zef:lizmat> <stem>;

# Default location of cache
my $default-cache := (%*ENV<RAKU_ECOSYSTEM_CACHE> andthen .IO)
  // ($*HOME // $*TMPDIR).add(".ecosystem").add("cache");

class Ecosystem::Cache:ver<0.0.1>:auth<zef:lizmat> {
    has Ecosystem $.ecosystem is built(:bind) = Ecosystem.new;
    has IO::Path  $.cache     is built(:bind) = $default-cache;
    has @.identities          is built(False);

    method TWEAK(--> Nil) {
        # Make sure different ecosystems don't collide in the cache
        $!cache := $!cache.add($!ecosystem.ecosystem);

        # Make sure the cache exists
        $!cache.mkdir unless $!cache.e;

        # Fetch the latest identities: we always need these
        @!identities = $!ecosystem.find-identities;
    }

    # Produce the URL from the content storage of a given identity
    method archive-url(Ecosystem:D: str $identity) {
        my str $eco = $!ecosystem.ecosystem;

        if $eco eq "rea" | "fez" {
            if $!ecosystem.identities{$identity} -> %meta {
                if $eco eq "rea" {
                    my $name := short-name($identity);
                    $!ecosystem.meta-url.chop(9)
                      ~ "archive/$name.substr(0,1)/$name/$identity.tar.gz"
                }
                else {  # fez
                    $!ecosystem.meta-url ~ %meta<path>;
                }
            }
            else {
                Failure.new: "'$identity' not found in '$eco' ecosystem"
            }
        }
        else {
            Failure.new: "'$eco' ecosystem not supported (yet)"
        }
    }

    # Produce IO for the directory of a given identity in the cache
    method cache-IO(Ecosystem:D: str $identity) {
        $!cache
          .add($!ecosystem.ecosystem)
          .add(short-name($identity).substr(0,1))
          .add($identity)
    }

    # Make sure the cache for the given identity is up to date
    method cache-identity(Ecosystem:D: str $identity) {
        my $IO := self.cache-IO($identity);

        if $IO.e {
            True
        }
        else {
            my $url      := self.archive-url($identity);
            my $basename := $url.IO.basename;
            my $stem     := stem $basename;
            my $proc := run 'curl', $url, "--output",  :!err;
        }
    }
}

#my $cache := Ecosystem::Cache.new;
#.say for $cache.identities;

# vim: expandtab shiftwidth=4
