import Foundation

struct Recipe: Identifiable, Codable, Hashable {
    let id: Int64
    let title: String
    let ingredients: String?
    let instructions: String?
    let category: String?
    let imageUrl: String?
    let authorUsername: String?
    var favorite: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case ingredients
        case instructions
        case category
        case imageUrl
        case authorUsername
        case favorite
    }

    init(
        id: Int64,
        title: String,
        ingredients: String?,
        instructions: String?,
        category: String?,
        imageUrl: String?,
        authorUsername: String?,
        favorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.ingredients = ingredients
        self.instructions = instructions
        self.category = category
        self.imageUrl = imageUrl
        self.authorUsername = authorUsername
        self.favorite = favorite
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int64.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        ingredients = try container.decodeIfPresent(String.self, forKey: .ingredients)
        instructions = try container.decodeIfPresent(String.self, forKey: .instructions)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        authorUsername = try container.decodeIfPresent(String.self, forKey: .authorUsername)
        favorite = try container.decodeIfPresent(Bool.self, forKey: .favorite) ?? false
    }
}
