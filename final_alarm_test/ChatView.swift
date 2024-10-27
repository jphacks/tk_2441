//
//  ChatView.swift
//  final_alarm_test
//
//  Created by 和田一真 on 2024/10/26.
//

import SwiftUI
import FirebaseFirestore

// Postモデル
struct Post: Identifiable {
    let id: String // ドキュメントID
    let content: String
    let date: String
    let userID: String
    let name: String
}

private var db = Firestore.firestore()

// PostModelクラス
class PostModel: ObservableObject {
    var followList: [String] = []
    @Published var postContents: [Post] = []
    private var listenerRegistration: ListenerRegistration?
    private var fetchedDocumentIDs: Set<String> = [] // 取得済みドキュメントIDを保持するセット
    private var calendar=Calendar(identifier: .gregorian)//日時調整用カレンダー
    private var currentDate: Date = Date()

    func fetchPostContents() {
        listenerRegistration = db.collection("posts")
            .whereField("userID", in:followList)
            .whereField("date", isGreaterThan: calendar.startOfDay(for: currentDate))
            .addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("ドキュメントの取得に失敗しました: \(error.localizedDescription)")
                self.postContents = []
            } else if let snapshot = snapshot {
                var updatedPosts: [Post] = []

                for document in snapshot.documents {
                    // ドキュメントIDが既に取得済みか確認
                    if self.fetchedDocumentIDs.contains(document.documentID) {
                        continue // 取得済みならスキップ
                    }
                    
                    let data = document.data()
                    let content = data["content"] as? String ?? "No Content"
                    let name = data["name"] as? String ?? "名無し"
                    let date = data["date"] as? String ?? "No Date"
                    let userID = data["userID"] as? String ?? "Unknown User"
                    
                    // 新しいポストを生成し追加
                    let post = Post(id: document.documentID, content: content, date: date, userID: userID, name: name)
                    updatedPosts.append(post)
                    
                    // 取得済みIDとしてセットに追加
                    self.fetchedDocumentIDs.insert(document.documentID)
                }

                // 新しいポストを既存の配列に追加
                self.postContents.append(contentsOf: updatedPosts)
            }
        }
    }
    
    deinit {
        listenerRegistration?.remove()
    }
}

struct ChatView: View {
    @EnvironmentObject var tabSelection: TabSelection
    @AppStorage("myUID") var myUID: String = "testID"
    @StateObject private var contents = PostModel() // @StateObjectを使ってPostModelを保持
    @AppStorage("showChatView") private var showChatView: Bool = false

    var body: some View {
        if showChatView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(contents.postContents) { post in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(post.name)
                                    .font(.headline)
                                    .padding(.bottom, 2)
                                Spacer()
                            }
                            HStack {
                                Text(post.content)
                                    .font(.subheadline)
                                Spacer()
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.cyan))
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .onAppear {
                Task {
                    // 非同期でフォローリストを取得して設定
                    contents.followList = await getFollowings()
                    contents.fetchPostContents() // フォローしているユーザーの投稿を取得
                }
            }
        } else {
            Text("また明日頑張ろう")
        }
    }
    
    private func getFollowings() async -> [String] {
        var followingUsernames: [String] = []
        
        let followingRef = db.collection("Users").document(myUID).collection("following")
        
        do {
            let snapshot = try await followingRef.getDocuments() // 非同期でドキュメントを取得
            for document in snapshot.documents {
                let username = document.documentID
                followingUsernames.append(username) // "username" フィールドからユーザー名を取得して追加
                print(username)
            }
        } catch {
            print("フォローしているユーザーの取得に失敗しました: \(error.localizedDescription)")
        }
        
        return followingUsernames // ユーザー名の配列を返す
    }
}
