#!/bin/bash
set -euo pipefail

source "$HOME/.config/backup-www-html.env"

BASE="/srv/backups/www-html"
STAMP="$(date -u +%Y-%m-%d_%H-%M-%S)"
DEST="$BASE/$STAMP"

# Estää ajoja menemästä päällekkäin
exec 9>"$HOME/.backup-www-html.lock"
flock -n 9 || exit 0

# Luo uusi aikaleimallinen kohdehakemisto B:lle
ssh -i "$KEY" "$REMOTE" "mkdir -p '$DEST'"

# Kopioi /var/www/html-kansion sisällön.
# Virhe pysäyttää skriptin ennen vanhojen kopioiden poistoa.
rsync -a --no-owner --no-group \
  -e "ssh -i $KEY" \
  /var/www/html/ \
  "$REMOTE:$DEST/"

# Säilytä 720 uusinta hakemistoa ja poista niitä vanhemmat.
ssh -i "$KEY" "$REMOTE" python3 - "$BASE" <<'PY'
import pathlib
import shutil
import sys

base = pathlib.Path(sys.argv[1])
snapshots = sorted(
    (p for p in base.iterdir() if p.is_dir()),
    key=lambda p: p.name,
    reverse=True
)

for old in snapshots[720:]:
    shutil.rmtree(old)
PY
