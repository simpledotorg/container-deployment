#!/usr/bin/env bash
#
# Mirror the bangladesh-production image set into the DGHS MIS Gitea registry.
#
# The registry at git.dghs.gov.bd is geo-fenced to Bangladesh source IPs, so a
# direct push from outside the country fails with an nginx 403 before any
# authentication happens. Two modes handle that:
#
#   1. Direct (default)  - pull, tag and push in one pass. Requires a host whose
#                          public egress is inside Bangladesh.
#   2. Bundle            - `--save DIR` on any host to pull and export tarballs,
#                          then `--load DIR` on a Bangladesh-side host to import
#                          and push. Use this while the geo-block stands.
#
# The Gitea container registry addresses images as <host>/<owner>/<image>:<tag>
# with exactly one owner segment, so source paths are flattened with dashes:
#   registry.k8s.io/ingress-nginx/controller:v1.9.4
#     -> git.dghs.gov.bd/<owner>/ingress-nginx-controller:v1.9.4
#
# Usage:
#   MIS_OWNER=<org> ./mirror-images.sh                 # pull, tag, push
#   MIS_OWNER=<org> ./mirror-images.sh --dry-run       # print the plan only
#   ./mirror-images.sh --save ./bundle                  # pull and export
#   MIS_OWNER=<org> ./mirror-images.sh --load ./bundle # import and push
#
# Log in first (do not put the password in the command line):
#   docker login git.dghs.gov.bd -u <user> --password-stdin < token.txt

set -euo pipefail

MIS_REGISTRY="${MIS_REGISTRY:-git.dghs.gov.bd}"
MIS_OWNER="${MIS_OWNER:-}"
PLATFORM="${PLATFORM:-linux/amd64}"
IMAGES_FILE="${IMAGES_FILE:-$(dirname "$0")/images.txt}"

MODE="push"
BUNDLE_DIR=""

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) MODE="dry-run"; shift ;;
    --save)    MODE="save"; BUNDLE_DIR="${2:?--save needs a directory}"; shift 2 ;;
    --load)    MODE="load"; BUNDLE_DIR="${2:?--load needs a directory}"; shift 2 ;;
    -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ "$MODE" != "save" ] && [ "$MODE" != "dry-run" ] && [ -z "$MIS_OWNER" ]; then
  echo "MIS_OWNER must be set (the Gitea owner/organisation to push into)." >&2
  exit 2
fi

# registry.k8s.io/ingress-nginx/controller:v1.9.4 -> ingress-nginx-controller:v1.9.4
flatten() {
  local ref="$1" name_tag repo tag first path
  name_tag="${ref%@*}"          # drop any @sha256: digest
  repo="${name_tag%:*}"
  tag="${name_tag##*:}"
  [ "$tag" = "$repo" ] && tag="latest"
  first="${repo%%/*}"
  # a leading segment containing a dot or colon is a registry host, not a path
  case "$first" in
    *.*|*:*) path="${repo#*/}" ;;
    *)       path="$repo" ;;
  esac
  echo "${path//\//-}:${tag}"
}

mapfile -t IMAGES < <(grep -vE '^\s*(#|$)' "$IMAGES_FILE")
echo "==> ${#IMAGES[@]} images from $IMAGES_FILE (mode: $MODE)"

[ "$MODE" = "save" ] && mkdir -p "$BUNDLE_DIR"

failed=()
for src in "${IMAGES[@]}"; do
  dest="$MIS_REGISTRY/$MIS_OWNER/$(flatten "$src")"
  tarball="$BUNDLE_DIR/$(flatten "$src" | tr ':/' '__').tar"

  case "$MODE" in
    dry-run)
      printf '%-72s -> %s\n' "$src" "$dest"
      continue
      ;;
    load)
      echo "==> load $tarball"
      docker load -i "$tarball" >/dev/null || { failed+=("$src (load)"); continue; }
      ;;
    *)
      echo "==> pull $src"
      docker pull --platform "$PLATFORM" "$src" >/dev/null || { failed+=("$src (pull)"); continue; }
      ;;
  esac

  echo "    tag  $dest"
  docker tag "$src" "$dest" || { failed+=("$src (tag)"); continue; }

  if [ "$MODE" = "save" ]; then
    echo "    save $tarball"
    docker save -o "$tarball" "$dest" || failed+=("$src (save)")
  else
    echo "    push $dest"
    docker push "$dest" >/dev/null || failed+=("$src (push)")
  fi
done

if [ ${#failed[@]} -gt 0 ]; then
  echo
  echo "FAILED (${#failed[@]}):"
  printf '  %s\n' "${failed[@]}"
  exit 1
fi

echo
echo "All ${#IMAGES[@]} images processed successfully."
