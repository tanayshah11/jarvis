import Flutter
import EventKit

class CalendarBridge: NSObject, FlutterPlugin {
    static let channelName = "com.jarvis/calendar"

    private let eventStore = EKEventStore()

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let instance = CalendarBridge()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    private let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private let iso8601FormatterNoFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private func parseISO8601Date(_ string: String) -> Date? {
        return iso8601Formatter.date(from: string) ?? iso8601FormatterNoFraction.date(from: string)
    }

    private func formatISO8601Date(_ date: Date) -> String {
        return iso8601Formatter.string(from: date)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestPermission":
            requestPermission(result: result)
        case "checkPermission":
            checkPermission(result: result)
        case "getCalendars":
            getCalendars(result: result)
        case "getEvents":
            guard let args = call.arguments as? [String: Any],
                  let startString = args["start"] as? String,
                  let endString = args["end"] as? String,
                  let startDate = parseISO8601Date(startString),
                  let endDate = parseISO8601Date(endString) else {
                result(FlutterError(code: "INVALID_ARGS", message: "Start and end dates required (ISO 8601 format)", details: nil))
                return
            }
            let calendarIds = args["calendarIds"] as? [String]
            getEvents(start: startDate,
                     end: endDate,
                     calendarIds: calendarIds,
                     result: result)
        case "createEvent":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Event data required", details: nil))
                return
            }
            createEvent(data: args, result: result)
        case "updateEvent":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Event data required", details: nil))
                return
            }
            updateEvent(data: args, result: result)
        case "deleteEvent":
            guard let args = call.arguments as? [String: Any],
                  let eventId = args["eventId"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Event ID required", details: nil))
                return
            }
            deleteEvent(eventId: eventId, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // Request calendar permission
    private func requestPermission(result: @escaping FlutterResult) {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                DispatchQueue.main.async {
                    if let error = error {
                        result(FlutterError(code: "PERMISSION_ERROR",
                                          message: error.localizedDescription,
                                          details: nil))
                        return
                    }
                    // Return status string instead of boolean
                    result(granted ? "authorized" : "denied")
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                DispatchQueue.main.async {
                    if let error = error {
                        result(FlutterError(code: "PERMISSION_ERROR",
                                          message: error.localizedDescription,
                                          details: nil))
                        return
                    }
                    // Return status string instead of boolean
                    result(granted ? "authorized" : "denied")
                }
            }
        }
    }

    // Check current permission status
    private func checkPermission(result: @escaping FlutterResult) {
        let status = EKEventStore.authorizationStatus(for: .event)

        var statusString: String
        switch status {
        case .notDetermined:
            statusString = "notDetermined"
        case .restricted:
            statusString = "restricted"
        case .denied:
            statusString = "denied"
        case .authorized:
            statusString = "authorized"
        default:
            if #available(iOS 17.0, *) {
                if status == .fullAccess {
                    statusString = "authorized"
                } else if status == .writeOnly {
                    statusString = "writeOnly"
                } else {
                    statusString = "notDetermined"
                }
            } else {
                statusString = "notDetermined"
            }
        }

        result(statusString)
    }

    // Get all calendars
    private func getCalendars(result: @escaping FlutterResult) {
        let authStatus = EKEventStore.authorizationStatus(for: .event)

        var isAuthorized = authStatus == .authorized
        if #available(iOS 17.0, *) {
            isAuthorized = isAuthorized || authStatus == .fullAccess || authStatus == .writeOnly
        }

        guard isAuthorized else {
            result(FlutterError(code: "PERMISSION_DENIED",
                              message: "Calendar permission not granted",
                              details: nil))
            return
        }

        let calendars = eventStore.calendars(for: .event)
        let calendarDicts = calendars.map { calendar -> [String: Any] in
            return [
                "id": calendar.calendarIdentifier,
                "title": calendar.title,
                "color": colorToHex(calendar.cgColor),
                "allowsModifications": calendar.allowsContentModifications,
                "source": calendar.source.title
            ]
        }

        result(calendarDicts)
    }

    // Get events in date range
    private func getEvents(start: Date, end: Date, calendarIds: [String]?, result: @escaping FlutterResult) {
        let authStatus = EKEventStore.authorizationStatus(for: .event)

        var isAuthorized = authStatus == .authorized
        if #available(iOS 17.0, *) {
            isAuthorized = isAuthorized || authStatus == .fullAccess || authStatus == .writeOnly
        }

        guard isAuthorized else {
            result(FlutterError(code: "PERMISSION_DENIED",
                              message: "Calendar permission not granted",
                              details: nil))
            return
        }

        // Create predicate
        var calendars: [EKCalendar]?
        if let ids = calendarIds {
            calendars = ids.compactMap { id in
                eventStore.calendar(withIdentifier: id)
            }
        }

        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: calendars)
        let events = eventStore.events(matching: predicate)

        let eventDicts = events.map { event -> [String: Any] in
            return eventToDict(event)
        }

        result(eventDicts)
    }

    // Create new event
    private func createEvent(data: [String: Any], result: @escaping FlutterResult) {
        let authStatus = EKEventStore.authorizationStatus(for: .event)

        var isAuthorized = authStatus == .authorized
        if #available(iOS 17.0, *) {
            isAuthorized = isAuthorized || authStatus == .fullAccess
        }

        guard isAuthorized else {
            result(FlutterError(code: "PERMISSION_DENIED",
                              message: "Calendar write permission not granted",
                              details: nil))
            return
        }

        guard let title = data["title"] as? String,
              let startString = data["startDate"] as? String,
              let endString = data["endDate"] as? String,
              let startDate = parseISO8601Date(startString),
              let endDate = parseISO8601Date(endString) else {
            result(FlutterError(code: "INVALID_ARGS",
                              message: "Title, startDate, and endDate required (ISO 8601 format)",
                              details: nil))
            return
        }

        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = data["isAllDay"] as? Bool ?? false

        if let location = data["location"] as? String {
            event.location = location
        }

        if let notes = data["notes"] as? String {
            event.notes = notes
        }

        // Set calendar
        if let calendarId = data["calendarId"] as? String,
           let calendar = eventStore.calendar(withIdentifier: calendarId) {
            event.calendar = calendar
        } else {
            event.calendar = eventStore.defaultCalendarForNewEvents
        }

        do {
            try eventStore.save(event, span: .thisEvent)
            result(eventToDict(event))
        } catch {
            result(FlutterError(code: "CREATE_ERROR",
                              message: error.localizedDescription,
                              details: nil))
        }
    }

    // Update existing event
    private func updateEvent(data: [String: Any], result: @escaping FlutterResult) {
        let authStatus = EKEventStore.authorizationStatus(for: .event)

        var isAuthorized = authStatus == .authorized
        if #available(iOS 17.0, *) {
            isAuthorized = isAuthorized || authStatus == .fullAccess
        }

        guard isAuthorized else {
            result(FlutterError(code: "PERMISSION_DENIED",
                              message: "Calendar write permission not granted",
                              details: nil))
            return
        }

        guard let eventId = data["eventId"] as? String,
              let event = eventStore.event(withIdentifier: eventId) else {
            result(FlutterError(code: "EVENT_NOT_FOUND",
                              message: "Event not found",
                              details: nil))
            return
        }

        // Update fields if provided
        if let title = data["title"] as? String {
            event.title = title
        }

        if let startString = data["startDate"] as? String,
           let startDate = parseISO8601Date(startString) {
            event.startDate = startDate
        }

        if let endString = data["endDate"] as? String,
           let endDate = parseISO8601Date(endString) {
            event.endDate = endDate
        }

        if let isAllDay = data["isAllDay"] as? Bool {
            event.isAllDay = isAllDay
        }

        if let location = data["location"] as? String {
            event.location = location
        }

        if let notes = data["notes"] as? String {
            event.notes = notes
        }

        do {
            try eventStore.save(event, span: .thisEvent)
            result(eventToDict(event))
        } catch {
            result(FlutterError(code: "UPDATE_ERROR",
                              message: error.localizedDescription,
                              details: nil))
        }
    }

    // Delete event
    private func deleteEvent(eventId: String, result: @escaping FlutterResult) {
        let authStatus = EKEventStore.authorizationStatus(for: .event)

        var isAuthorized = authStatus == .authorized
        if #available(iOS 17.0, *) {
            isAuthorized = isAuthorized || authStatus == .fullAccess
        }

        guard isAuthorized else {
            result(FlutterError(code: "PERMISSION_DENIED",
                              message: "Calendar write permission not granted",
                              details: nil))
            return
        }

        guard let event = eventStore.event(withIdentifier: eventId) else {
            result(FlutterError(code: "EVENT_NOT_FOUND",
                              message: "Event not found",
                              details: nil))
            return
        }

        do {
            try eventStore.remove(event, span: .thisEvent)
            result(["success": true])
        } catch {
            result(FlutterError(code: "DELETE_ERROR",
                              message: error.localizedDescription,
                              details: nil))
        }
    }

    // Convert EKEvent to Dictionary
    private func eventToDict(_ event: EKEvent) -> [String: Any] {
        var dict: [String: Any] = [:]

        dict["id"] = event.eventIdentifier
        dict["title"] = event.title ?? ""
        dict["startDate"] = formatISO8601Date(event.startDate)
        dict["endDate"] = formatISO8601Date(event.endDate)
        dict["isAllDay"] = event.isAllDay
        dict["location"] = event.location ?? ""
        dict["notes"] = event.notes ?? ""
        dict["calendarId"] = event.calendar.calendarIdentifier

        // Additional useful fields
        dict["hasAlarms"] = event.hasAlarms
        dict["hasRecurrenceRules"] = event.hasRecurrenceRules
        dict["hasAttendees"] = event.hasAttendees
        dict["availability"] = availabilityToString(event.availability)

        return dict
    }

    // Helper to convert color to hex
    private func colorToHex(_ cgColor: CGColor) -> String {
        guard let components = cgColor.components, components.count >= 3 else {
            return "#000000"
        }

        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)

        return String(format: "#%02X%02X%02X", r, g, b)
    }

    // Helper to convert availability to string
    private func availabilityToString(_ availability: EKEventAvailability) -> String {
        switch availability {
        case .notSupported:
            return "notSupported"
        case .busy:
            return "busy"
        case .free:
            return "free"
        case .tentative:
            return "tentative"
        case .unavailable:
            return "unavailable"
        @unknown default:
            return "notSupported"
        }
    }
}
