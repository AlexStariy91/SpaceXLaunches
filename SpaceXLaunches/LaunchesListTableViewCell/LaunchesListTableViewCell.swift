//
//  LaunchesListTableViewCell.swift
//  SpaceXLaunches
//
//  Created by Alexander Starodub on 02.08.2023.
//

import UIKit
import RealmSwift

 protocol LaunchesListTableViewCellDelegate: AnyObject{
     func didChangeFavorites(launch: Docs, tag: Int)
     func didAddToFavorites(launchForRealm: LaunchRealm)
}

extension LaunchesListTableViewCellDelegate {
    func didChangeFavorites(launch: Docs, tag: Int) {}
    func didAddToFavorites(launchForRealm: LaunchRealm) {}
}

class LaunchesListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var highlightView: UIView!
    @IBOutlet weak var launchDate: UILabel!
    @IBOutlet weak var launchName: UILabel!
    @IBOutlet weak var launchImage: UIImageView!
    @IBOutlet weak var favoritesButton: UIButton!
    private var currentLaunch: Docs?
    weak var delegate: LaunchesListTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.4) {
            self.highlightView.alpha = highlighted ? 0.3 : 0
        }
    }
    
    func fillUpCellWithJsonModelData(launch: Docs, indexPathRow: Int){
        currentLaunch = launch
        favoritesButton.setImage(UIImage(systemName: "star" + (currentLaunch!.isInFavorites ? ".fill" : "")), for: .normal)
        launchName.text = launch.name
        installLaunchDate(date: launch.date)
        installLaunchIconImage(urlString: launch.links?.patch?.small)
    }
    
    func fillUpCellWithDataRealmModelData(launchRealm: LaunchRealm, indexPathRow: Int ) {
        favoritesButton.setImage(UIImage(systemName: "star" + (launchRealm.isInFavorites ? ".fill" : "")), for: .normal)
        launchName.text = launchRealm.name
        installLaunchIconImage(urlString: launchRealm.smallIcon)
        installLaunchDate(date: launchRealm.date)
    }
    
    func installLaunchIconImage(urlString: String?) {
        let emptyImage = UIImage(systemName: "photo.circle")?.withRenderingMode(.alwaysOriginal).withTintColor(.gray)
        if let imageString = urlString {
            guard let url = URL(string: imageString) else {
                launchImage.image = emptyImage
                return
            }
            launchImage.kf.indicatorType = .activity
            launchImage.kf.setImage(with: url)
        } else {
            launchImage.image = emptyImage
        }
    }
    
    func installLaunchDate(date: String?) {
        guard let dateString = date else {return}
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate, .withFullTime]
        if let date = isoFormatter.date(from: dateString){
            let outputFormatter = DateFormatter()
            outputFormatter.locale = Locale(identifier: "en_US_POSIX")
            outputFormatter.dateStyle = .long
            outputFormatter.timeStyle = .short
            let launchDateString = outputFormatter.string(from: date)
            launchDate.text = "Launch date: \(launchDateString)"
        }
    }
    

    @IBAction func addToFavorites(_ sender: UIButton) {
        HapticManager.shared.selectionVibrate()
        guard let currentLaunch else {return}
        currentLaunch.isInFavorites = !currentLaunch.isInFavorites
        delegate?.didChangeFavorites(launch: currentLaunch, tag: favoritesButton.tag)
        let realmModel = currentLaunch.convertToRealmModel()
        delegate?.didAddToFavorites(launchForRealm: realmModel)
        NotificationCenter.default.post(name: NSNotification.Name("RealmChanged"), object: nil)
    }
}
