#TCReactiveCocoaExample
A simple concrete example of using [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) to implement a single view controller's functionality.

The view controller manages a form for the user to fill out. It will only allow the form to be
submitted, if all the text fields have a value. The password and password confirmation fields must also match.

##How to Build and Run

<dl>
  <dt>Build Requirements</dt>
  <dd>Xcode 5, iOS 7 SDK, CocoaPods</dd>
  <dt>Runtime Requirements</dt>
  <dd>iOS 7 or later</dd>
</dl>

####Step 1: Download and Install CocoaPods
If you've already installed CocoaPods, you can skip to **Step 2**.  
Otherwise, install CocoaPods by following the quick installation guide at <http://cocoapods.org/>.

####Step 2: Install Library Dependencies
This sample app needs to download and install the required libraries before it can be build. We'll let CocoaPods do all the hard work for us.

Run the following commands in `Terminal.app`: 
```
$ cd TCReactiveCocoaExample
$ pod install  
$ open TCReactiveCocoaExample.xcworkspace
```

##License
This project's source code is provided for educational purposes only. See the LICENSE file for more info.
