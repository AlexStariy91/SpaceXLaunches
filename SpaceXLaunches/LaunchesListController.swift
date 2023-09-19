//
//  ViewController.swift
//  SpaceXLaunches
//
//  Created by Alexander Starodub on 01.08.2023.
//

import UIKit
import Kingfisher
import RealmSwift

class LaunchesListController: UIViewController {
    
    @IBOutlet weak var launchesList: UITableView!
    private let urlApi = "https://api.spacexdata.com/v4/launches/query"
    private var requestPageWithLaunches = 1
    private var nextPageExistsWithLaunches = true
    private var launches: [Docs] = []
    private let refreshControl = UIRefreshControl()
    private let tableViewFooterSpinner = UIActivityIndicatorView(style: .medium)
    let realm = try! Realm()
    var items: Results<LaunchRealm>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizingNavigationBar()
        customizingTabBar()
        initUI()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        launchesList.addSubview(refreshControl)
        items = realm.objects(LaunchRealm.self)
        NetworkManager.shared.getPOSTData(numberOfPage: requestPageWithLaunches, urlString: urlApi) { [weak self] (launch) in
            self?.requestPageWithLaunches += 1
            self?.setIsFavoritesPropertyToJsonModel(launch: launch)
            self?.launches = launch.docs
            DispatchQueue.main.async {
                self?.launchesList.reloadData()
            }
        }
        unmarkLaunchFromFavoritesObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("unmarkLaunchFromFavorites"), object: nil)
    }
    
    @objc private func pullToRefresh(){
        requestPageWithLaunches = 1
        NetworkManager.shared.getPOSTData(numberOfPage: requestPageWithLaunches, urlString: urlApi) { [weak self] (launch) in
            self?.requestPageWithLaunches += 1
            self?.setIsFavoritesPropertyToJsonModel(launch: launch)
            self?.launches = launch.docs
            self?.nextPageExistsWithLaunches = true
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                self?.launchesList.reloadData()
            }
        }
    }
    
    @objc private func unmarkLaunchFromFavorite(_ notification: Notification){
        let launchId = notification.object as! String
        guard let index = launches.firstIndex(where: {$0.id == launchId}).flatMap({IndexPath(row: $0, section: 0)}) else {return}
        guard let unmarkFromFavoriteLaunch = launches.first(where: {$0.id == launchId}) else {return}
        unmarkFromFavoriteLaunch.isInFavorites = false
               DispatchQueue.main.async {
                   self.launchesList.reloadRows(at: [index], with: .none)
               }
    }
    
    private func initUI() {
        launchesList.register(UINib(nibName: "LaunchesListTableViewCell", bundle: nil), forCellReuseIdentifier: "LaunchesListTableViewCell")
    }
    
    private func customizingNavigationBar() {
        let appearence = UINavigationBarAppearance()
        appearence.backgroundEffect = .none
        appearence.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationItem.title = "Launches"
        self.navigationController?.navigationBar.standardAppearance = appearence
    }
    
    private func customizingTabBar(){
        let appearence = UITabBarAppearance()
        appearence.backgroundEffect = .none
        self.tabBarController?.tabBar.standardAppearance = appearence
    }
    
    private func unmarkLaunchFromFavoritesObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(unmarkLaunchFromFavorite), name: NSNotification.Name("unmarkLaunchFromFavorites"), object: nil)
    }
    
    private func setIsFavoritesPropertyToJsonModel(launch: JsonLaunch){
        launch.docs.forEach { doc in
            DispatchQueue.main.async {
                self.items.forEach { item in
                    if doc.id == item.id {
                        doc.isInFavorites = item.isInFavorites
                    }
                }
            }
        }
    }
}


// MARK: UITableViewDataSource, UITableViewDelegate
extension LaunchesListController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return launches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LaunchesListTableViewCell",for: indexPath) as! LaunchesListTableViewCell
        cell.favoritesButton.tag = indexPath.row
        cell.delegate = self
        cell.fillUpCellWithJsonModelData(launch: launches[indexPath.row], indexPathRow: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let launchDetailsVC = storyBoard.instantiateViewController(withIdentifier: "LaunchDetailsViewController") as! LaunchDetailsViewController
        launchDetailsVC.launch = launches[indexPath.row]
        launchDetailsVC.indexPathRow = indexPath.row
        launchDetailsVC.delegate = self
        navigationController?.pushViewController(launchDetailsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == launches.count - 1 {
            if nextPageExistsWithLaunches{
                tableViewFooterSpinner.startAnimating()
                tableViewFooterSpinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
                tableView.tableFooterView = tableViewFooterSpinner
                NetworkManager.shared.getPOSTData(numberOfPage: requestPageWithLaunches, urlString: urlApi) { [weak self] (launch) in
                    self?.setIsFavoritesPropertyToJsonModel(launch: launch)
                    self?.launches.append(contentsOf: launch.docs)
                    self?.requestPageWithLaunches += 1
                    self?.nextPageExistsWithLaunches = launch.hasNextPage
                    DispatchQueue.main.async {
                        self?.launchesList.reloadData()
                    }
                }
            } else {
                tableViewFooterSpinner.stopAnimating()
                tableView.tableFooterView = .none
            }
        }
    }
}

// MARK: LaunchesListTableViewCellDelegate
extension LaunchesListController: LaunchesListTableViewCellDelegate {
    func didChangeFavorites(launch: Docs, tag: Int) {
        let index = IndexPath(row: tag, section: 0)
        DispatchQueue.main.async {
            self.launchesList.reloadRows(at: [index], with: .none)
        }
    }
    
    func didAddToFavorites(launchForRealm: LaunchRealm) {
     if !items.contains(where: { item in
         item.id == launchForRealm.id
     }) {
         try! realm.write {
             realm.add(launchForRealm)
         }
     } else {
         try! realm.write {
             realm.delete(realm.objects(LaunchRealm.self).filter({ launch in
                 launch.id == launchForRealm.id
             }))
         }
     }
   }
}

extension LaunchesListController: LaunchDetailsViewControllerDelegate {
    func changeIsInFavoritesPropertyInLaunchesList(launch: Docs, indexPathRow: Int) {
        let index = IndexPath(row: indexPathRow, section: 0)
        DispatchQueue.main.async {
            self.launchesList.reloadRows(at: [index], with: .none)
        }
    }
}
