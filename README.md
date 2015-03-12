# Heroku rels

It's like running `heroku releases` for every heroku remote, but you don't have to type all the damn app names. Useful if you have many environments for the same app, e.g. production, staging, qa, etc.

To install:
```bash
heroku plugins:install git://github.com/stefansundin/heroku-rels.git
```

Usage:
```bash
heroku rels
heroku rels:info
heroku rels:version
```

To update:
```bash
heroku plugins:update heroku-rels
```

To uninstall:
```bash
heroku plugins:uninstall heroku-rels
```


# Changelog

[![RSS](https://stefansundin.github.io/img/feed.png) Release feed](https://github.com/stefansundin/heroku-rels/releases.atom)

**0.3** - 2015-03-12 - [diff](https://github.com/stefansundin/heroku-rels/compare/v0.2...v0.3):
- Added `rels:info`.
- Small fixes.

**0.2** - 2014-10-18 - [diff](https://github.com/stefansundin/heroku-rels/compare/v0.1...v0.2):
- Added `rels:version`.
- Small fixes.

**0.1** - 2014-08-08 - [diff](https://github.com/stefansundin/heroku-rels/compare/26ac7cd...v0.1):
- First release.
