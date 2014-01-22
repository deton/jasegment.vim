" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" autoload/jasegment/mecab.vim:
" MeCabを使って単語区切りを行う。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2014-01-22

if !exists('g:jasegment#mecab#cmd')
  let g:jasegment#mecab#cmd = 'mecab'
endif
if has('win32') || has('win64')
  let g:jasegment#mecab#cmd = substitute(g:jasegment#mecab#cmd, '\\', '/', 'g')
endif

if !exists('g:jasegment#mecab#args')
  let g:jasegment#mecab#args = '-Owakati'
endif

" mecabの入出力エンコーディング
if !exists('g:jasegment#mecab#enc')
  let g:jasegment#mecab#enc = &encoding
endif

let s:V = vital#of('jasegment')
let s:P = s:V.import('ProcessManager')

function! jasegment#mecab#segment(input)
  try
    if s:P.is_available()
      let line = s:ExecPM(a:input)
    else
      let line = s:Exec(a:input)
    endif
  catch
    echom 'jasegment#mecab#segment: ' . v:exception
    let line = ''
  endtry
  " mecab実行失敗?
  if line == ''
    return [a:input]
  endif
  return split(line, ' ')
endfunction

function! s:ExecPM(input)
  " 出力が空行になる入力の場合はwriteしない
  if a:input =~ '^[[:space:]]*$'
    return ''
  endif
  call s:P.touch('mecab', g:jasegment#mecab#cmd . ' ' . g:jasegment#mecab#args)
  let s = s:V.iconv(a:input, &encoding, g:jasegment#mecab#enc)
  call s:P.writeln('mecab', s)
  let [out, err, type] = s:P.read_wait('mecab', 30, [''])
  if type !=# 'matched'
    throw type . ',' . out . ',' . err
  endif
  let line = s:V.iconv(out, g:jasegment#mecab#enc, &encoding)
  return substitute(line, '\r*\n', '', 'g')
endfunction

function! s:Exec(input)
  let input = s:V.iconv(a:input, &encoding, g:jasegment#mecab#enc)
  let res = system(g:jasegment#mecab#cmd . ' ' . g:jasegment#mecab#args, input)
  if v:shell_error
    throw res
  endif
  let line = s:V.iconv(res, g:jasegment#mecab#enc, &encoding)
  return substitute(line, '\r*\n', '', 'g')
endfunction
