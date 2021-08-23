This is an Xcode project. It uses WKWebView.

To make an unsigned build:

```
xcodebuild -scheme WebView -configuration Release clean archive -archivePath build/app.xcarchive CODE_SIGNING_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

Then open build/app.xcarchive -> Distribute -> Copy App -> Select a place like your desktop
