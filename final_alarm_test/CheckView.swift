//
//  CheckView.swift
//  final_alarm_test
//
//  Created by Raimu Kinoshita on 2024/10/26.
//

import SwiftUI

struct CheckView: View {
    var body: some View {
        VStack {
            Text("適当なページ")
                .font(.largeTitle)
                .padding()

            Text("ここは画面遷移先の適当なページです。")
                .font(.body)
                .padding()
            
            Spacer() // 空白を追加して見た目を整える
        }
        .navigationTitle("詳細")
    }
}
