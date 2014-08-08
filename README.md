# Heroku rels

It's like running `heroku releases` for every heroku remote, but you don't have to type all the damn app names. Useful if you have production and staging for the same app.

To install:
```bash
heroku plugins:install git://github.com/stefansundin/heroku-rels.git
```

To uninstall:
```bash
heroku plugins:uninstall heroku-rels
```

Usage:
```bash
heroku rels
```


# Changelog

**0.1** - 2014-08-08:
- First release.
