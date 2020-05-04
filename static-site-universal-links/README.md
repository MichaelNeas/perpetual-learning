# Associated Domains with Github Pages

1. Want to set up universal links for your various Apple platform applications?
2. Don't have the desire, time, or resources to spin up or maintain a full website and server(s)?

We can leverage Github Pages to enable universal links.  This method accomplishes our #1 goal with minimal cost.  In a matter of minutes we can set up a web based landing page or sharable link to quickly distribute your app to new or existing users.  For new users, universal links redirect to an application on the App Store. If the application is already downloaded we can provide in-app routing and easily navigate our users to the content they care about most.

We will demonstrate an example process that accomplishes all of this of this using 1 repository!

If you're interested in why Apple officially recommends Universal Links for deep linking check [this out](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content)

TL;DR:
![Universal links ftw](./why-use.png)

## Universal Links Basics

Universal links require three things:
1. An apple-app-site-association file served from a website
2. Filling that association file with all the routing information desired using [wildcards and directives](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/enabling_universal_links#3002228).
3. The Associated Domains entitlement and capability inside the project.

You can snag an example apple-app-site-association file [here](./apple-app-site-association).  

The basic example to set up universal links looks like this:
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

#### What are any of these keys? 
- `applinks`: Apple uses this key to understand that this site has universal links.
- `apps`: Not used for universal links, but it must be present and set to an empty array.
- `details`: A list of applications handling universal links for a given website, along with the specific sections of the website being handled.
- `appID`: identifier of the application that will handle the paths
- `paths`: sections of the website supported by the linked application.  These paths are specified as an array of qualifying strings, where `*` will catch all paths.  The paths list gives us control over when we want the "open in app" banner to appear on our website and valid routes that allow app-site communication.

Apple goes into more expressive examples in [their documentation](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/enabling_universal_links)

##### One caveat to remember

```
iOS 12 uses the paths array and is not aware of the appIDs key. 
If you have multiple applications, use the singular appID key and 
specify a separate details dictionary for each application.
```

## Website Setup

My project was already using Github, this allows me to go in the settings of the repository and enable Github Pages.  If you don't know what Github Pages is, [definitely check it out](https://pages.github.com/)!  Once you turn on Pages we can get in to the good stuff.

Apple requires the app site association file to either be at the root or in the `/.well-known/` directory of your website.  Github Pages gives us a domain out of the box, but namespaces our repositories with an additional path, (ie. `michaelneas.github.io/coolproject`).  Therefore to satisfy the "fully qualified domain" requirement we'll need to create a custom domain name and assign it to our Pages repo.

I highly recommend using [domains.google.com](domains.google.com/), where we can purchase a $12/year domain of our liking.  There are 3 steps for linking Google Domains with Github Pages, instructions are found [here](https://dev.to/brunodrugowick/github-pages-and-google-domains-together-5ded).  At this point we can asyncronously wait for the existence of our site to propagate across the web along with the HTTPS certificates to be approved, distributed, and registered for our static site.  Github will automatically generate a CNAME after entering in the fancy new domain in the project settings. The last step is drop our app-site-association file in the root directory of our project.  Do not add a filetype to the file and Github Pages will correctly serve the "content-type" automatically.

![cname and aasa](./aasa-cname.png "CNAME and AASA in root of project")

## Validation

We should be all hooked up now to begin the validation step of our universally linked website.  

If we navigate to our new website and add the path `/apple-app-site-association` after the domain something like this should happen:
![Proof of aasa](./aasa-browser.png)

There are many sites that validate association files, but I suggest using [Apple's](https://search.developer.apple.com/appsearch-validation-tool) or [Branch.io's](https://branch.io/resources/aasa-validator/) tools.  

Validators typically check for these 5 things:
![branch validation](./branch-validation.png "Example showing valid aasa")

Once that's all set, we're ready to connect the iOS app.

## iOS App

At a minimum an iOS app requires the addition of the `applinks` property to a project in order to link the website we just created.  Start by enabling the associated domains capability.  Following that, insert `applinks:url` under `Domains` as seen in the image below.  The entitlements file will be updated automatically.
![associated domains capability](./associated-domains-capabilities.png)
![associated domains entitlements](./associated-domains-entitlement.png)

If we now run the app in simulator, navigate to safari, type in the url we set up before, and scroll down we will see the banner! (The "open in app" banner will be offset, which is why the scroll is required, if interested, a few lines of javascript can be used to auto scroll users when they land on a page)

![Working applink drawer](./applink-drawer.png)

On the iOS app itself we can see incoming requests in the `userActivity` method in the AppDelegate. From there we can parse the arguments and bubble up whatever view we want based on where the user was coming from.

More specific handling details for specific platforms can be found [here](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/handling_universal_links)

## Final Words

![All hooked up](./link-example.gif)

If you want to see this all working for yourself I have an application called [Framewerk](https://apps.apple.com/us/app/framewerk/id1496896308).  If you navigate to [Framewerk.app](framewerk.app), you'll see the static site will point you to download the iOS app on the app store.

It is up to us to decide how in depth we want to go with universal linking.  With AppStoreConnect containing fields for marketing and support URL's, why not take the time to add in universal links for users to get to your app? The setup can be less than 5 minutes plus some additional deployment/certificate processing time to enable universal links.  

This quick setup gets our feet wet with universal links.  Universal links are a powerful way to enable users on multiple platforms to explore your content.  At this point we also have the option to enable [webcredentials](https://developer.apple.com/documentation/security/shared_web_credentials) to pass secure credentials between our associated domains.

Further more if you're interested in diving in to a website and plan to support more than what Markdown/basic html gives us you can set up a [react based github pages site](https://github.com/gitname/react-gh-pages).  This can give you an expressive router within a static site and perhaps enable a bit more of a dynamic feel to your site.

If you'd like a fun exercise, go to one of your favorite sites and check out their association file.  Remember they can only exist in two places and can be absolutely massive. (Here is [Youtubes](https://www.youtube.com/apple-app-site-association))

## Helpful Links
- [AASA Gist](https://gist.github.com/anhar/6d50c023f442fb2437e1)
- [Apples Universal Link Validator](https://search.developer.apple.com/appsearch-validation-tool)
- [Branch.io validator](https://branch.io/resources/aasa-validator/)
- [Apple Docs for Universal Links](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/enabling_universal_links)
- [Associated Domains, by Apple](https://developer.apple.com/documentation/safariservices/supporting_associated_domains_in_your_app)
- [Google Domains and Github Pages](https://dev.to/trentyang/how-to-setup-google-domain-for-github-pages-1p58)
- [Custom Domains with Github Pages](https://help.github.com/en/github/working-with-github-pages/configuring-a-custom-domain-for-your-github-pages-site)
- [Universal links checklist](https://gist.github.com/andrewrohn/774185e4e15ddcc14f0a1e3c66c943e3)
- [React Github Pages](https://github.com/gitname/react-gh-pages)
- [Universal vs deep links](https://www.adjust.com/blog/universal-links-vs-deep-links/)
