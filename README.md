# MobileOne

Fisrt mobile app created by XPEHO

# Build status

![Build Android](https://github.com/XPEHO/MobileOne/workflows/Build%20Android/badge.svg)

![Build IOS](https://github.com/XPEHO/MobileOne/workflows/Build%20IOS/badge.svg)

# Design & wirframes

We choosed Figma to create, edit and share screens and design mockups

Please visit [Figma.com](https://www.figma.com/) for more information.

Note: You have to invited to the Figma project. Contact the project administrator to get an invitation.

# Patterns

## Router

We use named routes for screen navigation. More information on [router pattern here](https://flutter.dev/docs/cookbook/navigation/named-routes)

## Provider

Provider is used for data providing in screens. More information about [provider here](https://pub.dev/packages/provider)

# Internationalization

To translate any string in the app use the `getString(context, key)` method

# Tests

## Unit tests

To run unit test type `flutter test test/supported_test.dart` in a terminal

## Widget tests

To run integration test type `flutter test test/widget_test.dart` in a terminal

## Integration tests

To run integration test type `flutter drive --target=test_driver/app.dart` in a terminal

# CI/CD

We choosed `Github actions` for continuous integration/delivery

## Github actions infos

Please visit [Github actions page](https://github.com/features/actions) for more information.

All available actions can be found on the [Github Marketplace](https://github.com/marketplace?type=actions)

## Used actions in this project

[checkout](https://github.com/marketplace/actions/checkout)

[setup java](https://github.com/marketplace/actions/setup-java-jdk)

[flutter action](https://github.com/marketplace/actions/flutter-action)

[create a release](https://github.com/marketplace/actions/create-a-release)

[upload a release asset](https://github.com/marketplace/actions/upload-a-release-asset)