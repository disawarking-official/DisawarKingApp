import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAF1_OH3Szs8--OcwxHA11Fsj5x-iGSPIA",
        appId: "1:1015457895217:android:09cb8d98e56cc50b359610",
        messagingSenderId: "1015457895217",
        projectId: "disawarking-ead58",
      ),
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }
  runApp(DisawarKingApp());
}

class DisawarKingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DisawarKingApp',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFFF59E0B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF59E0B),
          secondary: Color(0xFFD97706),
          surface: Color(0xFF1E293B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          elevation: 2,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
          iconTheme: IconThemeData(color: Color(0xFFF59E0B)),
        ),
      ),
      home: SplashScreen(),
    );
  }
}

// ----------------- CONFIG & GLOBALS -----------------
String currentLoggedInUserMobile = "";
String currentLoggedInUserName = "";
const String adminMobile = "9761630128";
const String officialWhatsAppNumber = "917409989270";

class MarketConfig {
  final String name;
  final String hindiName;
  final int closeHour;
  final int closeMin;
  final String closeTimeStr;
  final String resultTimeStr;

  MarketConfig({
    required this.name,
    required this.hindiName,
    required this.closeHour,
    required this.closeMin,
    required this.closeTimeStr,
    required this.resultTimeStr,
  });

  DateTime getCloseDateTime() {
    DateTime now = DateTime.now();
    DateTime closeTime = DateTime(now.year, now.month, now.day, closeHour, closeMin);
    if (closeHour < 6 && now.hour >= 6) {
      closeTime = closeTime.add(const Duration(days: 1));
    }
    return closeTime;
  }

  bool isOpen() {
    return DateTime.now().isBefore(getCloseDateTime());
  }

  bool isWithin2Hours() {
    DateTime now = DateTime.now();
    Duration diff = getCloseDateTime().difference(now);
    return diff.inMinutes > 0 && diff.inMinutes <= 120;
  }

  String getRemainingTimeStr() {
    DateTime now = DateTime.now();
    DateTime close = getCloseDateTime();
    if (now.isAfter(close)) return "Closed";
    Duration diff = close.difference(now);
    String h = diff.inHours.toString().padLeft(2, '0');
    String m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    String s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }
}

// Order matching the Chart: DSWR, DLBZ, SRGN, FRBD, GZBD, GALI
final List<MarketConfig> appMarkets = [
  MarketConfig(name: "DISAWAR", hindiName: "दिसावर", closeHour: 4, closeMin: 00, closeTimeStr: "04:00 AM", resultTimeStr: "05:00 AM"),
  MarketConfig(name: "DELHI BAZAR", hindiName: "दिल्ली बाजार", closeHour: 14, closeMin: 50, closeTimeStr: "02:50 PM", resultTimeStr: "03:15 PM"),
  MarketConfig(name: "SHREE GANESH", hindiName: "श्री गणेश", closeHour: 16, closeMin: 00, closeTimeStr: "04:00 PM", resultTimeStr: "04:30 PM"),
  MarketConfig(name: "FARIDABAD", hindiName: "फ़रीदाबाद", closeHour: 17, closeMin: 50, closeTimeStr: "05:50 PM", resultTimeStr: "06:15 PM"),
  MarketConfig(name: "GHAZIABAD", hindiName: "गाज़ियाबाद", closeHour: 21, closeMin: 20, closeTimeStr: "09:20 PM", resultTimeStr: "09:45 PM"),
  MarketConfig(name: "GALI", hindiName: "गली", closeHour: 23, closeMin: 25, closeTimeStr: "11:25 PM", resultTimeStr: "11:55 PM"),
];

Future<void> openWhatsAppChat({String message = "Namaste DisawarKing Support, mujhe sahayata chahiye."}) async {
  final Uri url = Uri.parse("https://wa.me/$officialWhatsAppNumber?text=${Uri.encodeComponent(message)}");
  try {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } catch (_) {}
}

Widget buildAppLogo() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 18, spreadRadius: 2),
          ],
        ),
        child: const Icon(Icons.workspace_premium, size: 50, color: Color(0xFF0F172A)),
      ),
      const SizedBox(height: 10),
      const Text(
        "DisawarKingApp",
        style: TextStyle(
          color: Color(0xFFF59E0B),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      const Text("Official Gaming Platform", style: TextStyle(color: Colors.white70, fontSize: 12)),
    ],
  );
}

// ----------------- SPLASH SCREEN (AUTO LOGIN CHECK) -----------------
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkRememberLogin();
  }

  void _checkRememberLogin() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedMobile = prefs.getString('saved_mobile');
      String? savedName = prefs.getString('saved_name');

      if (savedMobile != null && savedMobile.length == 10) {
        currentLoggedInUserMobile = savedMobile;
        currentLoggedInUserName = savedName ?? "User";
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MainNavigationScreen()));
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildAppLogo(),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Colors.amber),
          ],
        ),
      ),
    );
  }
}

// ----------------- 1. LOGIN SCREEN -----------------
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    String mobile = _mobileController.text.trim();
    String pass = _passwordController.text.trim();

    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("10 anko ka Mobile Number dalein!")));
      return;
    }
    if (pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password dalein!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(mobile).get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.redAccent, content: Text("Account nahi mila! Pehle Register karein.")),
        );
        return;
      }

      var data = userDoc.data()!;
      if (data['password'] != pass) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.redAccent, content: Text("Galat Password!")),
        );
        return;
      }

      currentLoggedInUserMobile = mobile;
      currentLoggedInUserName = data['name'] ?? "User";

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_mobile', mobile);
      await prefs.setString('saved_name', currentLoggedInUserName);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainNavigationScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                buildAppLogo(),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.withOpacity(0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Login", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
                      const Text("Apne Mobile Number se Login karein", style: TextStyle(color: Colors.white60, fontSize: 13)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone_android, color: Colors.amber),
                          hintText: "Mobile Number",
                          counterText: "",
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.amber),
                          hintText: "Password",
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (c) => DirectResetPasswordScreen()));
                          },
                          child: const Text("Forgot Password?", style: TextStyle(color: Colors.amberAccent, fontSize: 13)),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                              : const Text("LOGIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => DirectRegisterScreen()));
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "Naya Account banayein? ",
                      style: TextStyle(color: Colors.white70),
                      children: [
                        TextSpan(text: "Register Now", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------- 2. REGISTER SCREEN -----------------
class DirectRegisterScreen extends StatefulWidget {
  @override
  _DirectRegisterScreenState createState() => _DirectRegisterScreenState();
}

class _DirectRegisterScreenState extends State<DirectRegisterScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isSaving = false;

  void _submitRegistration() async {
    String name = _nameController.text.trim();
    String mobile = _mobileController.text.trim();
    String pass = _passController.text.trim();
    String cPass = _confirmPassController.text.trim();

    if (name.isEmpty || mobile.length != 10 || pass.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sahi details bharein! Password min 4 digit ho.")));
      return;
    }

    if (pass != cPass) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Password aur Confirm Password match nahi huye!")));
      return;
    }

    setState(() => _isSaving = true);
    try {
      var checkUser = await FirebaseFirestore.instance.collection('users').doc(mobile).get();
      if (checkUser.exists) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Mobile number pehle se registered hai!")));
        setState(() => _isSaving = false);
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(mobile).set({
        'name': name,
        'mobile': mobile,
        'password': pass,
        'balance': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text("Success", style: TextStyle(color: Colors.amber)),
          content: Text("Account ban gaya!\nMobile: $mobile\nAb Login karein.", style: const TextStyle(color: Colors.white70)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text("Login", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Naya Account Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Naya Account Banayein", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
              const SizedBox(height: 18),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Aapka Pura Naam", border: OutlineInputBorder())),
              const SizedBox(height: 14),
              TextField(controller: _mobileController, keyboardType: TextInputType.phone, maxLength: 10, decoration: const InputDecoration(labelText: "Mobile Number", counterText: "", border: OutlineInputBorder())),
              const SizedBox(height: 14),
              TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: "Password Banayein", border: OutlineInputBorder())),
              const SizedBox(height: 14),
              TextField(controller: _confirmPassController, obscureText: true, decoration: const InputDecoration(labelText: "Confirm Password", border: OutlineInputBorder())),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  onPressed: _isSaving ? null : _submitRegistration,
                  child: _isSaving ? const CircularProgressIndicator(color: Colors.black) : const Text("REGISTER KAREIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------- 3. FORGOT PASSWORD SCREEN -----------------
class DirectResetPasswordScreen extends StatefulWidget {
  @override
  _DirectResetPasswordScreenState createState() => _DirectResetPasswordScreenState();
}

class _DirectResetPasswordScreenState extends State<DirectResetPasswordScreen> {
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  String? generatedOtp;
  bool isOtpSent = false;
  bool isOtpVerified = false;
  bool _isLoading = false;

  void _sendWhatsAppOtp() async {
    String mobile = _mobileController.text.trim();
    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("10 anko ka Registered Mobile Number dalein!")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(mobile).get();
      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Mobile number registered nahi mila!")));
        setState(() => _isLoading = false);
        return;
      }

      String otp = (1000 + Random().nextInt(9000)).toString();
      generatedOtp = otp;
      setState(() => isOtpSent = true);

      String msg = "Namaste DisawarKing Support, mera registered mobile $mobile hai. Password reset OTP code hai: $otp";
      await openWhatsAppChat(message: msg);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.green, content: Text("OTP bhej diya gaya hai! WhatsApp check karein: $otp")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _verifyOtp() {
    if (_otpController.text.trim().isNotEmpty && _otpController.text.trim() == generatedOtp) {
      setState(() => isOtpVerified = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("OTP Verified! Naya password set karein.")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Galat OTP!")));
    }
  }

  void _resetPassword() async {
    if (!isOtpVerified) return;

    String mobile = _mobileController.text.trim();
    String newPass = _newPassController.text.trim();
    String cPass = _confirmPassController.text.trim();

    if (newPass.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Naya Password min 4 digit ho!")));
      return;
    }

    if (newPass != cPass) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Dono password match nahi huye!")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(mobile).update({'password': newPass});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Password Badal Diya Gaya! Login karein.")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password with OTP")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("OTP Password Reset", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
              const SizedBox(height: 16),
              TextField(
                controller: _mobileController,
                enabled: !isOtpSent,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(labelText: "Registered Mobile Number", counterText: "", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              if (!isOtpSent)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                    onPressed: _isLoading ? null : _sendWhatsAppOtp,
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("SEND OTP CODE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              if (isOtpSent && !isOtpVerified) ...[
                const SizedBox(height: 14),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: const InputDecoration(labelText: "4-Digit OTP Code Dalein", counterText: "", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    onPressed: _verifyOtp,
                    child: const Text("VERIFY OTP", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
              if (isOtpVerified) ...[
                const SizedBox(height: 14),
                TextField(controller: _newPassController, obscureText: true, decoration: const InputDecoration(labelText: "New Password", border: OutlineInputBorder())),
                const SizedBox(height: 14),
                TextField(controller: _confirmPassController, obscureText: true, decoration: const InputDecoration(labelText: "Confirm Password", border: OutlineInputBorder())),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    onPressed: _isLoading ? null : _resetPassword,
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.black) : const Text("CONFIRM & SAVE PASSWORD", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------- 4. MAIN BOTTOM NAVIGATION -----------------
class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeLiveResultsScreen(),
    GameMarketsListScreen(),
    CombinedAllMarketsChartScreen(), // Single Master Table Chart
    ResultsHistoryScreen(),
    WalletScreen(),
    MoreMenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFF59E0B),
        unselectedItemColor: Colors.white60,
        backgroundColor: const Color(0xFF1E293B),
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: "Play Game"),
          BottomNavigationBarItem(icon: Icon(Icons.table_chart), label: "Chart"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: "Results"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "More"),
        ],
      ),
    );
  }
}

// ----------------- 5. HOME SCREEN -----------------
class HomeLiveResultsScreen extends StatefulWidget {
  @override
  _HomeLiveResultsScreenState createState() => _HomeLiveResultsScreenState();
}

class _HomeLiveResultsScreenState extends State<HomeLiveResultsScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                border: Border(bottom: BorderSide(color: Colors.amber.withOpacity(0.3))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFF59E0B),
                        child: Icon(Icons.person, color: Color(0xFF0F172A), size: 24),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(currentLoggedInUserName.isEmpty ? "User" : currentLoggedInUserName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                          Text("+91 $currentLoggedInUserMobile", style: const TextStyle(fontSize: 12, color: Colors.amberAccent, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection('users').doc(currentLoggedInUserMobile).snapshots(),
                        builder: (context, snapshot) {
                          double bal = 0.0;
                          if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                            var d = snapshot.data!.data() as Map<String, dynamic>?;
                            if (d != null && d.containsKey('balance')) bal = (d['balance'] as num).toDouble();
                          }
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.withOpacity(0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text("Wallet", style: TextStyle(color: Colors.white54, fontSize: 10)),
                                Text("₹ ${bal.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => openWhatsAppChat(message: "Namaste DisawarKing Support! Meri ID: $currentLoggedInUserMobile"),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Color(0xFF25D366), shape: BoxShape.circle),
                          child: const Icon(Icons.chat, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('results').snapshots(),
                builder: (context, snapshot) {
                  Map<String, String> liveResults = {};
                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      liveResults[doc.id] = doc['number']?.toString() ?? "--";
                    }
                  }

                  return ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF312E81), Color(0xFF1E293B)]),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("DISAWAR KING LIVE RESULTS", style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 14)),
                                SizedBox(height: 4),
                                Text("Taaza parinam & Live Updates", style: TextStyle(color: Colors.white70, fontSize: 11)),
                              ],
                            ),
                            Icon(Icons.flash_on, color: Color(0xFFF59E0B), size: 30),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text("Aaj Ka Live Result", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white70)),
                      const SizedBox(height: 8),
                      ...appMarkets.map((market) {
                        String resultNum = liveResults[market.name] ?? "XX";
                        return Card(
                          color: const Color(0xFF1E293B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text("${market.hindiName} (${market.name})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                            subtitle: Text("Result Time: ${market.resultTimeStr} | Time Left: ${market.getRemainingTimeStr()}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(resultNum, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- 6. PLAY GAME MARKET LIST -----------------
class GameMarketsListScreen extends StatefulWidget {
  @override
  _GameMarketsListScreenState createState() => _GameMarketsListScreenState();
}

class _GameMarketsListScreenState extends State<GameMarketsListScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Markets (Play Game)")),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: appMarkets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final market = appMarkets[index];
          final bool isOpen = market.isOpen();
          final bool isLast2Hours = market.isWithin2Hours();

          return Card(
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${market.hindiName} (${market.name})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFF59E0B))),
                        const SizedBox(height: 4),
                        Text("Band hone me: ${market.getRemainingTimeStr()}", style: TextStyle(color: isOpen ? Colors.greenAccent : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text("Close Time: ${market.closeTimeStr}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        if (isOpen && isLast2Hours)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text("⚠️ Antim 2 Ghante: Max ₹200 Limit", style: TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                  if (isOpen)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GameModeSelectScreen(market: market)),
                        );
                      },
                      child: const Text("Play Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: const Text("CLOSED", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ----------------- 7. GAME MODE SELECT -----------------
class GameModeSelectScreen extends StatelessWidget {
  final MarketConfig market;
  GameModeSelectScreen({required this.market});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${market.hindiName} (${market.name})")),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF1E293B),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text("Jodi Rate", style: TextStyle(color: Colors.white60, fontSize: 13)),
                    Text("10 ka 950 ₹", style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                SizedBox(height: 35, width: 1, child: VerticalDivider(color: Colors.white24)),
                Column(
                  children: [
                    Text("Haruff Rate", style: TextStyle(color: Colors.white60, fontSize: 13)),
                    Text("10 ka 95 ₹", style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _menuTile(context, "Jodi (01 to 100)", Icons.grid_on, () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => JodiSelectionScreen(market: market)));
          }),
          _menuTile(context, "Harup (Andar / Bahar)", Icons.swap_horiz, () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => HarupSelectionScreen(market: market)));
          }),
          _menuTile(context, "Crossing Game", Icons.shuffle, () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => CrossingSelectionScreen(market: market)));
          }),
        ],
      ),
    );
  }

  Widget _menuTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        tileColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(icon, color: const Color(0xFFF59E0B)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }
}

// ----------------- 8. JODI SCREEN -----------------
class JodiSelectionScreen extends StatefulWidget {
  final MarketConfig market;
  JodiSelectionScreen({required this.market});

  @override
  _JodiSelectionScreenState createState() => _JodiSelectionScreenState();
}

class _JodiSelectionScreenState extends State<JodiSelectionScreen> {
  final List<TextEditingController> _controllers = List.generate(100, (_) => TextEditingController());
  int totalAmount = 0;

  void _calculateTotal() {
    int total = 0;
    for (var c in _controllers) {
      total += int.tryParse(c.text) ?? 0;
    }
    setState(() => totalAmount = total);
  }

  void _submitBids() async {
    if (!widget.market.isOpen()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Market Band Ho Chuka Hai!")));
      return;
    }
    if (totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Points dalein!")));
      return;
    }

    if (widget.market.isWithin2Hours()) {
      for (int i = 0; i < 100; i++) {
        int val = int.tryParse(_controllers[i].text) ?? 0;
        if (val > 200) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Antim 2 ghante me max ₹200 limit hai!")));
          return;
        }
      }
    }

    var userDoc = await FirebaseFirestore.instance.collection('users').doc(currentLoggedInUserMobile).get();
    double currentBal = ((userDoc.data()?['balance'] ?? 0) as num).toDouble();

    if (totalAmount > currentBal) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text("Wallet balance kam hai!")));
      return;
    }

    List<String> chosenNumbers = [];
    Map<String, int> betBreakdown = {};

    for (int i = 0; i < 100; i++) {
      int val = int.tryParse(_controllers[i].text) ?? 0;
      if (val > 0) {
        String numStr = (i + 1) == 100 ? "00" : ((i + 1) < 10 ? "0${i + 1}" : "${i + 1}");
        chosenNumbers.add("$numStr (₹$val)");
        betBreakdown[numStr] = val;
      }
    }

    Map<String, dynamic> gameData = {
      "userMobile": currentLoggedInUserMobile,
      "userName": currentLoggedInUserName,
      "market": widget.market.name,
      "hindiMarket": widget.market.hindiName,
      "type": "Jodi",
      "numbers": chosenNumbers.join(", "),
      "betMap": betBreakdown,
      "amount": totalAmount,
      "status": "Pending",
      "time": DateTime.now().toString().substring(11, 16),
      "date": "${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}",
      "timestamp": FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('bets').add(gameData);
      await FirebaseFirestore.instance.collection('users').doc(currentLoggedInUserMobile).update({
        'balance': FieldValue.increment(-totalAmount),
      });

      for (var c in _controllers) c.clear();
      _calculateTotal();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Jodi Game Safalta se Lag Gaya!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.market.hindiName} - Jodi"),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(currentLoggedInUserMobile).snapshots(),
            builder: (context, snapshot) {
              double bal = 0.0;
              if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                var d = snapshot.data!.data() as Map<String, dynamic>?;
                if (d != null && d.containsKey('balance')) bal = (d['balance'] as num).toDouble();
              }
              return Center(child: Padding(padding: const EdgeInsets.only(right: 16), child: Text("Bal: ₹${bal.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold))));
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, childAspectRatio: 1.15, crossAxisSpacing: 8, mainAxisSpacing: 8),
                itemCount: 100,
                itemBuilder: (context, index) {
                  int num = index + 1;
                  String displayNum = num == 100 ? "00" : (num < 10 ? "0$num" : "$num");
                  return Container(
                    decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white12)),
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(displayNum, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFF59E0B))),
                        SizedBox(
                          height: 24,
                          child: TextField(
                            controller: _controllers[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: Colors.white),
                            onChanged: (_) => _calculateTotal(),
                            decoration: const InputDecoration(hintText: "-", border: InputBorder.none, isDense: true),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF0F172A),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Amount", style: TextStyle(color: Colors.white60, fontSize: 12)),
                        Text("₹ $totalAmount", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 20)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                      onPressed: _submitBids,
                      child: const Text("SUBMIT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- 9. HARUP SCREEN -----------------
class HarupSelectionScreen extends StatefulWidget {
  final MarketConfig market;
  HarupSelectionScreen({required this.market});

  @override
  _HarupSelectionScreenState createState() => _HarupSelectionScreenState();
}

class _HarupSelectionScreenState extends State<HarupSelectionScreen> {
  final List<TextEditingController> _andar = List.generate(10, (_) => TextEditingController());
  final List<TextEditingController> _bahar = List.generate(10, (_) => TextEditingController());
  int total = 0;

  void _calc() {
    int sum = 0;
    for (var c in _andar) sum += int.tryParse(c.text) ?? 0;
    for (var c in _bahar) sum += int.tryParse(c.text) ?? 0;
    setState(() => total = sum);
  }

  void _submitHarup() async {
    if (!widget.market.isOpen()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Market Band Ho Chuka Hai!")));
      return;
    }
    if (total <= 0) return;

    var userDoc = await FirebaseFirestore.instance.collection('users').doc(currentLoggedInUserMobile).get();
    double currentBal = ((userDoc.data()?['balance'] ?? 0) as num).toDouble();

    if (total > currentBal) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Wallet balance kam hai!")));
      return;
    }

    Map<String, int> andarMap = {};
    Map<String, int> baharMap = {};
    List<String> listStrs = [];

    for (int i = 0; i < 10; i++) {
      int a = int.tryParse(_andar[i].text) ?? 0;
      if (a > 0) {
        andarMap["$i"] = a;
        listStrs.add("Andar-$i (₹$a)");
      }
      int b = int.tryParse(_bahar[i].text) ?? 0;
      if (b > 0) {
        baharMap["$i"] = b;
        listStrs.add("Bahar-$i (₹$b)");
      }
    }

    Map<String, dynamic> gameData = {
      "userMobile": currentLoggedInUserMobile,
      "userName": currentLoggedInUserName,
      "market": widget.market.name,
      "hindiMarket": widget.market.hindiName,
      "type": "Harup",
      "numbers": listStrs.join(", "),
      "andarMap": andarMap,
      "baharMap": baharMap,
      "amount": total,
      "status": "Pending",
      "time": DateTime.now().toString().substring(11, 16),
      "date": "${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}",
      "timestamp": FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('bets').add(gameData);
      await FirebaseFirestore.instance.collection('users').doc(currentLoggedInUserMobile).update({
        'balance': FieldValue.increment(-total),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Harup Game Lag Gaya!")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildBox(String label, List<TextEditingController> list) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, childAspectRatio: 1.2, crossAxisSpacing: 6, mainAxisSpacing: 6),
              itemBuilder: (c, i) => Container(
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(6)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("$i", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                    SizedBox(
                      height: 22,
                      child: TextField(
                        controller: list[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (_) => _calc(),
                        decoration: const InputDecoration(hintText: "-", border: InputBorder.none, isDense: true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.market.hindiName} - Harup")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: ListView(children: [_buildBox("Andar Harup", _andar), _buildBox("Bahar Harup", _bahar)])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF0F172A),
              child: Row(
                children: [
                  Expanded(child: Text("Total: ₹ $total", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 20))),
                  ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)), onPressed: _submitHarup, child: const Text("SUBMIT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ----------------- 10. CROSSING SCREEN -----------------
class CrossingSelectionScreen extends StatefulWidget {
  final MarketConfig market;
  CrossingSelectionScreen({required this.market});

  @override
  _CrossingSelectionScreenState createState() => _CrossingSelectionScreenState();
}

class _CrossingSelectionScreenState extends State<CrossingSelectionScreen> {
  final _num1 = TextEditingController();
  final _num2 = TextEditingController();
  final _amount = TextEditingController();
  final List<Map<String, dynamic>> _list = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.market.hindiName} - Crossing")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: const Color(0xFF1E293B),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(controller: _num1, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Number 1")),
                    const SizedBox(height: 8),
                    TextField(controller: _num2, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Number 2")),
                    const SizedBox(height: 8),
                    TextField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Points")),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), minimumSize: const Size(double.infinity, 44)),
                      onPressed: () {
                        if (_num1.text.isNotEmpty && _num2.text.isNotEmpty && _amount.text.isNotEmpty) {
                          setState(() {
                            _list.add({"pair": "${_num1.text} X ${_num2.text}", "amt": _amount.text});
                            _num1.clear();
                            _num2.clear();
                            _amount.clear();
                          });
                        }
                      },
                      child: const Text("+ Add Entry", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
            ..._list.map((e) => Card(
                  color: const Color(0xFF1E293B),
                  child: ListTile(title: Text(e['pair']), trailing: Text("₹ ${e['amt']}", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold))),
                )),
          ],
        ),
      ),
    );
  }
}

// ----------------- 11. ALL-IN-ONE COMBINED MASTER CHART SCREEN (SORTED 1 SE 31) -----------------
class CombinedAllMarketsChartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DisawarKing Master Chart"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('results_history')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          List<String> dates = [];
          Map<String, Map<String, String>> chartMap = {};

          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;
              String dt = data['date'] ?? '';
              String market = data['market'] ?? '';
              String number = data['number'] ?? 'XX';

              if (dt.isNotEmpty) {
                if (!dates.contains(dt)) {
                  dates.add(dt);
                }
                if (!chartMap.containsKey(dt)) {
                  chartMap[dt] = {};
                }
                chartMap[dt]![market] = number;
              }
            }
          }

          // Date ko 1 se shuru karne ke liye Numeric Sort (01, 02, 03 ... 29)
          dates.sort((a, b) {
            int numA = int.tryParse(a) ?? 0;
            int numB = int.tryParse(b) ?? 0;
            return numA.compareTo(numB);
          });

          if (dates.isEmpty) {
            return const Center(
              child: Text("Abhi Chart ka koi record nahi hai.", style: TextStyle(color: Colors.white54, fontSize: 14)),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 48,
                dataRowHeight: 44,
                headingRowColor: MaterialStateProperty.all(const Color(0xFF1E293B)),
                dataRowColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                  return const Color(0xFF0F172A);
                }),
                border: TableBorder.all(color: Colors.amber.withOpacity(0.3), width: 1),
                columns: [
                  const DataColumn(
                    label: Text("DATE", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  ...appMarkets.map((m) => DataColumn(
                        label: Text(m.name, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                      )),
                ],
                rows: dates.map((d) {
                  return DataRow(
                    cells: [
                      DataCell(Text(d, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                      ...appMarkets.map((m) {
                        String res = chartMap[d]?[m.name] ?? "--";
                        return DataCell(
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: res == "--" ? Colors.transparent : Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                res,
                                style: TextStyle(
                                  color: res == "--" ? Colors.white38 : Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ----------------- 12. RESULTS SCREEN -----------------
class ResultsHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Game Results")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('results').snapshots(),
        builder: (context, snapshot) {
          Map<String, String> liveMap = {};
          if (snapshot.hasData) {
            for (var d in snapshot.data!.docs) {
              liveMap[d.id] = d['number']?.toString() ?? "--";
            }
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: appMarkets.length,
            itemBuilder: (context, index) {
              final m = appMarkets[index];
              String n = liveMap[m.name] ?? "XX";
              return Card(
                color: const Color(0xFF1E293B),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: Color(0xFFF59E0B), size: 20),
                  title: Text("Timing: ${m.resultTimeStr}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  subtitle: Text("${m.hindiName} (${m.name})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  trailing: Text(n, style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ----------------- 13. WALLET SCREEN -----------------
class WalletScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DisawarKing Wallet")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF312E81), Color(0xFF1E293B)])),
              child: Column(
                children: [
                  const Text("Available Balance", style: TextStyle(color: Colors.white60, fontSize: 14)),
                  const SizedBox(height: 6),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(currentLoggedInUserMobile).snapshots(),
                    builder: (context, snapshot) {
                      double bal = 0.0;
                      if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                        var d = snapshot.data!.data() as Map<String, dynamic>?;
                        if (d != null && d.containsKey('balance')) bal = (d['balance'] as num).toDouble();
                      }
                      return Text("₹ ${bal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)));
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text("Add Money", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => AddMoneyPaymentScreen())),
                      ),
                      const SizedBox(width: 14),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                        icon: const Icon(Icons.arrow_upward, color: Colors.black),
                        label: const Text("Withdraw", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => WithdrawRequestScreen())),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Rules & Payment Limits:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                  SizedBox(height: 8),
                  Text("• Kam se kam ADD MONEY: ₹50", style: TextStyle(color: Colors.white70)),
                  Text("• Kam se kam WITHDRAWAL: ₹500", style: TextStyle(color: Colors.white70)),
                  Text("• Withdrawal Timing: Subah 8:00 AM se 2:00 PM tak", style: TextStyle(color: Colors.white70)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ----------------- 14. ADD MONEY SCREEN -----------------
class AddMoneyPaymentScreen extends StatefulWidget {
  @override
  _AddMoneyPaymentScreenState createState() => _AddMoneyPaymentScreenState();
}

class _AddMoneyPaymentScreenState extends State<AddMoneyPaymentScreen> {
  final _amount = TextEditingController();
  final _utr = TextEditingController();
  final String qrCodeUrl = "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=upi://pay%3Fpa=9761630128@ybl%26pn=DisawarKing%26cu=INR";
  bool _isSaving = false;

  void _submitDeposit() async {
    double val = double.tryParse(_amount.text) ?? 0.0;
    if (val < 50 || _utr.text.trim().length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Min ₹50 aur sahi UTR dalein!")));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('deposits').add({
        'userMobile': currentLoggedInUserMobile,
        'userName': currentLoggedInUserName,
        'amount': val,
        'utr': _utr.text.trim(),
        'status': 'Pending Approval',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.green, content: Text("Deposit Request Bheji Gayi! Admin verify karke wallet me jod dega.")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Money (Deposit)")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.network(qrCodeUrl, height: 200, width: 200),
            const SizedBox(height: 16),
            TextField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Amount (Min ₹50)", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _utr, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "12-Digit UTR Number", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                onPressed: _isSaving ? null : _submitDeposit,
                child: _isSaving ? const CircularProgressIndicator(color: Colors.black) : const Text("SUBMIT PAYMENT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ----------------- 15. WITHDRAW SCREEN -----------------
class WithdrawRequestScreen extends StatefulWidget {
  @override
  _WithdrawRequestScreenState createState() => _WithdrawRequestScreenState();
}

class _WithdrawRequestScreenState extends State<WithdrawRequestScreen> {
  final _amount = TextEditingController();
  final _upiOrAccount = TextEditingController();
  bool _isSaving = false;

  void _submitWithdraw() async {
    double amt = double.tryParse(_amount.text) ?? 0.0;
    if (amt < 500) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kam se kam ₹500 dalein!")));
      return;
    }

    setState(() => _isSaving = true);
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(currentLoggedInUserMobile).get();
      double currentBal = ((userDoc.data()?['balance'] ?? 0) as num).toDouble();

      if (amt > currentBal) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Paryapt balance nahi hai!")));
        setState(() => _isSaving = false);
        return;
      }

      await FirebaseFirestore.instance.collection('withdrawals').add({
        "userMobile": currentLoggedInUserMobile,
        "userName": currentLoggedInUserName,
        "amount": amt,
        "account": _upiOrAccount.text.trim(),
        "date": "${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}",
        "status": "Pending",
        "timestamp": FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('users').doc(currentLoggedInUserMobile).update({
        'balance': FieldValue.increment(-amt),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Withdrawal Request Lag Gayi!")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Withdraw Money")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Withdrawal Amount (Min ₹500)", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _upiOrAccount, decoration: const InputDecoration(labelText: "UPI ID ya Bank Account", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                onPressed: _isSaving ? null : _submitWithdraw,
                child: _isSaving ? const CircularProgressIndicator(color: Colors.black) : const Text("WITHDRAW REQUEST BHEJO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ----------------- 16. MORE MENU SCREEN -----------------
class MoreMenuScreen extends StatelessWidget {
  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    currentLoggedInUserMobile = "";
    currentLoggedInUserName = "";
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("More Menu")),
      body: ListView(
        children: [
          if (currentLoggedInUserMobile == adminMobile)
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber, width: 2),
                borderRadius: BorderRadius.circular(10),
                color: Colors.amber.withOpacity(0.1),
              ),
              child: ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: Colors.amber, size: 30),
                title: const Text("MASTER ADMIN PANEL", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: const Text("Result Ghoshan, Bets & Upload Chart", style: TextStyle(color: Colors.white70, fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.amber),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => MasterAdminPanelScreen())),
              ),
            ),
          ListTile(leading: const Icon(Icons.sports_esports, color: Color(0xFFF59E0B)), title: const Text("My Played Game"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => MyPlayGameScreen()))),
          ListTile(leading: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFF59E0B)), title: const Text("Withdrawal History"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => WithdrawalListScreen()))),
          ListTile(leading: const Icon(Icons.chat, color: Color(0xFF25D366)), title: const Text("Help & Support (WhatsApp)"), onTap: () => openWhatsAppChat()),
          ListTile(leading: const Icon(Icons.lock_reset, color: Color(0xFFF59E0B)), title: const Text("Change Password"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => DirectResetPasswordScreen()))),
          ListTile(leading: const Icon(Icons.description, color: Color(0xFFF59E0B)), title: const Text("Terms & Conditions"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => TermsAndConditionsScreen()))),
          const Divider(),
          ListTile(leading: const Icon(Icons.power_settings_new, color: Colors.red), title: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), onTap: () => _logout(context)),
        ],
      ),
    );
  }
}

// ----------------- 17. MASTER ADMIN PANEL (WITH IMPORT PAST CHART DATA BUTTON) -----------------
class MasterAdminPanelScreen extends StatefulWidget {
  @override
  _MasterAdminPanelScreenState createState() => _MasterAdminPanelScreenState();
}

class _MasterAdminPanelScreenState extends State<MasterAdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // 1 Click function to bulk upload the exact 29-day chart data
  void _importPastChartData() async {
    setState(() => _isImporting = true);

    // Exact data extracted from your chart image (Single digits formatted with leading 0)
    final List<Map<String, dynamic>> rawChart = [
      {"date": "01", "DSWR": "", "DLBZ": "58", "SRGN": "89", "FRBD": "45", "GZBD": "86", "GALI": "81"},
      {"date": "02", "DSWR": "69", "DLBZ": "52", "SRGN": "54", "FRBD": "19", "GZBD": "85", "GALI": "96"},
      {"date": "03", "DSWR": "57", "DLBZ": "88", "SRGN": "20", "FRBD": "08", "GZBD": "32", "GALI": "77"},
      {"date": "04", "DSWR": "95", "DLBZ": "18", "SRGN": "01", "FRBD": "02", "GZBD": "95", "GALI": "26"},
      {"date": "05", "DSWR": "59", "DLBZ": "44", "SRGN": "02", "FRBD": "30", "GZBD": "68", "GALI": "37"},
      {"date": "06", "DSWR": "78", "DLBZ": "71", "SRGN": "25", "FRBD": "88", "GZBD": "69", "GALI": "94"},
      {"date": "07", "DSWR": "67", "DLBZ": "61", "SRGN": "17", "FRBD": "02", "GZBD": "02", "GALI": "10"},
      {"date": "08", "DSWR": "92", "DLBZ": "84", "SRGN": "83", "FRBD": "71", "GZBD": "93", "GALI": "64"},
      {"date": "09", "DSWR": "54", "DLBZ": "18", "SRGN": "15", "FRBD": "29", "GZBD": "93", "GALI": "69"},
      {"date": "10", "DSWR": "93", "DLBZ": "52", "SRGN": "12", "FRBD": "15", "GZBD": "72", "GALI": "40"},
      {"date": "11", "DSWR": "40", "DLBZ": "59", "SRGN": "32", "FRBD": "72", "GZBD": "98", "GALI": "34"},
      {"date": "12", "DSWR": "46", "DLBZ": "81", "SRGN": "42", "FRBD": "65", "GZBD": "16", "GALI": "35"},
      {"date": "13", "DSWR": "02", "DLBZ": "55", "SRGN": "48", "FRBD": "74", "GZBD": "47", "GALI": "72"},
      {"date": "14", "DSWR": "35", "DLBZ": "86", "SRGN": "34", "FRBD": "30", "GZBD": "50", "GALI": "87"},
      {"date": "15", "DSWR": "89", "DLBZ": "46", "SRGN": "28", "FRBD": "24", "GZBD": "19", "GALI": "83"},
      {"date": "16", "DSWR": "31", "DLBZ": "68", "SRGN": "94", "FRBD": "21", "GZBD": "42", "GALI": "91"},
      {"date": "17", "DSWR": "90", "DLBZ": "99", "SRGN": "50", "FRBD": "38", "GZBD": "34", "GALI": "73"},
      {"date": "18", "DSWR": "49", "DLBZ": "84", "SRGN": "38", "FRBD": "36", "GZBD": "03", "GALI": "50"},
      {"date": "19", "DSWR": "35", "DLBZ": "24", "SRGN": "20", "FRBD": "21", "GZBD": "86", "GALI": "07"},
      {"date": "20", "DSWR": "32", "DLBZ": "47", "SRGN": "80", "FRBD": "84", "GZBD": "24", "GALI": "66"},
      {"date": "21", "DSWR": "01", "DLBZ": "62", "SRGN": "08", "FRBD": "71", "GZBD": "70", "GALI": "32"},
      {"date": "22", "DSWR": "73", "DLBZ": "03", "SRGN": "98", "FRBD": "42", "GZBD": "50", "GALI": "00"},
      {"date": "23", "DSWR": "35", "DLBZ": "92", "SRGN": "10", "FRBD": "00", "GZBD": "42", "GALI": "02"},
      {"date": "24", "DSWR": "26", "DLBZ": "27", "SRGN": "48", "FRBD": "38", "GZBD": "32", "GALI": "90"},
      {"date": "25", "DSWR": "86", "DLBZ": "44", "SRGN": "68", "FRBD": "08", "GZBD": "63", "GALI": "37"},
      {"date": "26", "DSWR": "48", "DLBZ": "55", "SRGN": "43", "FRBD": "09", "GZBD": "18", "GALI": "66"},
      {"date": "27", "DSWR": "81", "DLBZ": "35", "SRGN": "07", "FRBD": "61", "GZBD": "66", "GALI": "64"},
      {"date": "28", "DSWR": "49", "DLBZ": "66", "SRGN": "90", "FRBD": "58", "GZBD": "03", "GALI": "03"},
      {"date": "29", "DSWR": "43", "DLBZ": "", "SRGN": "", "FRBD": "", "GZBD": "", "GALI": ""},
    ];

    try {
      final batch = FirebaseFirestore.instance.batch();
      final historyCol = FirebaseFirestore.instance.collection('results_history');

      for (var row in rawChart) {
        String dt = row['date'];
        int dayNum = int.parse(dt);
        DateTime fakeTimestamp = DateTime(2026, 9, dayNum, 12, 0);

        void addEntry(String market, String num) {
          if (num.isNotEmpty) {
            var docRef = historyCol.doc("${dt}_$market");
            batch.set(docRef, {
              'market': market,
              'number': num,
              'date': dt,
              'timestamp': Timestamp.fromDate(fakeTimestamp),
            });
          }
        }

        addEntry("DISAWAR", row['DSWR']);
        addEntry("DELHI BAZAR", row['DLBZ']);
        addEntry("SHREE GANESH", row['SRGN']);
        addEntry("FARIDABAD", row['FRBD']);
        addEntry("GHAZIABAD", row['GZBD']);
        addEntry("GALI", row['GALI']);
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.green, content: Text("29 Dinon Ka Pura Chart Safalta Se Upload Ho Gaya!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _declareResultAndDistribute(BuildContext context, String marketName) {
    final TextEditingController numCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text("Result: $marketName", style: const TextStyle(color: Colors.amber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Number daalte hi winners ke wallet me winning balance credit hoga aur Chart me permanent date-wise save ho jayega.", style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: numCtrl,
              keyboardType: TextInputType.number,
              maxLength: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber),
              decoration: const InputDecoration(hintText: "84", border: OutlineInputBorder(), counterText: ""),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              String result = numCtrl.text.trim();
              if (result.length != 2) return;
              Navigator.pop(ctx);

              String todayDate = "${DateTime.now().day.toString().padLeft(2, '0')}";

              await FirebaseFirestore.instance.collection('results').doc(marketName).set({
                'number': result,
                'declaredAt': FieldValue.serverTimestamp(),
              });

              await FirebaseFirestore.instance.collection('results_history').doc("${todayDate}_$marketName").set({
                'market': marketName,
                'number': result,
                'date': todayDate,
                'timestamp': FieldValue.serverTimestamp(),
              });

              String andarDigit = result.substring(0, 1);
              String baharDigit = result.substring(1, 2);

              var betsSnapshot = await FirebaseFirestore.instance
                  .collection('bets')
                  .where('market', isEqualTo: marketName)
                  .where('status', isEqualTo: 'Pending')
                  .get();

              int winnersCount = 0;

              for (var doc in betsSnapshot.docs) {
                var bet = doc.data();
                String type = bet['type'] ?? '';
                String userMob = bet['userMobile'];
                double winAmount = 0.0;

                if (type == "Jodi" && bet.containsKey('betMap')) {
                  Map<String, dynamic> betMap = Map<String, dynamic>.from(bet['betMap']);
                  if (betMap.containsKey(result)) {
                    int betPoints = (betMap[result] as num).toInt();
                    winAmount += (betPoints * 95).toDouble();
                  }
                }

                if (type == "Harup") {
                  if (bet.containsKey('andarMap')) {
                    Map<String, dynamic> aMap = Map<String, dynamic>.from(bet['andarMap']);
                    if (aMap.containsKey(andarDigit)) {
                      int pts = (aMap[andarDigit] as num).toInt();
                      winAmount += (pts * 9.5);
                    }
                  }
                  if (bet.containsKey('baharMap')) {
                    Map<String, dynamic> bMap = Map<String, dynamic>.from(bet['baharMap']);
                    if (bMap.containsKey(baharDigit)) {
                      int pts = (bMap[baharDigit] as num).toInt();
                      winAmount += (pts * 9.5);
                    }
                  }
                }

                if (winAmount > 0) {
                  winnersCount++;
                  await FirebaseFirestore.instance.collection('users').doc(userMob).update({
                    'balance': FieldValue.increment(winAmount),
                  });
                  await doc.reference.update({
                    'status': 'Won ₹${winAmount.toStringAsFixed(0)}',
                    'winningAmount': winAmount,
                  });
                } else {
                  await doc.reference.update({'status': 'Lost'});
                }
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: Colors.green, content: Text("$marketName Result $result Ghosit! $winnersCount winners ko credit ho gaya.")),
              );
            },
            child: const Text("Declare & Pay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Master Admin Panel"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(text: "Results"),
            Tab(text: "Live Bets"),
            Tab(text: "Deposits"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // One-click button to upload your provided chart data into Firebase
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFF59E0B)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: _isImporting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Icon(Icons.cloud_upload, color: Colors.black, size: 26),
                  label: Text(
                    _isImporting ? "UPLOADING CHART DATA..." : "ONE-CLICK UPLOAD 29-DAY CHART DATA",
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  onPressed: _isImporting ? null : _importPastChartData,
                ),
              ),
              ...appMarkets.map((m) {
                return Card(
                  color: const Color(0xFF1E293B),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text("${m.hindiName} (${m.name})", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                    subtitle: Text("Timing: ${m.resultTimeStr}"),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                      onPressed: () => _declareResultAndDistribute(context, m.name),
                      child: const Text("Declare Number", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('bets').orderBy('timestamp', descending: true).limit(50).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              var docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text("Koi Bet nahi lagi hai"));

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (ctx, i) {
                  var b = docs[i].data() as Map<String, dynamic>;
                  return Card(
                    color: const Color(0xFF1E293B),
                    child: ListTile(
                      title: Text("${b['market']} - ₹${b['amount']}", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                      subtitle: Text("User: ${b['userName']} (${b['userMobile']})\nBids: ${b['numbers']}\nStatus: ${b['status']}"),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('deposits').orderBy('timestamp', descending: true).limit(50).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              var docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text("Koi Deposit request nahi hai"));

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (ctx, i) {
                  var d = docs[i].data() as Map<String, dynamic>;
                  String status = d['status'] ?? 'Pending';
                  double amt = (d['amount'] as num).toDouble();
                  String mob = d['userMobile'];

                  return Card(
                    color: const Color(0xFF1E293B),
                    child: ListTile(
                      title: Text("₹$amt by ${d['userName']} ($mob)", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                      subtitle: Text("UTR: ${d['utr']}\nStatus: $status"),
                      trailing: status == "Pending Approval"
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                              onPressed: () async {
                                await docs[i].reference.update({'status': 'Approved'});
                                await FirebaseFirestore.instance.collection('users').doc(mob).update({
                                  'balance': FieldValue.increment(amt),
                                });
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("₹$amt Approved & Wallet Updated!")));
                              },
                              child: const Text("Approve", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            )
                          : Text(status, style: const TextStyle(color: Colors.white60)),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ----------------- 18. MY PLAYED GAME SCREEN -----------------
class MyPlayGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Played Game")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bets')
            .where('userMobile', isEqualTo: currentLoggedInUserMobile)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aapne abhi koi game nahi lagaya hai", style: TextStyle(color: Colors.white54, fontSize: 14)));
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var item = docs[index].data() as Map<String, dynamic>;
              String status = item['status'] ?? 'Pending';
              Color stColor = status.contains('Won') ? Colors.greenAccent : (status == 'Lost' ? Colors.redAccent : Colors.amber);

              return Card(
                color: const Color(0xFF1E293B),
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item['hindiMarket'] ?? item['market'] ?? "Market", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("₹ ${item['amount'] ?? 0}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text("Numbers: ${item['numbers'] ?? ''}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const Divider(color: Colors.white12, height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Status: $status", style: TextStyle(color: stColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          Text("${item['date'] ?? ''} ${item['time'] ?? ''}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ----------------- 19. WITHDRAWAL LIST SCREEN -----------------
class WithdrawalListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Withdrawal History")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('withdrawals')
            .where('userMobile', isEqualTo: currentLoggedInUserMobile)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Koi withdrawal request nahi hai", style: TextStyle(color: Colors.white54)));
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var item = docs[index].data() as Map<String, dynamic>;
              return Card(
                color: const Color(0xFF1E293B),
                child: ListTile(
                  title: Text("₹ ${item['amount'] ?? 0}", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text("A/C: ${item['account'] ?? ''}\nStatus: ${item['status'] ?? 'Pending'}", style: const TextStyle(color: Colors.white70)),
                  trailing: Text(item['date'] ?? '', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ----------------- 20. TERMS & CONDITIONS SCREEN -----------------
class TermsAndConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms & Conditions")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text("• Antim 2 ghante me max ₹200 limit lagti hai.\n• Min Add Money ₹50, Min Withdrawal ₹500.\n• Withdrawal timing: Subah 8:00 AM se 2:00 PM tak.", style: TextStyle(fontSize: 14, height: 1.6, color: Colors.white70)),
      ),
    );
  }
}
