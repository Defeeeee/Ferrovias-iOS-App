
import SwiftUI
import SwiftSoup

struct DepartureGroup: Identifiable, Hashable {
    let id = UUID()
    let destination: String
    var estimatedTimes: [String]
}

struct StartupScreen: View {
    @Binding var isLoading: Bool
    @Binding var companyLogo: Image?

    var body: some View {
        ZStack {
            Color.ferro
            if let companyLogo = companyLogo {
                companyLogo
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
            }
        }
        .ignoresSafeArea()
    }
}

struct ContentView: View {
    @State private var retiroDepartures: [DepartureGroup] = []
    @State private var villaRosaDepartures: [DepartureGroup] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var companyLogo: Image?
    @State private var selectedStation: Station = .retiro

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
    
    var body: some View {
           ZStack {
               if isLoading {
                   StartupScreen(isLoading: $isLoading, companyLogo: $companyLogo)
               } else {
                   NavigationView {
                       VStack(alignment: .center, spacing: 0) { // <-- No spacing in VStack
                           ZStack {
                               Color.ferro.ignoresSafeArea()
                               VStack(alignment: .center, spacing: 8) { // <-- Adjust spacing as needed
                                   Image("Logo")
                                       .resizable()
                                       .scaledToFit()
                                       .frame(height: 80) // <-- Reduced logo height

                                   Picker("Station", selection: $selectedStation) {
                                       ForEach(Station.allCases) { station in
                                           Text(station.rawValue).tag(station)
                                               .foregroundColor(.black)
                                       }
                                   }
                                   .pickerStyle(.menu)
                                   .padding(.horizontal)
                                   .background(
                                       RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.2)) // Semi-transparent gray background       // Add a subtle shadow
                                   )
                                   .foregroundColor(.white) // Set text color to white
                                   .font(.headline)
                                   .onChange(of: selectedStation) { _ in
                                       fetchTrainData()
                                   }
                               }
                               .padding(.top, 20) // Add padding to the top of the VStack
                           }
                           .frame(maxHeight: 200) // <-- Set a max height for the ZStack

                           if isLoading {
                               ProgressView()
                           } else if let errorMessage = errorMessage {
                               Text("Error: \(errorMessage)")
                                   .foregroundColor(.red)
                           } else {
                               List {
                                Section(header: Text("Retiro")) {
                                    ForEach(retiroDepartures) { group in
                                        DepartureGroupView(group: group)
                                    }
                                }
                                Section(header: Text("Villa Rosa")) {
                                    ForEach(villaRosaDepartures) { group in
                                        DepartureGroupView(group: group)
                                    }
                                }
                            }
                        }
                    }
                    .navigationTitle("Estación \(selectedStation.rawValue)")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .onAppear {
            fetchTrainData()
            fetchCompanyLogo()
        }
    }
    
    func fetchTrainData() {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "http://proximostrenes.ferrovias.com.ar/estaciones.asp") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "idEst=\(selectedStation.idEst)&adm=1".data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, error in
            defer { isLoading = false }
            
            if let error = error {
                errorMessage = "Network error: \(error.localizedDescription)"
                return
            }

            guard let data = data,
                  let html = String(data: data, encoding: .utf8) else {
                errorMessage = "Invalid data received"
                return
            }

            do {
                let doc = try SwiftSoup.parse(html)
                let rows = try doc.select("table#table_main_box table#table_main tr")

                var departures: [DepartureGroup] = []
                for row in rows {
                    if let destinationCell = try? row.select("td.tdEst").first(),
                       let destination = try? destinationCell.text(),
                       !destination.isEmpty {

                        if let index = departures.firstIndex(where: { $0.destination == destination }) {
                            if let estimatedTime = try? row.select("td.tdEst.tdEstr.tdflecha").text(), !estimatedTime.isEmpty {
                                departures[index].estimatedTimes.append(estimatedTime)
                            }
                        } else {
                            let estimatedTime = try row.select("td.tdEst.tdEstr.tdflecha").text()
                            departures.append(DepartureGroup(destination: destination, estimatedTimes: [estimatedTime]))
                        }
                    }
                }

                retiroDepartures = departures.filter { $0.destination.contains("RETIRO") }
                villaRosaDepartures = departures.filter { !$0.destination.contains("RETIRO") }

                DispatchQueue.main.async {
                    self.retiroDepartures = retiroDepartures
                    self.villaRosaDepartures = villaRosaDepartures
                }
            } catch {
                errorMessage = "Error parsing data: \(error.localizedDescription)"
            }
        }.resume()
    }

    func fetchCompanyLogo() {
        guard let url = URL(string: "https://i.pinimg.com/originals/1f/e5/c0/1fe5c07585a5dbfce82d90e89b085410.jpg") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error loading company logo: \(error.localizedDescription)")
                return
            }

            guard let data = data, let uiImage = UIImage(data: data) else {
                print("Invalid image data")
                return
            }

            DispatchQueue.main.async {
                self.companyLogo = Image("Logo")
            }
        }.resume()
    }
}


struct DepartureGroupView: View {
    let group: DepartureGroup

    var body: some View {
        VStack(alignment: .leading) {
            Text(group.destination).font(.headline)
            ForEach(group.estimatedTimes, id: \.self) { time in
                Text(time)
            }

        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
