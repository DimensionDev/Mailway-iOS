// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum ComposeMessage {
    internal enum Error {
      internal enum EmptyMessage {
        /// Message Format Invalid
        internal static let errorDescription = L10n.tr("Localizable", "ComposeMessage.Error.EmptyMessage.ErrorDescription")
        /// Cannot compose empty message.
        internal static let failureReason = L10n.tr("Localizable", "ComposeMessage.Error.EmptyMessage.FailureReason")
        /// Cannot compose empty message. Please input message and try again.
        internal static let message = L10n.tr("Localizable", "ComposeMessage.Error.EmptyMessage.Message")
        /// Please input message and try again.
        internal static let recoverySuggestion = L10n.tr("Localizable", "ComposeMessage.Error.EmptyMessage.RecoverySuggestion")
        /// Message Format Invalid
        internal static let title = L10n.tr("Localizable", "ComposeMessage.Error.EmptyMessage.Title")
      }
      internal enum IdentityNotFound {
        /// Identity Not Found
        internal static let errorDescription = L10n.tr("Localizable", "ComposeMessage.Error.IdentityNotFound.ErrorDescription")
        /// Cannot compose message without identity.
        internal static let failureReason = L10n.tr("Localizable", "ComposeMessage.Error.IdentityNotFound.FailureReason")
        /// Cannot compose message without identity. Please select identity and try again.
        internal static let message = L10n.tr("Localizable", "ComposeMessage.Error.IdentityNotFound.Message")
        /// Please select identity and try again.
        internal static let recoverySuggestion = L10n.tr("Localizable", "ComposeMessage.Error.IdentityNotFound.RecoverySuggestion")
        /// Identity Not Found
        internal static let title = L10n.tr("Localizable", "ComposeMessage.Error.IdentityNotFound.Title")
      }
      internal enum RecipientNotFound {
        /// Recipient Not Found
        internal static let errorDescription = L10n.tr("Localizable", "ComposeMessage.Error.RecipientNotFound.ErrorDescription")
        /// Cannot compose message without recipient.
        internal static let failureReason = L10n.tr("Localizable", "ComposeMessage.Error.RecipientNotFound.FailureReason")
        /// Cannot compose message without recipient. Please select recipient and try again.
        internal static let message = L10n.tr("Localizable", "ComposeMessage.Error.RecipientNotFound.Message")
        /// Please select recipient and try again.
        internal static let recoverySuggestion = L10n.tr("Localizable", "ComposeMessage.Error.RecipientNotFound.RecoverySuggestion")
        /// Recipient Not Found
        internal static let title = L10n.tr("Localizable", "ComposeMessage.Error.RecipientNotFound.Title")
      }
    }
  }

  internal enum Inbox {
    /// Inbox
    internal static let title = L10n.tr("Localizable", "Inbox.Title")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    Bundle(for: BundleToken.self)
  }()
}
// swiftlint:enable convenience_type
