# lmstat
A Swift command line tool analyzing iOS app LinkMap file and find out which lib makes your app so fat.

Follow the steps in http://blog.cnbang.net/tech/2296/ to locate LinkMap file.

Usage: lmstat YourApp-LinkMap.txt result.txt

Result sample:

2.74M	/Users/dancong/dev/YourApp/A.framework/A(zipUtil.o)

2.58M	/Users/dancong/dev/YourApp/B.framework/B

2.01M	/Users/dancong/dev/YourApp/C.framework/C

0.01M	/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS8.2.sdk/usr/lib/libSystem.dylib
