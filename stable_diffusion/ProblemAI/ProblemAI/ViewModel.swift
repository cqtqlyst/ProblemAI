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
        client?.sendCompletion(with: ("Generate problems with each question as a new line but dont create a new line otherwise, then do the same with the solutions after all the questions have been written. Label questions as Q1, Q2, etc, and answers as A1, A2, etc "+input),
                               maxTokens: 900,
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
