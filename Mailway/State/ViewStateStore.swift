//
//  ViewState.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Combine

struct ViewStateStore {
    var chatsView = ViewState.ChatsView()
    var contactsView = ViewState.Contacts()
    var addIdentityView = ViewState.AddIdentityView()
}

