import SwiftUI

struct UploadPhotoScreen: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.fill")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("Upload Photo")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Photo upload functionality is under development. Check back later!")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}
