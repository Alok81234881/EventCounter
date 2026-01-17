import WidgetKit
import SwiftUI

struct StandByWidget: Widget {
    let kind: String = "StandByWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectEventIntent.self, provider: Provider()) { entry in
            StandByWidgetView(entry: entry)
        }
        .configurationDisplayName("Nightstand Clock")
        .description("A beautiful neon clock for your nightstand. Perfect for StandBy mode.")
        .supportedFamilies([.systemSmall, .systemMedium]) // Restricted to StandBy-friendly sizes
    }
}
