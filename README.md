# Joydip Datta’s personal website

[jdatta.me](https://jdatta.me) brings together my projects, technical notes, personal writing, and art. I’m a distributed storage engineer interested in dependable systems and how software behaves at scale.

## What’s here

- **Projects:** weekend experiments, tiny tools, and personal archives, including [Number Garden](https://jdatta.me/number-garden/), a number puzzle, and [Dugga Elo](https://jdatta.me/dugga-elo/), a Bengali music and photography archive celebrating Durga Puja.
- **[Notes and essays](https://jdatta.me/blogs/):** writing on software, systems, and things learned along the way.
- **Art:** photographs, sketches, and watercolours featured on the homepage.
- **[About](https://jdatta.me/about/):** background, contact details, and links to my other work.

## Repository guide

| Location | Contents |
| --- | --- |
| [index.html](index.html) | Homepage with recent writing, selected projects, and art |
| [blog/](blog/) | Posts, about page, layouts, includes, and styles |
| [number-garden/](number-garden/) | Number Garden project pages |
| [dugga-elo/](dugga-elo/) | Dugga Elo app, assets, and documentation |
| [resources/](resources/) | Shared fonts, images, icons, and theme script |
| [_config.yml](_config.yml) | Site configuration |
| [docs/](docs/) | Project documentation and archived material |

## Site technology

The site uses Jekyll and is hosted on GitHub Pages at the custom domain `jdatta.me`. Its blog originated from the Jekyll Now theme. The [original Jekyll Now README](docs/README-jekyll-now.md) is preserved verbatim for historical setup instructions and credits.

## Local preview

With Ruby installed, run this setup once from the repository root. Skip the first command if Bundler 2.4.22 is already installed.

```sh
gem install --user-install bundler -v 2.4.22 --no-document
export PATH="$(ruby -rrubygems -e 'puts Gem.user_dir')/bin:$PATH"
bundle _2.4.22_ config set --local path .bundle/gems
bundle _2.4.22_ install
```

Keep the Ruby user gem bin directory on your `PATH` in new shells if you installed Bundler with `--user-install`.

Run `./serve.sh` and open [http://127.0.0.1:4173/](http://127.0.0.1:4173/). Jekyll rebuilds when you edit site files. Refresh the browser to see the changes. Press Ctrl+C to stop the server. To use another port, run `PORT=4000 ./serve.sh`.

## Code blocks in posts

Write the language immediately after the opening backticks. Use `bash` for shell commands, `console` for terminal sessions with output, `markdown` for Markdown source examples, and `text` for plain text. For example, this fence highlights Python at build time.

````markdown
```python
for title in titles:
    print(title)
```
````
