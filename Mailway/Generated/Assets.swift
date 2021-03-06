// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Arrows {
    internal static let arrowUp2 = ImageAsset(name: "Arrows/arrow.up.2")
    internal static let arrowtriangleDownFill = ImageAsset(name: "Arrows/arrowtriangle.down.fill")
  }
  internal enum Banner {
    internal static let createContactEntry = ImageAsset(name: "Banner/create.contact.entry")
  }
  internal enum Color {
    internal enum Background {
      internal static let blue = ColorAsset(name: "Color/Background/blue")
      internal static let blue300 = ColorAsset(name: "Color/Background/blue300")
      internal static let blue400 = ColorAsset(name: "Color/Background/blue400")
      internal static let greenLight = ColorAsset(name: "Color/Background/green.light")
      internal static let tealLight = ColorAsset(name: "Color/Background/teal.light")
    }
    internal enum PickPanel {
      internal static let blueLight = ColorAsset(name: "Color/PickPanel/blue.light")
      internal static let disableLight = ColorAsset(name: "Color/PickPanel/disable.light")
      internal static let greenLight = ColorAsset(name: "Color/PickPanel/green.light")
      internal static let indigoLight = ColorAsset(name: "Color/PickPanel/indigo.light")
      internal static let orangeLight = ColorAsset(name: "Color/PickPanel/orange.light")
      internal static let pinkLight = ColorAsset(name: "Color/PickPanel/pink.light")
      internal static let purpleLight = ColorAsset(name: "Color/PickPanel/purple.light")
      internal static let redLight = ColorAsset(name: "Color/PickPanel/red.light")
      internal static let tealLight = ColorAsset(name: "Color/PickPanel/teal.light")
      internal static let yellowLight = ColorAsset(name: "Color/PickPanel/yellow.light")
    }
    internal enum Tint {
      internal static let barButtonItem = ColorAsset(name: "Color/Tint/bar.button.item")
    }
  }
  internal enum Communication {
    internal static let arrowshapeTurnUpLeft2Fill = ImageAsset(name: "Communication/arrowshape.turn.up.left.2.fill")
    internal static let arrowshapeTurnUpLeftFill = ImageAsset(name: "Communication/arrowshape.turn.up.left.fill")
    internal static let listBubble = ImageAsset(name: "Communication/list.bubble")
    internal static let mail = ImageAsset(name: "Communication/mail")
    internal static let paperplane = ImageAsset(name: "Communication/paperplane")
    internal static let trayAndArrowDown = ImageAsset(name: "Communication/tray.and.arrow.down")
  }
  internal enum Editing {
    internal static let close = ImageAsset(name: "Editing/close")
    internal static let docOnDoc = ImageAsset(name: "Editing/doc.on.doc")
    internal static let moreVertical = ImageAsset(name: "Editing/more.vertical")
    internal static let pencil = ImageAsset(name: "Editing/pencil")
    internal static let plusCircleFill = ImageAsset(name: "Editing/plus.circle.fill")
    internal static let plusCircle = ImageAsset(name: "Editing/plus.circle")
  }
  internal enum Human {
    internal static let personCropCircle = ImageAsset(name: "Human/person.crop.circle")
  }
  internal enum Logo {
    internal static let discord = ImageAsset(name: "Logo/discord")
    internal static let facebook = ImageAsset(name: "Logo/facebook")
    internal static let telegram = ImageAsset(name: "Logo/telegram")
    internal static let twitter = ImageAsset(name: "Logo/twitter")
  }
  internal enum NavigationBar {
    internal static let close = ImageAsset(name: "NavigationBar/close")
    internal static let done = ImageAsset(name: "NavigationBar/done")
  }
  internal enum Objects {
    internal static let folder = ImageAsset(name: "Objects/folder")
    internal static let qrcodeViewfinder = ImageAsset(name: "Objects/qrcode.viewfinder")
  }
  internal enum Placeholder {
    internal static let document = ImageAsset(name: "Placeholder/document")
    internal static let inbox = ImageAsset(name: "Placeholder/inbox")
    internal static let message = ImageAsset(name: "Placeholder/message")
    internal static let search = ImageAsset(name: "Placeholder/search")
    internal static let task = ImageAsset(name: "Placeholder/task")
  }
  internal enum Sidebar {
    internal static let contacts = ImageAsset(name: "Sidebar/contacts")
    internal static let drafts = ImageAsset(name: "Sidebar/drafts")
    internal static let inbox = ImageAsset(name: "Sidebar/inbox")
    internal static let menu = ImageAsset(name: "Sidebar/menu")
    internal static let plugins = ImageAsset(name: "Sidebar/plugins")
    internal static let settings = ImageAsset(name: "Sidebar/settings")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

internal extension ImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    Bundle(for: BundleToken.self)
  }()
}
// swiftlint:enable convenience_type
