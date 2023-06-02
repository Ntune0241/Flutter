import 'package:flutter/material.dart';
import 'package:pallet_berlendir/todos.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

  void onSaveTodo(String title, String description, String startDate,
      String endDate, String category, BuildContext context) {
    final homePageState = context.findAncestorStateOfType<_MyHomePageState>();
    homePageState?.addTodo(title, description, startDate, endDate, category);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return MaterialApp(
            // Remove the debug banner
            debugShowCheckedModeBanner: false,
            title: 'Todos',
            theme: ThemeData(primarySwatch: Colors.purple),
            darkTheme: ThemeData.dark(),
            themeMode: currentMode,
            home: const MyHomePage(title: 'Todos'),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final List<Todo> _originalTodos = [];
  List<Todo> _filteredTodos = [];
  String? _value;
  List<String> stuff = ['Work', 'Routine', 'Others'];
  bool theme = false;

  void addTodo(String title, String description, String startDate,
      String endDate, String category) {
    setState(() {
      _originalTodos.add(Todo(
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
        category: category,
        isChecked: false,
      ));
      _filteredTodos = _originalTodos;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void _selectedChip(String? value) {
    List<Todo> filter;
    if (value != null) {
      filter = _originalTodos
          .where((tile) => tile.category.contains(value))
          .toList();
    } else {
      filter = _originalTodos;
    }
    setState(() {
      _filteredTodos = filter;
      _value = value;
    });
  }

  // ignore: unused_field
  int _selectedButtomIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedButtomIndex = index;
    });
  }

  Widget _counter(int num) {
    return Container(
      width: 20,
      height: 20,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
          color: Colors.red, borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Text(
          num.toString(),
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  int doneNumber(String item) {
    List<Todo> filtered;
    filtered = _originalTodos
        .where((tile) => tile.category.contains(item) && tile.isChecked != true)
        .toList();
    return filtered.length.toInt();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            
            child: Text('Todo App', style: TextStyle(fontSize: 40)),
          ),
          ListTile(
            title: const Text('Work'),
            trailing: Visibility(
                  visible: doneNumber('Work') != 0,
                  child: _counter(doneNumber('Work'))),
          ),
          ListTile(
            title: const Text('Routine'),
            trailing: Visibility(
                  visible: doneNumber('Routine') != 0,
                  child: _counter(doneNumber('Routine'))),
          ),
          ListTile(
            title: const Text('Others'),
            trailing: Visibility(
                  visible: doneNumber('Others') != 0,
                  child: _counter(doneNumber('Others'))),
          ),
          SwitchListTile(
              title: Text("Dark Mode"),
              value: theme,
              onChanged: (bool value) {
                MyApp.themeNotifier.value =
                    MyApp.themeNotifier.value == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light;
                setState(() {
                  theme = value;
                });
              })
        ],
      )),
      appBar: AppBar(
        title: Text(widget.title),
        // actions: [
        //   Icon(MyApp.themeNotifier.value == ThemeMode.light
        //       ? Icons.dark_mode
        //       : Icons.light_mode),
        //   Switch(
        //       value: theme,
        //       onChanged: (bool value) {
        //         MyApp.themeNotifier.value =
        //             MyApp.themeNotifier.value == ThemeMode.light
        //                 ? ThemeMode.dark
        //                 : ThemeMode.light;
        //         setState(() {
        //           theme = value;
        //         });
        //       }),
        // ],
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Column(children: <Widget>[
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Wrap(
                spacing: 5.0,
                children: List<Widget>.generate(
                  stuff.length,
                  (int index) {
                    return ChoiceChip(
                      label: Text(stuff[index]),
                      selectedColor: Colors.purpleAccent,
                      selected: _value == stuff[index],
                      onSelected: (bool value) {
                        setState(() {
                          _value = value ? stuff[index] : null;
                        });

                        if (value) {
                          _selectedChip(stuff[index]);
                        } else {
                          _selectedChip(null);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredTodos.length,
            itemBuilder: (context, index) {
              final todo = _filteredTodos[index];
              return ExpansionTile(
                leading: Checkbox(
                  value: todo.isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      todo.isChecked = value ?? false;
                    });
                  },
                ),
                title: Text(
                  todo.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                subtitle: Text(
                  '${todo.startDate} s/d ${todo.endDate}',
                ),
                trailing: const Icon(Icons.arrow_drop_down),
                children: <Widget>[
                  ListTile(
                      title: Text(
                    todo.description,
                  )),
                ],
              );
            },
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => Todos(onSaveTodo: addTodo))));
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Todos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class Todo {
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String category;
  bool isChecked;

  Todo({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.category,
    this.isChecked = false,
  });
}
