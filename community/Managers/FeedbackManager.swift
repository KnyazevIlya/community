//
//  FeedbackManager.swift
//  community
//
//  Created by Illia Kniaziev on 04.03.2022.
//

import UIKit

final class FeedbackManager {
    
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    init() {}
    
    func giveSuccessFeedback() {
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(.success)
    }
    
    func giveErrorFeedback() {
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(.error)
    }
    
}
