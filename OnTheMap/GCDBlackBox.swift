//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created by Yeontae Kim on 6/7/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
