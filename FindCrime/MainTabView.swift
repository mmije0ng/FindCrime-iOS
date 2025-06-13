import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            CrimeStatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("통계")
                }

            ReportView()
                .tabItem {
                    Image(systemName: "exclamationmark.bubble.fill")
                    Text("제보")
                }

            MapScreenView()
                .tabItem {
                    Image(systemName: "magnifyingglass.circle.fill")
                    Text("경찰서 찾기")
                }

            MyPageView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("마이페이지")
                }
        }
    }
}
