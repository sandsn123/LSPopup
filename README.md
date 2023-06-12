# LSPopup

SwiftUI自定义弹窗，可支持多层效果

## Requirements
- Xcode 12.x
- Swift 5.x


## Installation

### [Swift Package Manager (SPM)](https://github.com/ashleymills/Reachability.swift#swift-package-manager-spm)

1. File -> Swift Packages -> Add Package Dependency...
2. Enter package URL : https://github.com/sandsn123/LSPopup.git, choose the latest release

## Usage

```swift
// <dependent swiftui view>
.lspopup(isPresent: $isPresent, bgOpacity: 0.2, attributes: {
        $0.cornerRadius = 10.0
        $0.anchor = .absolute(originAnchor: .topRight, popoverAnchor: .topLeft)
        $0.padding = EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0)
        // ....
})
```

## Example
![](https://media.giphy.com/media/rIAm2DtreeylCc6BIG/giphy.gif)
