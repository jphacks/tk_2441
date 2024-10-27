import SwiftUI
import UserNotifications
import FirebaseFirestore

struct ContentView: View {
    @EnvironmentObject var tabSelection: TabSelection
    @State private var alarmTime = Date()
    @State private var isNavigationActive = false
    @State private var postContent: String = "読み込み中..."
    @AppStorage("showStopButton") private var showStopButton: Bool = false
    @AppStorage("notificationID1") private var notification1UUIDString: String = ""
    @AppStorage("notificationID2") private var notification2UUIDString: String = ""
    @AppStorage("notificationID3") private var notification3UUIDString: String = ""
    @AppStorage("myUID") private var myUID: String = "" // ローカルにユーザーIDを保存するためのAppStorage
    @AppStorage("myName") private var myName: String = "名無し" // ローカルにユーザーIDを保存するためのAppStorage
    private let db = Firestore.firestore()
    var body: some View {
        NavigationView{
            VStack {
                DatePicker("時間を選択", selection: $alarmTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding()
                Button(action: {
                    scheduleLocalNotification(for: alarmTime)
                    isNavigationActive = true
                    //セットのタイミングでボタンを隠す
                    showStopButton = false
                }) {
                    Text("セット")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: CheckView(), isActive: $isNavigationActive){
                    EmptyView()
                }
                .onAppear {
                    // ユーザーIDを生成してローカルストレージに保存
                    generateAndStoreUserID(myName: myName)
                }
            }
            .navigationTitle("アラーム設定")
            .onAppear {
                fetchPostContent() // 画面表示時にFirestoreからデータを取得
            }
        }
    }
    
    //自分のUIDの生成
    func generateAndStoreUserID(myName: String) {
            if myUID.isEmpty {
                // Firestoreで新しいドキュメントを作成し、そのIDを取得
                let userRef = db.collection("Users").document() // 自動生成のドキュメントIDを使う
                let newUID = userRef.documentID // 自動生成されたドキュメントIDをUIDとして使用
                let userData: [String: Any] = [
                    "created_at": Timestamp(date: Date()), // 作成日時
                    "name": myName // ユーザーの名前を追加
                ]
                // Firestoreにユーザーデータを保存
                userRef.setData(userData) { error in
                    if let error = error {
                        print("ユーザーIDの保存に失敗しました: \(error.localizedDescription)")
                    } else {
                        print("ユーザーIDをFirestoreに保存しました: \(newUID)")
                        
                        // フォローサブコレクションの生成
                        createFollowingSubcollection(for: newUID)
                        
                        // ローカルストレージに保存（次回起動時にも利用できるように）
                        myUID = newUID
                    }
                }
            } else {
                // すでにユーザーIDが存在する場合は何もしない
                print("既存のユーザーIDを使用しています: \(myUID)")
            }
        }
    
    // フォローリストサブコレクションを生成
    func createFollowingSubcollection(for uid: String) {
        let followingRef = db.collection("Users").document(uid).collection("following")
        followingRef.document("init").setData([:]) { error in
            if let error = error {
                print("フォローサブコレクションの初期化に失敗しました: \(error.localizedDescription)")
            } else {
                print("フォローサブコレクションを初期化しました")
            }
        }
    }
    
    // ローカル通知をスケジュールする関数
    func scheduleLocalNotification(for date: Date) {
        let content = UNMutableNotificationContent()
        let secondInterval = Double(Int.random(in: 10...450))
        let thirdInterval = Double(Int.random(in: 451...900))
        let intervals = [0.0, secondInterval, thirdInterval]
        print(intervals)
        let notificationTitles = ["アラーム","1回目の通知だよ","2回目の通知だよ"]
        let notificationMessages = ["アラームを止める","起きてるかな？","間に合うかな？"]
        //二つ目と三つ目のはわざと名前を間違えてデフォルトを読んでいる
        let notificationSounds = ["alarm_app.mp3","alarm_ap.mp3","alarm_ap.mp3"]
        var UUIDlist : [String] = []
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        //テストのために時間指定じゃなくて強制的に5秒後に通知が来るようにしています
        //        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        // dateComponents からターゲットの日時を生成
        guard let targetDate = calendar.date(from: dateComponents) else {
            print("日付の生成に失敗しました")
            return
        }

        // 現在の時間を取得
        let now = Date()

        // ターゲットの日時と現在の時間の差を計算（秒単位）
        let timeDifference = targetDate.timeIntervalSince(now)
        print(timeDifference)
        
        for i in 0...2 {
            content.title = notificationTitles[i]
            content.body = notificationMessages[i]
            content.sound = UNNotificationSound(named: UNNotificationSoundName(notificationSounds[i]))

            var trigger: UNNotificationTrigger

            if i == 0 {
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            } else {
                let additionalInterval = intervals[i] + timeDifference
                trigger = UNTimeIntervalNotificationTrigger(timeInterval: additionalInterval, repeats: false)
            }

            let newUUID = UUID().uuidString
            UUIDlist.append(newUUID)
            let request = UNNotificationRequest(identifier: newUUID, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("通知のスケジュールに失敗しました: \(error.localizedDescription)")
                } else {
                    print("通知がスケジュールされました: \(newUUID)")
                }
            }
        }
        //これによってアラーム設定時にかけられた通知にそれぞれアクセスできる
        notification1UUIDString = UUIDlist[0]
        notification2UUIDString = UUIDlist[1]
        notification3UUIDString = UUIDlist[2]
        
        
    }
    
    // Firestoreからデータを取得してpostContentに保存する関数
    func fetchPostContent() {
        let db = Firestore.firestore()
        let documentRef = db.collection("A").document("B")
        documentRef.getDocument { (document, error) in
            if let error = error {
                print("ドキュメントの取得に失敗しました: \(error.localizedDescription)")
                self.postContent = "エラーが発生しました"
            } else if let document = document, document.exists {
                let data = document.data()
                self.postContent = data?["C"] as? String ?? "データがありません"
            } else {
                print("ドキュメントは存在しません")
                self.postContent = "ドキュメントが存在しません"
            }
        }
    }
    
}
