//
//  FireworksService.swift
//  atomic-aether
//
//  Fireworks AI API implementation
//
//  ATOM 202: LLM Services - Fireworks provider
//
//  Atomic LEGO: Implements LLMService protocol for Fireworks
//  Uses OpenAI-compatible API format
//

import Foundation

@MainActor
class FireworksService: LLMService {
    private let config: ProviderConfig
    private let apiKey: String
    private let eventBus: EventBus?
    
    init(config: ProviderConfig, apiKey: String, eventBus: EventBus? = nil) {
        self.config = config
        self.apiKey = apiKey
        self.eventBus = eventBus
    }
    
    func supportsModel(_ model: String) -> Bool {
        let modelName = LLMProvider.extractModelName(from: model)
        return config.models.keys.contains(modelName)
    }
    
    func sendMessage(_ request: LLMRequest) async throws -> AsyncThrowingStream<LLMResponse, Error> {
        let modelName = LLMProvider.extractModelName(from: request.model)
        
        guard let modelConfig = config.models[modelName] else {
            throw LLMError.invalidModel(request.model)
        }
        
        // Publish request started event
        let startTime = Date()
        eventBus?.publish(LLMEvent.requestStarted(
            model: request.model,
            messageCount: request.messages.count,
            source: "FireworksService"
        ))
        
        // Build request body (OpenAI-compatible format)
        let messages = request.messages.map { ["role": $0.role.rawValue, "content": $0.content] }
        var body: [String: Any] = [
            "model": modelName,
            "messages": messages,
            "stream": request.streamingEnabled ?? config.streamingEnabled
        ]
        
        if let maxTokens = request.maxTokens {
            body["max_tokens"] = maxTokens
        } else {
            body["max_tokens"] = modelConfig.maxTokens
        }
        
        if let temperature = request.temperature {
            body["temperature"] = temperature
        }
        
        // Build URL request
        guard let url = URL(string: config.baseURL + config.endpoint) else {
            throw LLMError.networkError("Invalid URL")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("\(config.authPrefix)\(apiKey)", forHTTPHeaderField: config.authHeader)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        urlRequest.httpBody = jsonData
        
        // Create streaming response (same as OpenAI format)
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let (bytes, response) = try await URLSession.shared.bytes(for: urlRequest)
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw LLMError.networkError("Invalid response")
                    }
                    
                    if httpResponse.statusCode != 200 {
                        // Read error response
                        var errorData = Data()
                        for try await byte in bytes {
                            errorData.append(byte)
                        }
                        
                        if let errorJson = try? JSONSerialization.jsonObject(with: errorData) as? [String: Any],
                           let error = errorJson["error"] as? [String: Any],
                           let message = error["message"] as? String {
                            throw LLMError.providerError("Fireworks", message)
                        }
                        
                        throw LLMError.networkError("HTTP \(httpResponse.statusCode)")
                    }
                    
                    // Process streaming response
                    for try await line in bytes.lines {
                        if line.hasPrefix("data: ") {
                            let jsonString = String(line.dropFirst(6))
                            
                            if jsonString == "[DONE]" {
                                continuation.yield(.done)
                                break
                            }
                            
                            if let data = jsonString.data(using: .utf8),
                               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                
                                // Extract content from response
                                if let choices = json["choices"] as? [[String: Any]],
                                   let first = choices.first,
                                   let delta = first["delta"] as? [String: Any],
                                   let content = delta["content"] as? String {
                                    
                                    continuation.yield(.content(content))
                                    self.eventBus?.publish(LLMEvent.tokenReceived(
                                        token: content,
                                        model: request.model,
                                        source: "FireworksService"
                                    ))
                                }
                                
                                // Check for finish reason
                                if let choices = json["choices"] as? [[String: Any]],
                                   let first = choices.first,
                                   let finishReason = first["finish_reason"] as? String,
                                   finishReason != "null" {
                                    
                                    let metadata = LLMMetadata(
                                        model: modelName,
                                        promptTokens: nil,
                                        completionTokens: nil,
                                        totalTokens: nil,
                                        finishReason: finishReason
                                    )
                                    continuation.yield(.metadata(metadata))
                                }
                            }
                        }
                    }
                    
                    // Publish completion event
                    let duration = Date().timeIntervalSince(startTime)
                    self.eventBus?.publish(LLMEvent.responseCompleted(
                        model: request.model,
                        totalTokens: nil,
                        duration: duration,
                        source: "FireworksService"
                    ))
                    
                    continuation.finish()
                    
                } catch {
                    self.eventBus?.publish(LLMEvent.errorOccurred(
                        error: error.localizedDescription,
                        model: request.model,
                        source: "FireworksService"
                    ))
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}