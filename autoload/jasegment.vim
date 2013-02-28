" vi:set ts=8 sts=2 sw=2 tw=0:
scriptencoding utf-8

" autoload/jasegment.vim - TinySegmenterを使って、日本語を文節や単語で分割
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2013-02-28

" 直前に分割したsegmentをキャッシュ
let s:cache = {}

" 行をsegmentに分割して、各segmentの文字列と開始col、終了colの配列を返す。
" 'segmentStr1segmentStr2...'
" => [{'segment':'segmentStr1','col':1,'colend':12},
"     {'segment':'segmentStr2','col':13,'colend':24},...]
function! jasegment#SegmentCol(model_name, line)
  let cache = get(s:cache, a:model_name, {})
  if !empty(cache) && a:line ==# cache.line
    return cache.segcols
  endif
  let s:lastline = a:line
  " まずスペース区切りのsegmentに分割
  let spsegs = split(a:line, '[[:space:]　]\+\zs')
  if empty(spsegs)
    let s:lastsegcols = []
    return s:lastsegcols
  endif
  let spsegcols = []
  let col = 1
  " スペース区切りの各segment内に日本語が含まれていたら、文節区切り
  for i in range(len(spsegs))
    let seglen = strlen(spsegs[i])
    let nextcol = col + seglen
    let spseg = substitute(spsegs[i], '[[:space:]　]', '', 'g')
    if spseg != ''
      if spseg =~ '[^[:graph:]]'
	let js = tinysegmenter#{a:model_name}#segment(spseg)
	" TinySegmenterで"。"の後で切ってくれないことがあるので自分で分割
	call map(js, 'split(v:val, ''[^[:space:]　][\?、。]\+\zs'')')
	let segs = []
	for ar in js
	  call extend(segs, ar)
	endfor
      else
	let segs = [spseg]
      endif
      call add(spsegcols, {'segment': segs, 'col': col})
    endif
    let col = nextcol
  endfor
  " スペース区切りsegment内の文節区切りを展開する。
  "    [{'segment':['jaSeg1','jaSeg2'],'col':1},
  "     {'segment':['enSeg'],'col':13},...]
  " => [{'segment':'jaSeg1','col':1,'colend':6},
  "     {'segment':'jaSeg2','col':7,'colend':12},
  "     {'segment':'enSeg','col':13,'colend':17},...]
  let segcols = []
  let i = 0
  while i < len(spsegcols)
    let seg = spsegcols[i].segment
    let col = spsegcols[i].col
    let j = 0
    while j < len(seg)
      let nextcol = col + strlen(seg[j])
      call add(segcols, {'segment': seg[j], 'col': col, 'colend': nextcol - 1})
      let col = nextcol
      let j += 1
    endwhile
    let i += 1
  endwhile
  let s:cache[a:model_name] = {'line': a:line, 'segcols': segcols}
  return segcols
endfunction

" col位置のsegmentを取得する
function! jasegment#GetCurrentSegment(model_name, linestr, col)
  let segcols = jasegment#SegmentCol(a:model_name, a:linestr)
  if empty(segcols)
    return {}
  endif
  let i = 0
  while i < len(segcols)
    if segcols[i].col > a:col
      return segcols[i - 1]
    endif
    let i += 1
  endwhile
  return segcols[i - 1]
endfunction
