// Photo.swift
// Represents a photo for UI layer
import Foundation

struct Photo: Codable {
    let id: String
    let size: CGSize
    let createdAt: String?
    let description: String?
    let thumbImageURL: URL
    let largeImageURL: URL
    var isLiked: Bool
}

extension Photo {
    static func makeArray(from photoResults: [PhotoResult]) -> [Photo] {
        photoResults.map { result in
            Photo(
                id: result.id,
                size: CGSize(width: result.width, height: result.height),
                createdAt: result.createdAt,
                description: result.description,
                thumbImageURL: result.urls.thumb,
                largeImageURL: result.urls.full,
                isLiked: result.likedByUser
            )
        }
    }
}
