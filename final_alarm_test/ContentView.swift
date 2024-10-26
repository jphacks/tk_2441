import SwiftUI
import UserNotifications
import FirebaseFirestore

struct ContentView: View {
    @AppStorage("num") private var num: Int = 0
    @State private var alarmTime = Date()
    @State private var isNavigationActive = false
    @State private var postContent: String = "読み込み中..."
    
    var body: some View {
        NavigationView{
            VStack {
                Text("カウント数: \(num)")
                    .padding()
                Text("投稿内容: \(postContent)") // Firestoreから取得した内容を表示
                    .padding()
                DatePicker("時間を選択", selection: $alarmTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding()
                Button(action: {
                    scheduleLocalNotification(for: alarmTime)
                    isNavigationActive = true
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
            }
            .navigationTitle("アラーム設定")
            .onAppear {
                fetchPostContent() // 画面表示時にFirestoreからデータを取得
            }
        }
    }

    // ローカル通知をスケジュールする関数
    func scheduleLocalNotification(for date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "アラーム"
        content.body = "タップしてもどろう！！"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("alarm_ap.mp3"))
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: date)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if error != nil {
                print("通知のスケジュールに失敗しました: \(error?.localizedDescription ?? "")")
            } else {
                print("通知がスケジュールされました")
            }
        }
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
