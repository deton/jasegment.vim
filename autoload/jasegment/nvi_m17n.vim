" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" autoload/jasegment/nvi_m17n.vim:
" 文字種のみで文節を区切るためのスクリプト。
" nvi-m17nの区切り処理の移植。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2014-01-18

if !exists('g:jasegment#nvi_m17n#splitpat')
  " nvi_m17n.vimで区切った後、jasegment.vim内でg:jasegment#splitpatで、
  " さらに「?!」等で区切られないようにするため空にしておく
  let g:jasegment#nvi_m17n#splitpat = ''
endif

function! s:wave_dash()
  " &enc=cp932の場合、U+301Cが'?'になるが、'?'は入れたくないので
  " for euc-jp, shift_jis. U+301C WAVE DASH
  let c = iconv("\xe3\x80\x9c", 'utf-8', &encoding)
  if c == '?'
    return ''
  endif
  return c
endfunction
function! s:fullwidth_tilde()
  " for cp932. U+FF5E FULLWIDTH TILDE
  let c = iconv("\xef\xbd\x9e", 'utf-8', &encoding)
  if c == '?'
    return ''
  endif
  return c
endfunction

let s:chclass_kana = 'ヽヾゝゞー' . s:wave_dash() . s:fullwidth_tilde()
let s:patterns = {'[\x00-\x7f]':-1,'[〃仝々〆]':20,'[ぁ-ん]':2,'[ァ-ヶ]':10,'[０-９ａ-ｚＡ-Ｚα-ωΑ-Ω]':5}
" cf. Util::GetScriptType() in base/util.cc of mozc
let s:ucskanji = [[0x3400,0x4DBF],[0x4E00,0x9FFF],[0xF900,0xFAFF],[0x20000,0x2A6DF],[0x2A700,0x2B73F],[0x2B740,0x2B81F],[0x2F800,0x2FA1F]]
let s:start_kanji = char2nr('亜')

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

  if &encoding == 'utf-8'
    let ucs = char2nr(a:ch)
    for ucsrange in s:ucskanji
      if ucs >= ucsrange[0] && ucs <= ucsrange[1]
	return 20 " kanji
      endif
    endfor
    if ucs >= 0x3041 && ucs <= 0x309F || ucs == 0x1B001
      return 2 " hiragana
    endif
    if ucs >= 0x30A1 && ucs <= 0x30FF || ucs >= 0x31F0 && ucs <= 0x31FF || ucs >= 0xFF65 && ucs <= 0xFF9F || ucs == 0x1B000
      return 10 " katakana
    endif
    return 1 " mark
  endif

  " not utf-8: euc-jp, cp932
  let nr = char2nr(a:ch)
  " XXX: JISX0213で追加された文字には未対応。必要ならutf8環境にしてそうだし
  if nr >= s:start_kanji
    return 20 " kanji
  endif
  return 1 " mark
endfunction
