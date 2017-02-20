//
//  Mappable.swift
//  together
//
//  Created by ASda Bogasd on 19.02.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import Foundation

protocol Mappable {
    static func modelToDictionary(model:Any?) -> NSDictionary
    static func dictionaryToModel(dictionary:NSDictionary) -> Any?
}
