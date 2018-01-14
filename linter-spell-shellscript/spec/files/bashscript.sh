#!/bin/bash errror heeerre (here no spell check)
# comment commentary
# testing a comment
# testing errors:
#   testining
#   grammmars
for (( i = 0; i < 10; i++ )); do
  echo "testing words"
done

VAR=$(ls -la)
echo $VAR

# make a symbolic link of an FILE in download path
# of an INFOFILE path.
# how to use:
#   makeSymbolicLink INFOFILE FILE
function makeSymbolicLink()
{
  DESTDIR=$(dirname "$CWD/$1")
  ln -sf $DOWNLOAD_PATH/$2 $DESTDIR/$2
  echo "dir dirnames errors directoryy $DOWNLOADERRORHERE"
  echo "print array $DOWNLOADERRORHERE[${!URLARRAY[@]}]"
  echo 'test single quoted $ARRAYERROR here'
}

cat << EOF
Write some text using EOF
with errorsssss
EOF

if [ "$(grep ^oracle /etc/passwd)" = "" -o "$(grep ^dba /etc/group)" = "" ] ; then


# function comment
function name(arg1) { #commenttt with error
  # inner function comment
  # errors:
  #errrroooor herre
  #no more errors
  #testing comments
}
