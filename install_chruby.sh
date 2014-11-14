#!/bin/bash
# vim: sw=4 tw=72 ai et fo=tcqlnj com+=##

## Purpose
## =======
## Install chruby and ruby-install with public key verification of all
## signed packages.
##
## License
## =======
## Copyright 2014 Todd A. Jacobs
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.
##
## Notes
## =====
## - Requires GNU stow: <http://www.gnu.org/software/stow/>.
## - Always runs; doesn't check whether version is current before running
##   a (re)install.
## - Sources chruby in ~/.profile rather than shell-specific resource
##   files such as ~/.bash_profile or ~/.bashrc.
## - Doesn't install any rubies automagically because managing build
##   dependencies would add complexity.
## - Leaves the default Ruby as the system Ruby; add `chruby ruby-2.1.5`
##   or similar to your startup files if you like. See
##   <https://github.com/postmodern/chruby#default-ruby> for details.
## - GnuPG will be somewhat noisy unless you've signed Postmodern's
##   public key after manually verifying the fingerprint. This is a
##   feature.
##
## ---

######################################################################
# Default values.
######################################################################
: ${chruby:=0.3.8}
: ${ruby_install:=0.5.0}
: ${STOW:=/usr/local/stow}

######################################################################
# Public key retrieval and verification.
######################################################################
# Key data sourced from <http://postmodern.github.io/contact.html#pgp>
key='0xB9515E77'
fingerprint='04B2 F3EA 6541 40BC C7DA  1B57 54C3 D9E9 B951 5E77'

gpg --recv-key "$key"
gpg --fingerprint "$key" | fgrep --color "$fingerprint"

if [[ $? -ne 0 ]]; then
    echo 'Data Error: invalid fingerprint' > /dev/stderr
    exit 65
fi

######################################################################
# Stow with signature verification.
######################################################################
for program in chruby ruby_install; do
    version="${!program}"
    program="${program//_/-}"
    name="${program}-${version}"
    printf "\nInstalling $name ...\n"

    asc_url="https://raw.github.com/postmodern/$program/master/pkg"
    tar_url="https://github.com/postmodern/$program/archive"

    cd /tmp
    curl -sLO "${asc_url}/${name}.tar.gz.asc"
    curl -sLO "${tar_url}/v${version}.tar.gz"
    mv "v${version}.tar.gz" "${name}.tar.gz"

    gpg --verify ${name}.tar.gz{.asc,}

    if [[ $? -ne 0 ]]; then
	echo 'Data Error: invalid signature' > /dev/stderr
	exit 65
    fi

    tar xfz "${name}.tar.gz"
    cd "$name"

    if [[ -d "$STOW" ]]; then
	sudo /usr/bin/env PREFIX=/usr/local/stow/${name} make -s install
	cd "$STOW"
	for version_dir in ${program}-*; do sudo stow -D "$version_dir"; done
	sudo stow "$name"
    else
	sudo make -s install
    fi
done

######################################################################
# Configure interactive shell.
######################################################################
source_line='source /usr/local/share/chruby/chruby.sh'
if ! grep -qE "^${source_line}" ~/.profile; then
    echo -e "\n${source_line}" >> ~/.profile
fi

sed -i.bak \
    -e '/rvm/s/^[^#]/#&/' \
    -e '/rbenv/s/^[^#]/#&/' \
    ~/.profile
