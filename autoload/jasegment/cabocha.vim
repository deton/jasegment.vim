" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" autoload/jasegment/cabocha.vim:
" CaboChaを使って文節区切りを行う。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2014-01-13

if !exists('g:jasegment#cabocha#cmd')
  let g:jasegment#cabocha#cmd = 'cabocha'
endif

if !exists('g:jasegment#cabocha#args')
  let g:jasegment#cabocha#args = '-I0 -O2 -f1'
endif

" cabochaの入出力エンコーディング
if !exists('g:jasegment#cabocha#enc')
  let g:jasegment#cabocha#enc = &encoding
endif

function! jasegment#cabocha#segment(input)
  if s:has_vimproc()
    let lines = s:ExecPopen(a:input)
  else
    let lines = s:Exec(a:input)
  endif
  " cabocha実行失敗?
  if empty(lines)
    return [a:input]
  endif
  return s:cabocha2list(lines)
endfunction

function! s:cabocha2list(lines)
  let res = []
  let words = []
  for line in a:lines
    " 次の文節開始 || 終了
    if line[0] == '*' || line ==# 'EOS'
      if !empty(words)
        call add(res, join(words, ''))
      endif
      let words = []
    else
      call add(words, substitute(line, '\t.*$', '', ''))
    endif
  endfor
  return res
endfunction

function! s:ExecPopen(input)
  if !exists('s:proc')
    let s:proc = vimproc#popen2(g:jasegment#cabocha#cmd . ' ' . g:jasegment#cabocha#args)
  endif
  let s = a:input . "\n"
  let s = s:iconv(s, &encoding, g:jasegment#cabocha#enc)
  call s:proc.stdin.write(s)
  let res = []
  while 1
    if s:proc.stdout.eof
      let [cond, status] = s:proc.waitpid()
      unlet s:proc
      return res
    endif
    let lines = s:proc.stdout.read_lines()
    call extend(res, lines)
    if index(lines, 'EOS') >= 0
      call map(res, 's:iconv(v:val, g:jasegment#cabocha#enc, &encoding)')
      return res
    endif
  endwhile
endfunction

function! s:Exec(input)
  let input = s:iconv(a:input, &encoding, g:jasegment#cabocha#enc)
  let res = system(g:jasegment#cabocha#cmd . ' ' . g:jasegment#cabocha#args, input)
  let res = s:iconv(res, g:jasegment#cabocha#enc, &encoding)
  return split(res, '\n')
endfunction

" from vital.vim

" iconv() wrapper for safety.
function! s:iconv(expr, from, to)
  if a:from == '' || a:to == '' || a:from ==? a:to
    return a:expr
  endif
  let result = iconv(a:expr, a:from, a:to)
  return result != '' ? result : a:expr
endfunction

function! s:has_vimproc()
  if !exists('s:exists_vimproc')
    try
      call vimproc#version()
      let s:exists_vimproc = 1
    catch
      let s:exists_vimproc = 0
    endtry
  endif
  return s:exists_vimproc
endfunction
