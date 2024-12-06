import SwiftUI
import SwiftSoup
import WidgetKit

struct ContentView: View {
    @State private var selectedStation: Station = .villaAdelina
    @State private var departureInfo: [DepartureGroup] = []
    @State private var lastRefreshTime = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(Station.allCases) { station in
                    NavigationLink(value: station) {
                        Text(station.rawValue)
                    }
                }
            }
            .navigationDestination(for: Station.self) { station in
                DepartureListView(station: station)
            }
            .navigationTitle("Select Station")
        }
    }

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
            case .retiro: return 75
            case .saldias: return 78
            case .ciudadUniversitaria : return 80
            case .ADelValle: return 82
            case .padilla : return 84
            case .florida : return 86
            case .munro: return 88
            case .villaAdelina: return 90
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
            case .VRosa : return 126
            case .carapachay: return 130
            case .CGrierson : return 135
            }
        }
    }

    struct DepartureGroup: Identifiable {
        let id = UUID()
        let destination: String
        let estimatedTime: String?
    }

    struct DepartureListView: View {
        let station: Station
        @State private var departureInfo: [DepartureGroup] = []
        @State private var lastRefreshTime = ""
        @State private var isLoading = true

        var body: some View {
            VStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    List(departureInfo) { group in
                        DepartureGroupView(group: group)
                    }
                }
            }
            .refreshable {
                fetchTrainData()
            }
            
            
            .navigationTitle(station.rawValue)
//                    .toolbar {
//                        Button(action: {
//                            WKInterfaceController.reloadRootPageControllers(
//                                withNames: ["StationSelection"],
//                                contexts: nil,
//                                orientation: .horizontal,
//                                pageIndex: 0)
//                        }) {
//                            Image(systemName: "chevron.left")
//                        }
//                        .buttonStyle(.plain)
//                    }
            Text("Updated: \(lastRefreshTime)")
                .font(.caption)
                .onAppear {
                    fetchTrainData()
                }
        }
        struct DepartureGroupView: View {
                        let group: DepartureGroup

                        var body: some View {
                            HStack {
                                Text(group.destination)
                                Spacer()
                                Text(group.estimatedTime ?? "N/A") // Display "N/A" if no time
                            }
                        }
                    }


        func fetchTrainData() {
            isLoading = true // Start loading
            
            guard let url = URL(string: "http://proximostrenes.ferrovias.com.ar/estaciones.asp") else {
                DispatchQueue.main.async {
                    self.departureInfo = [] // Clear departures on error
                    self.lastRefreshTime = "Error: Invalid URL"
                    isLoading = false // Stop loading
                }
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = "idEst=\(station.idEst)&adm=1".data(using: .utf8)

            URLSession.shared.dataTask(with: request) { data, response, error in
                // Error Handling
                if let error = error {
                    print("Error fetching data: \(error)")
                    DispatchQueue.main.async {
                        self.departureInfo = [
                            DepartureGroup(destination: "Retiro", estimatedTime: "Error fetching data"),
                            DepartureGroup(destination: "Villa Rosa", estimatedTime: nil)
                        ]
                        self.lastRefreshTime = ""
                        isLoading = false // Stop loading
                    }
                    return
                }

                guard let data = data, let html = String(data: data, encoding: .utf8) else {
                    print("Invalid data or HTML")
                    DispatchQueue.main.async {
                        self.departureInfo = [
                            DepartureGroup(destination: "Retiro", estimatedTime: "Error: Invalid data"),
                            DepartureGroup(destination: "Villa Rosa", estimatedTime: nil)
                        ]
                        self.lastRefreshTime = ""
                        isLoading = false // Stop loading
                    }
                    return
                }

                // Parsing (assuming the HTML structure is correct)
                do {
                    let doc = try SwiftSoup.parse(html)
                    let rows = try doc.select("table#table_main_box table#table_main tr")
                    

                    var firstRetiroDeparture: String?
                    var firstVillaRosaDeparture: String?

                    for row in rows {
                        let destination = try row.select("td.tdEst").first()?.text() ?? ""
                        if destination.contains("RETIRO") && firstRetiroDeparture == nil {
                            firstRetiroDeparture = try row.select("td.tdEst.tdEstr.tdflecha").first()?.text()
                        } else if !destination.contains("RETIRO") && firstVillaRosaDeparture == nil {
                            firstVillaRosaDeparture = try row.select("td.tdEst.tdEstr.tdflecha").first()?.text()
                        }
                        if firstRetiroDeparture != nil && firstVillaRosaDeparture != nil {
                            break
                        }
                    }


                    // Update UI
                    DispatchQueue.main.async {
                        self.departureInfo = [
                            DepartureGroup(destination: "Retiro", estimatedTime: firstRetiroDeparture),
                            DepartureGroup(destination: "Villa Rosa", estimatedTime: firstVillaRosaDeparture)
                        ]
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "HH:mm:ss"
                        self.lastRefreshTime = dateFormatter.string(from: Date())
                        isLoading = false // Stop loading
                        WidgetCenter.shared.reloadAllTimelines()
                    }

                } catch {
                    print("Error parsing HTML: \(error)")
                    DispatchQueue.main.async {
                        self.departureInfo = [
                            DepartureGroup(destination: "Retiro", estimatedTime: "Error parsing data"),
                            DepartureGroup(destination: "Villa Rosa", estimatedTime: nil)
                        ]
                        self.lastRefreshTime = ""
                        isLoading = false // Stop loading
                    }
                }
            }.resume()
        }
    }
}

#Preview {
    ContentView()
}
