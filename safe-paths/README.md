# COVID Safe Paths



## The beginnings

Get information about some help needed on this new open source project.  Find out it's a react native application and there was a requirement for Scrypt hashing the location coordinates geohashes and timestamps in order to provide more secure location data.

## A change

From there the Android side of the house brought up a good point that the hash calculation might be better done in one place on the JS side.  So we start building the bridge and hooks into the secure Realm DB.  The JS side got the implementation all setup and ready to go.  When we find out the [RN library](https://github.com/mauron85/react-native-background-geolocation) for background locations keeps their own internal store of location data in a mySQLLite DB. And we are forced to inject our own code into the transform to prevent this from happening.  On both sides of the house the code checks for the existance of location data and then tries to store it.  SO we were like, "okay let's make it nil" TURNS OUT. That if you make it nil the location callback on the JS side stops getting called.  From there the JS implementation was essentially useless if we wanted to make sure that the mySQLite DB was not storing people's data in an unsecure manor.


## Back to the drawing board

At this point we've received new requirements that it would be better to collect geohashes based on the 8 cardinal directions, with a time 5 minutes ahead and behind the current timestamp in the location data.  The additional complexity was already conquered by the awesome JS developer so it was just a translation for the native side.  We just had to pull in or implement a geohash natively.  I chose to go with [this implementation](https://github.com/nh7a/Geohash/blob/master/Sources/Geohash/Geohash.swift) and Android went with [this kotlin implementation](https://github.com/drfonfon/android-kotlin-geohash).  Getting the timestamps and calculating unique geohashes was no problem.  This became the "password" we were going to hash using Scrypt.  By taking the unique geohashes and concatenating with the respective timestamps.

## SCRYPT

Here's were things get super interesting on the Swift side.  Java has this great implementation of Scrypt called [Bouncy Castle](https://www.bouncycastle.org/) so it was really a plug and play situation for that side.  IN SWIFT we have 7 options that show up in github search.  The first thing that comes to mind is apple's CommonCrypto, [CryptoKit](https://developer.apple.com/documentation/cryptokit), or [swift-crypto](https://github.com/apple/swift-crypto). Rats they don't have an Scrypt implementation, why not use [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift)?  Since that's the major crypto library I know of in Swift, and it's easily accessible through cocoapods and has been around since Swift's beginnings.  AND it has a [scrypt implementation](https://cryptoswift.io/).  This will be awesome just hook it up and test it out and I come to find that 3 hashes with an N value of 2^12 = 16384 took around 290+ seconds. Since we take time intervals of 5 minutes at a time and this was basically max CPU usage it was not a suitable situation to say the least.

After reading the libraries readme there's a suggestion `It is recommended to enable Whole-Module Optimization to gain better performance. Non-optimized build results in significantly worse performance.` Okay Cool! There's a chance! And I was seeing significant speed enhancements.  The one issue that seems to come with this library has been around since [2015](https://github.com/krzyzanowskim/CryptoSwift/issues/30) Swift hasn't reached a point where it can come close to the speed of C libraries, and the speed enhancements only seemed to half.  Back to the drawing board.

I noticed in the library search of github this repo called [swift-scrypt](https://github.com/greymass/swift-scrypt) a Swift Package Manager bridge between [libscrypt](https://github.com/technion/libscrypt) with swift bindings.  This was too good to be true!  I fired up XCode 11.4, used the awesome new SPM integrations and got everything working in a demo project.  Shout out to [jnordberg](https://github.com/jnordberg) for originally creating the repo.  

So back to the SafePaths project, I scrapped everything and started over.  Pulled in this new swift package and got everything to build.  Implemented all the requirements and was storing them in a new List on the existing Realm Location object.  Fun fact, if you're adding a new property to an existing object in Realm you need to increase the schema Version and provide an empty migration block for it to do all it's magic.  Anywho, everything was working, storing information perfectly, retrieval worked, all the tests passed!

It was time.

I submitted a new PR with all the newly added Native implementation.  Things were looking great! Thennnnnnnn the build machine told me it couldn't retrieve the SPM library AND therefore refused to compile.  BUT WHY!? It all worked on my machine!

At this point I had my friend [Tin](https://github.com/tindn) pull down my code and try to run it on his machine.  Turns out he was unable to fetch the dependency as well. CURIOUS. Turns out we needed to degrade the swift-tools-version to 5.1 from 5.2, and thus a [fork was born](https://github.com/MichaelNeas/swift-scrypt).  Okay Tin can fetch the dependency, I can fetch the dependency, we both can build the app, okay lets update the PR!

Build machine gets the change and would you look at that, it can also fetch the new dependency AND build the project!

There was another hurdle coming barreling down.

XCTEST

I am a big fan of tests, and the safe paths project has a lot of build automization with github workflows, fastlane, and other cool tools to make sure new features and bug fixes and seemlessly integrate into the existing system.

Anyways, the build machine begins to compile the project in order to begin the Unit Tests.  And would you guess what happened?? `No such module 'libscrypt'`. 

WHYYYY, the saving grace of libscrypt has turned against me in the Test Suite!

Everything was linked up and ran just fine in my version of XCode, surely this has to be a build machine issue.  Haha.

I go scouring across the internet looking for a solution to my problem. I asked everyone i knew, and went to every slack channel i could find.  But no avail.

I noticed that Tin and I had different XCode versions before with the swift-tools-version issue, maybe this was the root of my issue?  Jorge suggested I download the older version of XCode and try to reproduce the issue.  And would you guess, yep, libscrypt was unable to be found.  

The weird part, if I went and changed ANY build setting the test target would successfully compile.  It is only upon closing XCode and reopening that I was made aware that it had no idea where the library was.  So from there I began changing up a whole plethora of XCode build settings.  I tried directly pointing to the modulemap file, changing up order of execution, copying over differences from the App target that may lead to the solution, but NOTHING.  I read through pages of issues on reddit, swift forums, stack overflow, github issues.  I was just about done with this problem.  Ready to give up and go back to an older way of using C files without using SPM but an explicit bridging header when I stumbled on this [wonderful issue](https://github.com/apple/swift-nio/issues/1128) on the swift-nio project.

[Ankit Aggarwal](https://github.com/aciidb0mb3r) is a founding father of Swift Package Manager, and he suggests `Add -Xcc -fmodule-map-file=$(PROJECT_TEMP_ROOT)/GeneratedModuleMaps/macosx/<missing module name>.modulemap to OTHER_SWIFT_FLAGS in the test target.` Which worked like a fricken charm in the demo project from earlier.  But was not beneficial to the safe paths project building the tests.  Scroll down, read more and BOOM [Jared Sinclair](https://github.com/jaredsinclair) ran in to the EXACT same issue as me.

```
I've run into this on several similar projects, with Swift Packages that contain clang submodules to expose code to the parent Swift module. I've found a workaround that fixes this, at least as of Xcode 11.3.1:

    In your unit or UI test target, add the parent module (the Swift Package library) to the linked libraries build phase, even if that test target doesn't use it directly.

    Sometimes Required If you are also using an Xcode scheme that's pointed at a unit or UI test target, make sure that the "Build" section of the scheme editor includes the application target in that list. By default, if you add a new Xcode scheme for, e.g., a UI test target, the app won't be included there and so it isn't built properly.

In all reproduced cases, the underlying error is a missing -fmodule-map-file flag for the clang submodule (MyLibrary.MySubmodule) emitted from the compile command for any file in the app target that has an import MyLibrary statement.
```

I tried the first step only and the project BUILT!  But if we remember from before, the project always builds modifying the xcode settings.  So then I had to bring in the second step and would you know.  It actually worked!!! I jumped for joy, it all builds on my machine, sent up the PR and after a significant amount of time testing and building different targets things were looking great! 

Until I hit my final issue.

Seems like the unit tests for realm storage were throwing `EXC_BAD_ACCESS` when attempting to store anything in the DB.  Oh no, I cause a regression some how! Was it from adding the hash property?  Was this C library messing everything up some how?  It was all working before!

So now that I knew how to get the project working with SPM and a clibrary i started rebuilding the project off develop.  Testing the Realm tests every step of the way.  Nothing was breaking and I was slowly adding back all functionality.  It got time to add back the scrypt-swift project and I was nervous but ready for this thing to be completed.  I added it, and it all worked perfectly!  Then came time for the unit tests.  Now i was referencing a class somewhere else for a static time variable and that class became required to kick off the unit tests for my new functionality.  I clicked add to test target on the Realm Storage singleton and BOOOM the crash happened again! Seemed like the Test Realm instance and the singleton were getting mixed up during the testing.  So I pointed to a different static, removed the test membership, and we were off to the races again.

## UNTIL

A BUILD CONFIGURATION [issue](https://forums.swift.org/t/cannot-using-spm-module-with-some-custom-configuration-not-debug-release-on-xcode-11/26412) arrives with using SPM in XCode 11 with different configurations.   At this point had to make a decision to hack in a weird solution to incorporate all the react native cocoapods for staging but yet maintain Debug/Release configuration for the SPM Scrypt project.  And it was at this moment I realized SPM was just not going to cut it.   I love SPM but it's just too new to throw into a project like this.  I removed all the integration and work done before and added in the libscrypt c library with a header pointing directly to C.  Kept a Swift wrapper around the library and everything worked as expected. 


## In the end

This project was super fun to work on and I learned a ton.  Though the struggle was real, getting everything hooked up and working properly, the feeling of seeing all working tests passing might be my favorite feeling in the whole world.  If you're interested in joining the development the open source repo can be found [here](https://github.com/Path-Check/covid-safe-paths)