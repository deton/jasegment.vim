" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" autoload/jasegment/endhira_mbb.vim:
" TinySegmenterを使わないで、文字種のみで文節を区切るためのスクリプト。
" 「(漢字|カタカナ|記号)+ひらがな」や「ASCII文字列」を文節とみなす。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2014-01-14

if !exists('g:jasegment#endhira_mbb#splitpat0')
  " ひらがなで終端される文字列として分割もしくは、ASCII文字との境界で分割
  let g:jasegment#endhira_mbb#splitpat0 = '[ぁ-ん、。?!]\+\zs\|[\x01-\x7f]\zs[^\x01-\x7f]\@=\|[^\x01-\x7f]\zs[\x01-\x7f]\@='
endif

function! jasegment#endhira_mbb#segment(input)
  return split(a:input, g:jasegment#endhira_mbb#splitpat0)
endfunction
