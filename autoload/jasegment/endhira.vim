" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" autoload/jasegment/endhira.vim:
" TinySegmenterを使わないで、文字種のみで文節を区切るためのスクリプト。
" 「(漢字|カタカナ|記号|英数字)+ひらがな」を1つの文節とみなす。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2014-01-12

if !exists('g:jasegment#endhira#splitpat')
  " ひらがなで終端される文字列として分割
  let g:jasegment#endhira#splitpat = '[ぁ-ん、。?!]\+\zs'
endif

function! jasegment#endhira#segment(input)
  " autoload/jasegment.vim内でg:jasegment#endhira#splitpatで区切られる
  return [a:input]
endfunction
