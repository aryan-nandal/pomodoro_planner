#!/bin/bash
# Host orchestration script for running sandboxed E2E integration tests

# Ensure Homebrew path is loaded on macOS
export PATH="/opt/homebrew/bin:$PATH"

set -e

IMAGE_NAME="pomodoro-planner-test-runner"
DOCKERFILE_PATH="integration_test_system/Dockerfile"

echo "============================================="
echo "  Starting Sandboxed Integration Test Orchestrator"
echo "============================================="

# 1. Build the Docker image if it doesn't exist or needs update
echo "Building/Verifying Docker image: $IMAGE_NAME..."
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .

# 2. Setup caching Docker volumes for fast incremental compilations
echo "Ensuring cache volumes exist..."
docker volume create pomodoro-pub-cache > /dev/null
docker volume create pomodoro-build-cache > /dev/null
docker volume create pomodoro-build > /dev/null

# 3. Clean up old screenshots on host to avoid confusion
echo "Cleaning up old screenshots..."
rm -rf screenshots
mkdir -p screenshots

# 4. Define E2E tests and their associated database seeds
# Format: "test_file|seed_file"
declare -a TESTS=(
  "integration_test/auth_flow_test.dart|integration_test_system/seeds/auth_flow.json"
  "integration_test/tasks_flow_test.dart|integration_test_system/seeds/tasks_flow.json"
)

PASSED_TESTS=()
FAILED_TESTS=()

# 5. Run tests in isolated sandboxes (containers)
for entry in "${TESTS[@]}"; do
  IFS="|" read -r test_target seed_file <<< "$entry"
  test_name=$(basename "$test_target" _test.dart)
  
  echo ""
  echo "--------------------------------------------------------"
  echo "LAUNCHING SANDBOX FOR TEST: $test_name"
  echo "Target: $test_target"
  echo "Seed:   $seed_file"
  echo "--------------------------------------------------------"
  
  # Run the container
  # We mount:
  # - The project root to /workspace
  # - Cache volumes to preserve Dart packages and build caches for fast runs
  set +e
  docker run --rm \
    -v "$(pwd)":/workspace \
    -v pomodoro-pub-cache:/root/.pub-cache \
    -v pomodoro-build-cache:/app/.dart_tool \
    -v pomodoro-build:/app/build \
    -e TEST_TARGET="$test_target" \
    -e SEED_FILE="/workspace/$seed_file" \
    "$IMAGE_NAME" \
    /workspace/integration_test_system/entrypoint.sh
    
  EXIT_CODE=$?
  set -e
  
  if [ $EXIT_CODE -eq 0 ]; then
    PASSED_TESTS+=("$test_name")
  else
    FAILED_TESTS+=("$test_name")
  fi
done

# 6. Print Report
echo ""
echo "============================================="
echo "         INTEGRATION TEST REPORT"
echo "============================================="
echo "Passed: ${#PASSED_TESTS[@]}/${#TESTS[@]}"
for t in "${PASSED_TESTS[@]}"; do
  echo "  [PASS]  $t"
  if [ -d "screenshots/$t" ]; then
    echo "          Screenshots saved in: screenshots/$t/"
    ls -1 "screenshots/$t/" | sed 's/^/            - /'
  fi
done

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
  echo ""
  echo "Failed: ${#FAILED_TESTS[@]}/${#TESTS[@]}"
  for t in "${FAILED_TESTS[@]}"; do
    echo "  [FAIL]  $t"
    if [ -d "screenshots/$t" ]; then
      echo "          Screenshots saved in: screenshots/$t/"
      ls -1 "screenshots/$t/" | sed 's/^/            - /'
    fi
  done
  echo "============================================="
  exit 1
else
  echo "============================================="
  echo "All E2E integration tests completed successfully!"
  exit 0
fi
