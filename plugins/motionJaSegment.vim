" vi:set ts=8 sts=2 sw=2 tw=0:
"
" plugins/motionJaSegment.vim - E,W,B�Ǥΰ�ư��ʸ��ñ�̤ˤ��뤿��Υ�����ץȡ�
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2013-02-17

scriptencoding euc-jp

" Description:
" * ���ܸ�ʸ�Ͼ�Ǥ�E,W,B�Ǥΰ�ư�̤�ʸ��ñ�̤ˤ��ޤ���
"
" ���ץ����:
"    'g:loaded_motionJaSegment'
"       ���Υץ饰������ɤ߹��ߤ����ʤ����˼��Τ褦�����ꤹ�롣
"         let g:loaded_motionJaSegment = 1

if exists('g:loaded_motionJaSegment')
  finish
endif
let g:loaded_motionJaSegment = 1

if !exists('motionJaSegment_model')
  let motionJaSegment_model = 'knbc_bunsetu'
endif

noremap <silent> <Plug>MotionJaSegE :call <SID>ExecE()<CR>
noremap <silent> <Plug>MotionJaSegW :call <SID>ExecW()<CR>
noremap <silent> <Plug>MotionJaSegB :call <SID>ExecB()<CR>

function! s:ExecE()
  let lnum = line('.')
  let segcols = s:SegmentCol(getline(lnum))
  if empty(segcols)
    normal! E
    return
  endif
  let curcol = col('.')
  let i = 0
  while i < len(segcols)
    let colend = segcols[i].colend
    if colend > curcol
      call cursor(0, colend)
      if col('.') > curcol
	return
      endif
      " else ����segment�����ˤ�����硢����segment�����˰�ư
    endif
    let i += 1
  endwhile
  " ���˹����ˤ�����硢���Ԥκǽ��segment�������˰�ư
  " ���Ԥ�̵�����(�ǽ���)�ϡ�beep
  if lnum + 1 >= line('$')
    normal! E
    return
  endif
  call cursor(lnum + 1, 1)
  call s:ExecE()
endfunction

function! s:ExecW()
  let lnum = line('.')
  let segcols = s:SegmentCol(getline(lnum))
  if empty(segcols)
    normal! W
    return
  endif
  let curcol = col('.')
  let i = 0
  while i < len(segcols)
    let col = segcols[i].col
    if col > curcol
      call cursor(0, col)
      return
    endif
    let i += 1
  endwhile
  " �ԤκǸ��segment�ˤ����硢���Ԥκǽ��segment�˰�ư
  " ���Ԥ�̵�����(�ǽ���)�ϡ�beep
  if lnum + 1 >= line('$')
    normal! W
    return
  endif
  let segcols = s:SegmentCol(getline(lnum + 1))
  if empty(segcols)
    call cursor(lnum + 1, 1)
    return
  endif
  call cursor(lnum + 1, segcols[0].col)
endfunction

function! s:ExecB()
  let lnum = line('.')
  let segcols = s:SegmentCol(getline(lnum))
  if empty(segcols)
    normal! B
    return
  endif
  let curcol = col('.')
  let i = len(segcols) - 1
  while i >= 0
    let col = segcols[i].col
    if col < curcol
      call cursor(0, col)
      return
    endif
    let i -= 1
  endwhile
  " �Ԥκǽ��ʸ��ξ�硢���ιԤκǸ��ʸ��˰�ư
  " ���Ԥ�̵�����(��Ƭ��)�ϡ�beep
  if lnum <= 1
    normal! B
    return
  endif
  let segcols = s:SegmentCol(getline(lnum - 1))
  if empty(segcols)
    normal! B
    return
  endif
  call cursor(lnum - 1, segcols[len(segcols) - 1].col)
endfunction

" �Ԥ�segment��ʬ�䤷�ơ���segment��ʸ����ȳ���col����λcol��������֤���
" 'segmentStr1segmentStr2...'
" => [{'segment':'segmentStr1','col':1,'colend':11},
"     {'segment':'segmentStr2','col':12,'colend':22},...]
function! s:SegmentCol(line)
  let segs = tinysegmenter#{g:motionJaSegment_model}#segment(a:line)
  if empty(segs)
    return []
  endif
  let segcols = []
  let col = 1
  let i = 0
  while i < len(segs)
    let nextcol = col + strlen(segs[i])
    call add(segcols, {'segment': segs[i], 'col': col, 'colend': nextcol - 1})
    let col = nextcol
    let i += 1
  endwhile
  return segcols
endfunction
