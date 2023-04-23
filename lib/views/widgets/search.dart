import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipes/view_models/recipe_provider.dart';

class Search extends ConsumerWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return SafeArea(
      child: TextField(
        controller: _controller,
        onSubmitted: (value) {
          ref.read(recipeProvider.notifier).searchRecipes(value);
        },
        decoration: const InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2.0, color: Colors.black),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black,
            size: 32,
          ),
          labelText: 'Search food recipes',
          labelStyle: TextStyle(
            color: Colors.black,
            fontFamily: 'SF Pro Text',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
