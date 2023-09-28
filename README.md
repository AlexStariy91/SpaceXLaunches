# SpaceXLaunches
App for iOS that shows all latest launches and their details from open source API SpaceX
This app has 3 screens:
1) Launches screen shows all latest launches from API https://github.com/r-spacex/SpaceX-API.
   Each launch cell has image, launch name and date, also there is opportunity to add or delete launch to Favorites.
2) Details screen shows webcast, rocket name, payload mass, wiki website, also there is opportunity to add or delete launch to Favorites.(Some parameters can be apsent,
   because of API)
3) Favorites screen shows list of all added by user launches, they are saved in local DB, so after app restarts they will be re-displayed. From that screen user
   can delete launch from favorites and open details of saved launch.
