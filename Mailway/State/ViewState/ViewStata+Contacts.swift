//
//  ViewStata+Contacts.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-21.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Combine

extension ViewState {
    struct Contacts {
        // trigger CreateIdentityView modal
        let presentCreateIdentityViewPublisher = PassthroughSubject<Void, Never>()
    }
}
