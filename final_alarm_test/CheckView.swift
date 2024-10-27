//
//  CheckView.swift
//  final_alarm_test
//
//  Created by Raimu Kinoshita on 2024/10/26.
//

import SwiftUI


struct CheckView: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var currentDate = Date()
    @State private var colorIndex: Int = 0
    @State private var showwritepage = false
    @AppStorage("showStopButton") private var showStopButton: Bool = false
    @AppStorage("notificationID1") private var notification1UUIDString: String = ""
    @AppStorage("notificationID2") private var notification2UUIDString: String = ""
    @AppStorage("notificationID3") private var notification3UUIDString: String = ""
    @AppStorage("showChatView") private var showChatView: Bool = false
    @StateObject private var timerManager = TimerManager()
    var body: some View {
        VStack {
            Text("\(currentDate, formatter: dateFormatter)")
                .onReceive(timer) { input in
                    currentDate = input
                }
                .font(.system(size: 100))
            
            Spacer() // 空白を追加して見た目を整える
            HStack{
                VStack{
                    Text("一回目")
                    ZStack {
                        Circle()
                            .fill(getColorleft(for: colorIndex))
                            .frame(width: 100, height: 100)
                            .padding()
                        if colorIndex >= 1{
                            Image(systemName: "checkmark")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                VStack{
                    Text("二回目")
                    ZStack {
                        Circle()
                            .fill(getColorcenter(for: colorIndex))
                            .frame(width: 100, height: 100)
                            .padding()
                        if colorIndex >= 2{
                            Image(systemName: "checkmark")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                VStack{
                    Text("三回目")
                    ZStack {
                        Circle()
                            .fill(getColorright(for: colorIndex))
                            .frame(width: 100, height: 100)
                            .padding()
                        if colorIndex >= 3{
                            Image(systemName: "checkmark")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            Spacer()
            if colorIndex <= 2 {
                Button {
                    // 止めるボタンが押されたら通知を消す
                    if colorIndex == 0 {
                        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                    } else {
                        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification2UUIDString])
                    }
                    colorIndex += 1
                    showStopButton = false
                    timerManager.stopTimer()
                } label: {
                    Text("とめる")
                        .padding(.horizontal, 70)
                        .padding(.vertical, 40)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .frame(width: 400, height: 200)
                }
                .opacity(showStopButton ? 1 : 0) // ボタンは常に存在するが、透明度が0になる→レイアウトが崩れないから採用
            }
            
            if colorIndex >= 3 {
                Button {
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification3UUIDString])
                    
                    notification1UUIDString = ""
                    notification2UUIDString = ""
                    notification3UUIDString = ""
                    showwritepage = true
                    showChatView = true
                    timerManager.stopTimer()
                } label: {
                    Text("タイムラインへ投稿しよう！")
                        .padding(.horizontal, 70)
                        .padding(.vertical, 40)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .frame(width: 400, height: 200)
                }
                .opacity(colorIndex >= 3 ? 1 : 0) // ボタンは常に存在し、条件に応じて透明度を調整
            }
            
        }
        .fullScreenCover(isPresented: $showwritepage) {
            WriteView(showwritepage: $showwritepage)
        }
        .onDisappear(){
            //戻るボタンが押されたら全ての通知のスケジュールを削除する
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        }
    }
    
    
    
    func getColorleft(for index: Int) -> Color {
        switch index {
        case 0: return Color.red
        default: return Color.blue
        }
    }
    func getColorcenter(for index: Int) -> Color {
        switch index {
        case 0: return Color.red
        case 1: return Color.red
        default: return Color.blue
        }
    }
    func getColorright(for index: Int) -> Color {
        switch index {
        case 0: return Color.red
        case 1: return Color.red
        case 2: return Color.red
        default: return Color.blue
        }
    }
}

struct CheckView_Previews: PreviewProvider {
    static var previews: some View {
        CheckView()
    }
}
