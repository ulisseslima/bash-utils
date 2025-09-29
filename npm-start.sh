#!/bin/bash -e
# starts a node project
# otherwise, just `node index.js`

# Check if package.json exists
if [ ! -f package.json ]; then
  echo "❌ Error: package.json not found. Run 'npm init -y' first."
  exit 1
fi

echo "📦 Checking for nodemon..."
if ! npx --no-install nodemon --version > /dev/null 2>&1; then
  >&2 echo "📥 Install nodemon?"
  read confirmation
  npm install --save-dev nodemon
fi

# Backup original package.json
cp package.json package.json.bk-$(now.sh -f)

# Check if "scripts" section exists
if ! grep -q '"scripts"' package.json; then
  echo "🧪 Adding scripts section to package.json..."
  # Add scripts at the top level of package.json
  tmp=$(mktemp)
  jq '. + {scripts: {start: "node index.js", dev: "nodemon index.js"}}' package.json > "$tmp" && mv "$tmp" package.json
else
  # Add missing start/dev scripts if needed
  echo "⚙️ Updating scripts..."
  tmp=$(mktemp)
  jq '
    .scripts +=
    (if has("start") | not then {start: "node index.js"} else {} end) +
    (if has("dev") | not then {dev: "nodemon index.js"} else {} end)
  ' package.json > "$tmp" && mv "$tmp" package.json
fi

npm install
>&2 echo "🚀 Starting server with nodemon..."
#npm start
npm run dev
