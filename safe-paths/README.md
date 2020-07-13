# Adventures of Scrypt, A Journey with SPM

This is a story of the trials and tribulations behind a feature request with regularly changing requirements.  An adventure I initially thought would be short lived rapidly evolved into an unpredictable journey.  Hopefully any of my experience may be of assistance to others or an enjoyable read at the very least.

```
TL;DR: As of July 12, 2020 Swift needs a better native Scrypt implementation.  If you plan on using SPM to bridge a C library and wrap it as a Swift module it might help to have XCode 11.4+ installed.  If XCode tells you "No Such Module", but you know it's there, evaluate your scheme.  More details in "The weird part" below.  Additionally I hope SPM gets better support for custom configurations outside of debug and release.
```

## The beginnings

One day I received this message: "I've given Mike/Alex no context so they probably have no idea what is gong on". 

Never has such a sentiment rang true.

I find out that an open source React Native application was under construction with the primary goal to assist the world in understanding their potential exposure to the Coronavirus.  The app relied heavily on background geo location, there was little to no UI, and it only came with a few user settings.  

**My task**: Assist the JavaScript side with a better mechanism to encrypt user location data.  More specifically I needed to generate [geohashes](https://www.movable-type.co.uk/scripts/geohash.html) from location coordinates, concatenate that hash with a timestamp from when the location data recorded, and put that String through the [Scrypt](https://en.wikipedia.org/wiki/Scrypt) hashing function.  This allows user location data to compared and be stored in a more secure manner.  Scrypt is specifically designed to be memory and time intensive to decrypt.  One thing to note; Scrypt is a "password-based key derivation function" but that became our data input parameter since we do not directly deal with passwords of any kind.

## Ready!

Out of the gate, a point was brought up that the hash calculation might be better done in one place.  Specifically use JavaScript to produce the output String required and send those across the bridge to the respective native platform.   This reduces any issue behind Android and iOS having differing implementations, and multiple dependencies.  It seemed like the perfect use case for the JS layer and we began building a bridged `saveLocation` method to pass the data from JS in to the existing encrypted Realm DB.  In no time at all the combined native and RN implementations were all setup and ready to go.  

## Until...

We come to find out the [RN library](https://github.com/mauron85/react-native-background-geolocation) for background geo locations keeps their own internal store of location data in a mySQLLite database.  This went against the entire purpose of having an encrypted Realm Storage solution in the first place and we are now forced to inject our own code into the location transform callback to prevent this from happening.  On both sides of the library there is code to check for the existence of location data and then there is an attempt to store it.  

The first idea that comes to mind: "okay let's make location `nil`".  Since the check in the library was explicitly comparing against `nil` this was a reasonable assumption. 

_TURNS OUT._ If we passed back a nil location in the transform, the react native location callback on the JS side will never be called!  From that point alone, the JS implementation was essentially useless now if we wanted to make sure that the mySQLite DB was not storing duplicate user data in its current insecure format.

## Back to the drawing board

At this point we've received word that it would be better to collect geohashes based on 8 cardinal directions approximately 10 meters surrounding a location coordinate along with a timestamp 5 minutes ahead and behind the current time from the location data poll.  With more data, we can deliver more accurate results of potential exposure.  The additional complexity was already conquered by the awesome JS developer which became a translation on the native side.

We had to pull in or implement a geohash natively.  I chose to go with [this implementation](https://github.com/nh7a/Geohash/blob/master/Sources/Geohash/Geohash.swift) and Android went with [this kotlin implementation](https://github.com/drfonfon/android-kotlin-geohash).  Getting the timestamps and calculating unique geohashes was a 1 line calculation.  By taking the unique geohashes and concatenating with the respective +/- 5 minute timestamps we had our "password" to hash using Scrypt. 

## SCRYPT

Scrypt has become a popular hashing function thanks to crypto currency.  "The scrypt algorithm was invented by Colin Percival as the cryptoprotection of the online service to keep the backup copies of UNIX-like OS. The working principle of the scrypt algorithm lies in the fact that it artificially complicates the selection of options to solve a cryptographic task by filling it with “noise”. This noise are randomly generated numbers to which the scrypt algorithm refers, increasing the work time."

Java has a great implementation of Scrypt within [Bouncy Castle](https://www.bouncycastle.org/) which became plug and play solution for the Android side.  But here's where things get super interesting on the Swift side.  The first thing that comes to mind is Apple's CommonCrypto, [CryptoKit](https://developer.apple.com/documentation/cryptokit), or [swift-crypto](https://github.com/apple/swift-crypto), but none of those libraries have a Scrypt implementation.  So I turned to github search and found that in Swift we have 7 options for Scyrpt. One option is the ever popular [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift).   It's easily accessible through cocoapods and has been around since Swift's beginnings.  And would you look at that, it has a [scrypt implementation](https://cryptoswift.io/)!  

This will be awesome, just pull in the pod, import the module, test it out.  Done. 

## OH No You Don't

I found out that 3 hashes with an N value of 2^12 = 16384 took around 290+ seconds.  Since we take time intervals of 5 minutes at a time and this slammed the CPU to max usage it was not a suitable situation to say the least.

After reading the libraries README I found out that `It is recommended to enable Whole-Module Optimization to gain better performance. Non-optimized build results in significantly worse performance.` Okay Cool! There's a chance! And I was starting to see significant speed enhancements.  

The hash function with this new optimization mode was running at least 2x as fast.  Quickly my hope dwindled, this performance gain is significant, but it will not be sufficient enough for this project. The long standing issue that comes with this library in particular has been around since [2015](https://github.com/krzyzanowskim/CryptoSwift/issues/30). Swift just hasn't reached a point where it can come close to the performance of C libraries for the more intensive encryption algorithms.

## What to do now?

I went back to the library search on github and found a repo called [swift-scrypt](https://github.com/greymass/swift-scrypt) a Swift Package Managed bridge between [libscrypt](https://github.com/technion/libscrypt) with swift bindings.  This was too good to be true!  I fired up XCode 11.4, used the awesome new SPM integrations and got everything working in a demo project.  Shout out to [jnordberg](https://github.com/jnordberg) for originally creating the repo.  

Back on the main project, I scrapped my branch and started over.  I pulled in this new swift package and got everything to build.  I implemented all the requirements and was stored the new hashes in a List on the existing Realm Location object.  Fun fact, if you're adding a new property to an existing object in Realm you need to increase the schema version and provide an empty migration block for it to do all of its _magic_. 

Anyways, it was working! Information was being stored perfectly, retrieval was flawless, and ALL the tests passed!

## It was time.

I submitted a new PR with the newly added Native implementation and things were looking great! 

Thennnn the build machine told me that it couldn't retrieve the SPM library AND therefore refused to compile.  BUT WHY!? _It all worked on my machine!_

At this point I had my friend [Tin](https://github.com/tindn) pull down my code and try to run it on his computer.  To my delighted surprise he was unable to fetch the dependency as well.  Further investigation lead us to understand that we needed to degrade the swift-tools-version to 5.1 from 5.2, and thus a [fork was born](https://github.com/MichaelNeas/swift-scrypt).  

Now Tin and I can both fetch the dependency, we both can build the app, okay lets update the PR!

The build machine gets the change and would you look at that, the new dependency was fetched successfully and the project was built!

Little did I know, there was another hurdle barreling down towards me.

## XCTEST

The safe paths project has tons of build automation with github workflows, fastlane, and other modern tooling to ensure new features and bug fixes are seamlessly integrated into the existing system.

The build machine begins to compile the project in order to kick off the Unit Tests.  And guess what happened.

`No such module 'libscrypt'`

**WHYYYY**, the saving grace of libscrypt has turned against me in the test suite on the remote machine!

Everything was linked up and ran just fine in my version of XCode, surely this has to be a build machine issue.

After thinking long and hard, I do what any developer does and turn to the internet for a solution to my problems.

I asked everyone I knew, went to every slack channel I could find.  No avail.

I noticed that Tin and I had different XCode versions before with the swift-tools-version issue, maybe this was the root of my issue?  A buddy suggested I download the older version of XCode and try to reproduce the issue.  To my astonishment libscrypt was unable to be found in XCode 11.3! 

## The weird part

If I changed **ANY** build setting the test target would successfully compile.  It was only upon closing and reopening XCode that I was made aware that the compiler had no idea where the library was.  I started changing up a whole plethora of XCode build settings.  I tried directly pointing to the modulemap SPM file, changing up orders of execution, copying over differences from the App target, read through just about every setting, and **NOTHING**.  I read through pages of issues on reddit, swift forums, stack overflow, github issues.  I was just about done with this problem.

I was ready to give up on my SPM dreams and go back to the old way of bridging to C files.  This would require an explicit bridging header and copying a whole mess of files.  But with a stroke of luck I stumbled on this [wonderful issue](https://github.com/apple/swift-nio/issues/1128) in the swift-nio project.

[Ankit Aggarwal](https://github.com/aciidb0mb3r) is a founding father of Swift Package Manager, and he suggested `Add -Xcc -fmodule-map-file=$(PROJECT_TEMP_ROOT)/GeneratedModuleMaps/macosx/<missing module name>.modulemap to OTHER_SWIFT_FLAGS in the test target.` This worked like a charm in the demo project from earlier.  However it was not beneficial to the safe paths project in building the tests.  I scroll down further, reading more comments, and BOOM [Jared Sinclair](https://github.com/jaredsinclair) ran in to the EXACT same issue as me.

```
I've run into this on several similar projects, with Swift Packages that contain clang submodules to expose code to the parent Swift module. I've found a workaround that fixes this, at least as of Xcode 11.3.1:

    In your unit or UI test target, add the parent module (the Swift Package library) to the linked libraries build phase, even if that test target doesn't use it directly.

    Sometimes Required If you are also using an Xcode scheme that's pointed at a unit or UI test target, make sure that the "Build" section of the scheme editor includes the application target in that list. By default, if you add a new Xcode scheme for, e.g., a UI test target, the app won't be included there and so it isn't built properly.

In all reproduced cases, the underlying error is a missing -fmodule-map-file flag for the clang submodule (MyLibrary.MySubmodule) emitted from the compile command for any file in the app target that has an import MyLibrary statement.
```

I tried the first step only and the project BUILT and ran the tests!  But if we remember from before, the project always built after modifying the xcode settings.  I then brought in the second step and it actually worked! I jumped for joy! Everything built and ran on my machine, I quickly sent up the PR and after a significant amount of time testing and building different targets we were looking ready! 

## I Hit Another issue

Seems like the unit tests for realm storage were throwing `EXC_BAD_ACCESS` when attempting to store anything in the DB.  Oh no, I caused a regression.  Was it from adding the hash property?  Was this C library some how messing everything up?  It was all working before!

Now that I knew how to get the project working with SPM and a C library I began rebuilding the project off develop.  I tested the Realm tests every step of the way.  Nothing was breaking and I slowly added back all functionality from my original PR.  Time came to add back the scrypt-swift project and though I was nervous, I was ready for this journey to be completed.  I added it, and it everything worked perfectly!  

Back to the unit tests.  I was referencing a class somewhere else in the project for a static time variable for the timestamp.  That class I was referencing became required to kick off the unit tests for my new functionality.  I added the Secure Storage file, which included the Realm Storage singleton to the test target and BOOOM the crash happened again! Seemed like the Test Realm instance and the singleton were colliding during the runtime phase of testing.  I removed the files membership, pointed to a different static property, and we were back on the rails again.

## UNTIL

A [BUILD CONFIGURATION issue](https://forums.swift.org/t/cannot-using-spm-module-with-some-custom-configuration-not-debug-release-on-xcode-11/26412) arrived with using SPM in XCode 11 with different build configurations.   At this point I had to make a decision to hack in a weird solution to incorporate all the react native cocoapods for staging but still maintain Debug/Release configuration for the SPM Scrypt project.  

At this moment I realized SPM was just not going to cut it.  I love SPM but it's just too new to throw into a project like this.  I removed all the integration and work done before.  I added in the libscrypt library with a header pointing directly to C files and kept the Swift wrapper around the library.  I posted the new PR and all the build steps were kicked off and completed successfully.

## In the end

Later we were able use a different React Native Background Geolocation library and upgrade the XCode version in the build pipeline.  This allowed us to revert back to having the JS side implement the hashing or bring back SPM.

Nevertheless, effort is never wasted, this project was enjoyable to take on and I learned so much.  I was able to work along side incredibly smart and talented individuals.  The endorphans after getting everything connected, working properly, and seeing all green lights across the test suite keeps me in the business.  If you're interested in contributing to the project, the open source repo can be found [here](https://github.com/Path-Check/covid-safe-paths).  I hope this story provides a small insight on working with rapidly changing requirements and utilizing bleeding edge Swift/XCode features.