import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:recipes/models/recipe.dart';

export 'api_recipe.dart';

int from = 0;
const int size = 20;

Future<List<Recipe>> fetchRecipes([String? searchTerm]) async {
  try {
    final Uri uri;
    if (searchTerm == null) {
      uri = Uri.https('tasty.p.rapidapi.com', '/recipes/list',
          {'from': '$from', 'size': '$size'});
    } else {
      uri = Uri.https('tasty.p.rapidapi.com', '/recipes/list',
          {'from': '0', 'size': '$size', 'q': searchTerm});
    }

    final response = await http.get(
      uri,
      headers: {
        'X-RapidAPI-Key': '5df48ef477msh74cb6a092019485p19c505jsnfb110a147dfa',
        'X-RapidAPI-Host': 'tasty.p.rapidapi.com',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final recipes = jsonResponse['results'];
      List<Recipe> recipeObjects = [];

      for (var recipe in recipes) {
        // Continue if the object is an ingredient
        if (recipe.length == 28) {
          continue;
        }

        String name = recipe['name'];
        String image = recipe['thumbnail_url'];
        String rating;
        try {
          rating = (recipe['user_ratings']['score'] * 5).toStringAsFixed(1);
        } catch (e) {
          print(e.toString());
          rating = "No Rating";
        }

        List<String> ingredients = [];
        List<String> instructions = [];
        for (var ingredient in recipe['sections'][0]['components']) {
          ingredients.add(ingredient['raw_text']);
        }
        for (var instruction in recipe['instructions']) {
          instructions.add(instruction['display_text']);
        }

        recipeObjects.add(Recipe(
            name: name,
            image: image,
            rating: rating,
            ingredients: ingredients,
            instructions: instructions,
            isFavorite: false));
      }

      if (searchTerm == null) {
        from += size;
      }

      return recipeObjects;
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    print(e.toString());
    throw Exception('Failed to load data');
  }
}
