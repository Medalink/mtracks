# Changelog

All notable changes to MTracks will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- BigWigsMods packager setup for automated releases
- GitHub Actions workflow for CurseForge, Wago, and WoWInterface distribution
- Project metadata for distribution platforms

## [1.0.0] - 2025-01-08

### Added

- Initial release of MTracks
- LFG application tracking system
- Character and account-wide statistics
- Modern UI with styled logo system
- Minimap integration with LibDBIcon
- Per-character data persistence with AceDB
- Comprehensive application status tracking (Applied, Invited, Declined, Cancelled, etc.)
- Success rate calculations and performance metrics
- Clean, responsive interface design
- Console commands and slash command support
- Automated event handling for LFG system integration

### Features

- **Application History**: Complete tracking of all LFG applications
- **Success Rates**: Monitor acceptance and decline rates
- **Character Statistics**: Per-character and account-wide analytics
- **Activity Timeline**: Track when you last applied for groups
- **Status Tracking**: Support for all LFG application statuses
- **Modern UI**: Clean, professional design with color-coded data
- **Logo System**: Beautiful gradient text logo creation system
- **Database Management**: Persistent data storage across sessions
- **Performance Optimized**: Efficient event handling and data management

### Technical

- Built on Ace3 framework for reliability and performance
- LibDataBroker and LibDBIcon integration for minimap support
- Comprehensive error handling and data validation
- Modular code structure for maintainability
- Full compatibility with World of Warcraft 11.0.2.55665

[Unreleased]: https://github.com/Medalink/MTracks/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/Medalink/MTracks/releases/tag/v1.0.0
