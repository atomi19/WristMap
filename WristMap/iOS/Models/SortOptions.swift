//
//  RouteSortOptions.swift
//  WristMap
//


enum RouteSortOptions: String, CaseIterable {
    case dateCreated
    case nameAZ
    case distanceHighToLow
    case distanceLowToHigh
}

enum SessionSortOptions: String, CaseIterable {
    case dateCreated
    case finishedAt
    case distanceHighToLow
    case distanceLowToHigh
    case durationHighToLow
    case durationLowToHigh
}
