# MobileOne Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2020-04-01
### Added

- Google authentication
- Sign out method
- Add main screen navigation
- Login/password registration
- Login/password authentication
- Add profile page
- Add verification email
- Add password reset
- Add login Skip
- Add page step one for sharing a list
- Add page step two for sharing a list
- Add page for a big loyalty card
- Add loyalty cards deletion
- Add password changing
- Add item picked picture
- Add Logo
- Add voice recognition

### Changed

- Update share page
- Update loyalty cards page to create new loyalty cards
- Update profile page : change profile picture from Gallery
- Update Mainpage : change profile picture by tacking picture from Camera
- Update openedListPage : User can now scan item to get items informations
- Update openedListPage : User can now validate an item
- Update openedListPage : User can now change a wishlist name
- Update ItemPage : Item popup is now a complete page
- Update OpenedListPage : User can now leave a shared wishlist
- Update openedListPage : User can see the progress indicor when check items
- Update Global Ui

### Deprecated

- ...

### Removed

- ...

### Fixed

- Google authentication on iOS
- openedListPage : Connect share menu to the share process
- Share : Clic on list in share section should not open the list
- Share one  and share two : Contact loader missing / Filter Contacts / Cannot specify an unknown email
- lists : Guest cannot see shared wishlists
- openedListPage : Open old wishlists
- Item Popup : Modify an item created in a different language
- Widget_share_contact : contact name overflow
- Create_list : wishlist creation screen overflow
- Authentication-page : Account creation page not scrollable
- Loyalty Cards Page : Changed floating button icon
- Widget_item : Product designation overflow
- Share_one and Mainpage : Wishlist share process indicator visible on short process
- Card_page : Big loyalty card render problem
- Loyalty Cards Page : User can now scan different barcode types
- Loyalty Cards Page : Cancel a card creation don't create cards anymore
- Widget loyaltycards : Loyalty card name too short
- New_profile_page : change profile page ui
- New_profile_page : Account validation status 
- Changing password : User can now change his password without reconnecting
- Account deletion : User data is now deleted on account deletion
- Loyatly_card : Loyalty cards page bottom padding
- Item popup : Item image isn't erased anymore on item changes
- fr.json : Wrong password typo on the French connection page
- OpenedListPage : An infinite loading message is no longer displayed on an empty wishlist
- Rotation : User can no longer change the screen rotation
- New_list : Empty main screen
- target sdk is outdated
- OpenedListPage : Screen don't blink anymore on item creation/deletion
- Analytics tags
- New_profile : user avatar is oval
- Share-one and widget_share_contact : Ugly contact selection Widget
- Authentication_page : User can't go back to the authentication page if he is connected
- OpenedListPage : Screen don't overflow anymore on wishlist name changing
- openedListPage : Ugly padding in wishlist screen
- Picture : Item picture is now deleted from the storage on the item deletion/modification

### Security

- ...

[Unreleased]: https://github.com/XPEHO/MobileOne/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/XPEHO/MobileOne/compare/v1.0.0...v1.1.0
[0.0.1]: https://github.com/XPEHO/MobileOne/releases/tag/v0.0.1