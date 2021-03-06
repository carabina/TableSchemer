//
//  ArrayScheme.swift
//  TableSchemer
//
//  Created by James Richard on 6/12/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import UIKit

/** This class is used with WBLSchemeDataSource to display an array of cells.
 *
 *  Use this scheme when you want to have a set of cells that are based on an Array. An example of this case
 *  is displaying a font to choose, or wifi networks.
 *
 *  It's recommended that you don't create these directly, and let the
 *  SchemeSetBuilder.buildScheme(handler:) method generate them
 *  for you.
 */
public class ArrayScheme<T: Equatable, U: UITableViewCell>: Scheme {
    public typealias ConfigurationHandler = (cell: U, object: T) -> Void
    public typealias SelectionHandler = (cell: U, scheme: ArrayScheme<T, U>, object: T) -> Void
    public typealias HeightHandler = (object: T) -> RowHeight
    
    /** The reuseIdentifier for this scheme. 
     *
     *  Unlike other concrete Scheme subclasses that have an identifier
     *  for each cell that is being generated, this class takes a single
     *  reuse identifier for all cells. This is because this scheme is
     *  meant to be used with closely related cells.
     */
    public var reuseIdentifier: String!
    
    /** The objects this scheme is representing */
    public var objects: [T]!
    
    /** The closure called to determine the height of this cell.
     *
     *  Unlike other concrete Scheme subclasses that take predefined
     *  values this scheme uses a closure because the height may change
     *  due to the underlying objects state, and this felt like a better
     *  API to accomodate that.
     *
     *  This closure is only used if the table view delegate asks its 
     *  TableScheme for the height with heightInTableView(tableView:forIndexPath:)
     */
    public var heightHandler: HeightHandler?
    
    /** The closure called for configuring the cell the scheme is representing. */
    public var configurationHandler: ConfigurationHandler!
    
    /** The closure called when a cell representing this scheme is selected.
    *
    *  NOTE: This is only called if the TableScheme is asked to handle selection
    *  by the table view delegate.
    */
    public var selectionHandler: SelectionHandler?
    
    // MARK: Property Overrides
    override public var numberOfCells: Int {
        return countElements(objects)
    }
    
    required public init() {
        super.init()
    }
    
    // MARK: Abstract Method Overrides
    override public func configureCell(cell: UITableViewCell, withRelativeIndex relativeIndex: Int) {
        configurationHandler(cell: cell as U, object: objects![relativeIndex])
    }
    
    override public func selectCell(cell: UITableViewCell, inTableView tableView: UITableView, inSection section: Int, havingRowsBeforeScheme rowsBeforeScheme: Int, withRelativeIndex relativeIndex: Int) {
        if let sh = selectionHandler {
            sh(cell: cell as U, scheme: self, object: objects![relativeIndex])
        }
    }
    
    override public func reuseIdentifierForRelativeIndex(relativeIndex: Int) -> String? {
        return reuseIdentifier
    }
    
    override public func heightForRelativeIndex(relativeIndex: Int) -> RowHeight {
        if let hh = heightHandler {
            return hh(object: objects![relativeIndex])
        } else {
            return .UseTable
        }
    }
    
    override public func isValid() -> Bool {
        assert(reuseIdentifier != nil)
        assert(objects != nil)
        assert(configurationHandler != nil)
        return reuseIdentifier != nil && objects != nil && configurationHandler != nil
    }
}

public func ==<T, U: UITableViewCell>(lhs: ArrayScheme<T, U>, rhs: ArrayScheme<T, U>) -> Bool {
    let reuseIdentifiersEqual = lhs.reuseIdentifier == rhs.reuseIdentifier
    var objectsEqual = false
    
    if let lobjs = lhs.objects {
        if let robjs = rhs.objects {
            objectsEqual = lobjs == robjs
        }
    }
    
    return reuseIdentifiersEqual && objectsEqual
}

extension ArrayScheme: InferrableRowAnimatableScheme {
    typealias IdentifierType = T
    
    public var rowIdentifiers: [IdentifierType] {
        return objects!
    }
}
