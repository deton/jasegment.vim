" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" autoload/jasegment/nvi_m17n.vim:
" 文字種のみで文節を区切るためのスクリプト。
" nvi-m17nの区切り処理の移植。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2014-01-16

if !exists('g:jasegment#nvi_m17n#splitpat')
  " nvi_m17n.vimで区切った後、jasegment.vim内でg:jasegment#splitpatで、
  " さらに「?!」等で区切られないようにするため空にしておく
  let g:jasegment#nvi_m17n#splitpat = ''
endif

let s:chclass_kana = 'ヽヾゝゞー〜'
let s:patterns = {'[\x00-\x7f]':-1,'[〃仝々〆]':20,'[ぁ-ん]':2,'[ァ-ヴーｱ-ﾝﾞｰ]':10,'[０-９ａ-ｚＡ-Ｚ]':5}

function! jasegment#nvi_m17n#segment(input)
  let res = []
  let word = ''
  let oldchclass = 0
  for ch in split(a:input, '\zs')
    let chclass = s:chclass(ch, oldchclass)
    if s:Wordbound(oldchclass, chclass)
      call add(res, word)
      let word = ch
    else
      let word .= ch
    endif
    let oldchclass = chclass
  endfor
  if word != ''
    call add(res, word)
  endif
  return res
endfunction

function! s:Wordbound(oldchclass, curchclass)
  " if it is just beginning, we don't bother.
  if a:oldchclass == 0
    return 0
  endif
  " ASCIIとマルチバイト文字列境界?
  if a:oldchclass < 0 && a:curchclass > 0
    return 1
  endif
  if a:oldchclass > 0 && a:curchclass < 0
    return 1
  endif
  " if next char is stronger, we've hit word boundary.
  if a:oldchclass < a:curchclass
    return 1
  endif
  return 0
endfunction

function! s:chclass(ch, oldchclass)
  if stridx(s:chclass_kana, a:ch) >= 0
    if a:oldchclass == 2
      return 2 " hiragana
    else
      return 10 " katakana
    endif
  endif

  for [pat, value] in items(s:patterns)
    if match(a:ch, pat) >= 0
      return value
    endif
  endfor

  let nr = char2nr(a:ch)
  if nr < char2nr('ぁ')
    return 1 " mark
  endif
  return 20 " kanji
endfunction
