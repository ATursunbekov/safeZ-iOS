import SwiftUI
import UIKit

struct RemoteImage: View {
    let imageUrl: String
    
    var body: some View {
        ImageLoader(imageUrl: imageUrl)
            .aspectRatio(contentMode: .fill)
            .edgesIgnoringSafeArea(.all)
            .frame(maxWidth: UIScreen.main.bounds.width,
                   maxHeight: UIScreen.main.bounds.height)
    }
}

struct ImageLoader: View {
    @StateObject private var imageLoader = ImageLoaderViewModel()
    let imageUrl: String

    var body: some View {
        if let image = imageLoader.image {
            Image(uiImage: image)
                .resizable() // Make the image resizable
                .onAppear {
                    imageLoader.loadImage(from: imageUrl)
                }
        } else {
            ProgressView() // Show a loading indicator while the image is loading
                .onAppear {
                    imageLoader.loadImage(from: imageUrl)
                }
        }
    }
}

class ImageLoaderViewModel: ObservableObject {
    @Published var image: UIImage?

    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }

            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }.resume()
    }
}
