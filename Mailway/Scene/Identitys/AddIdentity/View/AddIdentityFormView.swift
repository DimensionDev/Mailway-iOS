//
//  AddIdentityFormView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-28.
//  Copyright © 2020 Dimension. All rights reserved.
//

import SwiftUI
import Combine

struct ContactInfo: Identifiable, Hashable {
    let id: UUID = UUID()
    
    let type: InfoType
    
    var key: String
    var value: String
    var avaliable = true
    
    var isEmptyInfo: Bool {
        switch type {
        case .channel:
            return key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                   value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        default:
            return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    enum InfoType: CaseIterable {
        case email
        case twitter
        case facebook
        case telegram
        case discord
        case channel
        
        var iconImage: UIImage {
            switch self {
            case .email:    return Asset.Communication.mail.image
            case .twitter:  return Asset.Logo.twitter.image
            case .facebook: return Asset.Logo.facebook.image
            case .telegram: return Asset.Logo.telegram.image
            case .discord:  return Asset.Logo.discord.image
            case .channel:  return Asset.Editing.plusCircleFill.image
            }
        }
        
        var typeName: String {
            switch self {
            case .email:    return "E-Mail"
            case .twitter:  return "Twitter"
            case .facebook: return "Facebook"
            case .telegram: return "Telegram"
            case .discord:  return "Discord"
            case .channel:  return "Custom contact info"
            }
        }
    }
}

struct AddIdentityFormView: View {
    
    @ObservedObject var keyboard = KeyboardResponder()
    
    @State var avatarImage = UIImage.placeholder(color: .systemFill)
    @State var name = ""
    @State var idColor = UIColor.systemPurple   // TODO: use random system color
    @State var privateKeyArmor = "pri1q8gqt3uyktu92n0vf22vhff3psmtx76ufxwmtpy7n59sns3r4ulqp3ynhe-Ed25519"   // TODO:
    @State var publicKeyArmor = "pub17rae4d3fmzvndag07h3vaw9ecymm7x9y6ptvj6k0wfn4jf5ujq2q9dws07-Ed25519"    // TODO:
    
    @State var contactInfos: [ContactInfo.InfoType: [ContactInfo]] = [:]
    
    var body: some View {
        ScrollView {
            // Section avatar
            Button("Edit Avatar") {
                    print("Tap")
                }
                .buttonStyle(AvatarButtonStyle(avatarImage: avatarImage))
                .padding(.top, 16.0)
                .padding(.bottom, 16.0)
            
            // Section name
            Group {
                VStack(spacing: 2.0) {
                    Text("Name".uppercased())
                        .modifier(TextSectionHeaderStyleModifier())
                    TextField("Name", text: $name)
                        .modifier(TextSectionBodyStyleModifier())
                }
                .modifier(SectionCellPaddingStyleModifier())
                Divider()
            }
            .padding(.leading)
            
            // Section ID color
            Group {
                HStack {
                    Text("Set ID Color")
                        .modifier(TextSectionBodyStyleModifier())
                    Image(uiImage: UIImage.placeholder(color: idColor))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 18.0, height: 18.0)
                        .cornerRadius(18.0)
                }
                .modifier(SectionCellPaddingStyleModifier())
                Divider()
            }
            .padding(.leading)
            
            // additional section spacing
            Color.clear
                .frame(height: 24)
                .frame(maxWidth: .infinity)
            
//            // Section private key
//            Group {
//                VStack(spacing: 2.0) {
//                    Text("Private Key".uppercased())
//                        .modifier(TextSectionHeaderStyleModifier())
//                    HStack {
//                        Text(privateKeyArmor)
//                            .foregroundColor(Color(UIColor.label.withAlphaComponent(0.6)))
//                            .lineLimit(1)
//                            .truncationMode(.tail)
//                            .modifier(TextSectionBodyStyleModifier())
//                        Button(action: {
//                            print("Copy")
//                        }) {
//                            Image(uiImage: Asset.Editing.copy.image)
//                                .foregroundColor(Color(UIColor.label))
//                        }
//                    }
//                }
//                .modifier(SectionCellPaddingStyleModifier())
//                Divider()
//            }
//            .padding(.leading)
//
//            // Section public key
//            Group {
//                VStack(spacing: 2.0) {
//                    Text("Public Key".uppercased())
//                        .modifier(TextSectionHeaderStyleModifier())
//                    HStack {
//                        Text(publicKeyArmor)
//                            .foregroundColor(Color(UIColor.label.withAlphaComponent(0.6)))
//                            .lineLimit(1)
//                            .truncationMode(.tail)
//                            .modifier(TextSectionBodyStyleModifier())
//                        Button(action: {
//                            print("Copy")
//                        }) {
//                            Image(uiImage: Asset.Editing.copy.image)
//                                .foregroundColor(Color(UIColor.label))
//                        }
//                    }
//                }
//                .modifier(SectionCellPaddingStyleModifier())
//                Divider()
//            }
//            .padding(.leading)
            
//            // additional section spacing
//            Color.clear
//                .frame(height: 24)
//                .frame(maxWidth: .infinity)
            
            // Channel section header
            Text("Contacts".uppercased())
                .modifier(TextSectionHeaderStyleModifier())
                .padding(.leading)
            
            Group {
                ForEach(ContactInfo.InfoType.allCases, id: \.self) { type in
                    Group {
                        Button(action: {
                            withAnimation {
                                self.addContactInfoInputEntry(for: type)
                            }
                        }) {
                            AddEntryView(iconImage: type.iconImage, entryName: type.typeName)
                        }
                        ForEach(Array((self.contactInfos[type] ?? []).enumerated()), id: \.1.id) { index, info in
                            Group {
                                if info.avaliable {
                                    EditableContactInfoView(contactInfo: Binding(self.$contactInfos[type])![index])
                                }
                            }
                            .transition(.slide)
                        }
                    }
                }
            }
            .background(Color(.systemBackground))
            .padding(.leading)
            
            // form bottom spacer
            Spacer()
                .padding(.bottom, keyboard.currentHeight).animation(.default)
        }
        .frame(maxWidth: .infinity)
    }
    
    func addContactInfoInputEntry(for type: ContactInfo.InfoType) {
        let infos = contactInfos[type] ?? []
        let shouldAppendNewEntry: Bool = {
            if infos.isEmpty { return true }
            if let last = infos.last, !last.isEmptyInfo { return true }
            return false
        }()
        
        guard shouldAppendNewEntry else {
            return
        }
        
        contactInfos[type] = infos + [ContactInfo(type: type, key: "", value: "")]
    }
    
}

//struct AddEntryVerticalCenterAlignmentID: AlignmentID {
//    static func defaultValue(in context: ViewDimensions) -> CGFloat {
//        return context.height / 2
//    }
//}
//
//extension VerticalAlignment {
//    static let addEntryVerticalCenterAlignment = VerticalAlignment(AddEntryVerticalCenterAlignmentID.self)
//}

struct EditableContactInfoView: View {
    @Binding var contactInfo: ContactInfo
    
    var body: some View {
        InputEntryView(infoType: contactInfo.type,
                       keyInput: $contactInfo.key,
                       valueInput: $contactInfo.value,
                       available: $contactInfo.avaliable)
    }
}

struct AddEntryView: View {
    
    let iconImage: UIImage
    let entryName: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 32) {
                Image(uiImage: iconImage)
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(.label))
                Text("Add \(entryName)")
                    .modifier(TextSectionBodyStyleModifier())
            }
            .modifier(SectionCellPaddingStyleModifier())
            Divider()
                .padding(.leading, 24 + 32)
        }
    }
}

struct InputEntryView: View {
    
    let infoType: ContactInfo.InfoType
    
    @Binding var keyInput: String
    @Binding var valueInput: String
    @Binding var available: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // network input
            if infoType == .channel {
                HStack(spacing: 0) {
                    Color.clear
                        .frame(width: 24 + 32, height: 24)
                    TextField("Custom network", text: $keyInput)
                        .modifier(TextSectionBodyStyleModifier())
                    deleteButton
                }
                .modifier(SectionCellPaddingStyleModifier())
                Divider()
                    .padding(.leading, 24 + 32)
            }
            
            // value input
            HStack(spacing: 0) {
                Color.clear
                    .frame(width: 24 + 32, height: 24)
                TextField(inputValueTextFieldPlaceholder, text: $valueInput)
                    .modifier(TextSectionBodyStyleModifier())
                if infoType != .channel {
                    deleteButton
                }
            }
            .modifier(SectionCellPaddingStyleModifier())
            Divider()
                .padding(.leading, 24 + 32)
        }
    }
    
    var inputValueTextFieldPlaceholder: String {
        switch infoType {
        case .channel:  return "Custom ID"
        default:        return "Input \(infoType.typeName)"
        }
    }
    
    var deleteButton: some View {
        Group {
            if !isDeleteButtonHidden {
                Button(action: {
                    withAnimation {
                        self.available = false
                    }
                }) {
                    Image(uiImage: Asset.Editing.close.image)
                }
                .accentColor(Color(UIColor.label.withAlphaComponent(0.6)))
                // TODO: add fade transition animation
            }
        }
    }
    
    var isDeleteButtonHidden: Bool {
        if infoType == .channel {
            return keyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                   valueInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        return valueInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

}

struct AddIdentityFormView_Previews: PreviewProvider {
    static var previews: some View {
        AddIdentityFormView()
    }
}

struct SectionCellPaddingStyleModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        return content
            .padding(.top, 16)
            .padding(.bottom, 14)
            .padding(.trailing, 19)
    }
    
}

struct TextSectionHeaderStyleModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        return content
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(Color(UIColor.label.withAlphaComponent(0.6)))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}

struct TextSectionBodyStyleModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        return content
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(Color(UIColor.label))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}

final class KeyboardResponder: ObservableObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    @Published private(set) var currentHeight: CGFloat = 0
    
    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            .sink { notification in
                guard let endFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    self.currentHeight = 0
                    return
                }
                self.currentHeight = endFrame.height
            }
            .store(in: &disposeBag)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification, object: nil)
            .sink { notification in
                self.currentHeight = 0
        }
        .store(in: &disposeBag)
    }

}
