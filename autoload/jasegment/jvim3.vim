" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" autoload/jasegment/jvim3.vim:
" 文字種のみで文節を区切るためのスクリプト。
" jvim3の区切り処理の移植: ASCII文字との境界と、記号で区切る
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2014-01-19

if !exists('g:jasegment#jvim3#splitpat')
  " jvim3.vimで区切った後、jasegment.vim内でg:jasegment#splitpatで、
  " さらに区切られないようにするため空にしておく
  let g:jasegment#jvim3#splitpat = ''
endif

function! s:add_if_iconvok(ls, seq)
  let c = iconv(a:seq, 'utf-8', &encoding)
  if c != '' && c !~ '^?\+$'
    call add(a:ls, c)
  endif
endfunction

" ひらがな扱いの文字"ヽヾゝゞ"、カタカナ扱いの文字"ー−"
" 漢字扱いの文字"〃仝々〆"、空白扱いの文字"　＿"以外の記号。
let s:kigou = ['、','。','，','．','・','：','；','？','！','゛','゜','´','｀','¨','＾','￣','〇','―','‐','／','＼','｜','…','‥','‘','’','“','”','（','）','〔','〕','［','］','｛','｝','〈','〉','《','》','「','」','『','』','【','】','＋','±','×','÷','＝','≠','＜','＞','≦','≧','∞','∴','♂','♀','°','′','″','℃','￥','＄','¢','£','％','＃','＆','＊','＠','§','☆','★','○','●','◎','◇','◆','□','■','△','▲','▽','▼','※','〒','→','←','↑','↓','〓','∈','∋','⊆','⊇','⊂','⊃','∪','∩','∧','∨','¬','⇒','⇔','∀','∃','∠','⊥','⌒','∂','∇','≡','≒','≪','≫','√','∽','∝','∵','∫','∬','Å','‰','♯','♭','♪','†','‡','¶','◯']

" &enc=cp932の場合、U+301CやU+2016が'?'になるが、'?'は入れたくない。
" &enc=euc-jpの場合、U+2225が'????'になる。
" U+301C WAVE DASH (for euc-jp, shift_jis)
call s:add_if_iconvok(s:kigou, "\xe3\x80\x9c")
" U+FF5E FULLWIDTH TILDE (for cp932)
call s:add_if_iconvok(s:kigou, "\xef\xbd\x9e")
" U+2016 DOUBLE VERTICAL LINE (for euc-jp, shift_jis)
call s:add_if_iconvok(s:kigou, "\xe2\x80\x96")
" U+2225 PARALLEL TO (for cp932)
call s:add_if_iconvok(s:kigou, "\xe2\x88\xa5")

let s:hankana = '[｡-ﾟ]'

function! jasegment#jvim3#segment(input)
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
  if a:oldchclass == 0
    return 0
  endif
  if a:curchclass != a:oldchclass
    return 1
  endif
  return 0
endfunction

function! s:chclass(ch, oldchclass)
  if char2nr(a:ch) <= 0x7f
    return 1 " ASCII
  endif
  if index(s:kigou, a:ch) >= 0
    return 7 " kigou
  endif
  if a:ch =~# s:hankana
    return 9 " 1byte kana
  endif
  return 4 " hira
endfunction
