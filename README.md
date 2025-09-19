# amethyst

Amethyst is a static site generator

## Getting started

You place markdown files in a `site/` directory Anything in top level with be
under `/` root

Example:

```shell
site/
    welcome.md  # served on /welcome
```

You can customize your site by using the look directory

Any css files placed in look directory will be applied to the page counterpart

Example:

```shell
site/
    index.md
look/
    index.css # applies to index.md only
```

You can also opt to have global styles:

```shell
site/
    index.md
site/posts/
    i_love_cats.md
    why_cats_rule.md
    cats_are_the_best_thing_ever.md
look/
    global.css # applies to all routes
```

Speaking of styling, how does it work?

Its very simple, just use the tag in css.

Example:

```css
h1 {
    font-size: 200%;
}
```

> There will be a more elegant solution in the future

Put static assets in the `assets/` folder

Example:

```shell
assets/
    favicon.ico
    secret-cat-photo.png
site/
look/
```

## Building

Install crystal and shards then run:

```shell
shards build --release --no-debug -O3
```

## Installing

```shell
# download repo
git clone https://github.com/CirklAI/amethyst.git /tmp/amethyst-ssg
cd /tmp/amethyst-ssg

# build release
shards build --release --no-debug -O3

# install
sudo mv /tmp/amethyst-ssg/bin/amethyst /usr/local/bin/

# cleanup
cd $HOME
rm -rf /tmp/amethyst-ssg
```

## License

> © 2025 Cirkl Labs See the [LICENSE](LICENSE)
