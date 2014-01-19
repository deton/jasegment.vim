" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" autoload/jasegment/mecab.vim:
" MeCabを使って単語区切りを行う。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2014-01-18

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

function! jasegment#mecab#segment(input)
  try
    if s:has_vimproc()
      let line = s:ExecPopen(a:input)
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

function! s:ExecPopen(input)
  " MeCabの出力が空行のみの間readを試みるので、無限にreadを試みないように、
  " 出力が空行になる入力の場合はwriteしない
  if a:input =~ '^[[:space:]]*$'
    return ''
  endif
  if !exists('s:proc')
    let s:proc = vimproc#popen2(g:jasegment#mecab#cmd . ' ' . g:jasegment#mecab#args)
  endif
  let s = a:input . "\n"
  let s = s:iconv(s, &encoding, g:jasegment#mecab#enc)
  call s:proc.stdin.write(s)
  while 1
    if s:proc.stdout.eof
      let [cond, status] = s:proc.waitpid()
      unlet s:proc
      return ''
    endif
    let lines = s:proc.stdout.read_lines()
    call filter(lines, 'v:val != ""')
    " Windowsの場合MeCab起動後初回read_lines()では空のみ。再度read_lines()
    if empty(lines)
      continue
    endif
    let res = join(lines)
    return s:iconv(res, g:jasegment#mecab#enc, &encoding)
  endwhile
endfunction

function! s:Exec(input)
  let input = s:iconv(a:input, &encoding, g:jasegment#mecab#enc)
  let res = system(g:jasegment#mecab#cmd . ' ' . g:jasegment#mecab#args, input)
  if v:shell_error
    throw res
  endif
  let line = s:iconv(res, g:jasegment#mecab#enc, &encoding)
  return substitute(line, '\n', '', 'g')
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
