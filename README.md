# PeaWiki

A simpler approach to vim-wiki then [soywiki][]

[soywiki]: https://github.com/danchoi/soywiki

## Features

- Markdown syntax (mostly for nice highlighting)
- Tags-based hyperlinks (familiar jumping commands, backwards jumping
  support)
- Links highlighting
- Git based history
- Delete / Rename page

## Status

Proof of concept and very primitive implementation.

## Using peawiki

At the moment the plugin assumes that wiki pages are files in `~/notes/`
with extension `.md`. Eventually this may become configurable.

Every such file becomes wiki-linkable, each verbatim mention of the file
will be highlighted as `peaTag` highlighting group (by default the same
as `Underlined`, which makes it appear the same color as markdown links).

Links are implemented as tags, so to follow a link press `Ctrl+]`, to
return press `Ctrl+t`. 

### Delete Page

To delete a page:

- open it (walk using links or otherwise)
- issue command `:DeletePeage`
- after the page is deleted vim will search for all mentions of it with
  `:vimgrep` and present quick fix window for review

### Rename Page

To rename a page:

- open it
- issue `:RenamePeage <NEW_NAME>`
- after the page is renamed vim will search for all mentions of it with
  `:argdo %s/OLD_NAME/NEW_NAME/gec` and ask to confirm each
  substitution.

