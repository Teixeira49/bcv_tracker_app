---
name: "configuring-codemagic"
description: "Configures Codemagic CI/CD pipelines for Flutter using `codemagic.yaml`. Use when setting up automated Flutter builds on Codemagic, configuring iOS code signing without Fastlane Match, deploying to App Store Connect or Google Play from Codemagic, caching pub dependencies in Codemagic, setting up encrypted environment variable groups, running tests with Codemagic's test dashboard, or choosing between Codemagic and GitHub Actions + Fastlane for a Flutter CI/CD pipeline."
metadata:
  last_modified: "2026-04-01 14:35:00 (GMT+8)"
---

# Flutter combined with Codemagic Best Practices (YAML approach)

## Goal
Implements Codemagic YAML configurations for Flutter deployment. [Codemagic](https://codemagic.io/) natively understands Flutter, requires no extra tooling for code signing, and provides Apple M-series machines for fast iOS compilation.

## Instructions

The recommended approach is using `codemagic.yaml` for "Infrastructure as Code," maintaining it within the project repository alongside the source code.

### 1. Infrastructure and Cache Strategy
Place `codemagic.yaml` in the project root. A single file can contain multiple Workflows (e.g., executing iOS deployments and Android deployments separately).

**Best Caching Practice**: Caching is fundamental to saving CI costs. Be sure to cache Dart dependencies and native build tools.

```yaml
# 🌟 codemagic.yaml
workflows:
  android-release:
    name: Android Release Workflow
    instance_type: mac_mini_m1 # Specify M1 machine for acceleration
    environment:
      # 🌟 Specify the Flutter version
      flutter: stable 
    cache:
      cache_paths:
        - $HOME/.pub-cache # Dart packages
        - $HOME/.gradle/caches # Gradle dependencies
```

### 2. Environment Variables & Encrypted Keys
**NEVER** hardcode Keystore passwords or API Keys in the YAML file. Codemagic provides highly secure UI dashboards to create variable groups, encrypt them, and consume them via scripts.

```yaml
    environment:
      flutter: stable
      groups:
        # Pre-configured group names on the Codemagic UI
        - keystore_credentials # Contains $KEY_PASSWORD, $ALIAS_PASSWORD
        - google_play_credentials # Contains the JSON key path for the Google Service Account
```

### 3. Analyze, Generate & Test
Before building, utilize the `scripts` block to execute commands sequentially.

```yaml
    scripts:
      - name: ⬇️ Fetch Dependencies
        script: flutter packages pub get
        
      - name: ⚙️ Code Generation (build_runner)
        script: dart run build_runner build --delete-conflicting-outputs
        
      - name: 🚨 Static Analysis
        script: flutter analyze
        
      - name: 🧪 Unit & Widget Tests
        script: flutter test
        # 🌟 Codemagic automatically parses the test results and displays them on a sleek Web Dashboard
        test_report: build/test-results/flutter.json 
```

### 4. Build Bundle / IPA
Codemagic's greatest strength lies in condensing complex Code Signing flows into extremely minimalist declarative syntax.

#### 4.1 Android Building (with Keystore)

```yaml
      - name: 🔨 Build Android App Bundle
        script: |
          # Generate a key.properties for android/app/build.gradle to read
          echo "storePassword=$KEYSTORE_PASSWORD" >> android/key.properties
          echo "keyPassword=$KEY_PASSWORD" >> android/key.properties
          echo "keyAlias=$KEY_ALIAS" >> android/key.properties
          echo "storeFile=$KEYSTORE_PATH" >> android/key.properties
          
          # 🌟 The build action
          flutter build appbundle --release
```

#### 4.2 iOS Code Signing
You typically do not need to manually configure Fastlane Match. Upload your `App Store Connect API Key` via Codemagic's Web Dashboard, and it automatically handles certificate fetching:

```yaml
    environment: # Declare before Workflow logic: Enable Auto Signing
      ios_signing:
        distribution_type: app_store
        bundle_identifier: com.yourcompany.app

    scripts:
      - name: 🍏 Build iOS IPA
        script: flutter build ipa --release
```

### 5. Push to Store (Publishing)
Once the build concludes, declare the target artifacts, and automatically push directly to the stores utilizing built-in modules—no upload scripting required!

```yaml
    artifacts:
      - build/app/outputs/bundle/release/**/*.aab
      - build/ios/ipa/*.ipa

    publishing:
      # Auto-email the team
      email:
        recipients:
          - devteam@company.com
          
      # 🌟 Publish to Google Play (Internal Track)
      google_play:
        credentials: $GCP_SERVICE_ACCOUNT_CREDENTIALS # The JSON key variable
        track: internal
        
      # 🌟 Publish to App Store Connect / TestFlight
      app_store_connect:
        auth: integration # Corresponds to the integrated Apple account from the Dashboard
        submit_to_testflight: true
```

## Constraints
*   Prefer `codemagic.yaml` over the Codemagic UI workflow editor — keeping pipeline configuration in the repository alongside source code is the recommended "Infrastructure as Code" approach.
*   For teams already using Fastlane, Codemagic can still call `bundle exec fastlane <lane>` from its `scripts` block; the two tools are not mutually exclusive.
