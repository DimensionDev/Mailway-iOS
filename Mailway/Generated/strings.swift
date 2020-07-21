// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum Common {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "Common.Cancel")
    /// OK
    internal static let ok = L10n.tr("Localizable", "Common.Ok")
  }

  internal enum ComposeMessage {
    internal enum Alert {
      internal enum DiscardCompose {
        /// Discard
        internal static let discard = L10n.tr("Localizable", "ComposeMessage.Alert.DiscardCompose.Discard")
        /// Please confirm discard message composing or save as draft.
        internal static let messageComposeOrSaveDraft = L10n.tr("Localizable", "ComposeMessage.Alert.DiscardCompose.MessageComposeOrSaveDraft")
        /// Please confirm discard message composing or update draft.
        internal static let messageComposeOrUpdateDraft = L10n.tr("Localizable", "ComposeMessage.Alert.DiscardCompose.MessageComposeOrUpdateDraft")
        /// Save Draft
        internal static let saveDraft = L10n.tr("Localizable", "ComposeMessage.Alert.DiscardCompose.SaveDraft")
        /// Discard Compose
        internal static let title = L10n.tr("Localizable", "ComposeMessage.Alert.DiscardCompose.Title")
        /// Update Draft
        internal static let updateDraft = L10n.tr("Localizable", "ComposeMessage.Alert.DiscardCompose.UpdateDraft")
      }
    }
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

  internal enum ContactDetail {
    internal enum Alert {
      internal enum ShareProfile {
        /// To File
        internal static let toFile = L10n.tr("Localizable", "ContactDetail.Alert.ShareProfile.ToFile")
        /// To QR Code
        internal static let toQrCode = L10n.tr("Localizable", "ContactDetail.Alert.ShareProfile.ToQrCode")
      }
    }
    internal enum Error {
      internal enum ContactBizcardNotFound {
        /// Bizcard Not Found
        internal static let errorDescription = L10n.tr("Localizable", "ContactDetail.Error.ContactBizcardNotFound.ErrorDescription")
        /// Cannot share bizcard because bizcard of this contact not found.
        internal static let failureReason = L10n.tr("Localizable", "ContactDetail.Error.ContactBizcardNotFound.FailureReason")
        /// Cannot share bizcard because bizcard of this contact not found. Please try again.
        internal static let message = L10n.tr("Localizable", "ContactDetail.Error.ContactBizcardNotFound.Message")
        /// Please try again.
        internal static let recoverySuggestion = L10n.tr("Localizable", "ContactDetail.Error.ContactBizcardNotFound.RecoverySuggestion")
        /// Bizcard Not Found
        internal static let title = L10n.tr("Localizable", "ContactDetail.Error.ContactBizcardNotFound.Title")
      }
      internal enum SignerKeyNotFound {
        /// Key Not Found
        internal static let errorDescription = L10n.tr("Localizable", "ContactDetail.Error.SignerKeyNotFound.ErrorDescription")
        /// Cannot share profile because signer key of this profile not found.
        internal static let failureReason = L10n.tr("Localizable", "ContactDetail.Error.SignerKeyNotFound.FailureReason")
        /// Cannot share profile because signer key of this profile not found. Please try again.
        internal static let message = L10n.tr("Localizable", "ContactDetail.Error.SignerKeyNotFound.Message")
        /// Please try again.
        internal static let recoverySuggestion = L10n.tr("Localizable", "ContactDetail.Error.SignerKeyNotFound.RecoverySuggestion")
        /// Key Not Found
        internal static let title = L10n.tr("Localizable", "ContactDetail.Error.SignerKeyNotFound.Title")
      }
    }
  }

  internal enum CreateContact {
    /// Import a Bizcard file
    internal static let importFile = L10n.tr("Localizable", "CreateContact.ImportFile")
    /// Import a QR code or Bizcard file to add a contact.\nYou can export any Bizcard from the contact list
    internal static let prompt = L10n.tr("Localizable", "CreateContact.Prompt")
    /// Scan the Bizcard QR code
    internal static let scanQrCode = L10n.tr("Localizable", "CreateContact.ScanQrCode")
    /// Add Contact
    internal static let title = L10n.tr("Localizable", "CreateContact.Title")
    internal enum Error {
      internal enum BizcardValidateFail {
        /// Bizcard Invalid
        internal static let errorDescription = L10n.tr("Localizable", "CreateContact.Error.BizcardValidateFail.ErrorDescription")
        /// Bizcard signature broken.
        internal static let failureReason = L10n.tr("Localizable", "CreateContact.Error.BizcardValidateFail.FailureReason")
        /// Bizcard signature broken. Please select valid bizcard and try again.
        internal static let message = L10n.tr("Localizable", "CreateContact.Error.BizcardValidateFail.Message")
        /// Please select valid bizcard and try again.
        internal static let recoverySuggestion = L10n.tr("Localizable", "CreateContact.Error.BizcardValidateFail.RecoverySuggestion")
        /// Bizcard Invalid
        internal static let title = L10n.tr("Localizable", "CreateContact.Error.BizcardValidateFail.Title")
      }
      internal enum DuplicateContact {
        /// Duplicate Contact
        internal static let errorDescription = L10n.tr("Localizable", "CreateContact.Error.DuplicateContact.ErrorDescription")
        /// Contact already exists.
        internal static let failureReason = L10n.tr("Localizable", "CreateContact.Error.DuplicateContact.FailureReason")
        /// Contact already exists. Please select another bizcard and try again.
        internal static let message = L10n.tr("Localizable", "CreateContact.Error.DuplicateContact.Message")
        /// Please select another bizcard and try again.
        internal static let recoverySuggestion = L10n.tr("Localizable", "CreateContact.Error.DuplicateContact.RecoverySuggestion")
        /// Duplicate Contact
        internal static let title = L10n.tr("Localizable", "CreateContact.Error.DuplicateContact.Title")
      }
      internal enum NotBizcard {
        /// Bizcard Invalid
        internal static let errorDescription = L10n.tr("Localizable", "CreateContact.Error.NotBizcard.ErrorDescription")
        /// Cannot read bizcard from this file.
        internal static let failureReason = L10n.tr("Localizable", "CreateContact.Error.NotBizcard.FailureReason")
        /// Cannot read bizcard from this file. Please select valid bizcard and try again.
        internal static let message = L10n.tr("Localizable", "CreateContact.Error.NotBizcard.Message")
        /// Please select valid bizcard and try again.
        internal static let recoverySuggestion = L10n.tr("Localizable", "CreateContact.Error.NotBizcard.RecoverySuggestion")
        /// Bizcard Invalid
        internal static let title = L10n.tr("Localizable", "CreateContact.Error.NotBizcard.Title")
      }
    }
  }

  internal enum DecryptMessage {
    /// Decrypt a file
    internal static let decryptFileButton = L10n.tr("Localizable", "DecryptMessage.DecryptFileButton")
    /// Decrypted Text
    internal static let decryptResultPlaceholder = L10n.tr("Localizable", "DecryptMessage.DecryptResultPlaceholder")
    /// MsgBegin…
    internal static let inputPlaceholder = L10n.tr("Localizable", "DecryptMessage.InputPlaceholder")
    /// Decrypting
    internal static let title = L10n.tr("Localizable", "DecryptMessage.Title")
  }

  internal enum Error {
    internal enum InternalError {
      /// Internal Error
      internal static let errorDescription = L10n.tr("Localizable", "Error.InternalError.ErrorDescription")
      /// Unknown error.
      internal static let failureReason = L10n.tr("Localizable", "Error.InternalError.FailureReason")
      /// Unknown error. Please try again.
      internal static let message = L10n.tr("Localizable", "Error.InternalError.Message")
      /// Please try again.
      internal static let recoverySuggestion = L10n.tr("Localizable", "Error.InternalError.RecoverySuggestion")
      /// Internal Error
      internal static let title = L10n.tr("Localizable", "Error.InternalError.Title")
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
