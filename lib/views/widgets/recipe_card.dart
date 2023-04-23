import 'package:flutter/material.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/views/screens/recipe_details.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipes/view_models/favorite_provider.dart';

class RecipeCard extends ConsumerStatefulWidget {
  const RecipeCard({
    Key? key,
    required this.recipe,
  }) : super(key: key);

  final Recipe recipe;

  @override
  _RecipeCardState createState() => _RecipeCardState();
}

class _RecipeCardState extends ConsumerState<RecipeCard> {
  @override
  Widget build(BuildContext context) {
    final favoritesList = ref.watch(favoriteProvider);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetails(
              recipe: widget.recipe,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 32),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(widget.recipe.image),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                Color.fromRGBO(0, 0, 0, 0.2),
                                Color.fromRGBO(0, 0, 0, 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            ref
                                .read(favoriteProvider.notifier)
                                .toggleFavorite(widget.recipe);
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: favoritesList.contains(widget.recipe)
                                ? const Icon(
                                    Icons.favorite,
                                    key: ValueKey('favorite'),
                                    color: Colors.yellow,
                                    size: 32,
                                  )
                                : const Icon(
                                    Icons.favorite_border,
                                    key: ValueKey('not_favorite'),
                                    color: Colors.yellow,
                                    size: 32,
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Row(
                          children: [
                            Text(
                              widget.recipe.rating,
                              style: const TextStyle(
                                fontFamily: 'SF Pro Text',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.yellow,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: 32,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.recipe.name,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
