//
//  ProfileView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-9.
//  Copyright © 2020 Dimension. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    
    @Binding var avatar: UIImage
    @Binding var colorBarColor: UIColor
    @Binding var name: String
    @Binding var isMyProfile: Bool
    @Binding var keyID: String
    @Binding var contactInfoDict: [ContactInfo.InfoType: [ContactInfo]]
    @Binding var note: String
    
    @Binding var isPlaceholderHidden: Bool
    
    var shareProfileAction: () -> ()
    var copyKeyIDAction: () -> ()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Banner
                Group {
                    // avatar
                    ProfileAvatarView(avatar: $avatar)
                    // 14pt padding
                    Color.clear.frame(width: .leastNonzeroMagnitude, height: 14)
                    // color bar
                    colorBar
                    // 14pt padding
                    Color.clear.frame(width: .leastNonzeroMagnitude, height: 14)
                    // name
                    Text(name)
                        .font(.system(size: 24, weight: .regular))
                    // 16pt padding
                    Color.clear.frame(width: .leastNonzeroMagnitude, height: 8)
                    // My Profile
                    Text("My Profile")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.secondaryLabel))
                        .isHidden(!isMyProfile)
                    // 16pt padding
                    Color.clear.frame(width: .leastNonzeroMagnitude, height: 16)
                    // share button
                    Button("Share Profile", action: {
                        self.shareProfileAction()
                    }).buttonStyle(LargeRoundedButtonStyle(title: "Share Profile"))
                }
                // 32pt padding
                Color.clear.frame(width: .leastNonzeroMagnitude, height: 32)
                // Info list
                Group {
                    // key ID section
                    keyIDSection
                    if isPlaceholderHidden {
                        Image(uiImage: Asset.Placeholder.document.image)
                            .resizable()
                            .frame(width: 250, height: 200)
                    } else {
                        // info section
                        infoSections
                        // note section
                        noteSection
                    }
                }
            }.frame(maxWidth: .infinity)
        }
    }
    
}

extension ProfileView {
    
    var colorBar: some View {
        RoundedRectangle(cornerRadius: 4 * 0.5, style: .continuous)
            .frame(width: 24, height: 4)
            .foregroundColor(Color(colorBarColor))
    }
    
    var keyIDSection: some View {
        Group {
            Text("Key ID")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color(UIColor.label.withAlphaComponent(0.6)))
                .frame(maxWidth: .infinity, alignment: .leading)
            // 8pt padding
            Color.clear.frame(width: .leastNonzeroMagnitude, height: 8.0)
            HStack {
            Text(ProfileView.formate(keyID: keyID))
                .lineLimit(2)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                Button(action: {
                    
                }) {
                    Image(uiImage: Asset.Editing.docOnDoc.image)
                }
                .accentColor(Color(.label))
            }
            // 24pt padding
            Color.clear.frame(width: .leastNonzeroMagnitude, height: 24)
        }
        .padding([.leading, .trailing])
    }
    
    var infoSections: some View {
        ForEach(ContactInfo.InfoType.allCases, id: \.self) { type in
            Group {
                // section header
                if !((self.contactInfoDict[type] ?? []).isEmpty) {
                    Text(type.editSectionName)
                        .modifier(TextSectionHeaderStyleModifier())
                    // info cell
                    ForEach(Array((self.contactInfoDict[type] ?? []).enumerated()), id: \.1.id) { index, info in
                        Group {
                            // top padding
                            Color.clear.frame(width: .leastNonzeroMagnitude, height: 8.0)
                            if type == .custom {
                                Text(info.key)
                                    .font(.system(size: 16))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Text(info.value)
                                .font(.system(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            // bottom padding
                            Color.clear.frame(width: .leastNonzeroMagnitude, height: 8.0)
                        }
                    }
                    // 24pt padding
                    Color.clear.frame(width: .leastNonzeroMagnitude, height: 24)
                }
            }
        }
        .padding([.leading, .trailing])
    }
    
    var noteSection: some View {
        Group {
            if !note.isEmpty {
                Text("Note")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(UIColor.label.withAlphaComponent(0.6)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                // 8pt padding
                Color.clear.frame(width: .leastNonzeroMagnitude, height: 8.0)
                Text(note)
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                // 24pt padding
                Color.clear.frame(width: .leastNonzeroMagnitude, height: 24)
            }
        }
        .padding([.leading, .trailing])
    }
    
}

extension ProfileView {
    
    static func formate(keyID: String) -> String {
        // assert(keyID.count == 64)
        guard keyID.count == 64 else {
            return keyID
        }
        
        return [keyID.prefix(32), keyID.suffix(32)]
            .map { String($0) }
            .map { $0.separate(every: 4, with: Character(" ")) }    // add cast to fix Xcode Preview crash issue
            .joined(separator: "\n")
    }
    
}

fileprivate struct TextSectionHeaderStyleModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        return content
            .font(.system(size: 12, weight: .regular))
            .foregroundColor(Color(UIColor.label.withAlphaComponent(0.6)))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}

struct ProfileAvatarView: View {
    @Binding var avatar: UIImage
    
    var body: some View {
        Image(uiImage: avatar)
            .resizable()
            .frame(width: 135, height: 135)
            .cornerRadius(135 * 0.5)
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let contactInfoDict: [ContactInfo.InfoType: [ContactInfo]] = [
            .email: [
                ContactInfo(type: .email, key: "email", value: "alice@mail.me")
            ],
            .twitter: [
                ContactInfo(type: .twitter, key: "twitter", value: "@Alice"),
                ContactInfo(type: .twitter, key: "twitter", value: "@realAlice"),
            ],
            .telegram: [
                ContactInfo(type: .telegram, key: "telegram", value: "teleAlice")
            ],
            .discord: [
                ContactInfo(type: .discord, key: "discord", value: "Alice#1234")
            ]
        ]
        return Group {
            ProfileView(
                avatar: .constant(UIImage.placeholder(color: .systemFill)),
                colorBarColor: .constant(.systemPurple),
                name: .constant("Alice"),
                isMyProfile: .constant(true),
                keyID: .constant("0816fe6c1edebe9fbb83af9102ad9c899abec1a87a1d123bc24bf11945cc807c"),
                contactInfoDict: .constant(contactInfoDict),
                note: .constant("Alice in the Book\nPhone Number: +00 123-456-7890"),
                isPlaceholderHidden: .constant(true),
                shareProfileAction: { print("Share") },
                copyKeyIDAction: { print("Copy") }
            )
            
            ProfileView(
                avatar: .constant(UIImage.placeholder(color: .systemFill)),
                colorBarColor: .constant(.systemPurple),
                name: .constant("Alice"),
                isMyProfile: .constant(true),
                keyID: .constant("0816fe6c1edebe9fbb83af9102ad9c899abec1a87a1d123bc24bf11945cc807c"),
                contactInfoDict: .constant(contactInfoDict),
                note: .constant("Alice in the Book\nPhone Number: +00 123-456-7890"),
                isPlaceholderHidden: .constant(false),
                shareProfileAction: { print("Share") },
                copyKeyIDAction: { print("Copy") }
            )
        }
    }
}
#endif
