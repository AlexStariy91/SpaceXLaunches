//
//  HapticManager.swift
//  SpaceXLaunches
//
//  Created by Alexander Starodub on 29.08.2023.
//

import Foundation
import UIKit

final class HapticManager {
    static let shared = HapticManager()
    private init(){}
    
    public func selectionVibrate(){
        let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        selectionFeedbackGenerator.prepare()
        selectionFeedbackGenerator.selectionChanged()
    }
}
