# PeaWiki

A simpler approach to vim-wiki than [soywiki][].

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

## Installation

Either copy `plugins/peawiki.vim` to `~/.vim/plugins` or if using
[pathogen][]:

    cd ~/.vim/bundle
    git clone git@github.com:artm/vim-peawiki.git peawiki

[pathogen]: https://github.com/tpope/vim-pathogen

## Using peawiki

At the moment the plugin assumes that wiki pages are files in `~/notes/`
with extension `.md`. Eventually this may become configurable.

Every such file becomes wiki-linkable, each verbatim mention of the file
will be highlighted as `peaTag` highlighting group (by default the same
as `Underlined`, which makes it appear the same color as markdown links).

Links are implemented as tags, so to follow a link press `Ctrl+]`, to
return press `Ctrl+t`. 

### Create a new page

Either `:new ~/notes/PAGENAME.md` or type in the page name, move cursor
to it in normal mode and press `Ctrl+]` as if to go to an existing page.
A new page will be created with default content (A single header
consisting of the page name).

New page can be aborted with `:bw!`. It wasn't written yet so it won't
end up in git repo too early.

### Delete page

To delete a page:

- open it (walk using links or otherwise)
- issue command `:DeletePeage`
- after the page is deleted vim will search for all mentions of it with
  `:vimgrep` and present quick fix window for review

### Rename page

To rename a page:

- open it
- issue `:RenamePeage <NEW_NAME>`
- after the page is renamed vim will search for all mentions of it with
  `:argdo %s/OLD_NAME/NEW_NAME/gec` and ask to confirm each
  substitution.
