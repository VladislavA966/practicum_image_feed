import Foundation

extension Date {
    private static let longRuFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    var longDateString: String {
        Date.longRuFormatter.string(from: self)
    }
}
