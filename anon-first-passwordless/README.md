# Anonymous First, Passwordless Second Firebase Authentication - October 11, 2020

In todays world we have SO many ways to provide users with a persistent, attributed, and social experiences.  So many apps have the notion of accounts and authentication.  People are used to social logins as a standard today and it's so nice to never have to worry about remembering a specific password for a different app.  There appears to be a path of least resistance at play.  It seems like so many apps give you this google, facebook, or apple wall before you're even allowed to use the application you downloaded.  

Why force users to authenticate to your application before they even get a chance to try it out?

This post will leverage firebase authentication to demonstrate the concept of anonymous first, passwordless authentication.

Anonymous users don't expire, and there isn't currently any automated way to purge them.

When a user signs out of an authenticated user make the choice to save some data or completely wipe local data when returning them back to an anonymous state.

Treat an anonymous account just like any other authenticated account, it's just not linked with a social provider and you don't have any specific user information like email off the start.  Each anonymous user has their own UID and that will need to be linked accordingly.

## References
- [Anonymous Users on iOS Firebase Documentation](https://firebase.google.com/docs/auth/ios/anonymous-auth)
- [Email Link Firebase Docs](https://firebase.google.com/docs/auth/ios/email-link-auth)
- [Account Linking Docs](https://firebase.google.com/docs/auth/ios/account-linking)
- [Anonymous Users iOS SwiftUI Firebase Video](https://www.youtube.com/watch?v=HDde7TqKCpk&t=2837s)
- [Magic links in iOS Video Tutorial](https://youtu.be/J-jtCB0jzTE)