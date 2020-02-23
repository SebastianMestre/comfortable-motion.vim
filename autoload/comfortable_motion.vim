"=============================================================================
" File: comfortable_motion.vim
" Author: Yuta Taniguchi
" Created: 2016-10-02
"=============================================================================

scriptencoding utf-8

if !exists('g:loaded_comfortable_motion')
    finish
endif
let g:loaded_comfortable_motion = 1

let s:save_cpo = &cpo
set cpo&vim


" Default parameter values
if !exists('g:comfortable_motion_interval')
  let g:comfortable_motion_interval = 1000.0 / 60
endif
if !exists('g:comfortable_motion_decay')
  let g:comfortable_motion_decay = 0.8
endif
if !exists('g:comfortable_motion_scroll_down_key')
  let g:comfortable_motion_scroll_down_key = "\<C-e>"
endif
if !exists('g:comfortable_motion_scroll_up_key')
  let g:comfortable_motion_scroll_up_key = "\<C-y>"
endif

" The state
let s:comfortable_motion_state = {
\ 'impulse': 0,
\ 'to_scroll': 0,
\ }

function! s:tick(timer_id)

  let l:st = s:comfortable_motion_state  " This is just an alias for the global variable
  if abs(l:st.to_scroll) > 0 || l:st.impulse != 0 " 

	let l:st.to_scroll += l:st.impulse
	let l:st.impulse = 0

    " Exponential decay
	" Cast to integer, substract, and assign to make scrolling deterministic
    let l:remaining = float2nr(l:st.to_scroll * g:comfortable_motion_decay)
	let l:int_delta = l:st.to_scroll - l:remaining
    let l:st.to_scroll = l:remaining

	" Assuming int_delta cannot be 0
    if l:int_delta > 0
      execute "normal! " . string(abs(l:int_delta)) . g:comfortable_motion_scroll_down_key
    else
      execute "normal! " . string(abs(l:int_delta)) . g:comfortable_motion_scroll_up_key
    endif
    redraw
  else
    " Stop scrolling and the thread
    let l:st.to_scroll = 0
    call timer_stop(s:timer_id)
    unlet s:timer_id
  endif
endfunction

function! comfortable_motion#flick(impulse)
  if !exists('s:timer_id')
    " There is no thread, start one
    let l:interval = float2nr(round(g:comfortable_motion_interval))
    let s:timer_id = timer_start(l:interval, function("s:tick"), {'repeat': -1})
  endif
  let s:comfortable_motion_state.impulse += a:impulse
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
