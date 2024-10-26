import UIKit
import UserNotifications
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        requestNotificationPermission()
        UNUserNotificationCenter.current().delegate = self
        FirebaseApp.configure()
        if FirebaseApp.app() == nil {
            print("Firebaseの初期化に失敗しました")
        } else {
            print("Firebaseの初期化に成功しました")
        }
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("通知がタッチされ、アプリに戻りました: \(response.notification.request.identifier)")
        let currentNum = UserDefaults.standard.integer(forKey:"num")
        UserDefaults.standard.set(currentNum + 1, forKey: "num")
        completionHandler()
    }
}

// 通知の権限をリクエストする関数
func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if error != nil {
            print("通知の権限リクエストに失敗しました: \(error?.localizedDescription ?? "")")
        } else {
            print("通知の権限が許可されました: \(granted)")
        }
    }
}
