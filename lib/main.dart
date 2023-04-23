import 'package:flutter/material.dart';
import 'package:recipes/views/screens/favorites.dart';
import 'package:recipes/views/screens/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;

void main() => runApp(ProviderScope(child: Navigation()));

final navigationStateProvider = StateProvider((ref) => 0);

class Navigation extends ConsumerWidget {
  final List<Widget> _children = [
    const Home(),
    const FavoritesPage(),
  ];

  Navigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FlutterError.demangleStackTrace = (StackTrace stack) {
      if (stack is stack_trace.Trace) return stack.vmTrace;
      if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
      return stack;
    };

    final currentIndex = ref.watch(navigationStateProvider);

    return MaterialApp(
      home: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.brown,
            selectedItemColor: Colors.yellow,
            unselectedItemColor: Colors.white,
            currentIndex: currentIndex,
            onTap: (int index) {
              ref.read(navigationStateProvider.notifier).state = index;
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
            index: currentIndex,
            children: _children,
          )),
    );
  }
}
