//
//  EditProfileView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-28.
//  Copyright © 2020 Dimension. All rights reserved.
//

import SwiftUI
import Combine

struct AddIdenittyView: View {
    
    @ObservedObject var viewModel: AddIdentityViewModel
    
    var body: some View {
        EditProfileView(
            avatar: $viewModel.avatar,
            name: $viewModel.name,
            color: $viewModel.color,
            infoDict: $viewModel.infoDict,
            note: $viewModel.note,
            pickColorAction: { self.viewModel.pickColorActionPublisher.send() }
        )
    }
}

struct EditProfileView: View {
    
    @Binding var avatar: UIImage?
    @Binding var name: String
    @Binding var color: UIColor
    @Binding var infoDict: [ContactInfo.InfoType: [ContactInfo]]
    @Binding var note: Note
    
    var pickColorAction: () -> Void
    
    @ObservedObject var keyboard = KeyboardResponder()
        
    var body: some View {
        ScrollView {
            // Section avatar
            Button("Edit Avatar") {
                    print("Tap")
                }
            .buttonStyle(AvatarButtonStyle(avatarImage: self.avatar ?? UIImage.placeholder(color: .systemFill)))
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
                    Image(uiImage: UIImage.placeholder(color: color))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 18.0, height: 18.0)
                        .cornerRadius(18.0)
                }
                .modifier(SectionCellPaddingStyleModifier())
                .contentShape(Rectangle())
                .onTapGesture {
                    self.pickColorAction()
                }
                Divider()
            }
            .padding(.leading)
            
            // additional section spacing
            Color.clear
                .frame(height: 24)
                .frame(maxWidth: .infinity)
            
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
                            AddEntryView(iconImage: type.iconImage, entryName: type.editSectionName)
                        }
                        ForEach(Array((self.infoDict[type] ?? []).enumerated()), id: \.1.id) { index, info in
                            Group {
                                if info.avaliable {
                                    EditableContactInfoView(
                                        contactInfo: Binding(self.$infoDict[type])![index],
                                        removeAction: {
                                            withAnimation {
                                                // fix iPad crash issue
                                                UIApplication.shared.endEditing()
                                                self.infoDict[type]?[index].avaliable = false
                                            }
                                        }
                                    )
                                    .transition(.slide)
                                } else {
                                    EmptyView()
                                }
                            }
                        }
                    }
                }
                // note
                Button(action: {
                    withAnimation {
                        self.note.isEnabled = true
                    }
                }) {
                    AddEntryView(iconImage: Asset.Communication.listBubble.image, entryName: "Node")
                }
                Group {
                    if note.isEnabled {
                        EdiableNoteView(note: $note)
                    }
                }
                .transition(.slide)
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
        let infos = infoDict[type] ?? []
        let shouldAppendNewEntry: Bool = {
            if infos.isEmpty { return true }
            if let last = infos.last, !last.isEmptyInfo { return true }
            return false
        }()
        
        guard shouldAppendNewEntry else {
            return
        }
        
        infoDict[type] = infos + [ContactInfo(type: type, key: "", value: "")]
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

extension EditProfileView {
    struct Note {
        var isEnabled = false
        var input = ""
    }
}



struct EditableContactInfoView: View {
    
    @Binding var contactInfo: ContactInfo
    var removeAction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // key (only for .custom)
            if contactInfo.type == .custom {
                InputEntryView(
                    isRemoveButtonEnabled: true && !isDeleteButtonHidden,
                    removeButtonPressAction: {
                        self.removeAction()
                    },
                    placeholder: "Custom network",
                    input: $contactInfo.key,
                    available: $contactInfo.avaliable
                )
            }
            // value
            InputEntryView(
                isRemoveButtonEnabled: contactInfo.type != .custom && !isDeleteButtonHidden,
                removeButtonPressAction: {
                    self.removeAction()
                },
                placeholder: valueInputPlaceholder,
                input: $contactInfo.value,
                available: $contactInfo.avaliable
            )
        }
        
    }
    
    var valueInputPlaceholder: String {
        switch contactInfo.type {
        case .custom:   return "Custom ID"
        default:        return "Input \(contactInfo.type.editSectionName)"
        }
    }
    
    var isDeleteButtonHidden: Bool {
        if contactInfo.type == .custom {
            return contactInfo.key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                contactInfo.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        return contactInfo.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
}

struct EdiableNoteView: View {
    
    @Binding var note: EditProfileView.Note
    
    var body: some View {
        InputEntryView(
            isRemoveButtonEnabled: !isDeleteButtonHidden,
            removeButtonPressAction: {
                // fix iPad crash issue
                UIApplication.shared.endEditing()
                self.note.input = ""
                self.note.isEnabled = false
            },
            placeholder: "Input Note",
            input: $note.input,
            available: $note.isEnabled
        )
    }
    
    var isDeleteButtonHidden: Bool {
        return note.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
    
    let isRemoveButtonEnabled: Bool
    let removeButtonPressAction: () -> Void
    let placeholder: String
        
    @Binding var input: String
    @Binding var available: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Color.clear
                    .frame(width: 24 + 32, height: 24)
                TextField(placeholder, text: $input)
                    .modifier(TextSectionBodyStyleModifier())
                if isRemoveButtonEnabled {
                    deleteButton
                }
            }
            .modifier(SectionCellPaddingStyleModifier())
            Divider()
                .padding(.leading, 24 + 32)
        }
    }
    
    var deleteButton: some View {
        Group {
            if isRemoveButtonEnabled {
                Button(action: {
                    withAnimation {
                        self.removeButtonPressAction()
                    }
                }) {
                    Image(uiImage: Asset.Editing.close.image)
                }
                .accentColor(Color(UIColor.label.withAlphaComponent(0.6)))
                // TODO: add fade transition animation
            }
        }
    }

}

struct AddIdentityFormView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(
            avatar: .constant(nil),
            name: .constant(""),
            color: .constant(.systemPurple),
            infoDict: .constant([:]),
            note: .constant(.init()),
            pickColorAction: { print("pick color") }
        ).environmentObject(AppContext.shared)
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

fileprivate struct TextSectionHeaderStyleModifier: ViewModifier {
    
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
