//
//  KeyboardLayout.swift
//  YobaSwitcher
//
//  Created by Vladislav Librecht on 12.01.2023.
//

struct LanguageIdentifier: Hashable, RawRepresentable {
    let rawValue: String
    
    static let en = LanguageIdentifier(rawValue: "en")
    static let ru = LanguageIdentifier(rawValue: "ru")
}

struct KeyboardLayoutMapping {
    let sourceLanguage: LanguageIdentifier
    let targetLanguage: LanguageIdentifier
    private let dict: [Character: Character]
    
    init(from sourceLanguage: LanguageIdentifier, to targetLanguage: LanguageIdentifier, map: [Character: Character]) {
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.dict = map
    }
    
    init(reversedTo other: KeyboardLayoutMapping) {
        self.init(
            from: other.targetLanguage,
            to: other.sourceLanguage,
            map: Dictionary(uniqueKeysWithValues: other.dict.map { ($1, $0) })
        )
    }
    
    subscript(_ input: Character) -> Character {
        if let result = dict[input] {
            return result
        }
        if input.isUppercase, let result = dict[Character(input.lowercased())] {
            return Character(result.uppercased())
        }
        return input
    }
    
    func hasKey(_ char: Character) -> Bool {
        dict[char] != nil
    }
    
    static let enToRu = KeyboardLayoutMapping(from: .en, to: .ru, map: [
        "§": ">",
        "±": "<",
        "@": "\"",
        "#": "№",
        "$": "%",
        "%": ":",
        "^": ",",
        "&": ".",
        "*": ";",
        "q": "й",
        "w": "ц",
        "e": "у",
        "r": "к",
        "t": "е",
        "y": "н",
        "u": "г",
        "i": "ш",
        "o": "щ",
        "p": "з",
        "[": "х",
        "]": "ъ",
        "{": "Х",
        "}": "Ъ",
        "a": "ф",
        "s": "ы",
        "d": "в",
        "f": "а",
        "g": "п",
        "h": "р",
        "j": "о",
        "k": "л",
        "l": "д",
        ";": "ж",
        "'": "э",
        "\\": "ё",
        ":": "Ж",
        "\"": "Э",
        "|": "Ё",
        "`": "]",
        "~": "[",
        "z": "я",
        "x": "ч",
        "c": "с",
        "v": "м",
        "b": "и",
        "n": "т",
        "m": "ь",
        ",": "б",
        ".": "ю",
        "<": "Б",
        ">": "Ю",
    ])
    
    static let ruToEn = KeyboardLayoutMapping(reversedTo: enToRu)
}
