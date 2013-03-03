
function! s:nr2byte(nr)
  if a:nr < 0x80
    return nr2char(a:nr)
  elseif a:nr < 0x800
    return nr2char(a:nr/64+192).nr2char(a:nr%64+128)
  else
    return nr2char(a:nr/4096%16+224).nr2char(a:nr/64%64+128).nr2char(a:nr%64+128)
  endif
endfunction

function! s:nr2enc_char(charcode)
  if &encoding == 'utf-8'
    return nr2char(a:charcode)
  endif
  let char = s:nr2byte(a:charcode)
  if strlen(char) > 1
    let char = strtrans(iconv(char, 'utf-8', &encoding))
  endif
  return char
endfunction

function! s:decode(json)
  let json = iconv(a:json, "utf-8", &encoding)
  let json = substitute(json, '\\n', '', 'g')
  let json = substitute(json, 'null', '""', 'g')
  let json = substitute(json, '\\u34;', '\\"', 'g')
  try
    let json = iconv(substitute(json, '\\u\(\x\x\x\x\)', '\=nr2char("0x".submatch(1), 1)', 'g'), 'utf-8', &enc)
  catch /.*/
    let json = substitute(json, '\\u\(\x\x\x\x\)', '\=s:nr2enc_char("0x".submatch(1))', 'g')
  endtry
  return eval(json)
endfunction

function! s:out(line)
  call setline(line('$')+1, a:line)
endfunction

function! s:neglect(str)
  return substitute(a:str,'<.\{-\}>','','g')
endfunction

function! gnews#start(split)
  call s:open_win(a:split)
  setl modifiable 
  for url in g:gnews#url
    let json = s:decode( system('curl -L -s -k "' . url . '"') )
    let last_category = ''
    for item in json.value.items
      if last_category != item.category
        let last_category = item.category
        call s:out('= ' . item.category . ' =')
        call s:out('')
      endif
      call s:out(' *' . item["y:title"])
      call s:out(' ' . s:neglect(item.description))
      call s:out('')
    endfor
  endfor
  setl nomodifiable
endfunction

function! s:open_win(split)
  if !exists('b:gnews_win')
    if a:split == 1
      new
    endif
    silent edit gnews
    setl bt=nofile noswf wrap hidden nolist nomodifiable ft=gnews fdm=indent ts=1 sw=1 et fdl=0 fdt=getline(v:foldstart)
    let b:weather_win = 0
  endif
endfunction

