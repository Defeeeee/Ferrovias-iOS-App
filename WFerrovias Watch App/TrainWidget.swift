import WidgetKit
import SwiftUI

struct TrainWidgetEntry: TimelineEntry {
    let date: Date
    let selectedStation: ContentView.Station
    let nextDepartureToRetiro: String?
    let nextDepartureToVillaRosa: String?
    let lastRefreshTime: String
}

struct TrainWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TrainWidgetEntry {
        TrainWidgetEntry(date: Date(), selectedStation: .retiro, nextDepartureToRetiro: "N/A", nextDepartureToVillaRosa: "N/A", lastRefreshTime: "N/A")
    }

    func getSnapshot(in context: Context, completion: @escaping (TrainWidgetEntry) -> Void) {
        let entry = TrainWidgetEntry(date: Date(), selectedStation: .retiro, nextDepartureToRetiro: "N/A", nextDepartureToVillaRosa: "N/A", lastRefreshTime: "N/A")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TrainWidgetEntry>) -> Void) {
        fetchTrainData { (selectedStation, nextDepartureToRetiro, nextDepartureToVillaRosa, lastRefreshTime) in
            let entry = TrainWidgetEntry(date: Date(), selectedStation: selectedStation, nextDepartureToRetiro: nextDepartureToRetiro, nextDepartureToVillaRosa: nextDepartureToVillaRosa, lastRefreshTime: lastRefreshTime)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }

    private func fetchTrainData(completion: @escaping (ContentView.Station, String?, String?, String) -> Void) {
        // Fetch data from the main app's ContentView
        // This is a placeholder implementation
        let selectedStation = ContentView.Station.villaAdelina
        let nextDepartureToRetiro = "10:30"
        let nextDepartureToVillaRosa = "10:45"
        let lastRefreshTime = "10:00"
        completion(selectedStation, nextDepartureToRetiro, nextDepartureToVillaRosa, lastRefreshTime)
    }
}

struct TrainWidgetEntryView: View {
    var entry: TrainWidgetProvider.Entry

    var body: some View {
        VStack {
            Text("Station: \(entry.selectedStation.rawValue)")
            Text("To Retiro: \(entry.nextDepartureToRetiro ?? "N/A")")
            Text("To Villa Rosa: \(entry.nextDepartureToVillaRosa ?? "N/A")")
            Text("Last Refresh: \(entry.lastRefreshTime)")
        }
    }
}

@main
struct TrainWidget: Widget {
    let kind: String = "TrainWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TrainWidgetProvider()) { entry in
            TrainWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Train Departures")
        .description("Shows the next train departures for the selected station.")
    }
}
