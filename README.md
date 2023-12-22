# ssl-certificates-check-ios

[![Test](https://github.com/nnsnodnb/ssl-certificates-check-ios/actions/workflows/test.yml/badge.svg)](https://github.com/nnsnodnb/ssl-certificates-check-ios/actions/workflows/test.yml)
[![AdHoc](https://github.com/nnsnodnb/ssl-certificates-check-ios/actions/workflows/adhoc.yml/badge.svg)](https://github.com/nnsnodnb/ssl-certificates-check-ios/actions/workflows/adhoc.yml)
[![AppStore](https://github.com/nnsnodnb/ssl-certificates-check-ios/actions/workflows/appstore.yml/badge.svg)](https://github.com/nnsnodnb/ssl-certificates-check-ios/actions/workflows/appstore.yml)

TLS/SSL Certificates check for iOS

## Environment

### Xcode

```bash
$ xcodebuild -version
Xcode 15.1
Build version 15C65
```

### Ruby

```bash
$ ruby -v
ruby 3.2.2 (2023-03-30 revision e51014f9c0) [arm64-darwin22]
```

## Setup

```bash
$ git clone git@github.com:nnsnodnb/ssl-certificates-check-ios.git
$ cd ssl-certificates-check-ios
$ xed .
```

Then change scheme to `Develop` and build and run.

## Let's try

<img alt="App Clip Code" src="https://github.com/nnsnodnb/ssl-certificates-check-ios/assets/9856514/ff284178-a2f9-488a-92f4-b29107e90132" width="400px">

## Bump version

Please edit MARKETING_VERSION of `update_app_version` in `fastlane/Fastfile`.

```bash
$ bundle exec fastlane update_app_version
```

## License

This software is licensed under the MIT license (See [LICENSE](LICENSE)).
