//
//  5mu6_generate_a_data.swift
//  Data-Driven Chatbot Parser
//
//  Created by [Your Name] on [Current Date].
//

import Foundation

// MARK: - Intent

enum Intent: String, CaseIterable {
    case greeting, goodbye, help, unknown
}

// MARK: - Entity

struct Entity: Codable {
    let type: String
    let value: String
}

// MARK: - Pattern

struct Pattern: Codable {
    let intent: Intent
    let patterns: [String]
}

// MARK: - Response

struct Response: Codable {
    let intent: Intent
    let response: String
}

// MARK: - ChatbotParser

class ChatbotParser {
    private let intents: [Intent: [Pattern]]
    private let responses: [Intent: Response]

    init(intents: [Intent: [Pattern]], responses: [Intent: Response]) {
        self.intents = intents
        self.responses = responses
    }

    func parse(input: String) -> Response? {
        let lowercasedInput = input.lowercased()
        for (intent, patterns) in intents {
            for pattern in patterns {
                if pattern.patterns.contains(where: { lowercasedInput.contains($0.lowercased()) }) {
                    return responses[intent]
                }
            }
        }
        return responses[.unknown]
    }
}

// MARK: - Data Driven Chatbot

class DataDrivenChatbot {
    let parser: ChatbotParser

    init(data: Data) {
        do {
            let intentResponses = try JSONDecoder().decode([Intent: [Pattern]].self, from: data)
            let responseDictionary = intentResponses.mapValues { intent, patterns in
                Response(intent: intent, response: "\(intent.rawValue.capitalized) response")
            }
            parser = ChatbotParser(intents: intentResponses, responses: responseDictionary)
        } catch {
            fatalError("Error parsing data: \(error.localizedDescription)")
        }
    }

    func respond(to input: String) -> String {
        guard let response = parser.parse(input: input) else {
            return "Error parsing input"
        }
        return response.response
    }
}

// MARK: - Example Usage

let data = """
{
    "greeting": [
        {"patterns": ["hello", "hi", "hey"]},
        {"patterns": ["bonjour", "salut"]},
        {"patterns": ["hola", "hello spanish"]}
    ],
    "goodbye": [
        {"patterns": ["goodbye", "see you later", "bye"]},
        {"patterns": ["au revoir", "à bientôt"]}
    ]
}
""".data(using: .utf8)!

let chatbot = DataDrivenChatbot(data: data)
print(chatbot.respond(to: "Hello")) // Output: Greeting response
print(chatbot.respond(to: "Au revoir")) // Output: Goodbye response
print(chatbot.respond(to: "FOO")) // Output: Unknown response