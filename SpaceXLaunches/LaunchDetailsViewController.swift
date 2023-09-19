//
//  LaunchDetailsViewController.swift
//  SpaceXLaunches
//
//  Created by Alexander Starodub on 01.08.2023.
//

import youtube_ios_player_helper
import UIKit
import RealmSwift

protocol LaunchDetailsViewControllerDelegate: AnyObject {
    func changeIsInFavoritesPropertyInLaunchesList(launch: Docs, indexPathRow: Int)
}

class LaunchDetailsViewController: UIViewController {
    
    @IBOutlet weak var wikiButton: UIButton!
    @IBOutlet weak var nameAndPayload: UILabel!
    @IBOutlet weak var launchDetails: UILabel!
    @IBOutlet weak var noWebcastLabel: UILabel!
    @IBOutlet weak var playerView: YTPlayerView!
    weak var delegate: LaunchDetailsViewControllerDelegate?
    let realm = try! Realm()
    var indexPathRow: Int = 0
    var launch: Docs?
    var launchFromRealm: LaunchRealm?
    var favoriteBarButtonItem: UIBarButtonItem?
    var favoriteImage: UIImage {
        if launch != nil{
            return UIImage(systemName: "star" + (launch!.isInFavorites ? ".fill" : ""))!
        }
        return UIImage()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizingNavigationBar()
        addUnmarkLaunchFromFavoritesObserver()
        if launch != nil {
            fillUpDetailsControllerWithData(wikipedia: launch?.links?.wikipedia ?? "", rocketName: launch?.rocket?.name ?? "", payloadMass: calculateTotalPayloadMassFromJsonModel(), webcast: launch?.links?.idYoutube ?? "", details: launch?.details ?? "")
        }
        
        if launchFromRealm != nil {
            fillUpDetailsControllerWithData(wikipedia: launchFromRealm?.wikipedia ?? "", rocketName: launchFromRealm?.rocketName ?? "", payloadMass: launchFromRealm?.payloads ?? 0, webcast: launchFromRealm?.idYoutube ?? "", details: launchFromRealm?.details ?? "")
        }
    }
    
    @IBAction func openWikiPage(_ sender: UIButton) {
        var wikiUrlString = ""
        if launch != nil {
            wikiUrlString = launch?.links?.wikipedia ?? ""
        }
        if launchFromRealm != nil {
            wikiUrlString = launchFromRealm?.wikipedia ?? ""
        }
        guard let url = URL(string: wikiUrlString) else {return}
        UIApplication.shared.open(url)
    }
    
    private func customizingNavigationBar() {
        favoriteBarButtonItem = UIBarButtonItem(image: favoriteImage, style: .plain, target: self, action: #selector(onTapFavoriteButton))
        navigationItem.rightBarButtonItem = favoriteBarButtonItem
        navigationItem.rightBarButtonItem?.tintColor = .systemOrange
    }
    
    private func fillUpDetailsControllerWithData(wikipedia: String, rocketName: String, payloadMass: Double, webcast: String, details: String){
        if !wikipedia.isEmpty {
            wikiButton.isHidden = false
        } else {
            wikiButton.isHidden = true
        }
        
        if payloadMass != 0 {
            nameAndPayload.text = ("Rocket name: \(rocketName)\nPayload mass: \(payloadMass)kg")
        } else {
            nameAndPayload.text = ("Rocket name: \(rocketName)\nPayload mass: no information")
        }
        
        if !details.isEmpty {
            launchDetails.text = ("Description: \(details)")
        } else {
            launchDetails.text = "This launch has no description"
        }
        
        if !webcast.isEmpty {
            noWebcastLabel.isHidden = true
            playerView.load(withVideoId: webcast)
        } else {
            noWebcastLabel.isHidden = false
        }
    }
    
    private func addUnmarkLaunchFromFavoritesObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(unmarkLaunchFromFavorites), name: NSNotification.Name("unmarkLaunchInDetailsVC"), object: nil)
    }
    
    @objc func unmarkLaunchFromFavorites(_ notification: Notification) {
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: "star")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("unmarkLaunchInDetailsVC"), object: nil)
    }
    
    private func calculateTotalPayloadMassFromJsonModel() -> Double {
        var totalPayloadMass: Double = 0
        if let payloadMass = launch?.payloads {
            payloadMass.forEach { payload in
                if let mass = payload.massKG {
                    totalPayloadMass += mass
                }
            }
        }
        return totalPayloadMass
    }
    
    @objc private func onTapFavoriteButton() {
        HapticManager.shared.selectionVibrate()
        guard let currentLaunch = launch else {return}
        currentLaunch.isInFavorites = !currentLaunch.isInFavorites
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: "star" + (currentLaunch.isInFavorites ? ".fill" : ""))
        delegate?.changeIsInFavoritesPropertyInLaunchesList(launch: currentLaunch, indexPathRow: indexPathRow)
        let realmModel = currentLaunch.convertToRealmModel()
        let items = realm.objects(LaunchRealm.self)
        if realmModel.isInFavorites {
            if !items.contains(where: { item in
                item.id == realmModel.id
            }) {
                try! realm.write {
                    realm.add(realmModel)
                }
            }
        } else {
            try! realm.write {
                realm.delete(items.filter({ item in
                    item.id == realmModel.id
                }))
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name("RealmChanged"), object: nil)
    }
}
