//
//  Launches.swift
//  SpaceXLaunches
//
//  Created by Alexander Starodub on 23.08.2023.
//

import Foundation
import RealmSwift

class JsonLaunch: Codable {
    let docs: [Docs]
    let page: Int
    let totalPages: Int
    let hasPrevPage: Bool
    let hasNextPage: Bool
}

class Docs: Codable {
    
    let links: Links?
    let name: String?
    let date: String?
    let details: String?
    let rocket: Rocket?
    let payloads: [Payloads]?
    let id: String?
    var isInFavorites = false
    
    
    enum CodingKeys: String, CodingKey {
        case links
        case name
        case date = "date_local"
        case details
        case rocket
        case payloads
        case id
    }
}

// MARK: -Links
class Links: Codable {
    let patch: Patch?
    let idYoutube: String?
    let wikipedia: String?
    
    enum CodingKeys: String, CodingKey {
        case patch
        case idYoutube = "youtube_id"
        case wikipedia
    }
}

// MARK: - Patch
class Patch: Codable {
    let small: String?
}


// MARK: - Rocket
class Rocket: Codable {
    let name: String?
}

// MARK: - Payloads

class Payloads: Codable {
    let massKG: Double?
    enum CodingKeys: String, CodingKey {
        case massKG = "mass_kg"
    }
}

extension Docs {
    func convertToRealmModel() -> LaunchRealm {
        let realmModel = LaunchRealm()
        realmModel.idYoutube = self.links?.idYoutube ?? ""
        realmModel.wikipedia = self.links?.wikipedia ?? ""
        realmModel.name = self.name ?? ""
        realmModel.date = self.date ?? ""
        realmModel.details = self.details ?? ""
        realmModel.smallIcon = self.links?.patch?.small ?? ""
        realmModel.rocketName = self.rocket?.name ?? ""
        realmModel.id = self.id ?? ""
        realmModel.isInFavorites = self.isInFavorites
        var totalPayloadMass: Double = 0
        if let mass = self.payloads {
            mass.forEach { payload in
                totalPayloadMass += payload.massKG ?? 0
            }
        }
        realmModel.payloads = totalPayloadMass
        return realmModel
    }
}
