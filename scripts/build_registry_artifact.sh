#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB_MANIFEST="$ROOT_DIR/crates/hello-world-lib/Cargo.toml"
ARTIFACT_DIR="$ROOT_DIR/dist/registry-upload"
INDEX_DIR="$ARTIFACT_DIR/index"
CRATES_DIR="$ARTIFACT_DIR/crates"
CONFIG_TEMPLATE="$ROOT_DIR/registry/config.template.json"
CONFIG_OUTPUT="$INDEX_DIR/config.json"
TARBALL="$ROOT_DIR/dist/private-registry-artifact.tar.gz"

DL_URL="${DL_URL:-https://dependabot-authenticated-registry-demo.swedencentral.cloudapp.azure.com/crates/\{crate\}/\{version\}/\{crate\}-\{version\}.crate}"
API_URL="${API_URL:-https://dependabot-authenticated-registry-demo.swedencentral.cloudapp.azure.com/api/v1/crates}"

rm -rf "$ARTIFACT_DIR"
mkdir -p "$INDEX_DIR" "$CRATES_DIR"

echo "Packaging hello-world-lib..."
cargo package --allow-dirty --manifest-path "$LIB_MANIFEST"

CRATE_FILE="$(ls "$ROOT_DIR"/target/package/hello-world-lib-*.crate | head -n 1)"
CRATE_BASENAME="$(basename "$CRATE_FILE")"
CRATE_VERSION="${CRATE_BASENAME#hello-world-lib-}"
CRATE_VERSION="${CRATE_VERSION%.crate}"

CHECKSUM="$(shasum -a 256 "$CRATE_FILE" | awk '{print $1}')"

# Render registry config.json from the editable template.
sed \
  -e "s|{{DL_URL}}|$DL_URL|g" \
  -e "s|{{API_URL}}|$API_URL|g" \
  "$CONFIG_TEMPLATE" > "$CONFIG_OUTPUT"

INDEX_CRATE_PATH="$INDEX_DIR/he/ll"
mkdir -p "$INDEX_CRATE_PATH"
cat > "$INDEX_CRATE_PATH/hello-world-lib" <<EOF
{"name":"hello-world-lib","vers":"$CRATE_VERSION","deps":[],"cksum":"$CHECKSUM","features":{},"yanked":false,"links":null}
EOF

CRATE_TARGET_DIR="$CRATES_DIR/hello-world-lib/$CRATE_VERSION"
mkdir -p "$CRATE_TARGET_DIR"
cp "$CRATE_FILE" "$CRATE_TARGET_DIR/$CRATE_BASENAME"

mkdir -p "$ROOT_DIR/dist"
tar -czf "$TARBALL" -C "$ARTIFACT_DIR" .

echo "Registry artifact created: $TARBALL"
echo "Upload the extracted contents so that:"
echo "  - index/config.json is served at your index URL"
echo "  - index/he/ll/hello-world-lib is available"
echo "  - crates/hello-world-lib/$CRATE_VERSION/$CRATE_BASENAME is downloadable"
