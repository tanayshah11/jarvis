import Flutter
import Contacts

class ContactsBridge: NSObject, FlutterPlugin {
    static let channelName = "com.jarvis/contacts"

    private let contactStore = CNContactStore()

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let instance = ContactsBridge()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    // Handle method calls from Flutter
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestPermission":
            requestPermission(result: result)
        case "checkPermission":
            checkPermission(result: result)
        case "search":
            guard let args = call.arguments as? [String: Any],
                  let query = args["query"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Query required", details: nil))
                return
            }
            searchContacts(query: query, result: result)
        case "getAll":
            let limit = (call.arguments as? [String: Any])?["limit"] as? Int ?? 100
            getAllContacts(limit: limit, result: result)
        case "getById":
            guard let args = call.arguments as? [String: Any],
                  let identifier = args["id"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "ID required", details: nil))
                return
            }
            getContact(identifier: identifier, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // Request contacts permission
    private func requestPermission(result: @escaping FlutterResult) {
        contactStore.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    result(FlutterError(code: "PERMISSION_ERROR",
                                      message: error.localizedDescription,
                                      details: nil))
                    return
                }
                result(granted)
            }
        }
    }

    // Check current permission status
    private func checkPermission(result: @escaping FlutterResult) {
        let status = CNContactStore.authorizationStatus(for: .contacts)

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
        @unknown default:
            statusString = "notDetermined"
        }

        result(statusString)
    }

    // Search contacts by query
    private func searchContacts(query: String, result: @escaping FlutterResult) {
        let authStatus = CNContactStore.authorizationStatus(for: .contacts)
        guard authStatus == .authorized else {
            result(FlutterError(code: "PERMISSION_DENIED",
                              message: "Contacts permission not granted",
                              details: nil))
            return
        }

        do {
            let keysToFetch: [CNKeyDescriptor] = [
                CNContactIdentifierKey as CNKeyDescriptor,
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
                CNContactOrganizationNameKey as CNKeyDescriptor
            ]

            let request = CNContactFetchRequest(keysToFetch: keysToFetch)
            var contacts: [[String: Any]] = []
            let queryLower = query.lowercased()

            try contactStore.enumerateContacts(with: request) { contact, stop in
                // Filter by query
                let fullName = "\(contact.givenName) \(contact.familyName)".lowercased()
                let orgName = contact.organizationName.lowercased()

                if fullName.contains(queryLower) || orgName.contains(queryLower) {
                    contacts.append(self.contactToDict(contact))
                }

                // Limit results to avoid memory issues
                if contacts.count >= 100 {
                    stop.pointee = true
                }
            }

            result(contacts)
        } catch {
            result(FlutterError(code: "FETCH_ERROR",
                              message: error.localizedDescription,
                              details: nil))
        }
    }

    // Get all contacts with limit
    private func getAllContacts(limit: Int, result: @escaping FlutterResult) {
        let authStatus = CNContactStore.authorizationStatus(for: .contacts)
        guard authStatus == .authorized else {
            result(FlutterError(code: "PERMISSION_DENIED",
                              message: "Contacts permission not granted",
                              details: nil))
            return
        }

        do {
            let keysToFetch: [CNKeyDescriptor] = [
                CNContactIdentifierKey as CNKeyDescriptor,
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
                CNContactOrganizationNameKey as CNKeyDescriptor
            ]

            let request = CNContactFetchRequest(keysToFetch: keysToFetch)
            var contacts: [[String: Any]] = []

            try contactStore.enumerateContacts(with: request) { contact, stop in
                contacts.append(self.contactToDict(contact))

                if contacts.count >= limit {
                    stop.pointee = true
                }
            }

            result(contacts)
        } catch {
            result(FlutterError(code: "FETCH_ERROR",
                              message: error.localizedDescription,
                              details: nil))
        }
    }

    // Get contact by ID
    private func getContact(identifier: String, result: @escaping FlutterResult) {
        let authStatus = CNContactStore.authorizationStatus(for: .contacts)
        guard authStatus == .authorized else {
            result(FlutterError(code: "PERMISSION_DENIED",
                              message: "Contacts permission not granted",
                              details: nil))
            return
        }

        do {
            let keysToFetch: [CNKeyDescriptor] = [
                CNContactIdentifierKey as CNKeyDescriptor,
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
                CNContactOrganizationNameKey as CNKeyDescriptor
            ]

            let contact = try contactStore.unifiedContact(withIdentifier: identifier,
                                                          keysToFetch: keysToFetch)
            result(contactToDict(contact))
        } catch {
            result(FlutterError(code: "CONTACT_NOT_FOUND",
                              message: error.localizedDescription,
                              details: nil))
        }
    }

    // Convert CNContact to Dictionary
    private func contactToDict(_ contact: CNContact) -> [String: Any] {
        var dict: [String: Any] = [:]

        dict["id"] = contact.identifier
        dict["givenName"] = contact.givenName
        dict["familyName"] = contact.familyName
        dict["fullName"] = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
        dict["organization"] = contact.organizationName

        // Phone numbers
        var phones: [[String: String]] = []
        for phoneNumber in contact.phoneNumbers {
            let label = CNLabeledValue<NSString>.localizedString(forLabel: phoneNumber.label ?? "")
            phones.append([
                "label": label,
                "value": phoneNumber.value.stringValue
            ])
        }
        dict["phones"] = phones

        // Email addresses
        var emails: [[String: String]] = []
        for emailAddress in contact.emailAddresses {
            let label = CNLabeledValue<NSString>.localizedString(forLabel: emailAddress.label ?? "")
            emails.append([
                "label": label,
                "value": emailAddress.value as String
            ])
        }
        dict["emails"] = emails

        return dict
    }
}
