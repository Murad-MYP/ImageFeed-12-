// UrlsResult.swift
// Represents URLs for different image sizes from Unsplash API
import Foundation

struct UrlsResult: Codable {
    let full: URL
    let thumb: URL
    let small: URL
}
