import UIKit
import CryptoKit

actor ImageCache {
    static let shared = ImageCache()

    private let memory: NSCache<NSString, UIImage> = {
        let c = NSCache<NSString, UIImage>()
        c.countLimit = 100
        c.totalCostLimit = 75 * 1024 * 1024  // 75 MB
        return c
    }()

    private let cacheDir: URL

    init() {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDir = base.appendingPathComponent("RecipeImages", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
    }

    func image(for url: URL) async -> UIImage? {
        let key = cacheKey(for: url)

        // 1. Memory
        if let cached = memory.object(forKey: key as NSString) {
            return cached
        }

        // 2. Disk
        let path = cacheDir.appendingPathComponent(key)
        if let data = try? Data(contentsOf: path), let image = UIImage(data: data) {
            memory.setObject(image, forKey: key as NSString, cost: data.count)
            return image
        }

        // 3. Network
        guard let (data, response) = try? await URLSession.shared.data(from: url),
              (response as? HTTPURLResponse).map({ (200..<300).contains($0.statusCode) }) != false,
              let image = UIImage(data: data) else { return nil }

        memory.setObject(image, forKey: key as NSString, cost: data.count)
        try? data.write(to: path, options: .atomic)
        return image
    }

    func clearMemoryCache() {
        memory.removeAllObjects()
    }

    private func cacheKey(for url: URL) -> String {
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
