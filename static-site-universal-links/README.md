# Universal Linking with Github Pages

1. Want to set up universal/deep links for your iOS applications?
2. Don't have the desire, time, or resources to spin up or maintain a website/server?

With Github pages or other static web service providers, we can still enable universal links for our iOS applications.  This method accomplishes our goal with minimal cost.  In a matter of minutes we can set up a web based landing page or sharable link to quickly distribute your app to new or existing users.  Universal link configurations are capable of incredibly advanced in-app routing and can get your users to parts of your app that they care the most about.

## Universal Links Basics

The standard example looks like this:
```
{
    "applinks": {
        "apps": [],
        "details": [
            {
                "appID": "<TEAM_DEVELOPER_ID>.<BUNDLE_IDENTIFIER>",
                "paths": [ "*" ]
            }
        ]
    }
}
```

## Website Setup

As of May 1, 2020 apple requires your app site association file to be at the root of your website. So we'll need to create a custom domain name and assign it to our github pages repo.  This carries a $12 yearly cost if you go through domains.google.com which I highly recommend.  Setup instructions are here: [Link to](instructions).  At this point we have to wait for some time to get https certificates approved and registered for our static site. So the last step to do here is drop your app-site-association file in the root directory of your project (insert pic).

## Validation

We should be all hooked up now to begin the validation step of our universally linked website.  There's a bunch of sites that do this, but I suggest using Apples or Branch.io's validator.  Once that's all set to go we're ready to connect up the iOS app.

## iOS App

Your iOS app requires you to add a single line addition to link it to the website we just created.  At this if you run your app in the simulator, navigate over to safari, and scroll down (the apple "open" button will be offset from the out of the box setup, we can add a few lines of javascript to always show the open drawer).

On the iOS app itself we can see incoming requests in the AppDelegate.  From there we can parse the arguments and bubble up whatever view we want based on where the user was coming from.

## Final Words

If you want to see this all working, I have an application called [Framewerk](framewerk app store).  If you navigate to [Framewerk.app](framewerk.app), you'll see the static site will point you to download the iOS app on the app store.

It is up to the developer to decide how in depth they want to go with universal linking.  With AppStoreConnect containing fields for marketing and support URL's, why not take the time to add in universal links for users to get to your app? The setup can be less than 5 minutes plus some deployment/certificate time to enable universal links.  

This is a quick setup to get our feet in the door with universal links.  We can link to anywhere in our app based on where the user is on the website.  Universal links are a powerful way to allow users multiple platforms to explore your content.

## Resources
- [AASA Gist](https://gist.github.com/anhar/6d50c023f442fb2437e1)
- [Apples Universal Link Validator](https://search.developer.apple.com/appsearch-validation-tool)
- [Branch.io validator](https://branch.io/resources/aasa-validator/)
- [Apple Docs for Universal Links](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/enabling_universal_links)
- [Google Domains and Github Pages](https://dev.to/trentyang/how-to-setup-google-domain-for-github-pages-1p58)
- [Custom Domains with Github Pages](https://help.github.com/en/github/working-with-github-pages/configuring-a-custom-domain-for-your-github-pages-site)
- [React Github Pages](https://github.com/gitname/react-gh-pages)