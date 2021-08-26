# webviews

Relatively simple wrappers around the WebView built in to some operating systems.

We intend to use these in the [TurboWarp Packager](https://packager.turbowarp.org/). If you can find another use, that's great. Typically, each executable will read files like `application_config.json` to configure things like title, width, height, etc., which allows us to ship static executables and glue everything together with simple JavaScript.

Each top-level folder represents a different platform:

 - `android` - For android
 - `macos` - For macOS
 - `wry` - For Windows, macOS, Linux
