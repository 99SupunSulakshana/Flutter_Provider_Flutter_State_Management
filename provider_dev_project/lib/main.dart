import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BreadCrumbProvider(),
      child: MaterialApp(
        title: 'Flutter Provider Pattern',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(title: 'Flutter Provider Pattern'),
        routes: {'/new': (context) => const NewBreadCrumbsWidget()},
      ),
    );
  }
}

class BreadCrumb {
  bool isActive;
  final String name;
  final String uuid;

  BreadCrumb({required this.isActive, required this.name})
      : uuid = const Uuid().v4();

  void activete() {
    isActive = true;
  }

  @override
  bool operator ==(covariant BreadCrumb other) => uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  String get title => name + (isActive ? ' > ' : '');
}

class BreadCrumbProvider extends ChangeNotifier {
  final List<BreadCrumb> _items = [];
  UnmodifiableListView<BreadCrumb> get item => UnmodifiableListView(_items);

  void add(BreadCrumb breadCrumb) {
    for (final item in _items) {
      item.activete();
    }
    _items.add(breadCrumb);
    notifyListeners();
  }

  void reset() {
    _items.clear();
    notifyListeners();
  }
}

typedef OnBreadCrumbTapped = void Function(BreadCrumb);

class BreadCrumbsWidget extends StatelessWidget {
  final UnmodifiableListView<BreadCrumb> breadCrumbs;

  const BreadCrumbsWidget({
    Key? key,
    required this.breadCrumbs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: breadCrumbs.map((breadCrumb) {
        return Text(
          breadCrumb.title,
          style: TextStyle(
              color: breadCrumb.isActive ? Colors.blue : Colors.black),
        );
      }).toList(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Consumer<BreadCrumbProvider>(builder: (context, value, child) {
              return BreadCrumbsWidget(breadCrumbs: value.item);
            }),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/new');
                },
                child: const Text('Add new bread crumb')),
            TextButton(
                onPressed: () {
                  context.read<BreadCrumbProvider>().reset();
                  context.select((value) => null);
                },
                child: const Text('Reset')),
          ],
        ),
      ),
    );
  }
}

class NewBreadCrumbsWidget extends StatefulWidget {
  const NewBreadCrumbsWidget({super.key});

  @override
  State<NewBreadCrumbsWidget> createState() => _NewBreadCrumbsWidgetState();
}

class _NewBreadCrumbsWidgetState extends State<NewBreadCrumbsWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new bread crumb"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
                hintText: 'Enter a new bread crumb here....'),
          ),
          TextButton(
              onPressed: () {
                final text = _controller.text;
                if (text.isNotEmpty) {
                  final breadCrumb = BreadCrumb(isActive: false, name: text);
                  context.read<BreadCrumbProvider>().add(breadCrumb);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'))
        ],
      ),
    );
  }
}
