fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### react_native_test

```sh
[bundle exec] fastlane react_native_test
```

Run React Native tests

### react_native_lint

```sh
[bundle exec] fastlane react_native_lint
```

Lint React Native code

### react_native_build_all

```sh
[bundle exec] fastlane react_native_build_all
```

Build both iOS and Android

### react_native_ci

```sh
[bundle exec] fastlane react_native_ci
```

Run full CI pipeline

----


## iOS

### ios test

```sh
[bundle exec] fastlane ios test
```

Run tests for iOS

### ios build

```sh
[bundle exec] fastlane ios build
```

Build iOS app

### ios ios_build

```sh
[bundle exec] fastlane ios ios_build
```



### ios archive

```sh
[bundle exec] fastlane ios archive
```

Build and archive iOS app

----


## Android

### android test

```sh
[bundle exec] fastlane android test
```

Run tests for Android

### android build

```sh
[bundle exec] fastlane android build
```

Build Android app

### android android_build

```sh
[bundle exec] fastlane android android_build
```



### android build_bundle

```sh
[bundle exec] fastlane android build_bundle
```

Build Android App Bundle

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
