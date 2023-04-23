import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipes/models/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final favoriteProvider = StateNotifierProvider<FavoriteNotifier, List<Recipe>>(
  (ref) => FavoriteNotifier.fromInitialFavorites(),
);

class FavoriteNotifier extends StateNotifier<List<Recipe>> {
  FavoriteNotifier() : super([]);

  FavoriteNotifier.fromInitialFavorites() : super([]) {
    getFavorites();
  }

  Future<void> getFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keys = prefs.getKeys().toList();
    List<Recipe> favorites = [];

    for (String key in keys) {
      String recipeJson = prefs.getString(key)!;
      Map<String, dynamic> recipeMap = jsonDecode(recipeJson);
      Recipe recipe = Recipe.fromJson(recipeMap);
      favorites.add(recipe);
    }

    state = favorites;
  }

  Future<void> addFavorite(Recipe recipe) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String recipeJson = jsonEncode(recipe.toJson());
    prefs.setString(recipe.name, recipeJson);
    state = [...state, recipe];
  }

  Future<void> removeFavorite(Recipe recipe) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(recipe.name);
    state = state.where((element) => element.name != recipe.name).toList();
  }

  void toggleFavorite(Recipe recipe) {
    if (state.contains(recipe)) {
      removeFavorite(recipe);
    } else {
      addFavorite(recipe);
    }
  }
  
}
