import SwiftUI // Import SwiftUI for the View struct
import SwiftSoup // Import SwiftSoup for HTML parsing

/*
 * The DepartureGroup struct represents a group of train departures to a specific destination.
 * It contains the destination name and an array of estimated departure times.
 */
struct DepartureGroup: Identifiable, Hashable {
    let id = UUID()
    let destination: String
    var estimatedTimes: [String]
}

/*
 * The StartupScreen view is displayed while the app is loading data.
 * It shows a loading indicator and the company logo.
 */

struct StartupScreen: View {
    @Binding var isLoading: Bool
    @Binding var companyLogo: Image?

    var body: some View {
        ZStack {
            Color.ferro //
            if let companyLogo = companyLogo { // if companyLogo is not nil, display the logo
                companyLogo
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView() // if companyLogo is nil, display a loading indicator
            }
        }
        .ignoresSafeArea() // Ignore safe area to fill the entire screen
    }
}

/*
 * The ContentView struct represents the main view of the app.
 * It displays a list of train departures from a selected station.
 */

struct ContentView: View {
    // Define the state variables
    @State private var retiroDepartures: [DepartureGroup] = []
    @State private var villaRosaDepartures: [DepartureGroup] = []

    @State private var isLoading = true

    @State private var errorMessage: String?

    @State private var companyLogo: Image?

    @State private var selectedStation: Station = .retiro // Set the default selected station to Retiro
    
    @State private var lastRefreshTime: String = ""
    
    @Environment(\.colorScheme) var colorScheme

    /*
     * The Station enum represents the available train stations.
     * Each station has a name and an associated ID.
     */
    enum Station: String, CaseIterable, Identifiable {
        case retiro = "Retiro"
        case saldias = "Saldias"
        case ciudadUniversitaria = "Ciudad Universitaria"
        case ADelValle = "A. del Valle"
        case padilla = "Padilla"
        case florida = "Florida"
        case munro = "Munro"
        case carapachay = "Carapachay"
        case villaAdelina = "Villa Adelina"
        case boulogne = "Boulogne Sur Mer"
        case AMontes = "A. Montes"
        case donTorcuato = "Don Torcuato"
        case ASordeaux = "A. Sordeaux"
        case VDMayo = "Villa de Mayo"
        case LPolvorines = "Los Polvorines"
        case PNougues = "Pablo Nogues"
        case GBourg = "Grand Bourg"
        case TAltas = "Tierras Altas"
        case Tortuguitas = "Tortuguitas"
        case MAlberti = "M. Alberti"
        case DelViso = "Del Viso"
        case CGrierson = "Cecilia Grierson"
        case VRosa = "Villa Rosa"

        var id: String { self.rawValue }

        var idEst: Int {
            switch self {
            case .villaAdelina: return 90
            case .retiro: return 75
            case .saldias: return 78
            case .ciudadUniversitaria : return 80
            case .ADelValle: return 82
            case .padilla : return 84
            case .florida : return 86
            case .munro: return 88
            case .carapachay: return 130
            case .boulogne : return 95
            case .AMontes: return 97
            case .donTorcuato: return 100
            case .ASordeaux: return 103
            case .VDMayo : return 105
            case .LPolvorines : return 108
            case .PNougues : return 111
            case .GBourg : return 113
            case .TAltas : return 116
            case .Tortuguitas : return 118
            case .MAlberti : return 120
            case .DelViso : return 123
            case .CGrierson : return 135
            case .VRosa : return 126
            }
        }
    }
    
    /*
     * The body property defines the view's layout and behavior.
     * It contains a ZStack with two main components: the StartupScreen and the main content.
     */

    var body: some View {
           ZStack {
               if isLoading { // Display the StartupScreen while loading data
                   StartupScreen(isLoading: $isLoading, companyLogo: $companyLogo)
               } else { // Display the main content once data is loaded
                   NavigationView {
                       VStack(alignment: .center, spacing: 0) { // <-- No spacing in VStack
                           ZStack {
                               Color.ferro.ignoresSafeArea()
                               VStack(alignment: .center, spacing: 8) { // <-- Add spacing between elements
                                   Image("Logo")
                                       .resizable()
                                       .scaledToFit()
                                       .frame(height: 80)
                                
                                   Picker("Station", selection: $selectedStation) { // <-- Use a Picker to select the station
                                       ForEach(Station.allCases) { station in
                                           Text(station.rawValue).tag(station)
                                               .foregroundColor(.black)
                                       }
                                   }
                                   .pickerStyle(.menu)
                                   .padding(.horizontal)
                                   .background(
                                       RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.2))
                                   )
                                   .foregroundColor(.white)
                                   .font(.headline)
                                   .onChange(of: selectedStation) { _ in
                                       fetchTrainData()
                                       
                                   }
                               }
                               .padding(.top, 20)
                               
                           }
                           .frame(maxHeight: 150)
                           
                           ZStack {
                                                       // Background color for the refresh section
                                                       Color.ferro.ignoresSafeArea()
                                                       
                                                       HStack {
                                                           // Spacer() // Push the refresh button and text to the right
                                                           Button(action: {
                                                               fetchTrainData()
                                                           }) {
                                                               Image(systemName: "arrow.clockwise")
                                                                   .font(.title2) // Adjust font size as needed
                                                                   .foregroundColor(.white)
                                                           }
                                                           .buttonStyle(.borderedProminent)
                                                        
                                                       }
                                                   }
                                                   .frame(maxHeight: 60)

                           if isLoading { // Display a loading indicator while fetching data
                               ProgressView()
                           } else if let errorMessage = errorMessage { // Display an error message if an error occurred
                               Text("Error: \(errorMessage)")
                                   .foregroundColor(.red)
                           } else {
                               List {
                                Section(header: Text("Retiro")) { // <-- Add a header to the section
                                    ForEach(retiroDepartures) { group in // <-- Iterate over the retiroDepartures array
                                        DepartureGroupView(group: group) // <-- Display the DepartureGroupView for each group
                                    }
                                }
                                Section(header: Text("Villa Rosa")) { // Same for Villa Rosa
                                    ForEach(villaRosaDepartures) { group in
                                        DepartureGroupView(group: group)
                                    }
                                }
                            }
                        }
                        Spacer() // Push the text to the bottom by adding a Spacer before it

                                                   // Display the last refresh time at the bottom
                                                   Text("Updated: \(lastRefreshTime)")
                               .foregroundColor(colorScheme == .dark ? .white : .black)
                                                       .padding()
                    }
                    .navigationTitle("Estación \(selectedStation.rawValue)") // Set the navigation title to the selected station
                    .navigationBarTitleDisplayMode(.inline) // Set the navigation title display mode to inline for smaller titles
                    
                }
            }
        }
        .onAppear { // Fetch train data and company logo when the view appears
            fetchTrainData()
            fetchCompanyLogo()
        }
    }
    
    func fetchTrainData() { // Fetch train data from the server
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "http://proximostrenes.ferrovias.com.ar/estaciones.asp") else { // Create a URL object from the URL string
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "idEst=\(selectedStation.idEst)&adm=1".data(using: .utf8) // Set the HTTP body with the selected station ID

        URLSession.shared.dataTask(with: request) { data, _, error in
            defer { isLoading = false }
            
            if let error = error {
                errorMessage = "Network error: \(error.localizedDescription)" // Display an error message if a network error occurs
                return
            }
 
            guard let data = data, // Check if data is not nil
                  let html = String(data: data, encoding: .utf8) else { // Convert the data to a UTF-8 string
                errorMessage = "Invalid data received"
                return
            }

            do {
                let doc = try SwiftSoup.parse(html) // Parse the HTML data using SwiftSoup
                let rows = try doc.select("table#table_main_box table#table_main tr") // Select the table rows containing the train data (table#table_main_box table#table_main tr)

                var departures: [DepartureGroup] = [] // Create an empty array to store the departure groups
                for row in rows {
                    if let destinationCell = try? row.select("td.tdEst").first(), // Select the destination cell
                       let destination = try? destinationCell.text(),
                       !destination.isEmpty { // Get the destination name and check if it's not empty

                        if let index = departures.firstIndex(where: { $0.destination == destination }) { // Check if the destination already exists in the departures array
                            if let estimatedTime = try? row.select("td.tdEst.tdEstr.tdflecha").text(), !estimatedTime.isEmpty { // Get the estimated departure time
                                departures[index].estimatedTimes.append(estimatedTime) // Append the estimated time to the existing group
                            }
                        } else {
                            let estimatedTime = try row.select("td.tdEst.tdEstr.tdflecha").text() // Get the estimated departure time
                            departures.append(DepartureGroup(destination: destination, estimatedTimes: [estimatedTime])) // Create a new departure group
                        }
                    }
                }

                retiroDepartures = departures.filter { $0.destination.contains("RETIRO") } // Filter the departures for Retiro
                villaRosaDepartures = departures.filter { !$0.destination.contains("RETIRO") } // Filter the departures for Villa Rosa

                DispatchQueue.main.async { // Update the UI on the main thread
                    self.retiroDepartures = retiroDepartures
                    self.villaRosaDepartures = villaRosaDepartures
                }
            } catch { // Catch any parsing errors
                errorMessage = "Error parsing data: \(error.localizedDescription)"
            }
            DispatchQueue.main.async {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm:ss" // Choose your desired time format
                self.lastRefreshTime = dateFormatter.string(from: Date()) }
        }.resume()
    }

    func fetchCompanyLogo() {
        // guard let url = URL(string: "https://i.pinimg.com/originals/1f/e5/c0/1fe5c07585a5dbfce82d90e89b085410.jpg") else {
        //     return
        // }

        // URLSession.shared.dataTask(with: url) { data, _, error in
        //     if let error = error {
        //         print("Error loading company logo: \(error.localizedDescription)")
        //         return
        //     }

        //     guard let data = data, let uiImage = UIImage(data: data) else {
        //         print("Invalid image data")
        //         return
        //     }

        //     DispatchQueue.main.async {
        //         self.companyLogo = Image("Logo")
        //     }
        // }.resume()
        self.companyLogo = Image("Logo") // Set the company logo image from the assets catalog directly
    }
}

/*
 * The DepartureGroupView struct represents a view for displaying a group of train departures.
 * It contains the destination name and a list of estimated departure times.
 */

struct DepartureGroupView: View { // Define the DepartureGroupView struct
    let group: DepartureGroup

    var body: some View {
        VStack(alignment: .leading) {
            Text(group.destination).font(.headline) // Display the destination name as a headline
            ForEach(group.estimatedTimes, id: \.self) { time in // Iterate over the estimated departure times
                Text(time) // Display each estimated time
            }

        }
    }
}

/*
 * The ContentView_Previews struct provides a preview for the ContentView.
 */

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
