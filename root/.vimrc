set encoding=utf-8

autocmd BufReadPost *
      \  if line("'\"") > 0 && line ("'\"") <= line("$") |
      \      exe "normal g'\"" |
      \  endif
