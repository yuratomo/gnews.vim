if version < 700
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn match gnewsTitle "^=.*=$"
syn match gnewsContent "^ \*.*$"

hi default link gnewsTitle Function
hi default link gnewsContent Underlined

let b:current_syntax = 'gnews'
