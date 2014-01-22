" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" autoload/jasegment/cabocha.vim:
" CaboChaを使って文節区切りを行う。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2014-01-22

if !exists('g:jasegment#cabocha#cmd')
  let g:jasegment#cabocha#cmd = 'cabocha'
endif
if has('win32') || has('win64')
  let g:jasegment#cabocha#cmd = substitute(g:jasegment#cabocha#cmd, '\\', '/', 'g')
endif

if !exists('g:jasegment#cabocha#args')
  let g:jasegment#cabocha#args = '-I0 -O2 -f1'
endif

" cabochaの入出力エンコーディング
if !exists('g:jasegment#cabocha#enc')
  let g:jasegment#cabocha#enc = &encoding
endif

let s:V = vital#of('jasegment')
let s:P = s:V.import('ProcessManager')

function! jasegment#cabocha#segment(input)
  try
    if s:P.is_available()
      let lines = s:ExecPM(a:input)
    else
      let lines = s:Exec(a:input)
    endif
  catch
    echom 'jasegment#cabocha#segment: ' . v:exception
    let lines = []
  endtry
  "echom join(lines)
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
  if !empty(words)
    call add(res, join(words, ''))
  endif
  return res
endfunction

function! s:ExecPM(input)
  call s:P.touch('cabocha', g:jasegment#cabocha#cmd . ' ' . g:jasegment#cabocha#args)
  let s = s:V.iconv(a:input, &encoding, g:jasegment#cabocha#enc)
  call s:P.writeln('cabocha', s)
  let [out, err, type] = s:P.read_wait('cabocha', 30, ['EOS'])
  if type !=# 'matched'
    throw type . ',' . out . ',' . err
  endif
  let res = s:V.iconv(out, g:jasegment#cabocha#enc, &encoding)
  return split(res, '\n')
endfunction

function! s:Exec(input)
  let input = s:V.iconv(a:input, &encoding, g:jasegment#cabocha#enc)
  let res = system(g:jasegment#cabocha#cmd . ' ' . g:jasegment#cabocha#args, input)
  if v:shell_error
    throw res
  endif
  let res = s:V.iconv(res, g:jasegment#cabocha#enc, &encoding)
  return split(res, '\n')
endfunction
