//
//  ApiClient.swift
//  Posts
//
//

import SwiftUI

// Error definition
enum ApiClientError: Error {
    case mappingError(requestID: UUID)
    case httpFailed(statusCode: Int, requestID: UUID)
}

// Actor declaration
actor ApiClient {

    // Initialization
    init(
        requestPosts: @escaping (FetchPostsRequest) async throws -> [Post],
        addPost: @escaping (AddPostRequest) async throws -> Post
    ) {
        self.requestPosts = requestPosts
        self.addPost = addPost
    }
    
    public var requestPosts: (FetchPostsRequest) async throws -> [Post]
    public var addPost: (AddPostRequest) async throws -> Post
    
    // Generic method to parse requests
    static func handle <Success: Decodable>(
        baseURL: URL,
        urlSession: URLSession,
        decoder: JSONDecoder,
        encoder: JSONEncoder,
        requestID: UUID,
        requester: URLRequester
    ) async throws -> Success {
        
        let request = try requester.urlRequest(
            baseURL: baseURL,
            encoder: encoder
        )
        
        let element: (data: Data, urlResponse: URLResponse) = try await urlSession.data(for: request)
        
        if let response = element.urlResponse as? HTTPURLResponse, response.statusCode != 200 {
            throw ApiClientError.httpFailed(
                statusCode: response.statusCode,
                requestID: requestID
            )
        }
        
        do {
            let response = try decoder.decode(Success.self, from: element.data)
            return response
        } catch {
            throw ApiClientError.mappingError(requestID: requestID)
        }
    }
    
    static func live(
        urlSession: URLSession = .shared,
        jsonDecoder: JSONDecoder = .init(),
        jsonEncoder: JSONEncoder = .init(),
        buildUUID: @escaping () -> UUID = { UUID() }
    ) -> Self {
        jsonDecoder.dateDecodingStrategy = .iso8601
        
        return .init(
            requestPosts: {
                try await handle(
                    baseURL: URL(string: "https://jsonplaceholder.typicode.com")!,
                    urlSession: urlSession,
                    decoder: jsonDecoder,
                    encoder: jsonEncoder,
                    requestID: buildUUID(),
                    requester: $0
                )
            },
            addPost: {
                try await handle(
                    baseURL: URL(string: "https://jsonplaceholder.typicode.com")!,
                    urlSession: urlSession,
                    decoder: jsonDecoder,
                    encoder: jsonEncoder,
                    requestID: buildUUID(),
                    requester: $0
                )
            }
        )
    }
}
