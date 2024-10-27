import SwiftUI
import Combine

class TimerManager: ObservableObject {
    @Published var remainingTime = 15
    @AppStorage("showChatView") private var showChatView: Bool = false
    @Published var shouldNavigateToChatView = false
    
    private var timer: Timer?

    // タイマーを開始する関数
    func startTimer() {
        print("タイマースタート！")
        remainingTime = 15
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.remainingTime > 0 {
                self.remainingTime -= 1
                print(self.remainingTime)
            } else {
                self.timer?.invalidate()
                print("タイマー終了")
                showChatView = false
                self.shouldNavigateToChatView = true
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            }
        }
    }

    // タイマーを停止する関数
    func stopTimer() {
        timer?.invalidate()
        shouldNavigateToChatView = false
        print("タイマーがストップされました")
    }
}
