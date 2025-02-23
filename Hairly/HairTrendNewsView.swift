import SwiftUI

struct HairTrendNewsView: View {
    @StateObject private var viewModel = HairTrendNewsViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.news) { item in
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.title)
                        .font(.headline)
                    Text(item.content)
                        .font(.body)
                    Text("日付: \(item.date)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("ヘアトレンドニュース")
        }
    }
}

struct HairTrendNewsView_Previews: PreviewProvider {
    static var previews: some View {
        HairTrendNewsView()
    }
}
