KyBoy
=====

Arduboy simulator for iPhone/iPad.

<img src="https://github.com/redbug26/KyBoy/raw/master/screenshot.png" width=320>

How to use ?
============

Create a new iOS project in XCode,

Use cocoapods, and include this line

```
    pod "KyBoy", :git => 'https://github.com/redbug26/KyBoy.git'
```

Execute the "pod install" command to create your project

Add all your arduboy source file in the xcode project (make sure that the .ino project is compiled too - add it in build settings and change its file properties to c++ source file)

Compile the project and play :)


License
=======

See the [LICENSE](LICENSE.md) file for license rights and limitations (MIT).

Copyright
=========

This Project is based upon the following work:

- [ArduboyPlaytune](https://github.com/Arduboy/ArduboyPlaytune): The ArduboyPlayTune library - Copyright 2011-2018, Len Shustek, Chris J. Martinez, Kevin "Arduboy" Bates, Josh Goebel, Scott Allen
- [Arduboy2](https://github.com/MLXXXp/Arduboy2): The Arduboy2 library - Copyright 2016-2018, Scott Allen, Chris Martinez, Kevin "Arduboy" Bates, Josh Goebel, Adafruit Industries

Arduboy is a registered trademark of Arduboy, Inc. and Arduboy Simulator is not created by, supported by, licensed by, or associated with Arduboy, Inc
