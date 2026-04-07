import SwiftUI

struct SocialView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(SocialPost.all) { post in
                        SocialCard(post: post,
                            isLiked: state.likedPosts.contains(post.id),
                            onLike: {
                                if state.likedPosts.contains(post.id) {
                                    state.likedPosts.remove(post.id)
                                } else {
                                    state.likedPosts.insert(post.id)
                                }
                            }
                        )
                    }
                }
                .padding(16)
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("Freunde")
        }
    }
}

private struct SocialCard: View {
    let post: SocialPost
    let isLiked: Bool
    let onLike: () -> Void

    var postColor: Color { Color(hex: post.colorHex) }
    var likeCount: Int   { post.likes + (isLiked ? 1 : 0) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .top, spacing: 12) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(postColor.opacity(0.13))
                        .frame(width: 42, height: 42)
                    Text(post.initials)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(postColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Theme.dark)
                    Text("\(post.action) · vor \(post.time)")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.muted)
                    HStack(spacing: 4) {
                        Text(post.emoji)
                        Text(post.dish)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Theme.dark)
                    }
                    .padding(.top, 6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider().padding(.horizontal, 16)

            // Aktionen
            HStack(spacing: 8) {
                Button(action: onLike) {
                    HStack(spacing: 5) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 12))
                            .foregroundColor(isLiked ? Color(hex: "#EE3333") : Theme.muted)
                        Text("\(likeCount)")
                            .font(.system(size: 12))
                            .foregroundColor(isLiked ? Color(hex: "#EE3333") : Theme.muted)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(isLiked ? Color(hex: "#FFE8E8") : Theme.cream)
                    .cornerRadius(20)
                }
                .animation(.easeInOut(duration: 0.15), value: isLiked)

                if post.isInvite {
                    Button {} label: {
                        Text("Zusagen →")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Theme.amber)
                            .cornerRadius(20)
                    }
                } else {
                    Button {} label: {
                        Text("Rezept übernehmen")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.muted)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Theme.cream)
                            .cornerRadius(20)
                    }
                }

                if post.isFrozen {
                    HStack(spacing: 4) {
                        Text("❄")
                            .font(.system(size: 10))
                        Text("Eingefroren")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(Color(hex: "#4B9CD3"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#E8F4FF"))
                    .cornerRadius(20)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Theme.white)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
    }
}
