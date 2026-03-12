import 'package:everywhere/components/formatters.dart';
import 'package:everywhere/models/notification_model.dart';
import 'package:everywhere/providers/chat_provider.dart';
import 'package:everywhere/providers/feed_provider.dart';
import 'package:everywhere/providers/order_provider.dart';
import 'package:everywhere/providers/profile_provider.dart';
import 'package:everywhere/providers/reward_provider.dart';
import 'package:everywhere/providers/vendor-center-provider.dart';
import 'package:everywhere/providers/vendor_provider.dart';
import 'package:everywhere/providers/withdrawal_provider.dart';
import 'package:everywhere/screens/bottom_navigation/wallet_screen.dart';
import 'package:everywhere/screens/bottom_navigation/profile_settings_screen.dart';
import 'package:everywhere/screens/bottom_navigation/services_screen.dart';
import 'package:everywhere/screens/core_services/airtime_gift.dart';
import 'package:everywhere/screens/core_services/airtime_screen.dart';
import 'package:everywhere/screens/core_services/cable_suscription.dart';
import 'package:everywhere/screens/core_services/data_screen.dart';
import 'package:everywhere/screens/core_services/electric_screen.dart';
import 'package:everywhere/screens/core_services/internet_services.dart';
import 'package:everywhere/screens/core_services/rechargepins_screen.dart';
import 'package:everywhere/screens/exams/jamb_screen.dart';
import 'package:everywhere/screens/exams/waec_screen.dart';
import 'package:everywhere/screens/first_screen.dart';
import 'package:everywhere/screens/welcome_screen.dart';
import 'package:everywhere/services/api_service.dart';
import 'package:everywhere/services/brain.dart';
import 'package:everywhere/services/notification_service.dart';
import 'package:everywhere/services/session_service.dart';
import 'package:everywhere/services/vendorService/order_repository.dart';
import 'package:everywhere/services/vendorService/vendor_repository.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constraints/constants.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  
  await Hive.initFlutter();

  await AppLinkHandler.init();

  Hive.registerAdapter(AppNotificationAdapter());
  await Hive.openBox<AppNotification>('notifications');

  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent
      )
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => SessionProvider(),
    child: MyApp(),
  ),
  );
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
    PushNotificationService().init();
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
    // if (state == AppLifecycleState.paused) {
    //  hasDone ?  Navigator.of(context).pushAndRemoveUntil(
    //       MaterialPageRoute(builder: (context) => FirstScreen()), (route) => false) : Navigator.of(context)
    //      .pushAndRemoveUntil(
    //      MaterialPageRoute(builder: (context) => WelcomeScreen()), (route) => false);
    // }
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

  String? currentUserId;

  void handleLogin(String uid) {
    setState(() {
      currentUserId = uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionProvider>(context);
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          backgroundColor: Color(0xFF0F172A),
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
      key: ValueKey(session.currentUserId),
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => RewardProvider()),
        ChangeNotifierProvider(create: (_) => WithdrawalProvider()),
        ChangeNotifierProvider(
          create: (_) => ChatsProvider(),
        ),
        ChangeNotifierProvider(
            create: (BuildContext context) =>
            Brain()..getData()..fetchTransactions()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
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
                color: Colors.white,
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
          ),
        ),
        home: hasDone ? const FirstScreen() : const WelcomeScreen(),
        routes: {
          HomeScreen.id : (context) => HomeScreen(),
          WalletScreen.id: (context) => WalletScreen(),
          ProfileSettingsScreen.id: (context) => ProfileSettingsScreen(),
          FirstScreen.id: (context) => FirstScreen(),
          WelcomeScreen.id: (context) => WelcomeScreen(),
          '/cable': (context) => CableSubscription(),
          '/airtimeNormal' : (context) => AirtimeScreen(),
          '/airtimeGift' : (context) => AirtimeGift(),
          '/data': (context) => DataScreen(),
          '/electric': (context) => ElectricScreen(),
          '/waec': (content) => WaecServices(),
          '/jamb' : (content) => JambServices(),
          '/rechargePins': (context) => RechargePinsBusiness(),
          '/internetServices' : (context) => InternetServicesScreen()
        },
      ),
    );
  }
}

