" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" autoload/jasegment/cabocha.vim:
" CaboChaを使って文節区切りを行う。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2014-01-12

if !exists('g:jasegment#cabocha#cmd')
  let g:jasegment#cabocha#cmd = 'cabocha'
endif

if !exists('g:jasegment#cabocha#args')
  let g:jasegment#cabocha#args = '-I0 -O2 -f1'
endif

" cabochaとの入出力エンコーディング
if !exists('g:jasegment#cabocha#enc')
  let g:jasegment#cabocha#enc = &encoding
endif

function! jasegment#cabocha#segment(input)
  " TODO: use vimproc
  if &encoding ==# g:jasegment#cabocha#enc
    let lines = s:Exec(a:input)
  else
    let lines = s:ExecUsingBuf(a:input)
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
    if line =~# '\V\^*' || line =~# '^EOS$'
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

function! s:Exec(input)
  let res = system(g:jasegment#cabocha#cmd . ' ' . g:jasegment#cabocha#args, a:input)
  return split(res, '\n')
endfunction

" cabochaにリダイレクトする文字列を保持する一時ファイル名
let s:cmdfile = tempname()

" 一時バッファを使ってencoding変換してcabochaを実行
function! s:ExecUsingBuf(input)
  if s:OpenWindow('new') < 0
    return []
  endif
  setlocal nobuflisted
  setlocal noswapfile
  call append(0, a:input)
  silent execute 'write! ++enc=' . g:jasegment#cabocha#enc . ' ' . s:cmdfile
  silent %d _

  silent execute 'read! ++enc=' . g:jasegment#cabocha#enc . ' ' . g:jasegment#cabocha#cmd . ' ' . g:jasegment#cabocha#args . ' < "' . s:cmdfile . '"'
  if &encoding !=# g:jasegment#cabocha#enc
    setlocal fileencoding=&encoding
  endif
  "return 0 " DEBUG: 実行結果確認

  let lines = getline(1, '$')
  bwipeout!
  return lines
endfunction

function! s:OpenWindow(cmd)
  if winheight(0) > 2
    silent execute a:cmd
    return winnr()
  else
    " 'noequalalways'の場合、高さが足りずにsplitがE36エラーになる場合あるので、
    " 一番高さのあるwindowで再度splitを試みる
    let maxheight = 2
    let maxnr = 0
    for i in range(1, winnr('$'))
      let height = winheight(i)
      if height > maxheight
        let maxheight = height
        let maxnr = i
      endif
    endfor
    if maxnr > 0
      execute maxnr . 'wincmd w'
      silent execute a:cmd
      return winnr()
    else
      redraw
      echomsg 'cabocha.vim: 画面上の空きが足りないため新規ウィンドウを開くのに失敗しました。ウィンドウを閉じて空きを作ってください(:' . a:cmd . ')'
      return -1
    endif
  endif
endfunction