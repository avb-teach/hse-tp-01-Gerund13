#!/bin/bash

INP="$1"
OUT="$2"
DEPTH=""

if [[ "$3" == "--max_depth" ]]; then
  DEPTH="$4"
fi

python3 - "$INP" "$OUT" "$DEPTH" << 'EOF'
#!/usr/bin/env python3
import os, sys, shutil

src = sys.argv[1]
dst = sys.argv[2]
mx = None
if len(sys.argv) > 3:
	try:
		mx = int(sys.argv[3])
	except:
		mx = None

if not os.path.exists(dst):
	os.makedirs(dst)

for root, dirs, files in os.walk(src):
	for f in files:
		path = os.path.join(root, f)
		rel = os.path.relpath(root, src)
		parts = rel.split(os.sep) if rel != "." else []

		if mx:
			if len(parts) > mx - 1:
				parts = parts[-(mx - 1):]
			target_dir = os.path.join(dst, *parts) if parts else dst
		else:
			target_dir = dst

		if not os.path.exists(target_dir):
			os.makedirs(target_dir)

		dest = os.path.join(target_dir, f)
		name, ext = os.path.splitext(f)
		i = 1
		while os.path.exists(dest):
			dest = os.path.join(target_dir, "{}_{}{}".format(name, i, ext))
			i += 1

		shutil.copy(path, dest)

EOF