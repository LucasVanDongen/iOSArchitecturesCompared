# Constraint
Constraint is a simple wrapper for iOS Auto Layout that has a very natural syntax

[![CI Status](https://img.shields.io/travis/lucasvandongen/Constraint.svg?style=flat)](https://travis-ci.org/LucasVanDongen/Constraint)
[![Version](https://img.shields.io/cocoapods/v/Constraint.svg?style=flat)](https://cocoapods.org/pods/Constraint)
[![License](https://img.shields.io/cocoapods/l/Constraint.svg?style=flat)](https://cocoapods.org/pods/Constraint)
[![Platform](https://img.shields.io/cocoapods/p/Constraint.svg?style=flat)](https://cocoapods.org/pods/Constraint)

## Usage
### On a UIView
Usually you will use the `Constraint` library on an instance of the (descendant class of) `UIView` you want to constrain. Every call returns the `UIView` again so it's very easy to chain all of your layouts like this:

```swift    
icon
    .attach(top: 20,
            leading: 10,
            bottom: 0,
            trailing: 10)
    .size(width: 24, height: 24)
```

Also there's the possibility to add various modifiers to offset constraints:

```swift
image.attach(top: 0.orMore, bottom: 12.defaultLowPrioritized)
// These are also chainable
label.attach(bottom: 0.orMore.prioritized(to: UILayoutPriority(800))
```
If you want to save a certain `Offset` for reuse you can do that like this:

```swift
let offset = 0.orMore.defaultLowPrioritized.respectingLayoutGuides
```
It's possible to respect any layout guide (like iPhone X's Safe Area) by using `respectingLayoutGuide` / `layoutGuideRespecting`

### As a generator for constraints
Sometimes you need to store the constraints that are generated. In this case you need to call the static methods on the `Constraint` class directly as follows:

```swift
private var messageHeight: NSLayoutContraint?
// ...
messageHeight = Constraint.height(50, for: message).activated
```
    
In this case you will have to add the constraint manually to the view. It's the maximum amount of flexibility but a bit more work.
## UIView API
These are all the publicly exposed extensions to `UIView`. They are based upon the options you see in `Interface Builder`. Here's a short overview to see how they are related:

![Align Screen](https://github.com/LucasVanDongen/Constraint/raw/master/Images/align.png)

 * The `align()` functions map to the first 7 options that are relations between two equal views
 * The `center()` functions are used for the last two options of the Align screen, where a `subview` is centered in it's `superview`

![Size Constraints](https://github.com/LucasVanDongen/Constraint/raw/master/Images/size_constraints.png)

 * `Spacing to nearest neighbor` is covered by all of the `attach()` functions
 * `Width`, `Height`, `Equal Widths` and `Equal Heights` are covered by `width()`, `height()` and `size()`
 * `Aspect Ratio` is handled by the `ratio()` function
 * `Align` is an alias for the Edges in the Align screen and therefore is covered by `align`

----------------------

### `attach`
This method is used to space the view related to is `superview`. You can define all sides at once, every side separately and leave some sides out. It takes `Offsetable` as it's parameter which means you can either use a primitive like `Int` or `CGFloat` or you can send an `Offset` directly. 
#### Attaching all sides at once
This is the most basic way to use `attach`. You can define an `offset` or accept the default of `0`:

```swift
view.attach() 
view.attach(offset: 12)
```
#### Attach only some sides
This version lets you specify which sides are going to be attached. You can define an `offset` or accept the default of `0`:

```swift
view.attach(sides: [.top, .leading, .trailing], 12)
```
#### Attach with different values per side
This is the most flexible way to use this API. Every side can have it's own separate definition which is `Offsetable` so can be mutated further when needed.

```swift
view.attach(top: 0, trailing: 12) // Does not apply the bottom and leading constraints
view.attach(top: 0.orMore) // It's possible to use it with primitives and still modify the priority or relation type
view.attach(leading: 12.orLess.defaultLowPriority) // These can also be chained
view.attach(bottom: Offset(0, .orMore, respectingLayoutGuide: true, priority: .defaultLow)) // Means the same as view.attach(bottom: 0.orMore.layoutGuideRespecting.defaultLowPriority)
```
`respectingLayoutGuide` / `layoutGuideRespecting` means it respects the layout guides, like in the root view of a `ViewController` where you expect it to respect the Safe Area sometimes. 

The default is to *not* respect the layout guides.

### `center`
Center lets you center the view inside another view, where it defaults to the `superview`. It's also possible to specify another view that needs to be part of the same view tree

```swift
view.center(axis: .both) // Centers the view on both the X and Y axis of it's superview
view.center(axis: .x, adjusted: 10, priority: .defaultLow) // Wants to center it's X to it's superview, then adjusts it +10 pixels and applies a low priority to it
```
### `align`
Align is used where you want to align two views that are not in a parent / child relationship.
#### Centering views with eachother
Centers can be aligned much like the `center()` API does for parent / child views:

```swift
view.align(axis: .x, to: anotherView, adjustment: 10) // Wants to center it's X to anotherView, then adjusts it +10 pixels
```
#### Aligning sides of views
It also allows you to align a side instead of the middle:

```swift
view.align(.leading, 12, otherView) // Aligns it's leading side to the leading side of otherView + 12 pixels
```

If you want to align multiple sides (much like `attach` does) you can do this too:

```swift
view.align([.top, .leading, .bottom], 0, to: otherView)
```

### `space`
Space the view to another view in any direction.

```swift
registerButton
    .space(20, .above, reconfirmButton)
    .space(8, .below, usernameLabel, .orMore, priority: .defaultLow)
```
### `width`, `height` and `size`
These functions are used to set the size of a UIView. You can set the width and height also related to the width or height of another view.
#### Setting width, height and size as a constant

```swift
otherView
    .size(width: 100, .orMore, height: 50)
view
    .width(200)
    .height(100)
```

`size()` also accepts a `CGRect` as a parameter which can be handy if you for example want to copy `frame.size`

```swift
view.size(superview.frame.size)
```

#### Setting width or height related to another view
You can also make it relative to another view:

```Swift
view.height(relatedTo: superview, adjusted: 10)
```
### `ratio`
Ratio sets the ratio between the width and the height of view.

```swift
view.ratio(of: 2) // Makes the width twice as much as the height
view.ratio(of: 3, to: 2) // Makes the width height have a ratio of 3:2
```
Alternatively, you can also call it with a `CGRect`. This is very handy if you want your `UIImageView` always have the same ratio as your `UIImage`:

```swift
view.ratio(avatarImage.size)
``` 

## Known issues and TODO's
This is the `0.1` release of this library but it already has been used in a few projects internally and all of the major kinks have been worked out. The following issues exist:

* Not all class funcs on `Constraint` return `NSLayoutConstraint` or `[NSLayoutConstraint]` yet
* The Fluent API hasn't been used everywhere yet
* The API might undergo some name changes or get improved parameters

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
* Swift 4
* iOS

## Installation

Constraint is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Constraint'
```

## Author

lucasvandongen, lucas.van.dongen@gmail.com

## License

Constraint is available under the MIT license. See the LICENSE file for more info.
