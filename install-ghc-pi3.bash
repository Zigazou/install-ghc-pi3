#!/bin/bash

function assert {
  local message="$1"
  shift
  "$@" > /dev/null
  local rc=$?
  [ $rc -eq 0 ] && return 0
  set $(caller)
  local date=$(date "+%Y-%m-%d %T%z")
  echo "$date $2 [$$]: $message (line=$1, rc=$rc)" >&2
  exit $rc
}

printf "Checking environment..."
assert "deb command not found" which deb
assert "apt-get command not found" which apt-get
assert "apt-key command not found" which apt-key
assert "gpg command not found" which gpg
assert "update-alternatives command not found" which update-alternatives
assert "unsupported architecture" test $(uname -m) = "armv7l"
printf "OK\n"

printf "Add Jessie Backports to APT sources..."
cat <<"EOT" > /etc/apt/sources.list.d/backports.list
deb ftp://ftp.debian.org/debian jessie-backports main
EOT
printf "OK\n"

printf "Retrieving public keys for Jessie Backports..."
gpg --keyserver pgpkeys.mit.edu --recv-key  8B48AD6246925553
gpg -a --export 8B48AD6246925553 | apt-key add -
gpg --keyserver pgpkeys.mit.edu --recv-key  7638D0442B90D010
gpg -a --export 7638D0442B90D010 | apt-key add -
printf "OK\n"

printf "Updating APT database..."
apt-get update > /dev/null
printf "OK\n"

printf "Installing ghc and cabal from Jessie Backports..."
apt-get install -t jessie-backports ghc cabal-install > /dev/null
printf "OK\n"

printf "Creating alternative for ghc to correct configuration..."
cat <<"EOT" > /usr/bin/ghc-7.10.3-pi3
#!/bin/bash
exedir="/usr/lib/ghc/bin"
exeprog="ghc-stage2"
executablename="$exedir/$exeprog"
datadir="/usr/share"
bindir="/usr/bin"
topdir="/usr/lib/ghc"
executablename="$exedir/ghc"
exec "$executablename" \
     -B"$topdir" \
     -opta-march=armv7-a \
     -opta-mtune=cortex-a53 \
     -optl-Wl,--no-fix-cortex-a8 \
     ${1+"$@"}
EOT
printf "OK\n"

printf "Installing alternative for ghc..."
update-alternatives --install /usr/bin/ghc ghc /usr/bin/ghc-7.10.3 1
update-alternatives --install /usr/bin/ghc ghc /usr/bin/ghc-7.10.3-pi3 2
printf "OK\n"
