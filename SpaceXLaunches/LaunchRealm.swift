//
//  LaunchRealm.swift
//  SpaceXLaunches
//
//  Created by Alexander Starodub on 07.09.2023.
//

import Foundation
import RealmSwift


class LaunchRealm: Object {
    @Persisted var idYoutube: String = ""
    @Persisted var wikipedia: String = ""
    @Persisted var name: String = ""
    @Persisted var date: String = ""
    @Persisted var details: String = ""
    @Persisted var smallIcon: String = ""
    @Persisted var rocketName: String = ""
    @Persisted var payloads: Double = 0
    @Persisted var id: String = ""
    @Persisted var isInFavorites = false
}
