#!/bin/bash

# Build script for ALMA web deployment

echo "========================================"
echo "ALMA Web Build Script"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed. Please install Flutter first."
    exit 1
fi

print_status "Flutter is installed"

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "Getting dependencies..."
flutter pub get

# Run tests
print_status "Running tests..."
if flutter test; then
    print_status "All tests passed!"
else
    print_error "Tests failed. Please fix the issues before building."
    exit 1
fi

# Analyze code
print_status "Analyzing code..."
if flutter analyze; then
    print_status "Code analysis passed!"
else
    print_warning "Code analysis found issues. Consider fixing them."
fi

# Build for web
print_status "Building for web (release mode)..."
if [ "$1" == "--github-pages" ]; then
    print_status "Building with GitHub Pages base href..."
    flutter build web --release --base-href "/alma/"
else
    flutter build web --release
fi

# Check if build was successful
if [ -d "build/web" ]; then
    print_status "Build successful!"
    echo ""
    echo "========================================"
    echo "Build completed successfully!"
    echo "Output directory: build/web"
    echo ""
    echo "To serve locally, run:"
    echo "  cd build/web && python3 -m http.server 8000"
    echo ""
    echo "Then open: http://localhost:8000"
    echo "========================================"
else
    print_error "Build failed. Please check the errors above."
    exit 1
fi

# Create deployment info file
echo "{
  \"buildDate\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\",
  \"version\": \"1.0.0\",
  \"environment\": \"production\"
}" > build/web/build-info.json

print_status "Build info created"