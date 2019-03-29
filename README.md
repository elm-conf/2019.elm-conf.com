# 2019.elm-conf.com

## Development

1. [have nix](https://nixos.org/nix/) ("Get Nix" button)
2. [have direnv](https://github.com/direnv/direnv) if you want to use your usual shell (run `nix-shell` otherwise)
3. activate the Nix environment by running `direnv allow` or `nix-shell`
4. `npm install`
5. `make`

You should have the site content in `public`.
You can view it by `cd`ing into `public` and running `python -m http.server`.
The site will be available on `:8000`

## Adding New Content

Add new markdown files in `content` with what you want.
When you run `make public` they will be copied to the correct place in `public` and entered into the routing tree (once generated, `src/Routes.elm`.)

The format looks like this:

```markdown
title: A great title!
---

# First-level heading

Top-level content. This is styled a bit larger and lives right under the page header.

## Second-level heading

This content is styled using the normal text styles.
```

### Rough spec on content (this isn't implemented yet)

- every markdown file should have a top-level heading
- all content after the top-level heading and the next heading should be the "big" style
- all content after the second-level heading should be the "normal" style
- in list pages (e.g. schedule) embedded page headings are decreased by one level (h1 -> h2, h2 -> h3, and so on) and the content is all styled as normal text.

BUT we have until speakers are announced to implement list pages, so don't worry about it too much before the CFP opens.

## Design

There's a design (`website.sketch`) that has all the assets.
The measurements there are not precise, though.
Ask Brian if you want specific measurements, or just eyeball it.

If it looks good to you, I'm not concerned about the design and implementation being pixel-perfect (in fact, it'd be better if they weren't; I didn't go over the design with a fine-tooth comb and a lot of it is a little rough.)
