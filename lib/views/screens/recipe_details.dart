import 'package:flutter/material.dart';
import 'package:recipes/models/recipe.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipes/view_models/favorite_provider.dart';

class RecipeDetails extends ConsumerStatefulWidget {
  const RecipeDetails({
    Key? key,
    required this.recipe,
  }) : super(key: key);

  final Recipe recipe;

  @override
  _RecipeDetailsState createState() => _RecipeDetailsState();
}

class _RecipeDetailsState extends ConsumerState<RecipeDetails> {
  @override
  Widget build(BuildContext context) {
    final favoritesList = ref.watch(favoriteProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 64, vertical: 8),
                          child: Text(
                            widget.recipe.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    margin: EdgeInsets.zero,
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(8),
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
                ],
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Ingredients',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < widget.recipe.ingredients.length; i++)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 64, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '${i + 1}.',
                        style: const TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.recipe.ingredients[i],
                          style: const TextStyle(
                            fontFamily: 'SF Pro Text',
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'Instructions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // generate the instructions list without a listview
              for (var i = 0; i < widget.recipe.instructions.length; i++)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 64, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '${i + 1}.',
                        style: const TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.recipe.instructions[i],
                          style: const TextStyle(
                            fontFamily: 'SF Pro Text',
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
