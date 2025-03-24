//
//  Post.swift
//  Posts
//
//

import Foundation

public struct Post: Codable, Equatable, Identifiable {
    public let id: Int
    let body: String
    let title: String
    let userID: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case body
        case title
        case userID = "userId"
    }
}

extension Post {
    static let preview: [Self] = [
        .init(id: 1, body: "Body 1", title: "Title 1", userID: 1),
        .init(id: 2, body: "Body 2", title: "Title 2", userID: 2),
        .init(id: 3, body: "Body 3", title: "Title 3", userID: 3)
    ]
}
