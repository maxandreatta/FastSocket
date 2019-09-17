# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
## [2.1.0] - XXXX-XX-XX
### Added
- swift 5.1 support
- fastlane build .xcframework

## [2.0.0] - XXXX-XX-XX
### Added
- clean up code
- redesign of framing protocol
- cryptokit
- multi send and receive feature
- iOS 13+

### Removed
- common crypto
- no ios 12- support
- support for untrusted tls certs removed

## [Released]
## [1.1.0] - 2019-05-26
### Added
- clean up code
- renamed transportParameters to the original naming, to parameters

### Removed
- unnecessary usage of `self`

## [1.0.0] - 2019-05-18
### Added
- first public release
- stable interface
- new framing model -> content size instead of fin byte
- tls feature added
- more generic code
- maintenance and improved stability
- travis-ci
- codeclimate

### Removed
- circle-ci
- codecov

## [0.5.0] - 2019-05-07
### Added
- fully designed communication protocol
- basic feature set implemented
- first working client release
