//
//  TableViewDataDifferentiator.swift
//  MVCChat
//
//  Created by Lucas van Dongen on 16/09/2018.
//  Copyright © 2018 Departamento B. All rights reserved.
//

import UIKit

struct TableViewDataDifferences {
    let rowsToDelete: [IndexPath]
    let rowsToUpdate: [IndexPath]
    let rowsToInsert: [IndexPath]
}

protocol Differentiable {
    func isSame(`as` other: Self) -> Bool
    func isOrderedHigher(than other: Self) -> Bool
    func isOrderedLower(than other: Self) -> Bool
    func hasChanged(comparedTo other: Self) -> Bool
}

class TableViewDataDifferentiator {
    class func differentiate<T: Differentiable>(oldValues: [T], with newValues: [T]) -> TableViewDataDifferences {
        let initial = (deleted: [T](), updated: [T]())
        let deletedAndUpdated = oldValues.reduce(initial) { (result: (deleted: [T], updated: [T]), oldValue: T)
            -> (deleted: [T], updated: [T]) in
            var newResult = result

            guard let newValue = newValues.first(where: { (newValue) -> Bool in
                oldValue.isSame(as: newValue)
            }) else {
                newResult.deleted.append(oldValue)
                return newResult
            }

            guard !newValue.hasChanged(comparedTo: oldValue) else {
                newResult.updated.append(newValue)
                return newResult
            }

            return result
        }

        let inserted = newValues.filter { (newValue) -> Bool in
            !oldValues.contains(where: { (oldValue) -> Bool in
                oldValue.isSame(as: newValue)
            })
        }

        return TableViewDataDifferences(rowsToDelete: updatedIndexPaths(for: deletedAndUpdated.deleted,
                                                                        from: oldValues),
                                        rowsToUpdate: updatedIndexPaths(for: deletedAndUpdated.updated,
                                                                        from: oldValues),
                                        rowsToInsert: insertingIndexPaths(for: inserted, from: oldValues))
    }

    private class func updatedIndexPaths<T: Differentiable>(for deletedValues: [T], from oldValues: [T])
        -> [IndexPath] {
        return oldValues.enumerated().compactMap { (arg: (offset: Int, element: T)) -> IndexPath? in
            let (offset, element) = arg
            guard deletedValues.contains(where: { (deleted) -> Bool in
                element.isSame(as: deleted)
            }) else {
                return nil
            }

            return IndexPath(row: offset, section: 0)
        }
    }

    private class func insertingIndexPaths<T: Differentiable>(for newValues: [T], from oldValues: [T]) -> [IndexPath] {
        return (oldValues.count..<oldValues.count + newValues.count).map { index in
            return IndexPath(row: index, section: 0)
        }
    }
}
