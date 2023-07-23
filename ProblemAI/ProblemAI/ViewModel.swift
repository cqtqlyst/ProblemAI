//
//  ViewModel.swift
//  Problem.AI
//
//  Created by Nikhil Krishnaswamy on 7/22/23.
//

import Foundation
import OpenAISwift


class ViewModel: ObservableObject {
    var client: OpenAISwift?
    
    init() {
        setup()
    }
    
    func setup() {
        client = OpenAISwift(authToken: "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") // Replace "YOUR_API_KEY" with your actual API key
    }
    
    func getOpenAIResponse(input: String, completion: @escaping (String) -> Void) {
        // Use the OpenAI API to generate a response based on the input text
        client?.sendCompletion(with: ("Generate problems given the following parameters"+input),
                               maxTokens: 150,
                               completionHandler: { result in
            switch result {
            case .success(let model):
                let output = model.choices.first?.text ?? ""
                completion(output)
            case .failure(let error):
                print("Error: \(error)")
                completion("Error occurred while processing the request.")
            }
        })
    }
}
