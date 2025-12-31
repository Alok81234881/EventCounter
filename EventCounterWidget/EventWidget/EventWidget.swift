import WidgetKit
import SwiftUI

struct EventWidget: Widget {
    let kind: String = "EventWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectEventIntent.self, provider: Provider()) { entry in
            EventWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Track Event")
        .description("Choose a specific event to track on your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
