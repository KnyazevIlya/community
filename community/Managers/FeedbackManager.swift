//
//  FeedbackManager.swift
//  community
//
//  Created by Illia Kniaziev on 04.03.2022.
//

import UIKit

final class FeedbackManager {
    
    static let shared = FeedbackManager()
    
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    private init() {}
    
    func giveSuccessFeedback() {
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(.success)
    }
    
    func giveErrorFeedback() {
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(.error)
    }
    
}
