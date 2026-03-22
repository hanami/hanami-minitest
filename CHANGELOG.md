# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Break Versioning](https://www.taoensso.com/break-versioning).

## [Unreleased]

### Added

- Initial release
- Minitest setup as part of `hanami install`, and test file generation with `hanami generate slice`, `hanami generate action`, and `hanami generate part`
- `RequestTest` base class for request tests using Rack::Test
- `FeatureTest` base class for feature tests using Capybara
- Database cleaning support via database_cleaner-sequel for tests that include `TestSupport::DB`
- Operations testing support with Dry::Monads helpers
- Rake tasks for running minitest
- Test helper generation with proper Hanami app bootstrapping
- Support files for minitest configuration, database handling, features, operations, and requests

### Changed

### Deprecated

### Removed

### Fixed

### Security

[Unreleased]: https://github.com/hanami/hanami-minitest
