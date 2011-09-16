" peawiki.vim - generate tags to files
" Maintainer:   Artem Baguinski <femistofel@gmail.com>
" Version:      0.1

if exists("g:loaded_peawiki") || &cp || v:version < 700
  finish
endif
let g:loaded_peawiki = 1

let s:cpo_save = &cpo " store compatible-mode in local variable
set cpo&vim             " go into nocompatible-mode

let g:PeaDir = $HOME . '/notes'
let s:PeageNameRe = '\(.*\/\)\?\([^/]\+\)\.md$'

fu! s:PeaTag(path)
  return substitute( a:path, s:PeageNameRe, '\2', '' )
endf

fu! s:PeaFile0(tag)
  return g:PeaDir . '/' . a:tag
endf

fu! PeaFile(tag)
  return s:PeaFile0(a:tag) . '.md'
endf

" lst is a list of files
fu! s:HighlightTags()
  syntax clear peage
  let tags = taglist('.*')
  for tag in tags
    exec "syntax keyword peage " . tag["name"]
  endfor
endf

fu! s:UpdateTags()
  let lst = split(glob( PeaFile('*')),"\n")

  " write tag list
  call map( lst, 's:PeaTag(v:val) . "\t" . v:val . "\t1"')
  call sort( lst )
  call writefile( lst, s:PeaFile0('tags') )

  " update tag highlights
  bufdo if match(expand('%'),'\.md') | call s:HighlightTags() | endif
call s:HighlightTags()
endf

fu! s:IsNew()
  return exists('b:isNew') && b:isNew
endf

" Regenerate tags file
fu! s:UpdateTagsIfNew()
  if s:IsNew()
    let b:isNew = 0
    call s:UpdateTags()
  endif
endf

fu! s:EnsureHasGit()
  if !isdirectory(g:PeaDir)
    call mkdir(g:PeaDir)
  endif
  if !isdirectory(s:PeaFile0('.git'))
    call system('cd ' . g:PeaDir . ' && git init')
  endif
endf

fu! s:DoGit(cmd, ...)
  if a:0 == 0
    let file = expand('%')
    let tag = s:PeaTag(file)
  elseif match(a:1, '\.md$')
    let file = a:1
    let tag = s:PeaTag(file)
  else
    let tag = a:1
    let file = PeaFile(tag)
  endif

  call s:EnsureHasGit()
  let cmd = 'cd ' . g:PeaDir . ' && ' . a:cmd
  let cmd = substitute(cmd, '%t', tag, "g")
  let cmd = substitute(cmd, '%f', file, "g")
  call system(cmd)

  return tag
endf

fu! s:OnSave()
  call s:UpdateTagsIfNew()
  call s:DoGit("git add %f && git commit -m \"edited '%t'\"")
endf

fu! DeletePeage()
  let tag = s:DoGit("git rm %f && git commit -m \"removed '%t'\"")

  bwipe
  call s:UpdateTags()
  exec "vimgrep " . tag . " " . PeaFile('*')
  cwindow
endf

fu! RenamePeage(newTag)
  let newFile = PeaFile(a:newTag)
  write
  let tag = s:DoGit("git mv %f " . newFile . " && git commit -m \"renamed '%t' to '" . a:newTag . "'\"")
  bwipe
  call s:UpdateTags()
  exec 'args ' . PeaFile('*')
  exec 'argdo %s/' . tag . '/' . a:newTag . '/gec | update' 
  call s:DoGit("git commit --amend -m \"renamed '%t' to '" . a:newTag . "'\"")

  exec 'vi ' . newFile
endf

fu! GotoOrCreatePeage()
  let tag = expand('<cword>')
  if len(taglist(tag)) 
    exec 'tag ' . tag
  else
    exec 'new ' . PeaFile(tag)
    exec "norm i# " . tag . "\<ESC>o\<CR>"
  endif
endf

fu! s:PeaSetup()
  call s:HighlightTags()
  command! -buffer DeletePeage call DeletePeage()
  command! -buffer -nargs=1 RenamePeage call RenamePeage(<f-args>)
  nmap <C-]> :call GotoOrCreatePeage()<CR>
endf

augroup peawiki
  au!
  exec 'au BufNewFile ' . PeaFile('*') . ' let b:isNew = 1 | call s:PeaSetup()'
  exec 'au BufNew,BufRead ' . PeaFile('*') . ' call s:PeaSetup()'
  exec 'au BufWritePost ' . PeaFile('*') . ' call s:OnSave()'
augroup END

nmap <Leader>h :exec 'vi ' . PeaFile('Home') <CR>

hi link peage Underlined

" restore compatible mode
let &cpo = s:cpo_save
