//import SwiftUI
//import CoreLocation
//
//struct ContentView: View {
//    @State private var showMap = false
//
//    var body: some View {
//        if showMap {
//            MapScreenView()
//        } else {
//            MainIntroView(showMap: $showMap)
//        }
//    }
//}
//
//struct MainIntroView: View {
//    @Binding var showMap: Bool
//
//    var body: some View {
//        VStack(spacing: 24) {
//            Spacer()
//
//            Text("FindCrime")
//                .font(.largeTitle.bold())
//                .foregroundColor(.blue)
//
//            Image(systemName: "map.fill")
//                .resizable()
//                .frame(width: 100, height: 100)
//                .foregroundColor(.blue)
//
//            Text("우리 지역의 범죄 통계와\n가까운 경찰서를 지도에서 찾아보세요.")
//                .font(.subheadline)
//                .foregroundColor(.gray)
//                .multilineTextAlignment(.center)
//
//            Spacer()
//
//            Button(action: {
//                showMap = true
//            }) {
//                Text("로그인")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//            .padding(.horizontal)
//            .padding(.bottom, 40)
//        }
//        .padding()
//    }
//}
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            MainTabView()
        } else {
            MainIntroView(isLoggedIn: $isLoggedIn)
        }
    }
}
