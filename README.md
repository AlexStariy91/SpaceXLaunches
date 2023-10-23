# SpaceXLaunches
App for iOS that shows all the latest launches and their details from open-source API SpaceX
This app has 3 screens:
1) The Launches screen shows all the latest launches from API https://github.com/r-spacex/SpaceX-API.
   Each launch cell has an image, launch name, and date, also there is an opportunity to add or delete a launch to Favorites.
2) Details screen shows webcast, rocket name, payload mass, and wiki website, also there is an opportunity to add or delete launch to Favorites. (Some parameters can be absent,
   because of API)
3) The Favorites screen shows the list of all added by user launches, they are saved in local DB, so after the app restarts they will be re-displayed. From that screen user
   can delete the launch from favorites and open details of the saved launch.
