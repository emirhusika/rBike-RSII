import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rbike_admin/providers/auth_provider.dart';
import 'package:rbike_admin/providers/bike_provider.dart';
import 'package:rbike_admin/providers/category_provider.dart';
import 'package:rbike_admin/providers/equipment_provider.dart';
import 'package:rbike_admin/providers/equipment_category_provider.dart';
import 'package:rbike_admin/providers/logged_bike_provider.dart';
import 'package:rbike_admin/providers/reservation_provider.dart';
import 'package:rbike_admin/providers/user_provider.dart';
import 'package:rbike_admin/providers/order_provider.dart';
import 'package:rbike_admin/providers/comment_provider.dart';
import 'package:rbike_admin/providers/popup_dialogs.dart';
import 'package:rbike_admin/screens/bike_list_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<BikeProvider>(
          create: (_) => LoggedBikeProvider(),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (_) => CategoryProvider(),
        ),
        ChangeNotifierProvider<EquipmentProvider>(
          create: (_) => EquipmentProvider(),
        ),
        ChangeNotifierProvider<EquipmentCategoryProvider>(
          create: (_) => EquipmentCategoryProvider(),
        ),
        ChangeNotifierProvider<ReservationProvider>(
          create: (_) => ReservationProvider(),
        ),
        ChangeNotifierProvider<OrderProvider>(create: (_) => OrderProvider()),
        ChangeNotifierProvider<CommentProvider>(
          create: (_) => CommentProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.red,
        ),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Center(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
            child: Card(
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: 150,
                    width: 150,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.password),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      AuthProvider.username = _usernameController.text;
                      AuthProvider.password = _passwordController.text;

                      try {
                        UserProvider userProvider = UserProvider();
                        var userData = await userProvider.login(
                          _usernameController.text,
                          _passwordController.text,
                        );

                        if (userData['status'] == false) {
                          MyDialogs.showError(
                            context,
                            "Vaš korisnički račun je deaktiviran. Kontaktirajte korisničku podršku ili se obratite putem mail-a: rbikeapp@gmail.com",
                          );
                          return;
                        }

                        if (!userProvider.hasAdminRole(userData)) {
                          MyDialogs.showError(
                            context,
                            "Nemate dozvolu za pristup ovom dijelu. Kontaktirajte podršku.",
                          );
                          return;
                        }

                        BikeProvider provider = new BikeProvider();
                        var data = await provider.get();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BikeListScreen(),
                          ),
                        );
                      } on Exception catch (e) {
                        String errorMessage = e.toString().replaceFirst(
                          'Exception: ',
                          '',
                        );

                        // Handle specific deactivated user error
                        if (errorMessage.contains('deaktiviran')) {
                          errorMessage = errorMessage;
                        } else if (errorMessage.contains('Neispravni podaci')) {
                          errorMessage =
                              'Neispravno korisničko ime ili lozinka';
                        } else {
                          errorMessage =
                              'Greška pri prijavi. Pokušajte ponovo.';
                        }

                        MyDialogs.showError(context, errorMessage);
                      }
                    },
                    child: Text("Login"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
