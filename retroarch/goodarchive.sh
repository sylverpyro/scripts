#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: $0 Archive name"
  exit
fi

while [ ! -f "$1" -a $# -gt 0 ]; do
  case $1 in
    '-v') VERBOSE="true"; shift ;;
    *)    echo "Error: Unrecognized argument or no such file: $1"; exit;;
  esac
done

if [ ! -f "$1" ]; then
  echo "Cannot find file: $1"
  exit
fi

function vecho () {
if [ "$VERBOSE" == "true" ]; then
  echo "$1"
fi
}

path="$(readlink -f "$1")"
file="$(basename "$path")"
name="${file%.*}"
ext="${file##*.}"
mime="$(file "$path" --mime-type -b)"

search_for="\.cso\|\.iso\|\.img\|\.bin\|\.mdf\|\.ecm\|\.nes\|\.nds\|\.nrg\|\.cdi\|\.dsk\|\.1a\|\.chf\|\.gbc\|\.gcm\|\.u26\|\.rom\|\.a78\|\.xex\|\.d64\|\.t64\|\.adf\|\.int\|\.pce\|\.gb\|\.smc\|\.gg\|\.sf7\|\.gen\|\.k7\|\.atr\|\.ssd\|\.do\|\.fmem1\|\.a52\|\.lnx\|\.st\|\.mtx\|\.sad\|\.app\|\.32x\|\.sms\|\.dim\|\.p\|\.tzx\|\.k7\|\.uef\|\.cpr\|\.jag\|\.j64\|\.a26\|\.bas\|\.atx\|\.com\|\.cas\|\.fpl\|\.fpt\|\.n64\|\.unf\|\.wad\|\.sfc\|\.3ds\|\.ws\|\.wsc\|\.col\|\.tap\|\.g64\|\.crt\|\.u[345]\|\.ue1\|\.ud7\|\.vec\|\.jrc\|\.sdf\|\.fds\|\.vb\|\.gdi\|\.sg\|\.md\|\.z80\|\.trd\|\.g41\|\.mv\|\.sc\|\.scl\|\.sp\|\.slt\|\.csw\|\.\$b\|\.fdi\|\.ngp\|\.ngc\|\.svi\|\.udi\|\.m5"

count=""
case "$mime" in
#  'zip')
  'application/zip')
    count="$(unzip -l "$path" | awk '/---------  ---------- -----   ----/,/---------                     -------/' | grep -v ^- | grep -i -c "$search_for")"
    if [ "$count" -eq 0 ]; then
      echo "Bad : $path"
    else
      echo "Good: $path"
    fi
    vecho "`unzip -l "$path" | awk '/---------  ---------- -----   ----/,/---------                     -------/' | grep -v ^-`"
    ;;
#  '7z')
  'application/x-7z-compressed')
    count="$(7z l "$path" | tail -n +18 | head -n -2 | grep -i -c "$search_for")"
    if [ "$count" -eq 0 ]; then 
      echo "Bad : $path"
    else
      echo "Good: $path"
    fi
    vecho "`7z l "$path" | tail -n +18 | head -n -2`"
    ;;
#  'rar')
  'application/x-rar')
    count="$(unrar l "$path" | tail -n +9 | head -n -3 | grep -i -c "$search_for")"
    if [ "$count" -eq 0 ]; then
      echo "Bad : $path"
    else
      echo "Good: $path"
    fi
    vecho "`unrar l "$path" | tail -n +9 | head -n -3`"
    ;;
  *)
    echo "Unknown mimetype '$mime' for file: $1" ;;
esac
