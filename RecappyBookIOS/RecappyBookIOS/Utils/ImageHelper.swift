import Foundation

func optimizedImageUrl(_ url: String, width: Int) -> String {
    url.replacingOccurrences(
        of: "/upload/",
        with: "/upload/f_auto,q_auto,w_\(width)/"
    )
}
