use Ecosystem:ver<0.0.31+>:auth<zef:lizmat>;
use Identity::Utils:ver<0.0.19+>:auth<zef:lizmat> <short-name>;

# Don't bother with 6.e
sub term:<nano>() is export { use nqp; nqp::time }

# Default location of cache
my $default-cache := (%*ENV<RAKU_ECOSYSTEM_CACHE> andthen .IO)
  // ($*HOME // $*TMPDIR).add(".ecosystem").add("cache");

class Ecosystem::Cache:ver<0.0.1>:auth<zef:lizmat> {
    has Ecosystem $.ecosystem is built(:bind) = Ecosystem.new;
    has IO::Path  $.cache     is built(:bind) = $default-cache;
    has @.identities          is built(False);

    method TWEAK(:$update --> Nil) {
        # Make sure different ecosystems don't collide in the cache
        $!cache := $!cache.add(self.name);

        # Make sure the cache exists
        $!cache.mkdir unless $!cache.e;

        # Fetch the latest identities: we always need these
        $!ecosystem.update if $update;
        @!identities = $!ecosystem.find-identities(:latest);
    }

    method name(Ecosystem::Cache:D:) { $!ecosystem.ecosystem }

    # Produce the URL from the content storage of a given identity
    method archive-URL(Ecosystem::Cache:D: str $identity) {
        my str $eco = self.name;

        if $eco eq "rea" | "fez" {
            if $!ecosystem.identities{$identity} -> %meta {
                if $eco eq "rea" {
                    my $name := short-name($identity);
                    ($!ecosystem.meta-url.chop(9)
                      ~ "archive/$name.substr(0,1).uc()/$name/$identity.tar.gz")
                      .subst(" ", "%20", :g)
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
    method cache-IO(Ecosystem::Cache:D: str $identity) {
        $!cache
          .add(short-name($identity).substr(0,1).uc)
          .add($identity)
    }

    # Make sure the cache for the given identity is up to date
    method cache-identity(Ecosystem::Cache:D: str $identity) {

        # Nothing to do for this identity
        my $IO := self.cache-IO($identity);
        return Nil if $IO.e;

        # Make sure the letter dir exists
        my $dir := $IO.parent;
        mkdir $dir;

        my $url      := self.archive-URL($identity);
        my $download := $IO.sibling(nano);
        my $proc := run 'curl', $url, "--output", $download, :err;
        
        if $proc.exitcode -> $error {
            return "Fetching failed with error: $error\n  $url";
        }
        elsif $download.s < 80 {
            my $slurped := $download.slurp;
            $download.unlink;
            return "$slurped\n  $url";
        }

        my $tmpdir := $dir.add(nano);
        $tmpdir.mkdir;
        indir $tmpdir, {
            $proc := run <tar zxfv>, $download, :err;
            if $proc.exitcode -> $error {
                return "Decompressing failed with error: $error";
            }
            my @paths = dir;
            # Tar file was made correctly
            if @paths == 1 {
                @paths.head.rename($IO);
                $tmpdir.rmdir;
            }
            else {
                $tmpdir.rename($IO);
            }

            $download.unlink;
        }

        True
    }

    method update(Ecosystem::Cache:D:
      @added   is raw = [],
      @removed is raw = [],
      %failed  is raw = {},
    --> Nil) {

        # Run update, remember id's seen, added and failed
        my %seen;
        for @!identities -> $id {
            my str $key = "$id.substr(0,1).uc()/$id";
            if self.cache-identity($id) -> $message {
                if $message ~~ Str {
                    %failed{$id} := $message;
                }
                else {
                    @added.push($id);
                    %seen{$key} := True;
                }
            }
            else {
                %seen{$key} := True;
            }
        }

        # Cleanup now superfluous distributions
        indir $!cache, {
            for dir>>.relative.sort {
                for (dir $_)>>.relative {
                    unless %seen{$_} {
                        my $proc := run <rm -rf>, $_;
                        @removed.push($_) unless $proc.exitcode;
                    }
                }
            }
        }
    }
}

#my $cache := Ecosystem::Cache.new(:update);
#$cache.update(my @added, my @removed, my %failed);
#dd :@added, :@removed;

# vim: expandtab shiftwidth=4
