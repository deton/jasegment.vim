" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" autoload/jasegment/mikan.vim
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2017-02-08
"
" mikan.jsのVim script移植版
" https://github.com/trkbt10/mikan.js
" 正規表現を用いた簡易形態素解析による、単語の改行問題への解決策を提供

let s:save_cpo = &cpo
set cpo&vim

let s:joshi = ['でなければ','について','ならば','までを','までの','くらい','なのか','として','とは','なら','から','まで','して','だけ','より','ほど','など','って','では','は','で','を','の','が','に','へ','と','て','じ']
let s:periods = '[\.,。、！!？?]\+$'
" 語のパターン。
" (\.[a-z]\{2,}付きパターンは拡張子付きファイル名。URLにもマッチしていまいち?)
let s:keywords = '\%([a-zA-Z0-9]\+\.[a-z]\{2,}\|[ぁ-んゝ]\+\|[ァ-ヴー]\+\|[a-zA-Z0-9]\+\|[ａ-ｚＡ-Ｚ０-９]\+\|[\.,。、！!？?]\+\)'
" Vim scriptだと[一-龠]はうまく行かないので別処理
" [一-龠々〆ヵヶゝ]\+
" jasegment用の場合はかっこ内が全部一つだとかえって編集が面倒かも
" [(（「『]\+.\{-}[)）」』]
" s:periodsも語として切り出し。でないと"。')"等で切り出されていまいちなので

if &encoding == 'utf-8'
  let s:kanjimin = char2nr('一')
  let s:kanjimax = char2nr('龠')
else " 'cp932', 'euc-jp'
  " TODO: support JIS X 0213
  let s:kanjimin = char2nr('亜')
  let s:kanjimax = char2nr('熙')
endif
let s:kanjiex = ['々','〆','ヵ','ヶ','ゝ']

" '[一-龠々〆ヵヶゝ]\+'のマッチ位置を返す
" @return [マッチした文字列, マッチ開始位置, マッチ終了位置]。
function s:matchkanjipos(str, idx)
  " マルチバイト文字が含まれなければすぐ戻る
  let st0 = match(a:str, '[^\x00-\xff]', a:idx)
  if st0 == -1
    return ['', -1, -1]
  endif
  if st0 > a:idx
    let preword = a:str[a:idx : (st0-1)]
  else
    let preword = ''
  endif
  let kanjistr = ''
  let inkanji = 0
  for c in split(a:str[st0:], '\zs')
    let nr = char2nr(c)
    if nr >= s:kanjimin && nr <= s:kanjimax || index(s:kanjiex, c) >= 0
      let inkanji = 1
      let kanjistr .= c
      continue
    elseif inkanji
      break
    endif
    let preword .= c
  endfor
  if !inkanji
    return ['', -1, -1]
  endif
  return [kanjistr, a:idx + strlen(preword), a:idx + strlen(preword) + strlen(kanjistr)]
endfunction

" 語を取得
" @param str 対象文字列
" @param idx str中の検索開始位置
" @return [新しいidx, 語の前にある文字列, 語]。
" 語や、語の前にある文字列は''の場合あり。
function s:getWord(str, idx)
  let [kw, kst, ked] = s:matchkanjipos(a:str, a:idx)
  let [w, st, ed] = matchstrpos(a:str, s:keywords, a:idx)
  if kst == -1 && st == -1
    return [strlen(a:str), a:str[a:idx :], '']
  endif
  " 漢字が先に出現していたら漢字を語として返す
  if st == -1 || kst != -1 && kst <= st
    let w = kw
    let st = kst
    let ed = ked
  endif
  let preword = ''
  if st > a:idx
    let preword = a:str[a:idx : st-1]
  endif
  return [ed, preword, w]
endfunction

function s:splitWords(str)
  let result = []
  let st = 0
  let len = strlen(a:str)
  while st < len
    let [st, word, word2] = s:getWord(a:str, st)
    if word !=# ''
      call add(result, word)
    endif
    if word2 !=# ''
      call add(result, word2)
    endif
  endwhile
  return result
endfunction

" 単語のあとの文字がひらがなかどうか
function s:isKwHira(prevWordType, word)
  return a:prevWordType == 'keyword' && a:word =~# '[ぁ-んゝ]\+'
endfunction

function s:simpleAnalyze(str)
  let words = s:splitWords(a:str)

  let result = [''] " 空だと、result[-1] .= word でエラーになる場合があるので
  let prevWordType = ''
  for word in words
    " 単語のあとの文字がひらがななら結合する
    if index(s:joshi, word) >= 0 || word =~# s:periods || s:isKwHira(prevWordType, word)
      let result[-1] .= word
      let prevWordType = ''
      continue
    endif
    let prevWordType = 'keyword'
    call add(result, word)
  endfor
  if result[0] == ''
    call remove(result, 0)
  endif
  return result
endfunction

function jasegment#mikan#segment(input)
  if a:input == ''
    return []
  endif
  return s:simpleAnalyze(a:input)
endfunction

let &cpo = s:save_cpo
