//
//  AppError.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation

enum AppError: Error, Identifiable {
    var id: String {
        String(describing: self)
    }

    case `internal`
//    case alreadyRegistered
//    case passwordWrong
//
//    case requiresLogin
//    case networkingFailed(Error)
    case fileError
}

//extension AppError: LocalizedError {
//    var localizedDescription: String {
//        switch self {
//        case .alreadyRegistered: return "该账号已注册"
//        case .passwordWrong: return "密码错误"
//        case .requiresLogin: return "需要账户"
//        case .networkingFailed(let error): return error.localizedDescription
//        case .fileError: return "文件操作错误"
//        }
//    }
//}
