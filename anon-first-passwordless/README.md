# Anonymous First, Passwordless Second Firebase Authentication - November 23, 2020

## Before Diving In

This post leverages Firebase to demonstrate the concept of anonymous first, passwordless authentication.  I will aim to target 2 powerful features that empower developers to integrate Anonymous Users and Passwordless Authentication. They can be used exclusively, but together they work quite nicely.

Even though this post carries iOS specific undertones, the underlining flow is adaptable for any Firebase driven [client application](https://firebase.google.com/docs/firestore/client/libraries) and can be extended as a general authentication practice for a wide variety of applications not backed by Firebase.

## Premise

There are many ways to provide application users with persistent, attributed, and social experiences.  Many applications implement some form of a user session, perhaps with accounts and authentication.  Social logins have become more or less a standard and for good reasons.  As a user I don't need to worry about maintaining a specific password for many of my apps and as a developer I don't need to worry about managing a user table and correctly handling passwords.

There is even more value in user association in applications.  
- There are security and access permissions by having defined users and roles within a system.
- It is sometimes important to know exactly who posted what and when in history.
- Applications can grow their user base by targeting existing user's social connections.
- Marketing departments can target users with emails to keep up and increase engagement.
- Companies can link user data across multiple applications based on who is signed in.
- The list goes on and on!

However, it feels like most applications I download present me with a social based "authentication wall" before I am even allowed to play around. 

This brings up the question.  Why do we force authentication before giving people the chance to get a feel for their newly downloaded application?

It is worth thinking about what user data an application truly needs.
- Does it need to store data related to specific user actions?
- Does it need attributed persistence? Where a user can post one thing, close the app and reopen it later and gain feedback and retain ownership?
- Does it not directly need personal user information to deliver value?
- Does it deliver a personalized experience based on decisions made within the application?
- Does it need the ability to retain information while in the early stages of development to permit users to be "upgraded" later on without losing their progress?

If you answered yes or no to any of those you might want to think about anonymous users.

It is easy to jump to social login first thing in an application because at the end of the day applications are supposed to benefit users and be as personalized as possible.

But what if we changed this default? What if applications empowered users to opt-in instead of being forced-in to authentication? Just like the user had the decision to download the application, shouldn't they be permitted the decision of not logging in if they don't want to? 

Why not try out an anonymous first flow?

### Prerequisite 

Setting up a firebase application with anonymous users is outlined in [Firebase documentation](https://firebase.google.com/docs/auth) under your specific platform's Anonymous Authentication tab.  Once the SDK is installed and configured to your firebase instance you're ready to begin the flow.

## About Anonymous Users

Treat an anonymous account just like any other authenticated account, they're just not linked with a social provider and you don't have any specific user information like email off the start of the users life.  Each anonymous user has their own UID and that can be linked and referenced accordingly.

This concept allows us to give user experiences tailored to their active sessions, persisted to a backend, and permit a less invasive, opt-in approach for authentication.

A caveat: Firebase Anonymous users don't expire and there isn't currently any automated way to remove them.  This brings up the importance of correctly linking and removing anonymous users during the time when users opt in to explicit authentication or sign out.

## The Flow

<p align="center">
  <img src="./resources/anonymousUsers.png" />
</p>

There truly isn't too much addition to a traditional authentication flow when adding Anonymous First users.  As the application launches, the firebase application is configured and a check to see if there is a current user session occurs by supplying the [authentication state listener](https://firebase.google.com/docs/auth/ios/start#listen_for_authentication_state).  In iOS world, by assigning the `addStateDidChangeListener` we can receive state updates about the active user.  If the User object comes back nil we can go ahead and proceed to the **No User** case below.

### No User

If there is no user session we jump straight in to creating an anonymous user! The Authentication package from firebase allows us to make a single call `signInAnonymously()` and we are off and running with an anonymous user.

### Anonymous User

If there is a user then Firebase Users have a property [isAnonymous](https://firebase.google.com/docs/reference/android/com/google/firebase/auth/FirebaseUser#isAnonymous()) which will be able to tell us if that user is anonymous. 

### Authenticated User

Otherwise we have an authenticated user and we can bypass the previous two steps.

Anonymous or not, once we have a `User`, we can treat them the same.  There will be a unique identifier in Firebase's Authentication tab for whoever is using the application.

### How to handle when a user wants to opt-in to Authentication

There are a few things to keep in mind when a user decides they want to authenticate with your application.  

1. User signs in to an account that has never been in your system before.
	This case is incredibly simple thanks to [account linking](https://firebase.google.com/docs/auth/ios/account-linking).  Linking allows us to take the UID from the anonymous user and assign a "link" to the social provider that we are signing in with.  Essentially the anonymous user "evolves" into this new authenticated user for free.
2. User signs in to an account that already exists.
	In this case the linking step from above won't be as simple.  We need to `signIn` as the new user while keeping a reference to the previous anonymous user.  When the new user is successfully signed in we need to take this time to re-associate the previous users assets to this existing user's UID.  Once that is complete we can then `delete` the anonymous user as it will no longer be needed.

## Passwordless sign in

Once a user is ready to take their account to the next level and link an email address and perhaps other personal information, we can use a social provider strategy (Google Auth/Apple Auth).  **OR** we can use a an email link authentication approach!  This way we can link a users email address without them needing a password and without requiring them to belong to a social provider.

The specific passwordless mechanism used by firebase is called [Email Link Auth](https://firebase.google.com/docs/auth/ios/email-link-auth) and they are handled through mobile applications as universal links from an email generated by firebase.

This sign in requires us to set up [Firebase Dynamic Links](https://firebase.google.com/docs/dynamic-links/ios/receive).

Passwordless authentication is a beautiful way to gain user attribution without requiring anyone to carry a social media account.  This could reduce the requirement of sign in supports as well since [Apple now requires Apple Sign In](https://developer.apple.com/app-store/review/guidelines/#sign-in-with-apple) if your iOS app uses almost any other social sign in provider.

On top of all that, no more reused or remembering passwords by the user, besides their email.

#### Common Firebase Error states

There are [A LOT](https://firebase.google.com/docs/reference/swift/firebaseauth/api/reference/Enums/AuthErrorCode) of errors to potentially account for when dealing with Firebase Authentication. However there are a few common errors I've seen regularly that are nice to know ahead of time.

- `AuthErrorCode.emailAlreadyInUse.rawValue` - when working with anonymous users and signing in to existing accounts this error is actionable with the steps outlined in #2 from above.

- `AuthErrorCode.accountExistsWithDifferentCredential.rawValue` - this error gives us the ability to inform our users they have an exiting account but different credentials.  At this step we can choose to link another account login or fire back to inform the user.  I have used this error to enable users to login passwordlessly with their email and another provider such as a google social login.

- `AuthErrorCode.credentialAlreadyInUse.rawValue` - This error informs us that we have tried to link a credential but it's already been linked somewhere else.  One strategy to handle this error is to migrate the current account over to this user upon sign in.  This requires a similar handling of removing the anonymous user if the current authenticated user is anonymous.

### Signing out

When a user signs out of an authenticated user make the choice to either save some data or completely wipe local data when returning them back to an anonymous state.  When the signOut callback is successful we find ourselves back in the "No User" state and should create a brand new anonymous user ready for action.  

It is a nice clean up step to remove the previous anonymous user at this step, as there will not really be a way for a user to associate themselves with that anonymous user again.

Signing out of an anonymous user is not an option I would personally suggest presenting to a user unless you inform them that it will "reset" them.

## That's it

We can give users a delightful persistent experience without requiring explicit authentication to our applications.  If they want to later down the line, that's great, and we'll persist all their data as they link different authentication providers.  But I'll tell you one thing.  It sure is nice to open an app, try it out and not be pressured into giving away unnecessary information about myself right off the bat.

Anonymous First, Passwordless authentication may not be the correct solution for your application.  Keeping this option in the back of our toolbox can potentially improve user adoption and increase awareness for something that has taken time and energy to create.

I present this flow with experience from Firebase.  If Firebase is not your cup of tea or your project does not use Firebase, you can still use similar principles to the flow pattern to deliver a pleasant user experience in your applications.

Last but not least, if you would like to see this idea in action, I've built out an isolated application to illustrate the flow.  Feel free to check it out [here](./example-app), you'll need to add your own [Google Service Plist](https://firebase.google.com/docs/ios/setup#add-config-file).

## References
- [Anonymous Users on iOS Firebase Documentation](https://firebase.google.com/docs/auth/ios/anonymous-auth)
- [Email Link Firebase Docs](https://firebase.google.com/docs/auth/ios/email-link-auth)
- [Account Linking Docs](https://firebase.google.com/docs/auth/ios/account-linking)
- [Anonymous Users iOS SwiftUI Firebase Video](https://www.youtube.com/watch?v=HDde7TqKCpk&t=2837s)
- [Magic links in iOS Video Tutorial](https://youtu.be/J-jtCB0jzTE)
- [Example iOS App](./example-app)
- [My other blogs](https://neas.dev)