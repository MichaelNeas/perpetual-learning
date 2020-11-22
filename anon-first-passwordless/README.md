# Anonymous First, Passwordless Second Firebase Authentication - November 23, 2020

### Before Diving In

This post leverages Firebase to demonstrate the concept of anonymous first, passwordless authentication.  I will aim to target 2 powerful features that empower developers to integrate Anonymous Users and Passwordless Authentication. They can be used exclusively of each other, but together they work quite nicely.

Additionally even though this post carries iOS specific undertones, the overarching flow is adaptable for any Firebase driven [client application](https://firebase.google.com/docs/firestore/client/libraries) and could  be extended as a general authentication practice for a wide variety of applications not backed by Firebase.

If you're already into the idea of anonymous, passwordless users with firebase or you prefer to read code instead of a blog I have written a [sample application](./example-app) in Swift.

### Premise

There are many ways to provide application users with persistent, attributed, and social experiences.  Many applications implement some form of a user session, perhaps with accounts and authentication.  Social logins have become more or less a standard and for good reasons.  As a user I don't need to worry about maintaining a specific password for many of my apps and as a developer I don't need to worry about managing a user table and correctly handle passwords.

However, it feels like most applications I download present me with this social based "authentication wall" before I am allowed to play with the application. 

This brings up the question.  Why do we force authentication before giving people the chance to get a feel for the experience?

There is value in user association in applications.  
- There are security and access permissions by having defined users and roles within a system.
- It is neat to know exactly who posted what and when in history.
- Applications can grow their user base by targeting existing user's social connections.
- Marketing departments can target users with emails to keep up and increase engagement.
- Companies can link user data across multiple applications based on who is signed in.

The list goes on and on!

That being said, it is worth thinking about what user data an application really needs.
- Does it need to store data related to specific user actions?
- Does it need attributed persistence? Where a user can post one thing, close the app and reopen it later and gain feedback and retain ownership?
- Does it not directly need personal user information to deliver value?
- Does it need to deliver a personalized experience based on decisions made within the application?
- Does it need the ability to retain information while in the early stage of building an application to allow for users to be "upgraded" later on without losing their progress?

If you answered yes or no to any of those you might want to think about anonymous users.

I think it is easy to jump to social login first thing in an application because at the end of the day applications are supposed to benefit users and be as personalized as possible.

But what if we changed the default? What if it was more the case that applications empowered users to opt-in instead of being forced in to authentication? Just like the user had the decision to download your application, shouldn't they be permitted the decision of not logging in if they don't want to? 

Why not try an anonymous first flow?

Setting up a firebase application with anonymous users is outlined in [Firebase documentation](https://firebase.google.com/docs/auth) under your specific platform's Anonymous Authentication tab.  Once the SDK is installed and configured to your firebase instance you're ready to begin the flow.

## About Anonymous Users

Treat an anonymous account just like any other authenticated account, they're just not linked with a social provider and you don't have any specific user information like email off the start of the users life.  Each anonymous user has their own UID and that can be linked and referenced accordingly.

This concept allows us to give user experiences tailored to their active sessions, persisted to a backend, and allow a less evasive, opt in approach to authentication.

One caveat: Firebase Anonymous users don't expire and there isn't currently any automated way to remove them.  This brings up the importance of correctly linking and removing anonymous users during the time when users opt in to explicit authentication.

## The Flow

<p align="center">
  <img src="./resources/anonymousUsers.png" />
</p>

There truly isn't too much addition to a traditional authentication flow.  As the application launches, the firebase application is configured and then we are able to check and see if there is a current user session by supplying the [authentication state listener](https://firebase.google.com/docs/auth/ios/start#listen_for_authentication_state).  By assigning the `addStateDidChangeListener` we can receive updates on the active user.  In iOS world, if the User object comes back nil we can go ahead and proceed to the **No User** case below.

### No User

If there is no user session we jump straight in to creating an anonymous user! The Authentication package from firebase allows us to make a single call `signInAnonymously()` and we are off and running with an anonymous user.

### Anonymous User

If there is a user then Firebase Users have a property [isAnonymous](https://firebase.google.com/docs/reference/android/com/google/firebase/auth/FirebaseUser#isAnonymous()) which will be able to tell you if that user is anonymous. 

### Authenticated User

Otherwise we have an authenticated user and we can bypass the previous two steps.

In all cases once we have a `User` regardless of being anonymous or not, we can treat them the same.  There will be a unique identifier in Firebase's Authentication tab for whoever is using the application.

### How to handle when a user wants to opt-in to Authentication

There are a few things to keep in mind when a user decides they want to authenticate with your application.  

1. User signs in to an account that has never been in your system before.
	This case is incredibly easy thanks to [linking](https://firebase.google.com/docs/auth/ios/account-linking).  Linking allows us to take the UID from the anonymous user and assign a "link" to the social provider that we are signing in with.  Essentially the anonymous user "evolves" into this new authenticated user for free.
2. User signs in to an account that already exists.
	In this case the linking step from above won't be as simple.  We need to `signIn` as the new user and keep a reference to the previous user.  When the new user is successfully signed in we need to take this time to re-associate the previous users assets to this existing user's UID.  Once that happens we can delete the anonymous user as it will no longer be needed.

#### Common Error states

During the sign in I would like to throw out a few common errors I see regularly. Since there are [A LOT](https://firebase.google.com/docs/reference/swift/firebaseauth/api/reference/Enums/AuthErrorCode) of errors to potentially account for.

- `AuthErrorCode.emailAlreadyInUse.rawValue` - when working with anonymous users and signing in to existing accounts this error is actionable with the steps outlined in #2 from above.

- `AuthErrorCode.accountExistsWithDifferentCredential.rawValue` - this error gives us the ability to inform our users they have a correct account but different credentials.  At this step we can choose to link another account login or fire back to inform the user.  I currently use this error to enable users to login passwordless with either their email and with a gmail social login.

- `AuthErrorCode.credentialAlreadyInUse.rawValue` - This error informs us that we have tried to link a credential but it's already been linked somewhere else.  One strategy to handle this error is to migrate the current account over to this user upon sign in.  This requires a similar handling of removing the anonymous user if the current authenticated user is anonymous.

### Signing out

When a user signs out of an authenticated user make the choice to either save some data or completely wipe local data when returning them back to an anonymous state.  When the signOut callback is successful we find ourselves back in the "No User" state and should create a brand new anonymous user ready for action.  

It is a nice clean up step to remove the previous anonymous user at this step, as there will not really be a way for a user to associate themselves with that anonymous user again.

Signing out of an anonymous user is not an option I would personally suggest presenting to a user unless you inform them that it will "reset" them.

## Your title has passwordless in it, but you've only talked about anonymous users.

I know I know.  I just get jazzed up about anonymous users.

Once a user is ready to take their account to the next level and link an email address and perhaps other personal information we can use the good old social provider strategy.  OR we can use this neat Passwordless Authentication approach!  This way we can link a users email address without them needing a password and without requiring a social provider.

The specific passwordless mechanism used by firebase is called [Email Link Auth](https://firebase.google.com/docs/auth/ios/email-link-auth) and they are handled through mobile applications as universal links from an email generated by firebase.

This sign in requires us to set up [Firebase Dynamic Links](https://firebase.google.com/docs/dynamic-links/ios/receive).

Passwordless authentication is a beautiful way to gain user attribution without requiring users to have social media accounts.  This could reduce the require of sign in supports as well since [Apple now requires Apple Sign In](https://developer.apple.com/app-store/review/guidelines/#sign-in-with-apple) if your iOS app uses other social sign in providers.

On top of all that, no more reused or requirement to remember passwords by the user.

## That's it

We can give our users a delightful persistent experience without requiring them to explicitly authenticate to our application.  If they want to later down the line, that's great and we'll persist all their data as they link authentication providers.  But I'll tell you one thing.  It is nice to open an app, try it out and not be pressured into giving away unnecessary information about myself right off the bat.

I talk about this flow with experience from Firebase.  If Firebase is not your cup of tea or your project does not use Firebase.  You can still use similar principles and flow pattern to deliver a pleasant user experience to your applications.

Last but not least, if you'd like to see this all in action, I've built out an isolated application to illustrate the flow, feel free to check it out [here](./example-app)!

## References
- [Anonymous Users on iOS Firebase Documentation](https://firebase.google.com/docs/auth/ios/anonymous-auth)
- [Email Link Firebase Docs](https://firebase.google.com/docs/auth/ios/email-link-auth)
- [Account Linking Docs](https://firebase.google.com/docs/auth/ios/account-linking)
- [Anonymous Users iOS SwiftUI Firebase Video](https://www.youtube.com/watch?v=HDde7TqKCpk&t=2837s)
- [Magic links in iOS Video Tutorial](https://youtu.be/J-jtCB0jzTE)
- [Example iOS App](./example-app)
- [My other blogs](https://neas.dev)