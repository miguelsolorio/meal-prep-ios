import Foundation

enum GroceryDepartment: String, CaseIterable, Identifiable {
    case produce     = "Produce"
    case meatSeafood = "Meat & Seafood"
    case dairy       = "Dairy & Eggs"
    case bakery      = "Bakery"
    case pantry      = "Pantry"
    case other       = "Other"

    var id: String { rawValue }

    static func classify(_ text: String) -> GroceryDepartment {
        let t = text.lowercased()
        if matches(t, produceKeywords)     { return .produce }
        if matches(t, meatKeywords)        { return .meatSeafood }
        if matches(t, dairyKeywords)       { return .dairy }
        if matches(t, bakeryKeywords)      { return .bakery }
        if matches(t, pantryKeywords)      { return .pantry }
        return .other
    }

    private static func matches(_ text: String, _ keywords: [String]) -> Bool {
        keywords.contains { text.contains($0) }
    }

    private static let produceKeywords = [
        "apple", "banana", "lemon", "lime", "orange", "grapefruit",
        "tomato", "onion", "garlic", "ginger", "carrot", "celery",
        "bell pepper", "pepper", "jalapeño", "serrano", "poblano",
        "spinach", "lettuce", "kale", "arugula", "chard", "bok choy",
        "mushroom", "zucchini", "eggplant", "broccoli", "cauliflower",
        "cucumber", "avocado", "potato", "sweet potato", "yam",
        "scallion", "green onion", "shallot", "leek", "chive",
        "asparagus", "green bean", "snap pea", "snow pea", "pea",
        "corn", "radish", "beet", "turnip", "parsnip", "rutabaga",
        "squash", "pumpkin", "fennel", "artichoke", "brussel sprout",
        "cabbage", "kohlrabi", "endive", "radicchio",
        "strawberry", "blueberry", "raspberry", "blackberry",
        "grape", "mango", "peach", "plum", "nectarine", "cherry",
        "pear", "watermelon", "cantaloupe", "honeydew", "melon",
        "fig", "date", "pomegranate", "passion fruit", "kiwi", "papaya",
        "basil", "parsley", "cilantro", "thyme", "rosemary", "sage",
        "mint", "dill", "tarragon", "oregano leaf", "fresh herb",
        "fresh thyme", "fresh rosemary", "fresh basil", "fresh parsley",
        "fresh dill", "fresh mint", "fresh cilantro"
    ]

    private static let meatKeywords = [
        "chicken", "beef", "pork", "lamb", "turkey", "duck", "veal",
        "sausage", "bacon", "pancetta", "prosciutto", "ham", "salami",
        "pepperoni", "chorizo", "ground beef", "ground turkey", "ground pork",
        "brisket", "steak", "tenderloin", "sirloin", "rib", "chop",
        "loin", "shank", "shoulder", "thigh", "breast", "drumstick",
        "salmon", "tuna", "shrimp", "cod", "halibut", "tilapia",
        "mahi", "sea bass", "snapper", "trout", "sardine", "anchovy",
        "crab", "lobster", "clam", "mussel", "oyster", "scallop",
        "squid", "octopus", "fillet", "filet"
    ]

    private static let dairyKeywords = [
        "milk", "heavy cream", "light cream", "half-and-half", "half and half",
        "butter", "ghee", "yogurt", "sour cream", "crème fraîche",
        "egg", "cheese", "cheddar", "mozzarella", "parmesan", "parmigiano",
        "pecorino", "feta", "ricotta", "cottage cheese", "cream cheese",
        "brie", "gouda", "gruyere", "gruyère", "swiss", "provolone",
        "mascarpone", "burrata", "whipping cream", "evaporated milk",
        "condensed milk"
    ]

    private static let bakeryKeywords = [
        "bread", "baguette", "sourdough", "loaf", "roll", "bun",
        "pita", "naan", "tortilla", "flatbread", "lavash", "brioche",
        "ciabatta", "focaccia", "english muffin", "bagel", "croissant",
        "crumpet", "puff pastry", "pie crust", "pizza dough"
    ]

    private static let pantryKeywords = [
        "flour", "sugar", "brown sugar", "powdered sugar", "salt", "pepper",
        "oil", "olive oil", "vegetable oil", "canola oil", "sesame oil",
        "coconut oil", "cooking spray",
        "vinegar", "balsamic", "apple cider vinegar", "rice vinegar",
        "soy sauce", "tamari", "fish sauce", "oyster sauce", "hoisin",
        "worcestershire", "hot sauce", "sriracha", "tabasco",
        "ketchup", "mustard", "mayonnaise", "relish", "tahini", "miso",
        "tomato paste", "tomato sauce", "crushed tomato", "diced tomato",
        "canned tomato", "tomato puree",
        "broth", "stock", "bouillon", "coconut milk", "coconut cream",
        "rice", "pasta", "noodle", "orzo", "farro", "quinoa", "couscous",
        "lentil", "chickpea", "black bean", "kidney bean", "white bean",
        "cannellini", "navy bean", "pinto bean",
        "oat", "cornmeal", "cornstarch", "breadcrumb", "panko",
        "baking powder", "baking soda", "yeast", "vanilla", "cocoa",
        "chocolate", "honey", "maple syrup", "molasses", "agave",
        "peanut butter", "almond butter", "jam", "jelly",
        "cumin", "paprika", "turmeric", "coriander", "cinnamon",
        "nutmeg", "cardamom", "clove", "bay leaf", "chili powder",
        "cayenne", "red pepper flake", "garlic powder", "onion powder",
        "curry", "garam masala", "za'atar", "sumac", "smoked paprika",
        "Italian seasoning", "dried herb", "dried thyme", "dried oregano",
        "dried basil", "dried rosemary", "dried sage", "dried dill",
        "spice", "seasoning", "rub"
    ]
}
