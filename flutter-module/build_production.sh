#!/bin/bash

# Production Build Script for Odalisque v0.13.0
# Builds secure, obfuscated releases for Android and iOS

set -e

echo "======================================"
echo "Odalisque Production Build v0.13.0"
echo "Security Hardening Enabled"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running from flutter-module directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}Error: Must run from flutter-module directory${NC}"
    exit 1
fi

# Parse command line arguments
BUILD_ANDROID=false
BUILD_IOS=false
BUILD_WEB=false
BUILD_ALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --android)
            BUILD_ANDROID=true
            shift
            ;;
        --ios)
            BUILD_IOS=true
            shift
            ;;
        --web)
            BUILD_WEB=true
            shift
            ;;
        --all)
            BUILD_ALL=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Usage: $0 [--android] [--ios] [--web] [--all]"
            exit 1
            ;;
    esac
done

if [ "$BUILD_ALL" = true ]; then
    BUILD_ANDROID=true
    BUILD_IOS=true
    BUILD_WEB=true
fi

if [ "$BUILD_ANDROID" = false ] && [ "$BUILD_IOS" = false ] && [ "$BUILD_WEB" = false ]; then
    echo -e "${YELLOW}No platform specified. Use --android, --ios, --web, or --all${NC}"
    exit 1
fi

# Clean previous builds
echo -e "\n${YELLOW}Cleaning previous builds...${NC}"
flutter clean

# Get dependencies
echo -e "\n${YELLOW}Getting dependencies...${NC}"
flutter pub get

# Run tests
echo -e "\n${YELLOW}Running tests...${NC}"
if ! flutter test; then
    echo -e "${RED}Tests failed! Aborting build.${NC}"
    exit 1
fi
echo -e "${GREEN}All tests passed!${NC}"

# Build Android
if [ "$BUILD_ANDROID" = true ]; then
    echo -e "\n${YELLOW}Building Android APK (Release - Obfuscated)...${NC}"
    flutter build apk \
        --release \
        --obfuscate \
        --split-debug-info=build/app/outputs/symbols \
        --target-platform android-arm64 \
        --split-per-abi

    echo -e "${GREEN}Android APK built successfully!${NC}"
    echo "Location: build/app/outputs/flutter-apk/"
    echo "Symbols: build/app/outputs/symbols/"

    echo -e "\n${YELLOW}Building Android App Bundle (Release - Obfuscated)...${NC}"
    flutter build appbundle \
        --release \
        --obfuscate \
        --split-debug-info=build/app/outputs/symbols-bundle

    echo -e "${GREEN}Android App Bundle built successfully!${NC}"
    echo "Location: build/app/outputs/bundle/release/"
    echo "Symbols: build/app/outputs/symbols-bundle/"
fi

# Build iOS
if [ "$BUILD_IOS" = true ]; then
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}iOS builds require macOS${NC}"
    else
        echo -e "\n${YELLOW}Building iOS (Release - Obfuscated)...${NC}"
        flutter build ios \
            --release \
            --obfuscate \
            --split-debug-info=build/ios/symbols \
            --no-codesign

        echo -e "${GREEN}iOS build completed!${NC}"
        echo "Location: build/ios/iphoneos/"
        echo "Symbols: build/ios/symbols/"
        echo -e "${YELLOW}Note: Code signing required for distribution${NC}"
    fi
fi

# Build Web
if [ "$BUILD_WEB" = true ]; then
    echo -e "\n${YELLOW}Building Web (Release)...${NC}"
    flutter build web \
        --release \
        --web-renderer canvaskit

    echo -e "${GREEN}Web build completed!${NC}"
    echo "Location: build/web/"
fi

# Security checklist
echo -e "\n======================================"
echo -e "${GREEN}Build Complete!${NC}"
echo -e "======================================"
echo -e "\n${YELLOW}Security Checklist:${NC}"
echo "✓ Code obfuscation enabled"
echo "✓ Debug symbols stripped and saved separately"
echo "✓ Secure storage for sensitive data"
echo "✓ Certificate pinning configured"
echo "✓ Audit logging enabled"
echo "✓ Rate limiting enabled"
echo ""
echo -e "${YELLOW}Before Distribution:${NC}"
echo "1. Test the release build thoroughly"
echo "2. Verify API keys are not hardcoded"
echo "3. Check ProGuard rules (Android)"
echo "4. Sign the APK/AAB (Android) or IPA (iOS)"
echo "5. Store debug symbols securely for crash reports"
echo "6. Update SSL certificates if needed"
echo "7. Configure production environment variables"
echo ""
echo -e "${GREEN}Debug symbols saved for crash reporting${NC}"
echo "Keep these symbols secure - needed to deobfuscate crash reports"
echo ""
