// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

/* 
    DFN - first-class functions - the concept of Higher-Order Functions where functions may be passed as args to other functions and functions may return new functions
    DFN - blocks - used to support first-class functions and defined inline using functions and closures as parameters (but more cumbersome in Objective-C than Swift)
    DFN - generics - increase the powerfulness of first-class functions (beyond using just blocks)
    DFN - compositional - refactoring code to be simpler and more declarative and easier to understand by creating a Helper function with Libraries of smaller First-Class functions (to Separate Concerns)
    DFN - closure - used to return a function
    DFN - typealias - allows introduce new name for existing type
    DFN - transformer - functional approach of creating a function that modifies/extends another function (avoids code duplication) to cater for additional use cases
*/

typealias Position = CGPoint
typealias Distance = CGFloat

//// PURPOSE - check if point is in range.
//func inRange1(target: Position, ownPosition: Position, range: Distance) -> Bool {
//
//    // assume we are not always located at origin
//    let dx = ownPosition.x - target.x
//    let dy = ownPosition.y - target.y
//    let targetDistance = sqrt(dx * dx + dy * dy)
//
//    return targetDistance <= range
//}

// PURPOSE - check if enemy ships are too close (within minimum distance away) to our current position and avoid targeting them
let minimumDistance: Distance = 2.0

//func inRange3(target: Position, ownPosition: Position, range: Distance) -> Bool {
//    let dx = ownPosition.x - target.x
//    let dy = ownPosition.y - target.y
//    let targetDistance = sqrt(dx * dx + dy * dy)
//    return targetDistance <= range && targetDistance >= minimumDistance
//}

//// PURPOSE - check if any ships are too close to one of our ships and avoid targetting them
//func inRange4(target: Position, ownPosition: Position, friendly: Position, range: Distance) -> Bool {
//    let dx = ownPosition.x - target.x
//    let dy = ownPosition.y - target.y
//    let targetDistance = sqrt(dx * dx + dy * dy)
//    let friendlyDx = friendly.x - target.x
//    let friendlyDy = friendly.y - target.y
//    let friendlyDistance = sqrt(friendlyDx * friendlyDx + friendlyDy * friendlyDy)
//    return targetDistance <= range
//        && targetDistance >= minimumDistance
//        && (friendlyDistance >= minimumDistance)
//}

// PURPOSE - Refactored inRange function to be more Declarative, Compositional (easier to understand) and less complex by using the Library of smaller First-Class Functions we have defined (i.e. circle2, shift, invert, intersection, union, difference). Each constituent Region is legible and may be easily debugged to see the complexities of how they are assembled under the hood. It is an improvement on inRange4, as it is a Helper function that Separates Concerns (rather than mixing the constituent Regions and the calculations that describe them).
func inRange(ownPosition: Position, target: Position, friendly: Position, range: Distance) -> Bool {
    let rangeRegion = difference(circle(range), circle(minimumDistance))
    // define two Regions (targetRegion & friendlyRegion) and take the difference between them and then apply it to the argument 'target' to determine boolean result of whether within range
    let targetRegion = shift(ownPosition, rangeRegion)
    let friendlyRegion = shift(friendly, circle(minimumDistance))
    let resultRegion = difference(targetRegion, friendlyRegion)
    return resultRegion(target)
}

// PURPOSE - define a region (circle) centered around an origin. Given a radius we can call circle to return a function (using Swift's notation for Closures) to check whether a point arg is in within the region.
func circle(radius: Distance) -> Region {
    return { point in
        sqrt(point.x * point.x + point.y * point.y) <= radius
    }
}

// PURPOSE - same as circle, but caters for circles centered around other positions other than just a single origin
func circle2(radius: Distance, center: Position) -> Region {
    return { point in
        let shiftedPoint = Position(x: point.x - center.x, y: point.y - center.y)
        // return Boolean as to whether the shiftedPoint (offset by a distance from the original origin) is less than or equal to the radius (i.e. whether it is located inside the circle)
        return sqrt(shiftedPoint.x * shiftedPoint.x + shiftedPoint.y * shiftedPoint.y) <= radius
    }
}

// PURPOSE - Functional Approach using a Region Transformer (transform an existing Region) that shifts the region by a certain position and caters for other shapes. Rather than creating an increasingly complicated circle2 function we create the 'shift' function that modifies another function (avoids code duplication). Using a closure it returns a Region (function that returns a boolean when given a point).
//  Express a circle centered at (5,5) with radius 10:
//  shift(Position(x: 5, y: 5), circle(10))
func shift(offset: Position, region: Region) -> Region {
    return { point in
        // given a point we compute a new point and check it is in the original Region, passing it as an arg to the Region function
        let shiftedPoint = Position(x: point.x - offset.x,
                                    y: point.y - offset.y)
        return region(shiftedPoint)
    }
}

// PURPOSE - Region Transformer that inverts a Region to give points outside the original Region
func invert(region: Region) -> Region {
    return { point in !region(point) }
}

// PURPOSE - Combine two existing Regions into a larger complex Region using Intersection (takes points in both the given argument Regions) & Union (takes points in either of the given argument Regions)
func intersection(region1: Region, region2: Region) -> Region {
    return { point in region1(point) && region2(point) }
}

func union(region1: Region, region2: Region) -> Region {
    return { point in region1(point) || region2(point) }
}

// PURPOSE - Combine two existing Regions and exclude points from a first Region that are not in the second Region using the Difference
func difference(region: Region, minusRegion: Region) -> Region {
    return intersection(region, invert(minusRegion))
}