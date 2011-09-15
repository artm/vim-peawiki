" peawiki.vim - generate tags to files
" Maintainer:   Artem Baguinski <femistofel@gmail.com>
" Version:      0.1

if exists("g:loaded_peawiki") || &cp || v:version < 700
  finish
endif
let g:loaded_peawiki = 1
let g:PeaDir = $HOME . '/notes'
let s:PeageNameRe = '\(.*\/\)\?\([^/]\+\)\.md$'

fu! s:PathToTag(path)
  return substitute( a:path, s:PeageNameRe, '\2', '' )
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
  let lst = split(glob( g:PeaDir . "/*.md"),"\n")

  " write tag list
  call map( lst, 's:PathToTag(v:val) . "\t" . v:val . "\t1"')
  call sort( lst )
  call writefile( lst, g:PeaDir . '/tags' )

  " update tag highlights
  bufdo if match(expand('%'),'\.md') | call s:HighlightTags() | endif
call s:HighlightTags()
endf

" Regenerate tags file
fu! s:UpdateTagsIfNew()
  if exists('b:isNew') && b:isNew
    let b:isNew = 0
    call s:UpdateTags()
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
  call s:UpdateTagsIfNew()
  call s:EnsureHasGit()
  let file = expand('%')
  let tag = s:PathToTag(file)
  let cmd = 'cd ' . g:PeaDir . ' && git add ' . file . ' && git commit -m "edited ''' . tag . '''"'
  call system(cmd)
endf

fu! DeletePeage()
  let file = expand('%')
  call s:EnsureHasGit()
  let tag = s:PathToTag(file)
  let cmd = 'cd ' . g:PeaDir . ' && git rm ' . file . ' && git commit -m "removed ''' . tag . '''"'
  call system(cmd)
  bwipe
  call s:UpdateTags()
  exec "vimgrep " . tag . " " . g:PeaDir . "/*.md"
  cwindow
endf

fu! RenamePeage(newTag)
  let file = expand('%')
  call s:EnsureHasGit()
  let tag = s:PathToTag(file)
  let newFile = g:PeaDir . '/' . a:newTag . '.md'
  write
  bwipe
  let cmd = 'cd ' . g:PeaDir . ' && git mv ' . file . ' ' . newFile . ' && git commit -m "renamed ''' . tag . ''' to ''' . a:newTag . '''"'
  call system(cmd)
  call s:UpdateTags()
  exec 'vi ' . newFile
  exec 'args ' . g:PeaDir . '/*.md'
  exec 'argdo %s/' . tag . '/' . a:newTag . '/gec | update' 
  let cmd = 'cd ' . g:PeaDir . ' && git commit --amend -m "renamed ''' . tag . ''' to ''' . a:newTag . '''"'
  call system(cmd)
  exec 'vi ' . a:newTag . '.md'
endf

fu! GotoOrCreatePeage()
  let tag = expand('<cword>')
  if len(taglist(tag)) 
    exec 'tag ' . tag
  else
    exec 'new ' . g:PeaDir . '/' . tag . '.md'
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
  exec 'au BufNewFile ' . g:PeaDir . '/*.md let b:isNew = 1 | call s:PeaSetup()'
  exec 'au BufNew,BufRead ' . g:PeaDir . '/*.md call s:PeaSetup()'
  exec 'au BufWritePost ' . g:PeaDir . '/*.md call s:OnSave()'
augroup END


hi link peage Underlined

