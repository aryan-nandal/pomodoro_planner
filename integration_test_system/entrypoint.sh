#!/bin/bash
# Enable bash strict mode
set -e

# Define directories
WORKSPACE_DIR="/workspace"
APP_DIR="/app"

echo "=== E2E Container Test Runner ==="
echo "Target Test: $TEST_TARGET"
echo "Seed File  : $SEED_FILE"
echo "================================="

# 1. Sync workspace to /app to isolate builds from the host
echo "Syncing workspace to $APP_DIR (excluding large build artifacts)..."
mkdir -p "$APP_DIR"
rsync -a \
  --exclude='.git' \
  --exclude='.github' \
  --exclude='.dart_tool' \
  --exclude='build' \
  --exclude='android' \
  --exclude='ios' \
  --exclude='macos' \
  --exclude='linux' \
  --exclude='windows' \
  "$WORKSPACE_DIR/" "$APP_DIR/"

cd "$APP_DIR"

# 2. Set up database seeder dependencies
echo "Installing Node.js seeder dependencies..."
cd "$APP_DIR/integration_test_system"
npm install --no-audit --no-fund
cd "$APP_DIR"

# 3. Start Firebase Emulators
echo "Starting Firebase Emulators..."
# We run firebase emulators in the background and capture the PID
# We specify the config file located at integration_test_system/firebase.json
firebase emulators:start --config=integration_test_system/firebase.json --project task-planner-c03ea &
EMULATOR_PID=$!

# Function to clean up emulators and services on script exit
cleanup() {
  echo "Stopping Firebase Emulators (PID: $EMULATOR_PID)..."
  kill $EMULATOR_PID || true
  wait $EMULATOR_PID 2>/dev/null || true
  
  if [ -n "$CHROMEDRIVER_PID" ]; then
    echo "Stopping ChromeDriver (PID: $CHROMEDRIVER_PID)..."
    kill $CHROMEDRIVER_PID || true
    wait $CHROMEDRIVER_PID 2>/dev/null || true
  fi
}
trap cleanup EXIT

# 4. Wait for the emulators to boot up (ports 8080 and 9099)
echo "Waiting for Firestore and Auth emulators to be healthy..."
timeout=60
while ! curl -s http://127.0.0.1:8080/ > /dev/null; do
  sleep 1
  timeout=$((timeout - 1))
  if [ $timeout -le 0 ]; then
    echo "ERROR: Firebase Firestore Emulator failed to start in time."
    exit 1
  fi
done

timeout=60
while ! curl -s http://127.0.0.1:9099/ > /dev/null; do
  sleep 1
  timeout=$((timeout - 1))
  if [ $timeout -le 0 ]; then
    echo "ERROR: Firebase Auth Emulator failed to start in time."
    exit 1
  fi
done
echo "Firebase Emulators are online."

# 5. Seed the database
if [ -n "$SEED_FILE" ] && [ -f "$SEED_FILE" ]; then
  echo "Seeding database using: $SEED_FILE"
  node integration_test_system/seed.js "$SEED_FILE"
else
  echo "No seed file provided or found. Initializing with empty database..."
  node integration_test_system/seed.js ""
fi

# 6. Run Flutter Integration Test
# Start ChromeDriver in the background (required for Flutter Web integration tests)
echo "Starting ChromeDriver on port 4444..."
chromedriver --port=4444 --whitelisted-ips=127.0.0.1 &
CHROMEDRIVER_PID=$!

# Wait for ChromeDriver to start
sleep 2

echo "Running Flutter drive E2E test..."
# Disable pub upgrade check and run in offline mode where possible to speed up
export PUB_CACHE=/root/.pub-cache

# Run flutter drive against headless Chrome
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target="$TEST_TARGET" \
  -d web-server \
  --browser-name=chrome \
  --web-browser-flag="--headless" \
  --web-browser-flag="--no-sandbox" \
  --web-browser-flag="--disable-gpu" \
  --web-browser-flag="--disable-dev-shm-usage" \
  --web-browser-flag="--window-size=1280,800" \
  --dart-define=USE_EMULATOR=true \
  --dart-define=EMULATOR_HOST=localhost

TEST_EXIT_CODE=$?

if [ $TEST_EXIT_CODE -eq 0 ]; then
  echo "SUCCESS: Test $TEST_TARGET passed!"
else
  echo "FAILURE: Test $TEST_TARGET failed with exit code $TEST_EXIT_CODE"
fi

exit $TEST_EXIT_CODE
