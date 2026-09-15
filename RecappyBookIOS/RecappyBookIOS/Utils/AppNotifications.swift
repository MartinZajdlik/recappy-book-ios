import Foundation

/// Appka-wide notifikace, kterými si nezávislé view modely řeknou o změnách,
/// které se je netýkají přímo, ale mají na ně dopad (typicky napříč obrazovkami).
extension Notification.Name {
    /// Poslána poté, co uživatel někoho zablokuje – nese "authorId" (Int64)
    /// v userInfo. Seznamy receptů na to reagují okamžitým odebráním
    /// receptů od toho autora, ať uživatel nemusí appku restartovat/
    /// znovu se přihlásit, aby se mu recepty přestaly zobrazovat.
    static let userDidBlockAuthor = Notification.Name("userDidBlockAuthor")

    /// Poslána poté, co uživatel někoho odblokuje – nese "authorId" (Int64)
    /// v userInfo. Seznamy receptů na to reagují znovunačtením, ať se
    /// recepty toho autora zase objeví bez restartu appky/nového přihlášení.
    static let userDidUnblockAuthor = Notification.Name("userDidUnblockAuthor")
}
