import SwiftUI

struct MainIntroView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("FindCrime")
                .font(.largeTitle.bold())
                .foregroundColor(.blue)

            Image(systemName: "map.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)

            Text("우리 지역의 범죄 통계와\n가까운 경찰서를 지도에서 찾아보세요.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Spacer()

            Button(action: {
                isLoggedIn = true
            }) {
                Text("로그인")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .padding()
    }
}
