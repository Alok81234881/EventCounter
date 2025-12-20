import WidgetKit
import SwiftUI

struct EventWidget: Widget {
    let kind: String = "EventWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EventWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Next Event")
        .description("Shows your nearest upcoming event.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
