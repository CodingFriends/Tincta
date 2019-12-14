# Tincta

The famous and much-loved text editor *Tincta* for macOS.

## Contribute

Just do it!

## More Information

[Here is most of it](https://codingfriends.github.io/Tincta/)

## Build

It should just compile with XCode. There are two caveats, though:

* We have our dev certificate setup in the project so you need to remove that or replace it with your own
* The App Store build includes the App Center crash reporter. The key is defined in the `AppCenterConfig.h` which is not included in the source. There is a `AppCenterConfig_Example.h` that you can use for your own App Center account. Or you can delete all references to it alltogether and remove the import from `Tincta-AppStore-Prefix.pch`

## Supporters

[![Supported by the Spice Program](https://github.com/futurice/spiceprogram/raw/gh-pages/assets/img/logo/chilicorn_with_text-180.png)](https://spiceprogram.org)
