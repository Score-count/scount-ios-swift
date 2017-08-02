//
//  ManagedObject+extension.swift
//  SwiftyScount
//
//  Created by Roman Mogutnov on 03/08/2017.
//  Copyright © 2017 Score-count. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import AERecord

extension NSManagedObject {
    
    @discardableResult func updateAttributes(with keyedValues: [String: Any]) -> Bool {
        let attributesByName = entity.attributesByName
        var values = [String: Any]()
        
        for attributeByName in attributesByName {
            switch attributeByName.value.attributeType {
            case .undefinedAttributeType:
                break
            case .integer16AttributeType:
                if let v = keyedValues[attributeByName.key] as? Int16 {
                    values[attributeByName.key] = v
                }
            case .integer32AttributeType:
                if let v = keyedValues[attributeByName.key] as? Int32 {
                    values[attributeByName.key] = v
                }
            case .integer64AttributeType:
                if let v = keyedValues[attributeByName.key] as? Int64 {
                    if value(forKey: attributeByName.key) as! Int64? != v {
                        values[attributeByName.key] = v
                    }
                }
            case .decimalAttributeType:
                if let v = keyedValues[attributeByName.key] {
                    values[attributeByName.key] = NSDecimalNumber(string: JSON(v).stringValue)
                }
            case .doubleAttributeType:
                if let v = keyedValues[attributeByName.key] as? Double {
                    values[attributeByName.key] = v
                }
            case .floatAttributeType:
                if let v = keyedValues[attributeByName.key] as? Float {
                    values[attributeByName.key] = v
                }
            case .stringAttributeType:
                if let v = keyedValues[attributeByName.key] as? String {
                    if value(forKey: attributeByName.key) as! String? != v {
                        values[attributeByName.key] = v
                    }
                }
            case .booleanAttributeType:
                if let v = keyedValues[attributeByName.key] as? Bool {
                    if value(forKey: attributeByName.key) as! Bool? != v {
                        values[attributeByName.key] = v
                    }
                }
            case .dateAttributeType:
                if let v = keyedValues[attributeByName.key] as? String {
                    if let date = v.dateISO8601 {
                        values[attributeByName.key] = date
                    }
                }
            case .binaryDataAttributeType:
                if let v = keyedValues[attributeByName.key] as? Data {
                    values[attributeByName.key] = v
                }
            case .transformableAttributeType:
                // If your attribute is of NSTransformableAttributeType, the attributeValueClassName must be set or attribute value class must implement NSCopying.
                if let v = keyedValues[attributeByName.key] {
                    if let val = value(forKey: attributeByName.key) {
                        if JSON(val).rawString(options: JSONSerialization.WritingOptions(rawValue: 0)) != JSON(v).rawString(options: JSONSerialization.WritingOptions(rawValue: 0)) {
                            values[attributeByName.key] = v
                        }
                    } else {
                        values[attributeByName.key] = v
                    }
                }
                
            case .objectIDAttributeType:
                // Кто придумает, как это использовать - велкам
                break
            }
        }
        
        if values.count > 0 {
            setValuesForKeys(values)
            return true
        } else {
            return false
        }
    }
    
    
    /// refreshes relationship set in main context
    ///
    /// - Parameter set: set of objects to refresh
    func refreshObjects(set: NSSet?) {
        let ids = set?.map { ($0 as! NSManagedObject).objectID } ?? []
        AERecord.refreshObjects(with: ids, mergeChanges: true, in: AERecord.Context.main) // note that faulting objects does not make much sense outside the main context - it's purpose is pretty much only to trigger refresh of a FRC that's tied to UI displaying fields of a relationship
    }
    
    /// refreshes relationship in main context
    ///
    /// - Parameter set: set of objects to refresh
    func refreshObject(_ object: NSManagedObject?) {
        guard let id = object?.objectID else { return }
        AERecord.refreshObjects(with: [id], mergeChanges: true, in: AERecord.Context.main) // see note above
    }
    
    
    /// returns an instance of the object from context matching current thread
    ///
    /// - Parameter context: specific context
    /// - Returns: same object on specified context
    func `in`(context: NSManagedObjectContext = AERecord.Context.default) -> Self {
        return inContext(type: type(of: self), context: context)
    }
    
    // facilitates method above
    private func inContext<T>(type: T.Type, context: NSManagedObjectContext = AERecord.Context.default) -> T {
        return context.object(with: self.objectID) as! T
    }
    
}


class DictionaryTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let dictionary = value as? [String: Any] else {
            return nil
        }
        
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(dictionary, forKey: "DictionaryTransformer")
        archiver.finishEncoding()
        
        return data
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            return nil
        }
        
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        if let dictionary = unarchiver.decodeObject(forKey: "DictionaryTransformer") as? [String: Any] {
            return dictionary
        }
        
        return nil
    }
    
}

class ArrayTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let array = value as? [Any] else {
            return nil
        }
        
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(array, forKey: "ArrayTransformer")
        archiver.finishEncoding()
        
        return data
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            return nil
        }
        
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        if let array = unarchiver.decodeObject(forKey: "ArrayTransformer") as? [Any] {
            return array
        }
        
        return nil
    }
    
}

extension Date {
    
    struct Date {
        static let formatterISO8601: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
            return formatter
        }()
    }
    
    var formattedISO8601: String { return Date.formatterISO8601.string(from: self) }
    
}

extension String {
    
    var dateISO8601: Date? { return Date.Date.formatterISO8601.date(from: self) }
    
}
