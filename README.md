# Ferrovias trains ETA for iOS

## About

This SwiftUI app provides real-time departure information for trains on the Ferrovias network in Argentina. It displays upcoming departures to "Retiro" and "Villa Rosa" based on the selected station.

## Features

- **Real-time data:** Fetches the latest departure times directly from the Ferrovias website.
- **Station selection:** Choose your desired station from a dropdown menu.
- **Organized display:** Departures are grouped by destination for easy viewing.
- **Loading indicator:** Provides feedback while data is being fetched.
- **Error handling:** Displays messages for network or parsing errors.

## Usage
0. **NOT YET AVAILABLE FOR DOWNLOAD**
1. **Download:** Download the pre-built app binary from the "Releases" section of this repository.
2. **Open:** Launch the app on your iOS device.
3. **Select Station:** Choose the station you're interested in from the dropdown menu at the top.
4. **View Departures:** The app will automatically display the upcoming departures for the selected station.

## Important Notes

- **No Modification:** This app is designed to be used as-is.  It's not intended for users to modify the code. 
- **Data Source:** Departure information is scraped from the Ferrovias website. Any changes to the website structure may affect the app's functionality.
- **Network Connection:** A stable internet connection is required for the app to work properly.

## Dependencies

- **SwiftUI:** Apple's UI framework used for building the app's interface.
- **SwiftSoup:** A library for parsing HTML and extracting data from web pages.

## Author

[Federico Diaz Nemeth](https://github.com/Defeeeee)

## Known Bugs
 - Due to the trains sorting logic, trains departing from a station like "Villa Rosa" or "Grand Bourg" with destination "Boulogne Sur Mer" will fall onto the "Villa Rosa" Category

## License
This project is licensed under the MIT License - see the LICENSE file for details.

This app is distributed for informational purposes only and is not affiliated with Ferrovias.  Please refer to the [Ferrovias website](http://proximostrenes.ferrovias.com.ar/) for official departure information.
