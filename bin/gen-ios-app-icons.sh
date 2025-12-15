#!/bin/sh
set -euo pipefail
# generate icons for every entry in Contents.json
# usage: run from this folder: sh generate_icons.sh

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required" >&2; exit 1
fi
if ! command -v sips >/dev/null 2>&1; then
  echo "sips is required (macOS). Install ImageMagick or use Xcode to add icons." >&2; exit 1
fi

FOLDER_NAME=$(basename "$PWD")
SOURCE_IMAGE="../${FOLDER_NAME%.*}.png"

if [ ! -f "$SOURCE_IMAGE" ]; then
  echo "Creating placeholder $SOURCE_IMAGE"
  cat > /tmp/_appicon_b64.txt <<'B64'
iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACklEQVR4nGNgYAAAAAYAAjCB0C8AAAAASUVORK5CYII=
B64

  python3 - <<PY
import base64
open('$SOURCE_IMAGE','wb').write(base64.b64decode(open('/tmp/_appicon_b64.txt','rb').read()))
PY
  rm -f /tmp/_appicon_b64.txt
else
  echo "Using existing $SOURCE_IMAGE"
fi

CONTENTS=Contents.json
if [ ! -f "$CONTENTS" ]; then
  echo "Contents.json not found in $(pwd)" >&2
  exit 1
fi

python3 - <<'PY'
import json, subprocess, math
f = 'Contents.json'
data = json.load(open(f))
entries = data.get('images', [])
outputs = []
updated = False
for e in entries:
    size = e.get('size')
    scale = e.get('scale','1x')
    if not size:
        continue
    point = float(size.split('x')[0])
    scale_n = int(scale.replace('x',''))
    px = int(math.ceil(point * scale_n))
    fn = e.get('filename')
    if not fn:
        fn = f"Icon-{int(point)}@{scale}.png"
        e['filename'] = fn
        updated = True
        print(f"Updated entry: {size} @ {scale} -> {fn}")
    outputs.append((fn, px, px))

    # call sips to resize
    cmd = ['sips','-z',str(px),str(px),'$SOURCE_IMAGE','--out',fn]
    print('RUN:', ' '.join(cmd))
    subprocess.check_call(cmd)

if updated:
    with open(f, 'w') as out:
        json.dump(data, out, indent=2, separators=(',', ' : '))
        out.write('\n')
    print('Updated Contents.json with new filenames')

print('Generated', len(outputs), 'icons')
PY

echo "Done"
