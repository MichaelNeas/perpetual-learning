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

## Validation

## iOS App

## Final Words

It is up to the developer to decide how in depth they want to go with universal linking.  With AppStoreConnect containing fields for marketing and support URL's, why not take the time to add in universal links for users to get to your app? The setup can be less than 5 minutes plus some deployment/certificate time to enable universal links.

## Resources
- [AASA Gist](https://gist.github.com/anhar/6d50c023f442fb2437e1)
- [Apples Universal Link Validator](https://search.developer.apple.com/appsearch-validation-tool)
- [Branch.io validator](https://branch.io/resources/aasa-validator/)
- [Apple Docs for Universal Links](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/enabling_universal_links)
- [Google Domains and Github Pages](https://dev.to/trentyang/how-to-setup-google-domain-for-github-pages-1p58)
- [Custom Domains with Github Pages](https://help.github.com/en/github/working-with-github-pages/configuring-a-custom-domain-for-your-github-pages-site)
- [React Github Pages](https://github.com/gitname/react-gh-pages)