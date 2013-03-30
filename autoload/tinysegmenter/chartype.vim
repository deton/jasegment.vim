" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" autoload/tinysegmenter/chartype.vim:
" TinySegmenterを使わないで、文字種のみで文節を区切るためのスクリプト。
" 「(漢字|カタカナ|記号|英数字)+ひらがな」を1つの文節とみなす。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2013-03-30

if !exists('g:jasegment#tinysegmenter#chartype#splitpat')
  " ひらがなで終端される文字列として分割。
  " (g:jasegment#splitpatに「、。?!」が含まれている前提)
  let g:jasegment#tinysegmenter#chartype#splitpat = '[ぁ-ん、。?!]\+\zs'
endif

function! tinysegmenter#chartype#segment(input)
  return split(a:input, g:jasegment#tinysegmenter#chartype#splitpat)
endfunction
