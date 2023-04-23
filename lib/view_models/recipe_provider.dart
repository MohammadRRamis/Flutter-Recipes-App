import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/view_models/api_recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

final recipeProvider = StateNotifierProvider<RecipeNotifier, List<Recipe>>(
  (ref) => RecipeNotifier.fromInitialRecipes(fetchRecipes()),
);

class RecipeNotifier extends StateNotifier<List<Recipe>> {
  RecipeNotifier() : super([]);

  RecipeNotifier.fromInitialRecipes(Future<List<Recipe>> initialRecipes)
      : super([]) {
    initialRecipes.then((recipes) => {
          // for (Recipe recipe in recipes)
          //   {
          //     SharedPreferences.getInstance().then((prefs) {
          //       if (prefs.containsKey(recipe.name)) {
          //         recipe.isFavorite = true;
          //       }
          //     })
          //   },
          state = recipes
        });
  }

  Future<void> getRecipes() async {
    final List<Recipe> newRecipes = await fetchRecipes();
    // for (Recipe recipe in newRecipes) {
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   if (prefs.containsKey(recipe.name)) {
    //     recipe.isFavorite = true;
    //   }
    // }
    state = [...state, ...newRecipes];
  }

  Future<void> searchRecipes(String searchTerm) async {
    final List<Recipe> newRecipes = await fetchRecipes(searchTerm);
    state = newRecipes;
  }
}
