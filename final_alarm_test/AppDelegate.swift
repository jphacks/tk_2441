import UIKit
import UserNotifications
import Firebase
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    let timerManager = TimerManager()
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
    
    //フォアグラウンドにいる時の通知を検知
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
        //タイマースタート
        timerManager.startTimer()
        UserDefaults.standard.set(Date(), forKey: "notificationReceivedTime")
        UserDefaults.standard.set(true, forKey: "showStopButton")
    }
    
    // リモート通知の受信をバックグラウンドで検知
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // 通知の到着時刻を保存
        UserDefaults.standard.set(Date(), forKey: "notificationReceivedTime")
        print("バックグラウンドで通知を検知しました")
        completionHandler(.newData)
    }
    
    //バックグラウンドで通知バナーをタップしたことを検知
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("通知がタッチされ、アプリに戻りました: \(response.notification.request.identifier)")
        navigateToCheckView()
        UserDefaults.standard.set(true, forKey: "showStopButton")
        completionHandler()
    }
    // CheckViewに遷移する関数
    private func navigateToCheckView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            // UIHostingControllerを使ってSwiftUIビューに遷移
            window.rootViewController = UIHostingController(rootView: CheckView())
            window.makeKeyAndVisible()
        }
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
