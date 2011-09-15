# Peawiki

A simpler approach to vim-wiki then [soywiki][]

[soywiki]: https://github.com/danchoi/soywiki

- Use markdown
- Use tag files for hyperlinks
- Highlight tags

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

## TODO

- git for history
  - DONE autoinitialization, commit on save
- refactoring: page rename
  - rename tag in tags
  - rename in git
  - subst in all .md files (complete word OldTag to NewTag)
- page delete
  - "are you sure?"
    - on the other hand all is in the repo, why bother
  - DONE regenerate tags
  - DONE remove from git


