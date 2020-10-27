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
- Add filter list
- Add Choose Loyalty card color
- Add Feedbcack
- Add sort items
- Add restart wishlist button
- Add email/password verification on account deletion
- Add about screen
- Add notifications
- Add pull to refresh
- Add settings page
- Add recipes
- Add possiblity to add a recipe to a list
- Add choose wishlist color
- Add user can now save a picture
- Add owner picture on shared list
- Add invitation email on inexistent user
- Add fingerprint authentication
- Add wishlists categories
- Add wishlist progression
- Add new units for items
- Add sort wishlists
- Add tutorial

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
- Update Lists ui
- Update OpenedListPage : User can now click on an item
- Update item page
- Update user can now rename a wishlist and a recipe with a rename button
- Update a text is now displayed if the list is shared with nobody

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
- Picture : Item picture is now stored smaller
- Password : User can now see the password he his typing
- Progress_bar : Progress bar value error
- openedListPage and new_list : change ui 
- list Creation : User don't have to use the creation list page to create a list anymore
- user must validate his account before access to the app
- Authentication path : The path to the authentication page is now /authentication
- Empty loyaltycards screen
- Voice recognition : The microphone can now listen to international words
- Set the share deletion button icon to a material design icon
- Email/password : The autocorrect is now disabled on email and password texts
- reduce the writing size of the navigation bar
- Optimise Big loyalty card
- "my shares " title is not on appbar 
- LoyaltyCards : User can now validate the loyalty card name changes 
- Fixed app name
- Shared contacts : User can now see all the contacts of a shared list
- LoyaltyCards : The big card don't rotate on card opening
- MainPage : Bottom floating action button background is now green on app start
- Fixed about screen
- Items sort : The items in a list are now sorted alphabeti
- New account : A new account can now create a wishlist and share it
- Authentication : user now have error messages on authentication/registration
- Account : User recipes and messagin token are now deleted on user account deletion
- Loyalty cards : user can now click on the whole card to open the big card
- Color : don't use different blue anymore
- Google auth : temporarily disable google auth button
- Color : colors are not pastel anymore
- UI : fixed too big screens
- Pull to refresh : messages are now translated
- Share contact : User can now have contacts without a name
- Accessibility : text size can't be modified by the phone settings anymore
- Profile page : Email will be displayed only one time if there is no displayname
- Mainpage : share page title is not displayed anymore
- Analytics : Added new analytics
- Wishlist color : wishslist color is now fixed on a new wishlist
- Item image : items with old images now have an icon
- Camera : fixed error on camera cancel
- Sort : fixed tolowercase error
- iOS : fixed copy/paste menu
- Voice recognition : user can now use voice recognition on iOS
- Scan : The item label is now set when a barcode is scanned
- Progression : user can now see the progress bar
- Tabbar : lists menu tabbar is now bigger
- Quantity : a message is now displayed if the quantity of an item is set to 0
- Item creation : user can now create new items and define the properties

### Security

- ...

[Unreleased]: https://github.com/XPEHO/MobileOne/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/XPEHO/MobileOne/compare/v1.0.0...v1.1.0
[0.0.1]: https://github.com/XPEHO/MobileOne/releases/tag/v0.0.1