if exists('g:gnews_loaded') && g:gnews_loaded == 1
  finish
endif

if !exists('g:gnews#url')
  let g:gnews#url = [
    \ 'http://pipes.yahoo.com/pipes/pipe.run?_id=a1f4674ad9a307d54262ff8b600793f6&_render=json',
    \ ]
endif

command! -nargs=0 Gnews      :call gnews#start(0)
command! -nargs=0 GnewsSplit :call gnews#start(1)

let g:gnews_loaded = 1
