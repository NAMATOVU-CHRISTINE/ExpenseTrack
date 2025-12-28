.PHONY: help install clean test analyze build run

help:
	@echo "Available commands:"
	@echo "  make install    - Install dependencies"
	@echo "  make clean      - Clean build files"
	@echo "  make test       - Run tests"
	@echo "  make analyze    - Run static analysis"
	@echo "  make build-apk  - Build release APK"
	@echo "  make build-aab  - Build app bundle"
	@echo "  make run        - Run the app"

install:
	flutter pub get

clean:
	flutter clean
	flutter pub get

test:
	flutter test

analyze:
	flutter analyze

build-apk:
	flutter build apk --release

build-aab:
	flutter build appbundle --release

run:
	flutter run

format:
	dart format lib/

fix:
	dart fix --apply
