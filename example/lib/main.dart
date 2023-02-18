import 'package:crowdin_sdk/crowdin_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_gen/gen_l10n/crowdin_localizations.dart';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

final GlobalKey<ScaffoldState> _key = GlobalKey();

List<Locale> locales = const [
  Locale('en'),
  Locale('uk'),
  Locale('it'),
  Locale('he'),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Crowdin.init(
    distributionHash: dotenv.env['DISTRIBUTION_HASH'] ?? '', //your distribution hash
    connectionType: InternetConnectionType.mobileData,
    distributionTtl: const Duration(minutes: 25),
  );
  runApp(const MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  Locale currentLocale = Locale(Locale(Platform.localeName).toLanguageTag());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: currentLocale,
      localizationsDelegates: CrowdinLocalization.localizationsDelegates,
      supportedLocales: locales,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(
        changeLocale: (locale) => {
          setState(() {
            currentLocale = locale;
          })
        },
      ),
    );
  }
}

class Home extends StatefulWidget {
  final void Function(Locale locale) changeLocale;

  const Home({Key? key, required this.changeLocale}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String dropdownValue = locales.first.languageCode;

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        key: _key,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Menu'),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      onLanguageChanged: (locale) => widget.changeLocale(locale),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Center(child: Text(AppLocalizations.of(context)!.main)),
        leading: const SizedBox(),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.list_outlined),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.example,
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.hello('userName'),
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.counter(_counter),
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.nThings(0, 'thing'),
              style: const TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final Function(Locale locale) onLanguageChanged;

  const SettingsScreen({
    required this.onLanguageChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all( 16.0),
        child: Row(
          children: [
            Text('${AppLocalizations.of(context)!.language}: '),
            DropdownButton(
              iconSize: 40,
              value: AppLocalizations.of(context)!.localeName,
              items: [
                ...locales
                    .map((locale) => DropdownMenuItem<String>(
                          value: locale.languageCode,
                          onTap: () async {
                            await Crowdin.getDistribution(locale);
                            widget.onLanguageChanged(locale);
                            setState(() {
                              // dropdownValue = locale.languageCode;
                            });
                          },
                          child: Text(locale.languageCode),
                        ))
                    .toList(),
              ],
              onChanged: (item) {},
            ),
          ],
        ),
      ),
    );
  }
}
