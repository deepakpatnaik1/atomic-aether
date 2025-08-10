//
//  AnthropicService.swift
//  atomic-aether
//
//  Anthropic API implementation
//
//  ATOM 202: LLM Services - Anthropic provider
//
//  Atomic LEGO: Implements LLMService protocol for Anthropic
//  Handles streaming responses from Anthropic's Messages API
//

import Foundation

@MainActor
class AnthropicService: LLMService {
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
            source: "AnthropicService"
        ))
        
        // Build Anthropic-specific request body
        // Extract system message if present
        let systemMessage = request.messages.first(where: { $0.role == .system })?.content
        let nonSystemMessages = request.messages.filter { $0.role != .system }
        
        // Convert messages to Anthropic format
        let messages = nonSystemMessages.map { ["role": $0.role.rawValue, "content": $0.content] }
        
        var body: [String: Any] = [
            "model": modelName,
            "messages": messages,
            "stream": request.stream ?? request.streamingEnabled ?? config.streamingEnabled,
            "max_tokens": request.maxTokens ?? modelConfig.maxTokens
        ]
        
        // Add tool definitions if present in metadata
        if let tools = request.metadata?["tools"] as? [[String: Any]] {
            body["tools"] = tools
        }
        
        // Add tool choice if present
        if let toolChoice = request.metadata?["tool_choice"] as? [String: Any] {
            body["tool_choice"] = toolChoice
        }
        
        if let system = systemMessage {
            body["system"] = system
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
        urlRequest.setValue(apiKey, forHTTPHeaderField: config.authHeader)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add additional headers (like anthropic-version)
        if let additionalHeaders = config.additionalHeaders {
            for (key, value) in additionalHeaders {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        urlRequest.httpBody = jsonData
        
        // Create streaming response
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
                            throw LLMError.providerError(config.name, message)
                        }
                        
                        throw LLMError.networkError("HTTP \(httpResponse.statusCode)")
                    }
                    
                    // Check if this is a streaming response
                    let isStreaming = request.stream ?? request.streamingEnabled ?? config.streamingEnabled
                    
                    if isStreaming {
                        // Process streaming response
                        for try await line in bytes.lines {
                            if line.hasPrefix("data: ") {
                                let jsonString = String(line.dropFirst(6))
                                
                                if let data = jsonString.data(using: .utf8),
                                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                
                                // Handle different event types
                                if let type = json["type"] as? String {
                                    switch type {
                                    case "content_block_delta":
                                        if let delta = json["delta"] as? [String: Any],
                                           let text = delta["text"] as? String {
                                            continuation.yield(.content(text))
                                            self.eventBus?.publish(LLMEvent.tokenReceived(
                                                token: text,
                                                model: request.model,
                                                source: "AnthropicService"
                                            ))
                                        }
                                        
                                    case "message_stop":
                                        continuation.yield(.done)
                                        
                                    case "message_delta":
                                        if let usage = json["usage"] as? [String: Any] {
                                            let metadata = LLMMetadata(
                                                model: modelName,
                                                promptTokens: usage["input_tokens"] as? Int,
                                                completionTokens: usage["output_tokens"] as? Int,
                                                totalTokens: nil,
                                                finishReason: json["stop_reason"] as? String
                                            )
                                            continuation.yield(.metadata(metadata))
                                        }
                                        
                                    default:
                                        break
                                    }
                                }
                                }
                            }
                        }
                    } else {
                        // Non-streaming response (for structured output)
                        var responseData = Data()
                        for try await byte in bytes {
                            responseData.append(byte)
                        }
                        
                        // Validate JSON and convert to string for structured parsing
                        guard JSONSerialization.isValidJSONObject(try JSONSerialization.jsonObject(with: responseData)) else {
                            throw LLMError.invalidResponse("Invalid JSON response")
                        }
                        
                        if let responseString = String(data: responseData, encoding: .utf8) {
                            continuation.yield(.content(responseString))
                            continuation.yield(.done)
                        } else {
                            throw LLMError.invalidResponse("Invalid JSON response")
                        }
                    }
                    
                    // Publish completion event
                    let duration = Date().timeIntervalSince(startTime)
                    self.eventBus?.publish(LLMEvent.responseCompleted(
                        model: request.model,
                        totalTokens: nil,
                        duration: duration,
                        source: "AnthropicService"
                    ))
                    
                    continuation.finish()
                    
                } catch {
                    self.eventBus?.publish(LLMEvent.errorOccurred(
                        error: error.localizedDescription,
                        model: request.model,
                        source: "AnthropicService"
                    ))
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}