import 'package:crowdin_sdk/crowdin_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/crowdin_localizations.dart';

import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Crowdin.init(
    distributionHash: 'c7853d00ebba88f0db086f9ap19', //your distribution hash
    connectionType: InternetConnectionType.any,
    updatesInterval: const Duration(minutes: 25),
  );
  runApp(const MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Locale currentLocale = Locale(Intl.shortLocale(Intl.systemLocale));
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Crowdin.loadTranslations(currentLocale).then((value) => setState(() {
          isLoading = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: currentLocale,
      localizationsDelegates: CrowdinLocalization.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isLoading
          ? const Material(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : MainScreen(
              changeLocale: (locale) => {
                setState(() {
                  currentLocale = locale;
                })
              },
            ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final void Function(Locale locale) changeLocale;

  const MainScreen({
    required this.changeLocale,
    Key? key,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Icon(
                Icons.account_circle_rounded,
                size: 50,
                color: Colors.white,
              ),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _incrementCounter();
        },
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
  Locale currentLocale = AppLocalizations.supportedLocales.first;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text('${AppLocalizations.of(context)!.localeName}: '),
                  DropdownButton(
                    iconSize: 40,
                    value: AppLocalizations.of(context)!.localeName,
                    items: [
                      ...AppLocalizations.supportedLocales
                          .map((locale) => DropdownMenuItem<String>(
                                value: locale.toString(),
                                child: Text(locale.toLanguageTag()),
                                onTap: () async {
                                  await onPickLanguage(locale);
                                  setState(() {
                                    currentLocale = locale;
                                  });
                                },
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

  Future<void> onPickLanguage(Locale locale) async {
    // manage app loading state
    setState(() {
      isLoading = true;
    });
    // get translations from Crowdin
    await Crowdin.loadTranslations(locale);
    // change app locale
    widget.onLanguageChanged(locale);

    setState(() {
      isLoading = false;
    });
  }
}
