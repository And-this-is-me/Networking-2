//
//  ContentView.swift
//  Posts
//
//

import SwiftUI

struct ContentView: View {
    
    private var apiClient = ApiClient.live()
    
    @State var posts: [Post]?
    
    var body: some View {
        NavigationView {
            Group {
                VStack {
                    if let posts {
                        List {
                            ForEach(posts) { i in
                                Text("\(i.title)")
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Posts")
                        .navigationBarItems(trailing:
                            Button(action: {
                                Task {
                                    await addRandomPost()
                                }
                            }) {
                                Text("Add")
                            }
                        )
        }
        .task {
            await loadPosts()
        }
    }
    
    func loadPosts() async {
        do {
            posts = try await apiClient.requestPosts(.init())
        } catch {
            print(error)
        }
    }
    
    func addRandomPost() async {
        do {
            let post = try await apiClient.addPost(.init(
                title: "Added post",
                body: "Added post on \(Date.printNow())",
                userID: 1)
            )
        } catch {
            print(error)
        }
    }
}

extension Date {
    static func printNow() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        let dateTimeString = formatter.string(from: Date())
    }
}
