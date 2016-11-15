set encoding=utf-8

set number

set relativenumber

autocmd BufReadPost *
      \  if line("'\"") > 0 && line ("'\"") <= line("$") |
      \      exe "normal g'\"" |
      \  endif
