//
//  FavoritesListViewController.swift
//  SpaceXLaunches
//
//  Created by Alexander Starodub on 01.08.2023.
//

import UIKit
import RealmSwift

class FavoritesListViewController: UIViewController {

    @IBOutlet weak var noFavoriteLaunches: UILabel!
    @IBOutlet weak var favoritesTableView: UITableView!
    private var favoriteLaunches: Results<LaunchRealm>!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizingNavigationBar()
        customizingTabBar()
        initUI()
        favoriteLaunches = realm.objects(LaunchRealm.self)
        addRealmChangeObserver()
    }
        
    private func initUI() {
        favoritesTableView.register(UINib(nibName: "LaunchesListTableViewCell", bundle: nil), forCellReuseIdentifier: "LaunchesListTableViewCell")
    }
    
    private func customizingNavigationBar() {
        let appearence = UINavigationBarAppearance()
        appearence.backgroundEffect = .none
        appearence.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationItem.title = "Favorites"
        self.navigationController?.navigationBar.standardAppearance = appearence
        
    }
    
    private func customizingTabBar() {
        let appearence = UITabBarAppearance()
        appearence.backgroundEffect = .none
        self.tabBarController?.tabBar.standardAppearance = appearence
    }
    
    private func addRealmChangeObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(realmHasChanged), name: NSNotification.Name("RealmChanged"), object: nil)
    }
    
    @objc func realmHasChanged(_ notification: Notification) {
        favoriteLaunches = realm.objects(LaunchRealm.self)
        DispatchQueue.main.async {
            self.favoritesTableView.reloadData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("RealmChanged"), object: nil)
    }
}


// MARK: UITableViewDataSource, UITableViewDelegate
extension FavoritesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favoriteLaunches.count != 0 {
            favoritesTableView.isHidden = false
            noFavoriteLaunches.isHidden = true
            self.navigationItem.leftBarButtonItem = self.editButtonItem
            return favoriteLaunches.count
        } else {
            favoritesTableView.isHidden = true
            noFavoriteLaunches.isHidden = false
            self.navigationItem.leftBarButtonItem = .none
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LaunchesListTableViewCell", for: indexPath) as! LaunchesListTableViewCell
        cell.favoritesButton.isHidden = true
        cell.fillUpCellWithDataRealmModelData(launchRealm: favoriteLaunches[indexPath.row], indexPathRow: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            let editingRow = favoriteLaunches[indexPath.row]
            NotificationCenter.default.post(name: NSNotification.Name("unmarkLaunchFromFavorites"), object: editingRow.id)
            NotificationCenter.default.post(name: NSNotification.Name("unmarkLaunchInDetailsVC"), object: nil)
            try! realm.write {
                realm.delete(editingRow)
            }
            tableView.deleteRows(at: [indexPath], with: .left)
            if favoriteLaunches.count == 0 {
                self.setEditing(false, animated: false)
            }
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.setEditing(true, animated: false)
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        self.setEditing(false, animated: false)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        DispatchQueue.main.async {
            self.favoritesTableView.setEditing(editing, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let detailsVC = storyBoard.instantiateViewController(withIdentifier: "LaunchDetailsViewController") as! LaunchDetailsViewController
        detailsVC.launchFromRealm = favoriteLaunches[indexPath.row]
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}
