class Recipe {
  final String image;
  final String name;
  final String rating;
  final List<dynamic> ingredients;
  final List<dynamic> instructions;
  bool isFavorite;

  Recipe(
      {required this.image,
      required this.name,
      required this.rating,
      required this.ingredients,
      required this.instructions,
      required this.isFavorite});

  Map<String, dynamic> toJson() => {
        'image': image,
        'name': name,
        'rating': rating,
        'ingredients': ingredients,
        'instructions': instructions,
        'isFavorite': isFavorite,
      };

  //Make a fromJson method to convert the json to a Recipe object
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      image: json['image'],
      name: json['name'],
      rating: json['rating'],
      ingredients: json['ingredients'],
      instructions: json['instructions'],
      isFavorite: json['isFavorite'],
    );
  }
}
