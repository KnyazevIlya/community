//
//  ReactionManager.swift
//  community
//
//  Created by Anatoliy Khramchenko on 30.05.2022.
//

import Foundation

//TEMPORARY FILE

class ReactionManager {
    
    static let shared = ReactionManager()
    
    private var data = [String:[Reaction]]()
    
    func getReactions(byPinName pin: String) -> [Reaction] {
        if !data.keys.contains(pin) {
            data[pin] = [
                Reaction(reaction: "😡", count: Int.random(in: 20...800)),
                Reaction(reaction: "👍", count: Int.random(in: 20...800)),
                Reaction(reaction: "😔", count: Int.random(in: 20...800)),
                Reaction(reaction: "😭", count: Int.random(in: 20...800)),
                Reaction(reaction: "😊", count: Int.random(in: 20...800)),
                Reaction(reaction: "🤔", count: Int.random(in: 20...800)),
                Reaction(reaction: "😒", count: Int.random(in: 20...800)),
                Reaction(reaction: "😐", count: Int.random(in: 20...800)),
                Reaction(reaction: "🌚", count: Int.random(in: 20...800)),
                Reaction(reaction: "🙊", count: Int.random(in: 20...800)),
                Reaction(reaction: "🥶", count: Int.random(in: 20...800)),
                Reaction(reaction: "🔥", count: Int.random(in: 20...800))
            ]
        }
        return data[pin]!
    }
    
}
