# ssl-certificates-check-ios

[![Test](https://github.com/nnsnodnb/ssl-certificates-check-ios/actions/workflows/test.yml/badge.svg)](https://github.com/nnsnodnb/ssl-certificates-check-ios/actions/workflows/test.yml)
[![AdHoc](https://github.com/nnsnodnb/ssl-certificates-check-ios/actions/workflows/adhoc.yml/badge.svg)](https://github.com/nnsnodnb/ssl-certificates-check-ios/actions/workflows/adhoc.yml)
[![AppStore](https://github.com/nnsnodnb/ssl-certificates-check-ios/actions/workflows/appstore.yml/badge.svg)](https://github.com/nnsnodnb/ssl-certificates-check-ios/actions/workflows/appstore.yml)

TLS/SSL Certificates check for iOS

## Environment

### Xcode

```bash
$ xcodebuild -version
Xcode 26.6
Build version 17F113
```

### Ruby

```bash
$ ruby -v
ruby 4.0.6 (2026-07-14 revision 03b6d3f889) +PRISM [arm64-darwin25]
```

## Setup

```bash
$ git clone git@github.com:nnsnodnb/ssl-certificates-check-ios.git
$ cd ssl-certificates-check-ios
$ xed .
```

Then change scheme to `Develop` and build and run.

## Bump version

Please edit MARKETING_VERSION of `update_app_version` in `fastlane/Fastfile`.

```bash
$ bundle exec fastlane update_app_version
```

## License

This software is licensed under the MIT license (See [LICENSE](LICENSE)).
