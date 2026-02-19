#!/bin/bash
# pdf from text (stdin)

show_help() {
  echo "creates a PDF from text."
  echo "usage: echo text | pdf.sh [output.pdf] [--landscape]"
}

options=""
out=""
while test $# -gt 0; do
  case "$1" in
  --help|-h)
    show_help
    exit 0
  ;;
  --verbose|-v)
    verbose=true
  ;;
  --landscape)
    options="$options --landscape"
  ;;
  -* )
    echo "bad option '$1'"
  ;;
  *)
    out="$1"
  ;;
  esac
  shift
done

now=$(date +'%Y-%m-%d_%H-%M-%S')
fname="pdf-${now}"

# read stdin into temp file (works with pipes and heredocs)
tmpin=$(mktemp)
cat - > "$tmpin"

# ensure required commands
if ! command -v enscript >/dev/null 2>&1; then
  echo "enscript not found. installing..."
  sudo apt install -y enscript
fi
if ! command -v ps2pdf >/dev/null 2>&1; then
  echo "ghostscript (ps2pdf) not found. installing..."
  sudo apt install -y ghostscript
fi

# detect input charset (file -bi) and pick encoding for enscript
mime=$(file -bi "$tmpin" 2>/dev/null || true)
enc=${mime##*charset=}
# If input is UTF-8, try converting to ISO-8859-1 (latin1) for enscript
if [[ "$enc" =~ utf-?8 ]]; then
  ens_encoding="latin1"
  convtmp=$(mktemp)
  if command -v iconv >/dev/null 2>&1; then
    if iconv -f utf-8 -t iso-8859-1//TRANSLIT "$tmpin" > "$convtmp" 2>/dev/null; then
      usefile="$convtmp"
    else
      usefile="$tmpin"
      rm -f "$convtmp"
    fi
  else
    usefile="$tmpin"
  fi
else
  ens_encoding="latin1"
  usefile="$tmpin"
fi

# run enscript with chosen encoding, reading the selected file
enscript -v --encoding="$ens_encoding" $options -p "${fname}.ps" "$usefile"
ps2pdf "${fname}.ps"

# cleanup
rm -f "${fname}.ps" "$tmpin"

if [ -n "$out" ]; then
  mv "${fname}.pdf" "$out"
else
  # if no output argument, write to current dir with generated name
  echo "created ${fname}.pdf"
fi

