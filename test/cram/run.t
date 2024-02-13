Exercising the error handling from the command line.

  $ cat > file << EOF
  > Hello World
  > EOF

  $ ./main.exe write --file file --line 1 --pos-bol 0 \
  > --pos-cnum 0 --length 5 \
  > --message-kind Error
  File "file", line 1, characters 0-5:
  1 | Hello World
      ^^^^^
  Error: error message
  [1]

  $ ./main.exe write --file file --line 1 --pos-bol 0 \
  > --pos-cnum 6 --length 5 \
  > --message-kind Warning
  File "file", line 1, characters 6-11:
  1 | Hello World
            ^^^^^
  Warning: warning message

  $ ./main.exe write --file file --line 1 --pos-bol 0 \
  > --pos-cnum 6 --length 5 \
  > --message-kind Warning \
  > --warn-error
  File "file", line 1, characters 6-11:
  1 | Hello World
            ^^^^^
  Warning: warning message
  [1]

  $ ./main.exe write --file file --line 1 --pos-bol 0 \
  > --pos-cnum 6 --length 5 \
  > --message-kind Info

  $ ./main.exe write --file file --line 1 --pos-bol 0 \
  > --pos-cnum 6 --length 5 \
  > --message-kind Info \
  > --verbose
  File "file", line 1, characters 6-11:
  1 | Hello World
            ^^^^^
  Info: info message

  $ ./main.exe write --file file --line 1 --pos-bol 0 \
  > --pos-cnum 6 --length 5 \
  > --message-kind Debug \
  > --verbose

  $ ./main.exe write --file file --line 1 --pos-bol 0 \
  > --pos-cnum 6 --length 5 \
  > --message-kind Debug \
  > --debug
  File "file", line 1, characters 6-11:
  1 | Hello World
            ^^^^^
  Debug: debug message
