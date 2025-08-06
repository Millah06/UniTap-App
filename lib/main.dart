import 'package:everywhere/models/cable_beneficiary_model.dart';
import 'package:everywhere/screens/bottom_navigation/wallet_screen.dart';
import 'package:everywhere/screens/bottom_navigation/profile_settings_screen.dart';
import 'package:everywhere/screens/bottom_navigation/home_screen.dart';
import 'package:everywhere/screens/cable_suscription.dart';
import 'package:everywhere/screens/edit_template.dart';
import 'package:everywhere/screens/first_screen.dart';
import 'package:everywhere/screens/welcome_screen.dart';
import 'package:everywhere/services/brain.dart';
import 'package:everywhere/services/purchase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/edit2.dart';
import 'constraints/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(CableBeneficiaryModelAdapter());
  await Hive.openBox<CableBeneficiaryModel>('categories');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  AppLifecycleState? _appLifecycleState;
  // Key _key = UniqueKey();
  bool  hasDone = false;
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _finish();
  }

  Future<void> _finish () async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        hasDone  = prefs.getBool('isSetupDone') ?? false;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    setState(() {
      _appLifecycleState = state;
    });
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          setState(() {
            // _key = UniqueKey();
          });
          final prefs = await SharedPreferences.getInstance();
          setState(() {
            hasDone  = prefs.getBool('isSetupDone') ?? false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              value: 20,
              backgroundColor: kCardColor,
              color: kButtonColor,
            ),
          ),
        ),
      );
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (BuildContext context) => Brain()..getData()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // key: _key,
        theme: ThemeData(
          scaffoldBackgroundColor: Color(0xFF0F172A),
          inputDecorationTheme: InputDecorationTheme(
              floatingLabelStyle: TextStyle(
                  color: Colors.white
              ),
              labelStyle: TextStyle(
                color:  Color(0x8AFFFFFF),
                fontSize: 13,
              ),
              helperStyle: TextStyle(
                  color: Colors.white
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: kButtonColor
                  ),
                  borderRadius: BorderRadius.circular(10)
              ),
              border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white54
                  ),
                  borderRadius: BorderRadius.circular(10)
              ),
              focusColor: Colors.white,
              prefixIconColor: Colors.white,
              focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.red.shade400
                  ),
                  borderRadius: BorderRadius.circular(10)
              ),
              errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.red.shade400
                  ),
                  borderRadius: BorderRadius.circular(10)
              )
          ),
          textTheme: TextTheme(
              bodyMedium: TextStyle(color: Colors.white,),

          ),
          iconTheme: IconThemeData(
              // color: Color(0xFF21D3ED)
            color: Colors.white
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: Color(0xFF21D3ED),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF177E85),
            titleTextStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
            iconTheme: IconThemeData(
                color: Colors.white
            ),
          ),
          bottomSheetTheme: BottomSheetThemeData(
            showDragHandle: true,
            dragHandleSize: Size(70, 5),
            backgroundColor: Color(0xFF0F172A),
            dragHandleColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              side: BorderSide(
                  color: kButtonColor
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
              ),
              textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold)
            ),
          )
        ),
        home:  hasDone ? const FirstScreen() : const WelcomeScreen(),
        routes: {
          HomeScreen.id : (context) => HomeScreen(),
          WalletScreen.id: (context) => WalletScreen(),
          ProfileSettingsScreen.id: (context) => ProfileSettingsScreen(),
          FirstScreen.id: (context) => FirstScreen(),
          WelcomeScreen.id: (context) => WelcomeScreen(),
          '/cable': (context) => CableSubscription(),
        },
      ),
    );
  }
}

