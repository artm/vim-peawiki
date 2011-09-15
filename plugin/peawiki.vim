" peawiki.vim - generate tags to files
" Maintainer:   Artem Baguinski <femistofel@gmail.com>
" Version:      0.1

if exists("g:loaded_peawiki") || &cp || v:version < 700
  finish
endif
let g:loaded_peawiki = 1
let g:PeaDir = $HOME . '/notes'
let s:PageNameRe = '\(.*\/\)\?\([^/]\+\)\.md$'

" lst is a list of files
fu! s:HighlightTags()
  let tags = taglist('.*')
  for tag in tags
    exec "syntax keyword peaTag " . tag["name"]
  endfor
endf

" Regenerate tags file
fu! s:UpdateTagsIfNew()
  if exists('b:isNew') && b:isNew
    let b:isNew = 0

    let lst = split(glob( g:PeaDir . "/*.md"),"\n")

    " write tag list
    call map( lst, 'substitute(v:val, s:PageNameRe, ''\1\t\0\t1'', '''')')
    call sort( lst )
    call writefile( lst, g:PeaDir . '/tags' )

    " update tag highlights
    bufdo if match(expand('%'),'\.md') | call s:HighlightTags() | endif
    call s:HighlightTags()
  endif
endf

fu! s:EnsureHasGit()
  if !isdirectory(g:PeaDir)
    call mkdir(g:PeaDir)
  endif
  if !isdirectory(g:PeaDir . "/.git")
    call system('cd ' . g:PeaDir . ' && git init')
  endif
endf

fu! s:OnSave()
  call s:EnsureHasGit()
  let file = expand('%')
  let tag = substitute( file, s:PageNameRe, '''\2''', '' )
  let cmd = 'cd ' . g:PeaDir . ' && git add ' . file . ' && git commit -m "edited ' . tag . '"'
  echo cmd
  call system(cmd)
endf

augroup peawiki
  au!
  exec 'au BufNewFile ' . g:PeaDir . '/*.md let b:isNew = 1 | call s:HighlightTags()'
  exec 'au BufNew,BufRead ' . g:PeaDir . '/*.md call s:HighlightTags()'
  exec 'au BufWritePost ' . g:PeaDir . '/*.md call s:UpdateTagsIfNew() | call s:OnSave()'
augroup END

hi link peaTag Underlined

