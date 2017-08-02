//
//  FetchedResultController+extension.swift
//  SwiftyScount
//
//  Created by Roman Mogutnov on 03/08/2017.
//  Copyright © 2017 Score-count. All rights reserved.
//

import Foundation

extension IndexPath {
    
    func sectionAsRow(for section: Int = 0) -> IndexPath {
        return IndexPath(row: self.section, section: section)
    }
    
}

