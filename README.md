Purpose
=======
Install chruby and ruby-install with public key verification of all
signed packages.

License
=======
Copyright 2014 Todd A. Jacobs

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

Notes
=====
- Requires GNU stow: <http://www.gnu.org/software/stow/>.
- Always runs; doesn't check whether version is current before running
  a (re)install.
- Sources chruby in ~/.profile rather than shell-specific resource
  files such as ~/.bash_profile or ~/.bashrc.
- Doesn't install any rubies automagically because managing build
  dependencies would add complexity.
- Leaves the default Ruby as the system Ruby; add `chruby ruby-2.1.5`
  or similar to your startup files if you like. See
  <https://github.com/postmodern/chruby#default-ruby> for details.
- GnuPG will be somewhat noisy unless you've signed Postmodern's
  public key after manually verifying the fingerprint. This is a
  feature.

---
