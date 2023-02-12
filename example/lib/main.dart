import 'package:crowdin_sdk/crowdin_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/crowdin_localizations.dart';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

List<Locale> locales = const [
  Locale('en'),
  Locale('uk'),
  Locale('zh'),
  Locale('he'),
  Locale('ar'),
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
  String dropdownValue = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.test_string ?? '11'),
        actions: [
          DropdownButton(
            iconSize: 40,
            value: dropdownValue,
            items: [
              ...locales
                  .map(
                      (locale) => DropdownMenuItem<String>(
                    value: locale.languageCode,
                    onTap: () async {
                      await Crowdin.getDistribution(locale);
                      widget.changeLocale(locale);
                      print(AppLocalizations.supportedLocales);
                      print(AppLocalizations.of(context)!.localeName);
                      setState(() {
                        dropdownValue = locale.languageCode;
                      });
                    },
                    child: Text(locale.languageCode),
                  )
              )
                  .toList(),
            ],
            onChanged: (item) {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)?.example ?? '',
              style: const TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
