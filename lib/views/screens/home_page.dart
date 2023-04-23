import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipes/views/widgets/recipe_card.dart';
import 'package:recipes/views/widgets/search.dart';
import 'package:recipes/view_models/recipe_provider.dart';

final fetchingStateProvider = StateProvider((ref) => false);

class Home extends ConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFetching = ref.watch(fetchingStateProvider);
    final recipeList = ref.watch(recipeProvider);

    return Center(
      child: recipeList.isEmpty
          ? const CircularProgressIndicator()
          : NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification.metrics.pixels ==
                        scrollNotification.metrics.maxScrollExtent &&
                    !isFetching) {
                  ref.read(fetchingStateProvider.notifier).state = true;

                  ref.read(recipeProvider.notifier).getRecipes().then((_) {
                    ref.read(fetchingStateProvider.notifier).state = false;
                  });
                }

                return true;
              },
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Column(
                  children: [
                    Search(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: recipeList.length,
                        itemBuilder: (context, index) {
                          return RecipeCard(
                            recipe: recipeList[index],
                          );
                        },
                      ),
                    ),
                    isFetching
                        ? const CircularProgressIndicator()
                        : Container(),
                  ],
                ),
              ),
            ),
    );
  }
}
