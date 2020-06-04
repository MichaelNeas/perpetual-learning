# Adventures of Scrypt, A Journey with SPM

This is a story about the trials and tribulations of a feature request with regularly changing requirements, that ended up teaching me more than I could bargain for.  Hopefully any of this experience may be of assistance to others or an enjoyable read at the very least.

## The beginnings

One day I received a message: "i've given Mike/Tambet no context so they probably have no idea what is gong on". Never has a sentiment ever been so spot on.  I come to find out that new open source React Native application was under construction with the goal to help out the world with understanding their potential exposure to the corona virus.  The app relied heavily on background geo location, there was little to no UI at the time and a few settings.  

My task: Assist the JS side with a better mechanism to encrypt user location data.  More specifically I was to generate [geohashes](https://www.movable-type.co.uk/scripts/geohash.html) from location coordinates, concatenate that hash with the timestamp relating to when the data was produced and finally put that String through a [Scrypt](https://en.wikipedia.org/wiki/Scrypt) hashing function in order to provide more secure comparison of location data.

## Ready!

From there the Android side of the house brought up a good point.  The hash calculation might be better done in one place, with the same functions producing the output String on the JS side.  This would reduce any issue behind Android and iOS having differing implementations.  It seems like the perfect use case for the JS layer and we start building a bridged `saveLocation` method to pass the data into an existing secure Realm DB.  In no time at all the combined native and RN implementations were all setup and ready to go. Until...  

## First Hurdle

We come to find out the [RN library](https://github.com/mauron85/react-native-background-geolocation) for background geo locations keeps their own internal store of location data in a mySQLLite DB.  This went against the entire purpose of having an encrypted Realm Storage solution in the first place and we are now forced to inject our own code into the location transform callback to prevent this from happening.  On both sides of the library there is code to check for the existence of location data and then tries to store it.  SO first idea that comes to mind, "okay let's make it nil".  Since the check in the library was explicitly comparing against `nil` this was a reasonable assumption. 

TURNS OUT. That if we passed back a nil location in the transform, the react native location callback on the JS side will never be called!  From that point alone, the JS implementation was essentially useless now if we wanted to make sure that the mySQLite DB was not storing user data in it's currently insecure manor.

## Back to the drawing board

At this point we've also received the word that it would be better to collect geohashes based on 8 cardinal directions approximately 10 meters surrounds a location coordinate along with a timestamp 5 minutes ahead and behind the current time from the location data.  The additional complexity was already conquered by the awesome JS developer so it was became a translation on the native side.  We had to pull in or implement a geohash natively.  I chose to go with [this implementation](https://github.com/nh7a/Geohash/blob/master/Sources/Geohash/Geohash.swift) and Android went with [this kotlin implementation](https://github.com/drfonfon/android-kotlin-geohash).  Getting the timestamps and calculating unique geohashes was a 1 line calculation.  By taking the unique geohashes and concatenating with the respective +/- 5 minute timestamps we had our "password" to hash using Scrypt. 

## SCRYPT

Scrypt has become a popular hashing function thanks to crypto currency.  "The scrypt algorithm was invented by Colin Percival as the cryptoprotection of the online service to keep the backup copies of UNIX-like OS. The working principle of the scrypt algorithm lies in the fact that it artificially complicates the selection of options to solve a cryptographic task by filling it with “noise”. This noise are randomly generated numbers to which the scrypt algorithm refers, increasing the work time."

Java has this great implementation of Scrypt called [Bouncy Castle](https://www.bouncycastle.org/) so it was really a plug and play situation for that side.  Here's where things get super interesting on the Swift side.  IN SWIFT we have 7 options that show up in github search.  The first thing that comes to mind is apple's CommonCrypto, [CryptoKit](https://developer.apple.com/documentation/cryptokit), or [swift-crypto](https://github.com/apple/swift-crypto), but they don't have an Scrypt implementation. So why not use [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift)?  It's one of the most popular crypto library I know of in Swift, it's easily accessible through cocoapods, and has been around since Swift's beginnings.  Not to mention it has a [scrypt implementation](https://cryptoswift.io/)!  This will be awesome, just hook it up, test it out.  Done. 


## OH No You Don't

I come to find that 3 hashes with an N value of 2^12 = 16384 took around 290+ seconds. Since we take time intervals of 5 minutes at a time and this slammed the phone CPU to max usage it was not a suitable situation to say the least.

After reading the libraries Readme there revealed a suggestion `It is recommended to enable Whole-Module Optimization to gain better performance. Non-optimized build results in significantly worse performance.` Okay Cool! There's a chance! And I was seeing significant speed enhancements.  The one issue that seems to come with this library has been around since [2015](https://github.com/krzyzanowskim/CryptoSwift/issues/30) Swift hasn't reached a point where it can come close to the speed of C libraries, and the speed enhancements only seemed to half.  


## What to do now?

I went back to the library search on github and found a repo called [swift-scrypt](https://github.com/greymass/swift-scrypt) a Swift Package Managed bridge between [libscrypt](https://github.com/technion/libscrypt) with swift bindings.  This was too good to be true!  I fired up XCode 11.4, used the awesome new SPM integrations and got everything working in a demo project.  Shout out to [jnordberg](https://github.com/jnordberg) for originally creating the repo.  

Back on the main project, I scrapped everything and started over.  I pulled in this new swift package and got everything to build.  Implemented all the requirements and was storing them in a new List on the existing Realm Location object.  Fun fact, if you're adding a new property to an existing object in Realm you need to increase the schema Version and provide an empty migration block for it to do all it's magic.  Any who, everything was working, storing information perfectly, retrieval worked, and all the tests passed!

## It was time.

I submitted a new PR with all the newly added Native implementation.  Things were looking great! 

Thennnn the build machine told me it couldn't retrieve the SPM library AND therefore refused to compile.  BUT WHY!? It all worked on my machine!

At this point I had my friend [Tin](https://github.com/tindn) pull down my code and try to run it on his machine.  Turns out he was unable to fetch the dependency as well. CURIOUS. Turns out we needed to degrade the swift-tools-version to 5.1 from 5.2, and thus a [fork was born](https://github.com/MichaelNeas/swift-scrypt).  Now Tin and I can both fetch the dependency, we both can build the app, okay lets update the PR!

Build machine gets the change and would you look at that, it can also fetch the new dependency AND build the project!

Little did I know, there was another hurdle coming barreling down.

## XCTEST

Firstly, I am a big fan of tests and the safe paths project has a lot of build automation with github workflows, fastlane, and other modern tooling to ensure new features and bug fixes are seamlessly integrated into the existing system.

The build machine begins to compile the project in order to begin the Unit Tests.  And would you guess what happened?? `No such module 'libscrypt'`. 

**WHYYYY**, the saving grace of libscrypt has turned against me in the Test Suite on the remote machine!

Everything was linked up and ran just fine in my version of XCode, surely this has to be a build machine issue. Haha.

I think long and hard, then go scouring across the internet looking for a solution to my problem. I asked everyone I knew, and went to every slack channel I could find.  No avail.

I noticed that Tin and I had different XCode versions before with the swift-tools-version issue, maybe this was the root of my issue?  A buddy Jorge suggested I download the older version of XCode and try to reproduce the issue.  And would you guess, libscrypt was unable to be found in XCode 11.3! 

## The weird part

If I changed _ANY_ build setting the test target would successfully compile.  It was only upon closing XCode and reopening that I was made aware that the compiler had no idea where the library was.  From there I took off changing up a whole plethora of XCode build settings.  I tried directly pointing to the modulemap SPM file, changing up orders of execution, copying over differences from the App target, read through just about every setting, and **NOTHING**.  I read through pages of issues on reddit, swift forums, stack overflow, github issues.  I was just about done with this problem.  

At this point I was ready to give up and go back to an older way of using C files without using SPM.  This would require an explicit bridging header and copying a whole mess of files.  Then I stumbled on this [wonderful issue](https://github.com/apple/swift-nio/issues/1128) on the swift-nio project.

[Ankit Aggarwal](https://github.com/aciidb0mb3r) is a founding father of Swift Package Manager, and he suggested `Add -Xcc -fmodule-map-file=$(PROJECT_TEMP_ROOT)/GeneratedModuleMaps/macosx/<missing module name>.modulemap to OTHER_SWIFT_FLAGS in the test target.` Which worked like a fricken charm in the demo project from earlier.  However it was not beneficial to the safe paths project building the tests.  I scroll down further, reading more, and BOOM [Jared Sinclair](https://github.com/jaredsinclair) ran in to the EXACT same issue as me.

```
I've run into this on several similar projects, with Swift Packages that contain clang submodules to expose code to the parent Swift module. I've found a workaround that fixes this, at least as of Xcode 11.3.1:

    In your unit or UI test target, add the parent module (the Swift Package library) to the linked libraries build phase, even if that test target doesn't use it directly.

    Sometimes Required If you are also using an Xcode scheme that's pointed at a unit or UI test target, make sure that the "Build" section of the scheme editor includes the application target in that list. By default, if you add a new Xcode scheme for, e.g., a UI test target, the app won't be included there and so it isn't built properly.

In all reproduced cases, the underlying error is a missing -fmodule-map-file flag for the clang submodule (MyLibrary.MySubmodule) emitted from the compile command for any file in the app target that has an import MyLibrary statement.
```

I tried the first step only and the project BUILT!  But if we remember from before, the project always builds modifying the xcode settings.  So then I had to bring in the second step. Would you guess, it actually worked!!! I jumped for joy! Everything builds on my machine, I quickly sent up the PR and after a significant amount of time testing and building different targets things were looking great! 

## I Hit Another issue

Seems like the unit tests for realm storage were throwing `EXC_BAD_ACCESS` when attempting to store anything in the DB.  Oh no, I caused a regression some how! Was it from adding the hash property?  Was this C library messing everything up some how?  It was all working before!

So now that I knew how to get the project working with SPM and a c library I began rebuilding the project off develop.  Testing the Realm tests every step of the way.  Nothing was breaking and I was slowly adding back all functionality.  It got time to add back the scrypt-swift project and though I was nervous, I was more ready for this thing to be completed.  I added it, and it all worked perfectly!  Then came time for the unit tests.  Turns out I was referencing a class somewhere else in the project for a static time variable and that class became required to kick off the unit tests for my new functionality.  I added the Secure Storage file, which included the Realm Storage singleton, to the test target and BOOOM the crash happened again! Seemed like the Test Realm instance and the singleton were getting mixed up during the runtime phase of testing.  So I pointed to a different static, removed the files membership, and we were off to the races again.

## UNTIL

A BUILD CONFIGURATION [issue](https://forums.swift.org/t/cannot-using-spm-module-with-some-custom-configuration-not-debug-release-on-xcode-11/26412) arrives with using SPM in XCode 11 with different configurations.   At this point I had to make a decision to hack in a weird solution to incorporate all the react native cocoapods for staging but yet maintain Debug/Release configuration for the SPM Scrypt project.  And it was at this moment I realized SPM was just not going to cut it.   I love SPM but it's just too new to throw into a project like this.  I removed all the integration and work done before and added in the libscrypt c library with a header pointing directly to C.  Keeping a Swift wrapper around the library and everything worked as expected.  I posted the PR and all the build steps were able to kick off successfully.

## In the end

To finish it all off we were able to later use a different React Native Background Geolocation library and upgrade the XCode version in the build pipeline.  This will allow us to choose between reverting to having the JS side implement the hashing or bringing back SPM.

Nevertheless, effort is never wasted, this project was enjoyable work on and I learned a ton.  I was able to work with some incredibly smart and talented individuals and even though the struggle was real I felt wicked accomplished seeing this project take off.  The feeling after getting everything hooked up, working properly, and seeing all green lights across the test suite might be my favorite feeling in the whole world.  If you're interested in development, the open source repo can be found [here](https://github.com/Path-Check/covid-safe-paths).  Hope this story brings a little insight to working with rapidly changing requirements and SPM integration.