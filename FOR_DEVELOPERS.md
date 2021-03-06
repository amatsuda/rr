# Instructions for developers

## Releasing a new version

To release a new version of RR, update the version in VERSION and update
CHANGES.md with changes made since the previous release. Commit and push, and
then run `rake release` to push to RubyGems.

## Notes on Debian and Fedora packaging

Keep in mind that Debian and Fedora both have wrapper packages for RR. We want
to make sure to stay on good terms with them.

Although it is usually not necessary we include the Rakefile and tests in the gem itself specifically for these package maintainers.

### Debian

* [How Ruby gems are packaged](http://wiki.debian.org/Teams/Ruby/Packaging)
* [How packaged Ruby gems are tested](http://wiki.debian.org/Teams/Ruby/Packaging/Tests)
* [Page for the ruby-rr package](http://packages.qa.debian.org/r/ruby-rr.html)
* [Git repo for the ruby-rr package](http://anonscm.debian.org/gitweb/?p=pkg-ruby-extras/ruby-rr.git;a=summary)

### Fedora

* [How Ruby gems are packaged and tested](http://fedoraproject.org/wiki/Packaging_talk:Ruby)
* [Git repo for the rubygem-rr package](http://pkgs.fedoraproject.org/cgit/rubygem-rr.git)
