import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)?
    
    let secondButtonText: String?
    let secondButtonCompletion: (() -> Void)?
    
    var hasSecondButton: Bool {
        return secondButtonText != nil
    }

    init(
        title: String,
        message: String,
        buttonText: String,
        completion: (() -> Void)? = nil,
        secondButtonText: String? = nil,
        secondButtonCompletion: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.buttonText = buttonText
        self.completion = completion
        self.secondButtonText = secondButtonText
        self.secondButtonCompletion = secondButtonCompletion
    }
}
