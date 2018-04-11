Rindeal's Ebuild Repository <img src="./assets/logo_96.png" title="Sir Benjamin the Bull" alt="logo" align="right">
=================================================================================================

_Packages done right™_

[![Build Status][ci-master-badge]][ci-master] [![Dev Branch Build Status][ci-dev-badge]][ci-dev]

Every package here has been carefully crafted to the highest level of perfection.

Features that the vast majority of my ebuilds has in common:

 - code in ebuilds is **clean and documented**, thus making packages maintainable and easily updatable
 - **USE flags** are provided for almost any configurable option
     - instead of packing multitude of options under a single feature as _Gentoo™_ devs do
 - full **_systemd_** integration (services, templates, timers, ...), no _OpenRC_/_cron_ support
     - note that only recent versions of _systemd_ are supported (cca. only the last 3-4 releases)
 - sane **default configurations** (default USE-flags, config files, ...)
 - **locales** support (`nls`/`l10n_*` USE-flags)
     - _Gentoo™_ packages mostly install all locales unconditionally
 - **x86_64**/**armv6**/**armv7**/**armv8** architectures only
     - this allows me to remove clutter introduced by Gentoo devs for exotic arches
 - only the **native ABI** is supported, again to reduce the clutter
 - no _libav_, _libressl_, ... support

In most package directories there is a _README_ file that says why is my package superior to any other out there including the "official" one.

> _If you find a package superior to mine, please [report it here][New issue], so that I can improve it even more._

You can also visit a user-friendly [list of packages][LISTING].
I highly encourage you to browse through the list as the chances are high for you to discover some great new software.


Quality Assurance
------------------

You should be able to use any package from my overlay without regrets, because I do and I have quite high standards.
To achieve this goal I'm using several safety guards:

- my brain of course
- _[Travis CI](https://travis-ci.org/)_, which runs:
    - _[repoman](https://wiki.gentoo.org/wiki/Repoman)_ checks
    - _[shellcheck](https://www.shellcheck.net/)_ checks
    - custom checks
- all points of _GitHub_'s feature called _[protected branches]_, which means that all merges to _master_ must pass CI tests

This all, of course, doesn't prevent build failures, missing dependencies, etc. So, should you find
some issues, please send me a PR (if you know how to fix it), or at least [file an issue][New issue].


How to install this overlay
----------------------------

### Manually (recommended)

#### 1. Add an entry to [`/etc/portage/repos.conf`](https://wiki.gentoo.org/wiki//etc/portage/repos.conf):

```ini
[rindeal]
## set this to any location you want
location = /var/cache/portage/repos/rindeal
sync-uri = https://ebuilds.janchren.eu/repos/rindeal/.git
sync-type = git
auto-sync = yes
## prefer my packages over the Gentoo™ ones to improve UX and stability (recommended by 9/10 IT experts)
#priority = 9999
```

#### 2. Sync

```sh
# Preferrably
eix-sync
# or if you need to
emerge --sync
```

### Automatically with Layman

```sh
layman -o 'https://raw.githubusercontent.com/imbubble/rindeal-ebuild-repo/master/repositories.xml' -a rindeal
```

Not so FAQ
-----------

#### How up-to-date are the packages here?

- No automated upstream release checker a la Fedora exists yet, but neither does at Gentoo, so the freshness is provided on a best effort basis.
- Very few packages in my repo have a "stable" version that is artificially kept back behind the upstream release schedule.
- My goal is to have no package more than 6 months late with updates.

#### I have a problem building/running a package from official Gentoo repos, can I use yours instead?

Yes, in fact, one of the most common reasons for including a package in my repo is the presence of a buggy version in Gentoo repos.

#### May I trust your packages?

If you trust official Gentoo repos, you can trust this, too. Getting commit access to Gentoo repos is possible for any person with an internet connection and enough social engineering skills, physical identity is never verified, so the only difference is then the amount of exposure each repository gets. But then again, issues reported to bugs.gentoo.org are often not resolved for weeks, months, years if ever, while issues reported to me are fixed within hours or days.

---

### Colophon

- [Animal vector designed by Freepik](http://www.freepik.com/free-photos-vectors/animal)

[protected branches]: https://help.github.com/articles/about-protected-branches/
[LISTING]: ./LISTING.md
[New issue]: https://github.com/rindeal/rindeal-ebuild-repo/issues/new
[ci-master-badge]: https://img.shields.io/travis/rindeal/rindeal-ebuild-repo/master.svg?style=flat-square&label=master%20build
[ci-master]: https://travis-ci.org/rindeal/rindeal-ebuild-repo
[ci-dev-badge]: https://img.shields.io/travis/rindeal/rindeal-ebuild-repo/dev.svg?style=flat-square&label=dev%20build
[ci-dev]: https://travis-ci.org/rindeal/rindeal-ebuild-repo
