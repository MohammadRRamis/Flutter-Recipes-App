import 'dart:convert';

import 'package:flutter/material.dart';
import 'services/api_recipe.dart';
import 'models/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    const HomePage(),
    FavoritesPage(key: UniqueKey()),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.brown,
            selectedItemColor: Colors.yellow,
            unselectedItemColor: Colors.white,
            currentIndex: _currentIndex,
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  size: 32,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.favorite,
                  size: 32,
                ),
                label: 'Favorites',
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: _children,
          )),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Recipe> _recipes = [];
  bool _fetching = false;

  void updateRecipes(List<Recipe> newRecipes) {
    setState(() {
      _recipes = newRecipes;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchRecipes().then((recipes) {
      setState(() {
        SharedPreferences.getInstance().then((prefs) {
          for (Recipe recipe in recipes) {
            if (prefs.containsKey(recipe.name)) {
              recipe.isFavorite = true;
            }
          }
        });
        _recipes = recipes;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _recipes.isEmpty
          ? const CircularProgressIndicator()
          : NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification.metrics.pixels ==
                        scrollNotification.metrics.maxScrollExtent &&
                    !_fetching) {
                  _fetching = true;
                  fetchRecipes().then((recipes) {
                    setState(() {
                      _recipes.addAll(recipes);
                      _fetching = false;
                    });
                  });
                }
                return true;
              },
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Column(
                  children: [
                    Container(
                      child: Search(updateRecipes: updateRecipes),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _recipes.length,
                        itemBuilder: (context, index) {
                          return Container(
                            child: RecipeCard(
                              recipe: _recipes[index],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class Search extends StatefulWidget {
  const Search({Key? key, required this.updateRecipes}) : super(key: key);
  final Function(List<Recipe>) updateRecipes;

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: TextField(
        controller: _controller,
        onSubmitted: (value) {
          fetchRecipes(_controller.text).then((recipes) {
            widget.updateRecipes(recipes);
          });
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

class RecipeCard extends StatefulWidget {
  const RecipeCard({
    Key? key,
    required this.recipe,
  }) : super(key: key);

  final Recipe recipe;

  @override
  _RecipeCardState createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  @override
  Widget build(BuildContext context) {
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
                            setState(() {
                              SharedPreferences.getInstance().then((prefs) {
                                if (prefs.containsKey(widget.recipe.name)) {
                                  prefs.remove(widget.recipe.name);
                                  widget.recipe.isFavorite = false;
                                } else {
                                  String recipeJson =
                                      jsonEncode(widget.recipe.toJson());
                                  prefs.setString(
                                      widget.recipe.name, recipeJson);
                                  widget.recipe.isFavorite = true;
                                }
                              });
                            });
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
                            child: widget.recipe.isFavorite
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

class RecipeDetails extends StatefulWidget {
  const RecipeDetails({
    Key? key,
    required this.recipe,
  }) : super(key: key);

  final Recipe recipe;

  @override
  _RecipeDetailsState createState() => _RecipeDetailsState();
}

class _RecipeDetailsState extends State<RecipeDetails> {
  @override
  Widget build(BuildContext context) {
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
                        setState(() {
                          SharedPreferences.getInstance().then((prefs) {
                            if (prefs.containsKey(widget.recipe.name)) {
                              prefs.remove(widget.recipe.name);
                              widget.recipe.isFavorite = false;
                            } else {
                              String recipeJson =
                                  jsonEncode(widget.recipe.toJson());
                              prefs.setString(widget.recipe.name, recipeJson);
                              widget.recipe.isFavorite = true;
                            }
                          });
                        });
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
                        child: widget.recipe.isFavorite
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

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Recipe> favorites = [];

  void updateFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keys = prefs.getKeys().toList();
    List<Recipe> updatedFavorites = [];

    for (String key in keys) {
      String recipeJson = prefs.getString(key)!;
      Map<String, dynamic> recipeMap = jsonDecode(recipeJson);
      Recipe recipe = Recipe.fromJson(recipeMap);
      updatedFavorites.add(recipe);
    }

    setState(() {
      favorites = updatedFavorites;
    });
  }

  @override
  void initState() {
    print('init state');
    super.initState();
    updateFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateFavorites();
  }

  @override
  Widget build(BuildContext context) {
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
                          child: const Text(
                            'Favorites',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (Recipe recipe in favorites)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetails(
                          recipe: recipe,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 64, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(recipe.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            recipe.name,
                            style: const TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
