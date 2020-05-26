//
//  AppCommand.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Combine

protocol AppCommand {
    func execute(in store: AppContext)
}
//
//struct RegisterAppCommand: AppCommand {
//    let email: String
//    let password: String
//
//    func execute(in store: Context) {
//        let token = SubscriptionToken()
//        RegisterRequest(
//            email: email,
//            password: password
//        ).publisher
//        .sink(
//            receiveCompletion: { complete in
//                if case .failure(let error) = complete {
//                    store.dispatch(.accountBehaviorDone(result: .failure(error)))
//                }
//                token.unseal()
//            },
//            receiveValue: { user in
//                store.dispatch(.accountBehaviorDone(result: .success(user)))
//            }
//        ).seal(in: token)
//    }
//}
//
//struct LoginAppCommand: AppCommand {
//    let email: String
//    let password: String
//
//    func execute(in store: Context) {
//        let token = SubscriptionToken()
//        LoginRequest(
//            email: email,
//            password: password
//        ).publisher
//        .sink(
//            receiveCompletion: { complete in
//                if case .failure(let error) = complete {
//                    store.dispatch(.accountBehaviorDone(result: .failure(error)))
//                }
//                token.unseal()
//            },
//            receiveValue: { user in
//                store.dispatch(.accountBehaviorDone(result: .success(user)))
//            }
//        )
//        .seal(in: token)
//    }
//}
//
//struct LoadPokemonsCommand: AppCommand {
//    func execute(in store: Context) {
//        let token = SubscriptionToken()
//        LoadPokemonRequest.all
//            .sink(
//                receiveCompletion: { complete in
//                    if case .failure(let error) = complete {
//                        store.dispatch(.loadPokemonsDone(result: .failure(error)))
//                    }
//                    token.unseal()
//                }, receiveValue: { value in
//                    store.dispatch(.loadPokemonsDone(result: .success(value)))
//                }
//            )
//            .seal(in: token)
//    }
//}
//
//struct LoadAbilitiesCommand: AppCommand {
//
//    let pokemon: Pokemon
//
//    func load(pokemonAbility: Pokemon.AbilityEntry, in store: Context)
//        -> AnyPublisher<AbilityViewModel, AppError>
//    {
//        if let value = store.appState.pokemonList.abilities?[pokemonAbility.id.extractedID!] {
//            return Just(value)
//                .setFailureType(to: AppError.self)
//                .eraseToAnyPublisher()
//        } else {
//            return LoadAbilityRequest(pokemonAbility: pokemonAbility).publisher
//        }
//    }
//
//    func execute(in store: Context) {
//        let token = SubscriptionToken()
//        pokemon.abilities
//            .map { load(pokemonAbility: $0, in: store) }
//            .zipAll
//            .sink(
//                receiveCompletion: { complete in
//                    if case .failure(let error) = complete {
//                        store.dispatch(.loadAbilitiesDone(result: .failure(error)))
//                    }
//                    token.unseal()
//                },
//                receiveValue: { value in
//                    store.dispatch(.loadAbilitiesDone(result: .success(value)))
//                }
//            )
//            .seal(in: token)
//    }
//}
//
//struct ClearCacheCommand: AppCommand {
//    func execute(in store: Context) {
//        KingfisherManager.shared.cache.clearMemoryCache()
//        KingfisherManager.shared.cache.clearDiskCache()
//    }
//}
//
//class SubscriptionToken {
//    var cancellable: AnyCancellable?
//    func unseal() { cancellable = nil }
//}
//
//extension AnyCancellable {
//    func seal(in token: SubscriptionToken) {
//        token.cancellable = self
//    }
//}
