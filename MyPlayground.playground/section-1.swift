// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

/* 
    DFN - first-class functions - functions may be passed as args to other functions and functions may return new functions
    DFN - typealias - allows introduce new name for existing type
*/

typealias Position = CGPoint
typealias Distance = CGFloat

// PURPOSE - check if point is in range.
func inRange1(target: Position, ownPosition: Position, range: Distance) -> Bool {
    
    // assume we are not always located at origin
    let dx = ownPosition.x - target.x
    let dy = ownPosition.y - target.y
    let targetDistance = sqrt(dx * dx + dy * dy)
    
    return targetDistance <= range
}

// PURPOSE - check if enemy ships are too close (within minimum distance away) to our current position and avoid targeting them
let minimumDistance: Distance = 2.0

func inRange3(target: Position, ownPosition: Position, range: Distance) -> Bool {
    let dx = ownPosition.x - target.x
    let dy = ownPosition.y - target.y
    let targetDistance = sqrt(dx * dx + dy * dy)
    return targetDistance <= range && targetDistance >= minimumDistance
}