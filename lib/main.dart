import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint("Flutter Error: ${details.exception}");
  };

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

// ----------------- DYNAMIC APP CONFIG & GLOBALS -----------------
String currentLoggedInUserMobile = "";
String currentLoggedInUserName = "";
const String adminMobile = "9761630128";

String dynamicWhatsAppNumber = "917409989270";
String dynamicUpiId = "9761630128@ybl";
String dynamicNoticeText = "";
bool dynamicEmergencyLock = false;
String dynamicLatestApkUrl = "";
String dynamicTermsText = "• जोड़ी रेट: 10 का 900 ₹ | हरूफ रेट: 10 का 90 ₹।\n"
    "• अंतिम 2 घंटे में प्रति जोड़ी अधिकतम ₹200 की सीमा लागू होगी।\n"
    "• महीने के अंतिम दिन (Month End) सभी बाज़ार बंद रहते हैं।\n"
    "• कम से कम पैसे जोड़ें (Add Money): ₹50\n"
    "• कम से कम निकासी (Withdrawal): ₹500\n"
    "• केवल जीती हुई राशि (Winning Balance) ही निकाली जा सकती है। डिपॉजिट राशि से गेम खेलें।\n"
    "• नए यूजर को पहली बार पैसे जोड़ने पर 5% का सीधा बोनस मिलेगा।\n"
    "• निकासी का समय: प्रतिदिन सुबह 8:00 AM से दोपहर 2:00 PM तक।\n"
    "• ₹5,000 से ऊपर की राशि केवल बैंक अकाउंट (Bank Transfer) में ही भेजी जाएगी।\n"
    "• निकासी अनुरोध सबमिट होने के 30 मिनट के अंदर राशि ट्रांसफर कर दी जाती है।\n"
    "• रेफरल कमीशन: आपके रेफरल कोड से जुड़े यूजर की प्रत्येक हारी हुई बाजी पर 7% कमीशन तुरंत आपके वॉलेट में स्वतः ट्रांसफर होगा।";

Map<String, Map<String, dynamic>> dynamicMarketTimings = {
  "DELHI BAZAR": {"closeHour": 14, "closeMin": 50, "closeTimeStr": "02:50 PM", "resultTimeStr": "03:15 PM"},
  "SHREE GANESH": {"closeHour": 16, "closeMin": 0, "closeTimeStr": "04:00 PM", "resultTimeStr": "04:30 PM"},
  "FARIDABAD": {"closeHour": 17, "closeMin": 50, "closeTimeStr": "05:50 PM", "resultTimeStr": "06:15 PM"},
  "GHAZIABAD": {"closeHour": 21, "closeMin": 20, "closeTimeStr": "09:20 PM", "resultTimeStr": "09:45 PM"},
  "GALI": {"closeHour": 23, "closeMin": 25, "closeTimeStr": "11:25 PM", "resultTimeStr": "11:55 PM"},
  "DISAWAR": {"closeHour": 4, "closeMin": 0, "closeTimeStr": "04:00 AM", "resultTimeStr": "05:00 AM"},
};

Map<String, int> parseTimeString(String timeStr) {
  try {
    String clean = timeStr.trim().toUpperCase();
    bool isPm = clean.contains("PM");
    bool isAm = clean.contains("AM");
    clean = clean.replaceAll("AM", "").replaceAll("PM", "").trim();
    var parts = clean.split(":");
    int h = int.parse(parts[0].trim());
    int m = int.parse(parts[1].trim());

    if (isPm && h < 12) h += 12;
    if (isAm && h == 12) h = 0;
    return {"hour": h, "min": m};
  } catch (_) {
    return {"hour": 0, "min": 0};
  }
}

bool isMonthEndToday() {
  DateTime now = DateTime.now();
  DateTime tomorrow = now.add(const Duration(days: 1));
  return tomorrow.month != now.month;
}

class MarketConfig {
  final String name;
  final String hindiName;

  MarketConfig({
    required this.name,
    required this.hindiName,
  });

  int get closeHour {
    if (dynamicMarketTimings.containsKey(name)) {
      var d = dynamicMarketTimings[name]!;
      if (d['closeHour'] != null && d['closeHour'] is int && d['closeHour'] > 0) {
        return d['closeHour'];
      }
      return parseTimeString(d['closeTimeStr'] ?? "")["hour"] ?? 0;
    }
    return 0;
  }

  int get closeMin {
    if (dynamicMarketTimings.containsKey(name)) {
      var d = dynamicMarketTimings[name]!;
      if (d['closeMin'] != null && d['closeMin'] is int) {
        return d['closeMin'];
      }
      return parseTimeString(d['closeTimeStr'] ?? "")["min"] ?? 0;
    }
    return 0;
  }

  String get closeTimeStr => dynamicMarketTimings[name]?["closeTimeStr"] ?? "--";
  String get resultTimeStr => dynamicMarketTimings[name]?["resultTimeStr"] ?? "--";

  DateTime getCloseDateTime() {
    DateTime now = DateTime.now();
    DateTime closeTime = DateTime(now.year, now.month, now.day, closeHour, closeMin);
    if (closeHour < 6 && now.hour >= 6) {
      closeTime = closeTime.add(const Duration(days: 1));
    }
    return closeTime;
  }

  bool isOpen() {
    if (dynamicEmergencyLock) return false;
    DateTime now = DateTime.now();
    if (isMonthEndToday()) {
      if (name != "DISAWAR" || now.hour >= 4) {
        return false;
      }
    }
    return now.isBefore(getCloseDateTime());
  }

  bool isWithin2Hours() {
    if (!isOpen()) return false;
    Duration diff = getCloseDateTime().difference(DateTime.now());
    return diff.inMinutes > 0 && diff.inMinutes <= 120;
  }

  String getRemainingTimeStr() {
    if (dynamicEmergencyLock) return "Maintenance Mode";
    if (isMonthEndToday()) {
      DateTime now = DateTime.now();
      if (name != "DISAWAR" || now.hour >= 4) {
        return "Month End Closed";
      }
    }
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

final List<MarketConfig> appMarkets = [
  MarketConfig(name: "DELHI BAZAR", hindiName: "दिल्ली बाजार"),
  MarketConfig(name: "SHREE GANESH", hindiName: "श्री गणेश"),
  MarketConfig(name: "FARIDABAD", hindiName: "फ़रीदाबाद"),
  MarketConfig(name: "GHAZIABAD", hindiName: "गाज़ियाबाद"),
  MarketConfig(name: "GALI", hindiName: "गली"),
  MarketConfig(name: "DISAWAR", hindiName: "दिसावर"),
];

Future<void> openWhatsAppChat({String message = "Namaste DisawarKing Support, mujhe sahayata chahiye."}) async {
  final Uri url = Uri.parse("https://wa.me/$dynamicWhatsAppNumber?text=${Uri.encodeComponent(message)}");
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

Map<String, double> extractUserBalances(Map<String, dynamic>? data) {
  if (data == null) return {'deposit': 0.0, 'winning': 0.0, 'total': 0.0};

  double dep = 0.0;
  double win = 0.0;

  if (data.containsKey('depositBalance')) {
    dep = ((data['depositBalance'] ?? 0) as num).toDouble();
  }
  if (data.containsKey('winningBalance')) {
    win = ((data['winningBalance'] ?? 0) as num).toDouble();
  } else if (data.containsKey('balance')) {
    win = ((data['balance'] ?? 0) as num).toDouble();
  } else if (data.containsKey('wallet')) {
    win = ((data['wallet'] ?? 0) as num).toDouble();
  }

  return {'deposit': dep, 'winning': win, 'total': (dep + win)};
}

// ----------------- SPLASH SCREEN -----------------
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
    await Future.delayed(const Duration(milliseconds: 900));
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
  final _referralController = TextEditingController();
  bool _isSaving = false;

  void _submitRegistration() async {
    String name = _nameController.text.trim();
    String mobile = _mobileController.text.trim();
    String pass = _passController.text.trim();
    String cPass = _confirmPassController.text.trim();
    String refCode = _referralController.text.trim();

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

      String? verifiedReferrer;
      if (refCode.isNotEmpty) {
        if (refCode == mobile) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Aap apna number referral me nahi daal sakte!")));
          setState(() => _isSaving = false);
          return;
        }
        var refDoc = await FirebaseFirestore.instance.collection('users').doc(refCode).get();
        if (refDoc.exists) {
          verifiedReferrer = refCode;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Referral code galat hai! Khali chhod dein agar nahi hai.")));
          setState(() => _isSaving = false);
          return;
        }
      }

      await FirebaseFirestore.instance.collection('users').doc(mobile).set({
        'name': name,
        'mobile': mobile,
        'password': pass,
        'depositBalance': 0.0,
        'winningBalance': 0.0,
        'hasDepositedBefore': false,
        'referredBy': verifiedReferrer ?? "",
        'referralEarnings': 0.0,
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
              const SizedBox(height: 14),
              TextField(
                controller: _referralController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: "Referral Code (Optional - Mobile No.)",
                  hintText: "Dost ka 10-digit mobile number",
                  counterText: "",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.card_giftcard, color: Colors.amber),
                ),
              ),
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

// ----------------- SIDE DRAWER COMPONENT -----------------
class AppSideNavigationDrawer extends StatelessWidget {
  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    currentLoggedInUserMobile = "";
    currentLoggedInUserName = "";
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1E293B),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF312E81), Color(0xFF1E293B)]),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Color(0xFFF59E0B),
              child: Icon(Icons.person, color: Color(0xFF0F172A), size: 38),
            ),
            accountName: Text(
              currentLoggedInUserName.isEmpty ? "User" : currentLoggedInUserName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            accountEmail: Text(
              "+91 $currentLoggedInUserMobile",
              style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                if (currentLoggedInUserMobile == adminMobile)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.amber, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.amber.withOpacity(0.1),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.admin_panel_settings, color: Colors.amber, size: 28),
                      title: const Text("ADMIN PANEL", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 14),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (c) => MasterAdminPanelScreen()));
                      },
                    ),
                  ),
                ListTile(
                  leading: const Icon(Icons.share, color: Color(0xFFF59E0B)),
                  title: const Text("Refer & Earn (7% Commission)"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (c) => ReferAndEarnScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sports_esports, color: Color(0xFFF59E0B)),
                  title: const Text("My Played Game"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (c) => MyPlayGameScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFF59E0B)),
                  title: const Text("Withdrawal History"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (c) => WithdrawalListScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat, color: Color(0xFF25D366)),
                  title: const Text("Help & Support (WhatsApp)"),
                  onTap: () {
                    Navigator.pop(context);
                    openWhatsAppChat();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock_reset, color: Color(0xFFF59E0B)),
                  title: const Text("Change Password"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (c) => DirectResetPasswordScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description, color: Color(0xFFF59E0B)),
                  title: const Text("Terms & Conditions"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (c) => TermsAndConditionsScreen()));
                  },
                ),
                const Divider(color: Colors.white24),
                ListTile(
                  leading: const Icon(Icons.power_settings_new, color: Colors.redAccent),
                  title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  onTap: () => _logout(context),
                ),
              ],
            ),
          )
        ],
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
  StreamSubscription<DocumentSnapshot>? _configSub;

  @override
  void initState() {
    super.initState();
    _configSub = FirebaseFirestore.instance.collection('app_settings').doc('config').snapshots().listen((snap) {
      if (snap.exists && snap.data() != null) {
        var d = snap.data() as Map<String, dynamic>;
        setState(() {
          dynamicWhatsAppNumber = d['whatsapp'] ?? dynamicWhatsAppNumber;
          dynamicUpiId = d['upi'] ?? dynamicUpiId;
          dynamicNoticeText = d['notice'] ?? "";
          dynamicEmergencyLock = d['emergencyLock'] ?? false;
          dynamicLatestApkUrl = d['apkUrl'] ?? "";
          dynamicTermsText = d['termsText'] ?? dynamicTermsText;

          if (d.containsKey('marketTimings') && d['marketTimings'] != null) {
            Map<String, dynamic> rawTimes = Map<String, dynamic>.from(d['marketTimings']);
            rawTimes.forEach((key, value) {
              if (dynamicMarketTimings.containsKey(key)) {
                var mData = Map<String, dynamic>.from(value);
                String cTime = mData['closeTimeStr'] ?? "";
                var parsed = parseTimeString(cTime);
                mData['closeHour'] = parsed['hour'];
                mData['closeMin'] = parsed['min'];
                dynamicMarketTimings[key] = mData;
              }
            });
          }
        });

        if (dynamicLatestApkUrl.isNotEmpty && mounted) {
          _showUpdateNoticeDialog(dynamicLatestApkUrl);
        }
      }
    });
  }

  void _showUpdateNoticeDialog(String apkUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("नया अपडेट उपलब्ध है! 🚀", style: TextStyle(color: Colors.amber)),
        content: const Text(
          "ऐप का एक नया और बेहतर वर्ज़न आ चुका है। सुचारू रूप से खेलने के लिए अभी अपडेट करें।",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
            onPressed: () async {
              final Uri u = Uri.parse(apkUrl);
              try {
                await launchUrl(u, mode: LaunchMode.externalApplication);
              } catch (_) {}
            },
            child: const Text("UPDATE NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _configSub?.cancel();
    super.dispose();
  }

  final List<Widget> _screens = [
    HomeLiveResultsScreen(),
    GameMarketsListScreen(),
    CombinedAllMarketsChartScreen(),
    WalletScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppSideNavigationDrawer(),
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
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Wallet"),
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
    bool isMonthEnd = isMonthEndToday();

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
                  Builder(
                    builder: (innerContext) => GestureDetector(
                      onTap: () {
                        Scaffold.of(innerContext).openDrawer();
                      },
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              const CircleAvatar(
                                radius: 22,
                                backgroundColor: Color(0xFFF59E0B),
                                child: Icon(Icons.person, color: Color(0xFF0F172A), size: 26),
                              ),
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Color(0xFF0F172A), shape: BoxShape.circle),
                                child: const Icon(Icons.menu, size: 12, color: Colors.amber),
                              ),
                            ],
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
                    ),
                  ),
                  Row(
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection('users').doc(currentLoggedInUserMobile).snapshots(),
                        builder: (context, snapshot) {
                          double totalBal = 0.0;
                          if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                            var d = snapshot.data!.data() as Map<String, dynamic>?;
                            var balMap = extractUserBalances(d);
                            totalBal = balMap['total'] ?? 0.0;
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
                                Text("₹ ${totalBal.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 14)),
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
                      if (dynamicNoticeText.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.campaign, color: Colors.amber, size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  dynamicNoticeText,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (dynamicEmergencyLock)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orangeAccent),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.build, color: Colors.orangeAccent, size: 24),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "⚠️ सिस्टम मेंटेनेंस मोड में है। कुछ समय के लिए नई बिड बंद कर दी गई हैं।",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isMonthEnd)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.redAccent),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.event_busy, color: Colors.redAccent, size: 28),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "⚠️ आज महीने का अंतिम दिन (Month End) है। सभी बाज़ार बंद हैं। कोई नई बाज़ी नहीं लगेगी।",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                        String remainingStr = market.getRemainingTimeStr();

                        return Card(
                          color: const Color(0xFF1E293B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text("${market.hindiName} (${market.name})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                            subtitle: Text(
                              remainingStr == "Month End Closed" || remainingStr == "Maintenance Mode"
                                  ? "Result: ${market.resultTimeStr} | स्थिति: $remainingStr"
                                  : "Result Time: ${market.resultTimeStr} | Time Left: $remainingStr",
                              style: TextStyle(
                                color: (remainingStr == "Month End Closed" || remainingStr == "Maintenance Mode") ? Colors.redAccent : Colors.white54,
                                fontSize: 11,
                                fontWeight: (remainingStr == "Month End Closed" || remainingStr == "Maintenance Mode") ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
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
          final String timeLeft = market.getRemainingTimeStr();

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
                        if (timeLeft != "Month End Closed" && timeLeft != "Maintenance Mode")
                          Text(
                            "Band hone me: $timeLeft",
                            style: TextStyle(color: isOpen ? Colors.greenAccent : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
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
                      child: Text(
                        timeLeft == "Month End Closed" ? "MONTH END CLOSED" : "CLOSED",
                        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
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
                    Text("10 ka 900 ₹", style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                SizedBox(height: 35, width: 1, child: VerticalDivider(color: Colors.white24)),
                Column(
                  children: [
                    Text("Haruff Rate", style: TextStyle(color: Colors.white60, fontSize: 13)),
                    Text("10 ka 90 ₹", style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 18)),
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

// ----------------- WALLET DEDUCTION HELPER FUNCTION -----------------
Future<bool> deductGamePoints(String mobile, double points) async {
  var uRef = FirebaseFirestore.instance.collection('users').doc(mobile);
  var snap = await uRef.get();
  if (!snap.exists) return false;

  var d = snap.data()!;
  var bal = extractUserBalances(d);
  double dep = bal['deposit']!;
  double total = bal['total']!;

  if (points > total) return false;

  if (dep >= points) {
    await uRef.update({'depositBalance': FieldValue.increment(-points)});
  } else {
    double remainder = points - dep;
    await uRef.update({
      'depositBalance': 0.0,
      'winningBalance': FieldValue.increment(-remainder),
    });
  }
  return true;
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
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text("बाज़ार बंद है", style: TextStyle(color: Colors.redAccent)),
          content: Text(
            isMonthEndToday()
                ? "महीने के अंतिम दिन (Month End) सभी बाज़ार बंद रहते हैं। आज कोई बिड नहीं लग सकती।"
                : (dynamicEmergencyLock ? "सिस्टम मेंटेनेंस की वजह से गेम बंद है।" : "इस बाज़ार का समय समाप्त हो चुका है।"),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () => Navigator.pop(ctx),
              child: const Text("ठीक है", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
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

    bool success = await deductGamePoints(currentLoggedInUserMobile, totalAmount.toDouble());
    if (!success) {
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
              double total = 0.0;
              if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                var d = snapshot.data!.data() as Map<String, dynamic>?;
                var bMap = extractUserBalances(d);
                total = bMap['total'] ?? 0.0;
              }
              return Center(child: Padding(padding: const EdgeInsets.only(right: 16), child: Text("Bal: ₹${total.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold))));
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
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text("बाज़ार बंद है", style: TextStyle(color: Colors.redAccent)),
          content: Text(
            isMonthEndToday()
                ? "महीने के अंतिम दिन (Month End) सभी बाज़ार बंद रहते हैं। आज कोई बिड नहीं लग सकती।"
                : (dynamicEmergencyLock ? "सिस्टम मेंटेनेंस की वजह से गेम बंद है।" : "इस बाज़ार का समय समाप्त हो चुका है।"),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () => Navigator.pop(ctx),
              child: const Text("ठीक है", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
      return;
    }
    if (total <= 0) return;

    bool success = await deductGamePoints(currentLoggedInUserMobile, total.toDouble());
    if (!success) {
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
  final _set1Controller = TextEditingController();
  final _set2Controller = TextEditingController();
  final _amountController = TextEditingController();

  List<String> generatedJodis = [];
  int totalJodisCount = 0;
  int calculatedTotalAmount = 0;
  bool _isSaving = false;

  void _generateCrossingPairs() {
    String set1 = _set1Controller.text.trim();
    String set2 = _set2Controller.text.trim();
    int amountPerJodi = int.tryParse(_amountController.text.trim()) ?? 0;

    if (set1.isEmpty || set2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dono number box me digits dalein!")));
      return;
    }
    if (amountPerJodi <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Har jodi ka amount (₹) dalein!")));
      return;
    }

    List<String> jodis = [];
    for (int i = 0; i < set1.length; i++) {
      for (int j = 0; j < set2.length; j++) {
        String pair = "${set1[i]}${set2[j]}";
        jodis.add(pair);
      }
    }

    setState(() {
      generatedJodis = jodis;
      totalJodisCount = jodis.length;
      calculatedTotalAmount = totalJodisCount * amountPerJodi;
    });
  }

  void _submitCrossingBids() async {
    if (!widget.market.isOpen()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text("बाज़ार बंद है", style: TextStyle(color: Colors.redAccent)),
          content: Text(
            isMonthEndToday()
                ? "महीने के अंतिम दिन (Month End) सभी बाज़ार बंद रहते हैं। आज कोई बिड नहीं लग सकती।"
                : (dynamicEmergencyLock ? "सिस्टम मेंटेनेंस की वजह से गेम बंद है।" : "इस बाज़ार का समय समाप्त हो चुका है।"),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () => Navigator.pop(ctx),
              child: const Text("ठीक है", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
      return;
    }
    if (generatedJodis.isEmpty || calculatedTotalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pehle crossing jodi generate karein!")));
      return;
    }

    int amountPerJodi = int.tryParse(_amountController.text.trim()) ?? 0;

    if (widget.market.isWithin2Hours() && amountPerJodi > 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Antim 2 ghante me max ₹200 limit hai!")));
      return;
    }

    setState(() => _isSaving = true);

    try {
      bool success = await deductGamePoints(currentLoggedInUserMobile, calculatedTotalAmount.toDouble());
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text("Wallet balance kam hai!")));
        setState(() => _isSaving = false);
        return;
      }

      Map<String, int> betBreakdown = {};
      List<String> listStrs = [];

      for (var jodi in generatedJodis) {
        betBreakdown[jodi] = (betBreakdown[jodi] ?? 0) + amountPerJodi;
        listStrs.add("$jodi (₹$amountPerJodi)");
      }

      Map<String, dynamic> gameData = {
        "userMobile": currentLoggedInUserMobile,
        "userName": currentLoggedInUserName,
        "market": widget.market.name,
        "hindiMarket": widget.market.hindiName,
        "type": "Jodi",
        "subType": "Crossing",
        "numbers": listStrs.join(", "),
        "betMap": betBreakdown,
        "amount": calculatedTotalAmount,
        "status": "Pending",
        "time": DateTime.now().toString().substring(11, 16),
        "date": "${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}",
        "timestamp": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('bets').add(gameData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.green, content: Text("Safal! $totalJodisCount Crossing Jodiyan (₹$calculatedTotalAmount) lag gayi.")),
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
      appBar: AppBar(title: Text("${widget.market.hindiName} - Crossing")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Crossing Numbers & Amount", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _set1Controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Set 1 Numbers (Jaise: 2345)", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _set2Controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Set 2 Numbers (Jaise: 5940)", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Har Jodi Ka Amount (₹) (Jaise: 10)", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                        icon: const Icon(Icons.shuffle, color: Colors.black),
                        label: const Text("GENERATE CROSSING JODIS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        onPressed: _generateCrossingPairs,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (generatedJodis.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.withOpacity(0.3))),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Jodiyan: $totalJodisCount", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                        Text("Kul Rashi: ₹ $calculatedTotalAmount", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 17)),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: generatedJodis.map((j) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.amber.withOpacity(0.4))),
                        child: Text(j, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                        onPressed: _isSaving ? null : _submitCrossingBids,
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("SUBMIT CROSSING BID", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// ----------------- 11. MONTH-WISE MASTER CHART SCREEN -----------------
class CombinedAllMarketsChartScreen extends StatefulWidget {
  @override
  _CombinedAllMarketsChartScreenState createState() => _CombinedAllMarketsChartScreenState();
}

class _CombinedAllMarketsChartScreenState extends State<CombinedAllMarketsChartScreen> {
  String selectedMonthYear = "";

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    selectedMonthYear = "${now.month.toString().padLeft(2, '0')}-${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    List<String> monthOptions = [];
    for (int i = 0; i < 6; i++) {
      DateTime prev = DateTime(now.year, now.month - i, 1);
      monthOptions.add("${prev.month.toString().padLeft(2, '0')}-${prev.year}");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("DisawarKing Master Chart"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: const Color(0xFF1E293B),
                value: selectedMonthYear,
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                icon: const Icon(Icons.calendar_month, color: Colors.amber, size: 20),
                items: monthOptions.map((String m) {
                  return DropdownMenuItem<String>(
                    value: m,
                    child: Text(m),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedMonthYear = val);
                },
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('results_history').snapshots(),
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
              String monthYear = data['monthYear'] ?? "";

              if (monthYear.isNotEmpty && monthYear != selectedMonthYear) {
                continue;
              }

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

          dates.sort((a, b) {
            int numA = int.tryParse(a) ?? 0;
            int numB = int.tryParse(b) ?? 0;
            return numA.compareTo(numB);
          });

          if (dates.isEmpty) {
            return Center(
              child: Text("Month ($selectedMonthYear) me Chart ka koi record nahi hai.", style: const TextStyle(color: Colors.white54, fontSize: 14)),
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

// ----------------- 12. WALLET SCREEN -----------------
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
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF312E81), Color(0xFF1E293B)])),
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(currentLoggedInUserMobile).snapshots(),
                builder: (context, snapshot) {
                  double depBal = 0.0;
                  double winBal = 0.0;
                  double totalBal = 0.0;

                  if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                    var d = snapshot.data!.data() as Map<String, dynamic>?;
                    var bMap = extractUserBalances(d);
                    depBal = bMap['deposit'] ?? 0.0;
                    winBal = bMap['winning'] ?? 0.0;
                    totalBal = bMap['total'] ?? 0.0;
                  }

                  return Column(
                    children: [
                      const Text("Total Available Balance", style: TextStyle(color: Colors.white60, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text("₹ ${totalBal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white12)),
                              child: Column(
                                children: [
                                  const Text("Deposit Wallet (गेम खेलें)", style: TextStyle(color: Colors.white54, fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Text("₹ ${depBal.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.withOpacity(0.4))),
                              child: Column(
                                children: [
                                  const Text("Winning Wallet (निकासी)", style: TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text("₹ ${winBal.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("नियम व शर्तें (Payment Rules):", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                  SizedBox(height: 8),
                  Text("• नए यूजर को 1st डिपॉजिट पर 5% का सीधा बोनस दिया जाएगा।", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text("• केवल Winning Wallet (जीती हुई राशि) ही निकाली जा सकती है।", style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text("• कम से कम निकासी (Withdrawal): ₹500", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text("• निकासी का समय: सुबह 8:00 AM से दोपहर 2:00 PM तक", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text("• ₹5,000 से ऊपर की राशि केवल बैंक अकाउंट में ही ट्रांसफर की जाएगी।", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  SizedBox(height: 10),
                  Text("⚡ निकासी अनुरोध (Withdrawal Request) सबमिट करने के 30 मिनट के अंदर राशि ट्रांसफर कर दी जाएगी।", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ----------------- 13. ADD MONEY SCREEN -----------------
class AddMoneyPaymentScreen extends StatefulWidget {
  @override
  _AddMoneyPaymentScreenState createState() => _AddMoneyPaymentScreenState();
}

class _AddMoneyPaymentScreenState extends State<AddMoneyPaymentScreen> {
  final _amount = TextEditingController();
  final _utr = TextEditingController();
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
    final String dynamicQrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=upi://pay%3Fpa=${Uri.encodeComponent(dynamicUpiId)}%26pn=DisawarKing%26cu=INR";

    return Scaffold(
      appBar: AppBar(title: const Text("Add Money (Deposit)")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.greenAccent)),
              child: const Row(
                children: [
                  Icon(Icons.stars, color: Colors.greenAccent, size: 24),
                  SizedBox(width: 8),
                  Expanded(child: Text("1st Deposit Offer: नए यूजर को पहले डिपॉजिट पर 5% अतिरिक्त बोनस मिलेगा!", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            Image.network(dynamicQrUrl, height: 200, width: 200),
            const SizedBox(height: 8),
            Text("UPI ID: $dynamicUpiId", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
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

// ----------------- 14. WITHDRAW SCREEN -----------------
class WithdrawRequestScreen extends StatefulWidget {
  @override
  _WithdrawRequestScreenState createState() => _WithdrawRequestScreenState();
}

class _WithdrawRequestScreenState extends State<WithdrawRequestScreen> {
  final _amount = TextEditingController();
  final _upiController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _accountNumController = TextEditingController();
  final _ifscController = TextEditingController();

  int _selectedMethod = 0;
  bool _isSaving = false;

  void _submitWithdraw() async {
    DateTime now = DateTime.now();
    if (now.hour < 8 || now.hour >= 14) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text("निकासी का समय समाप्त", style: TextStyle(color: Colors.redAccent)),
          content: const Text(
            "निकासी अनुरोध करने का समय केवल सुबह 8:00 AM से दोपहर 2:00 PM तक है।\n\nकृपया सुबह 8:00 AM के बाद प्रयास करें।",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () => Navigator.pop(ctx),
              child: const Text("ठीक है", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
      return;
    }

    double amt = double.tryParse(_amount.text) ?? 0.0;
    if (amt < 500) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("कम से कम ₹500 की निकासी करें!")));
      return;
    }

    if (amt > 5000 && _selectedMethod == 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text("बैंक ट्रांसफर अनिवार्य", style: TextStyle(color: Colors.amber)),
          content: const Text(
            "₹5,000 से ऊपर की राशि केवल बैंक अकाउंट में ही ट्रांसफर की जाएगी।\n\nकृपया 'Bank Transfer' का विकल्प चुनें और अपनी बैंक जानकारी भरें।",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _selectedMethod = 1);
              },
              child: const Text("Bank Transfer चुनें", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
      return;
    }

    String withdrawMode = "";
    String paymentDetails = "";

    if (_selectedMethod == 0) {
      if (_upiController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("अपनी UPI ID भरें!")));
        return;
      }
      withdrawMode = "UPI Transfer";
      paymentDetails = "UPI ID: ${_upiController.text.trim()}";
    } else {
      String bName = _bankNameController.text.trim();
      String hName = _holderNameController.text.trim();
      String accNum = _accountNumController.text.trim();
      String ifsc = _ifscController.text.trim().toUpperCase();

      if (bName.isEmpty || hName.isEmpty || accNum.isEmpty || ifsc.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("कृपया बैंक की पूरी जानकारी भरें!")));
        return;
      }
      withdrawMode = "Bank Transfer";
      paymentDetails = "Bank: $bName | A/C Holder: $hName | A/C: $accNum | IFSC: $ifsc";
    }

    setState(() => _isSaving = true);
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(currentLoggedInUserMobile).get();
      var bMap = extractUserBalances(userDoc.data());
      double winBal = bMap['winning'] ?? 0.0;

      if (amt > winBal) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text("निकासी अस्वीकृत", style: TextStyle(color: Colors.redAccent)),
            content: Text(
              "आप केवल अपनी जीती हुई राशि (Winning Balance: ₹${winBal.toStringAsFixed(2)}) ही निकाल सकते हैं।\n\nडिपॉजिट की गई राशि से गेम खेलें और जीतें!",
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () => Navigator.pop(ctx),
                child: const Text("समझ गया", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        );
        setState(() => _isSaving = false);
        return;
      }

      await FirebaseFirestore.instance.collection('withdrawals').add({
        "userMobile": currentLoggedInUserMobile,
        "userName": currentLoggedInUserName,
        "amount": amt,
        "method": withdrawMode,
        "account": paymentDetails,
        "date": "${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}",
        "time": "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
        "status": "Pending",
        "timestamp": FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('users').doc(currentLoggedInUserMobile).update({
        'winningBalance': FieldValue.increment(-amt),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.green, content: Text("निकासी अनुरोध भेज दिया गया! 30 मिनट में राशि ट्रांसफर हो जाएगी।")),
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
      appBar: AppBar(title: const Text("पैसे निकालें (Withdraw)")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.amberAccent, size: 24),
                      SizedBox(width: 8),
                      Text("निकासी का समय: सुबह 8:00 AM से दोपहर 2:00 PM तक", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text("• केवल जीती हुई राशि (Winning Wallet) ही निकाली जा सकती है।", style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  SizedBox(height: 4),
                  Text("• ₹5,000 से ऊपर की राशि केवल बैंक अकाउंट में ही ट्रांसफर की जाएगी।", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "निकासी राशि (Amount - Min ₹500)", border: OutlineInputBorder()),
              onChanged: (val) {
                double? a = double.tryParse(val);
                if (a != null && a > 5000 && _selectedMethod == 0) {
                  setState(() => _selectedMethod = 1);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text("UPI ID", style: TextStyle(fontWeight: FontWeight.bold))),
                    selected: _selectedMethod == 0,
                    selectedColor: Colors.amber,
                    onSelected: (val) {
                      double a = double.tryParse(_amount.text.trim()) ?? 0.0;
                      if (a > 5000) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("₹5,000 से ऊपर केवल बैंक अकाउंट में ट्रांसफर होगा!")));
                        return;
                      }
                      setState(() => _selectedMethod = 0);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text("Bank Transfer", style: TextStyle(fontWeight: FontWeight.bold))),
                    selected: _selectedMethod == 1,
                    selectedColor: Colors.amber,
                    onSelected: (val) => setState(() => _selectedMethod = 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedMethod == 0) ...[
              TextField(
                controller: _upiController,
                decoration: const InputDecoration(labelText: "अपनी UPI ID डालें (जैसे: 9876543210@ybl)", border: OutlineInputBorder()),
              ),
            ] else ...[
              TextField(controller: _bankNameController, decoration: const InputDecoration(labelText: "बैंक का नाम (Bank Name)", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: _holderNameController, decoration: const InputDecoration(labelText: "खाताधारक का नाम (Bank Me Jo Naam Hai)", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: _accountNumController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "बैंक खाता संख्या (Account Number)", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: _ifscController, decoration: const InputDecoration(labelText: "IFSC कोड", border: OutlineInputBorder())),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                onPressed: _isSaving ? null : _submitWithdraw,
                child: _isSaving ? const CircularProgressIndicator(color: Colors.black) : const Text("निकासी अनुरोध भेजें (SUBMIT)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ----------------- REFER & EARN SCREEN -----------------
class ReferAndEarnScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Refer & Earn")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.card_giftcard, size: 60, color: Colors.amber),
                  const SizedBox(height: 12),
                  const Text("Aapka Referral Code", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Text(
                      currentLoggedInUserMobile,
                      style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Jab aapka dost aapke referral code se register karega, toh uski har ek Loss Bidding par 7% Commission sidhe aapke wallet me automatic transfer ho jayega!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                      icon: const Icon(Icons.share, color: Colors.white),
                      label: const Text("SHARE ON WHATSAPP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        String shareMsg = "Disawar King App download karein aur khelein! Register karte waqt mera Referral Code dalein: $currentLoggedInUserMobile\nDownload App: https://disawarking.app";
                        openWhatsAppChat(message: shareMsg);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- 16. MASTER ADMIN PANEL -----------------
class MasterAdminPanelScreen extends StatefulWidget {
  @override
  _MasterAdminPanelScreenState createState() => _MasterAdminPanelScreenState();
}

class _MasterAdminPanelScreenState extends State<MasterAdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isImporting = false;

  final _whatsappCtrl = TextEditingController(text: dynamicWhatsAppNumber);
  final _upiCtrl = TextEditingController(text: dynamicUpiId);
  final _noticeCtrl = TextEditingController(text: dynamicNoticeText);
  final _apkUrlCtrl = TextEditingController(text: dynamicLatestApkUrl);
  final _termsCtrl = TextEditingController(text: dynamicTermsText);
  bool _emergencyLock = dynamicEmergencyLock;
  bool _isSavingSettings = false;

  final Map<String, TextEditingController> _closeTimeControllers = {};
  final Map<String, TextEditingController> _resultTimeControllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    dynamicMarketTimings.forEach((market, data) {
      _closeTimeControllers[market] = TextEditingController(text: data['closeTimeStr']);
      _resultTimeControllers[market] = TextEditingController(text: data['resultTimeStr']);
    });
  }

  void _saveRemoteSettings() async {
    setState(() => _isSavingSettings = true);
    try {
      Map<String, dynamic> updatedTimings = {};
      dynamicMarketTimings.forEach((market, data) {
        String cTime = _closeTimeControllers[market]?.text.trim() ?? data['closeTimeStr'];
        var parsed = parseTimeString(cTime);

        updatedTimings[market] = {
          'closeHour': parsed['hour'],
          'closeMin': parsed['min'],
          'closeTimeStr': cTime,
          'resultTimeStr': _resultTimeControllers[market]?.text.trim() ?? data['resultTimeStr'],
        };
      });

      await FirebaseFirestore.instance.collection('app_settings').doc('config').set({
        'whatsapp': _whatsappCtrl.text.trim(),
        'upi': _upiCtrl.text.trim(),
        'notice': _noticeCtrl.text.trim(),
        'emergencyLock': _emergencyLock,
        'apkUrl': _apkUrlCtrl.text.trim(),
        'termsText': _termsCtrl.text.trim(),
        'marketTimings': updatedTimings,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.green, content: Text("Settings & Timings Live Update Ho Gaye! Timer Synchronized.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSavingSettings = false);
    }
  }

  void _importPastChartData() async {
    setState(() => _isImporting = true);

    final List<Map<String, dynamic>> rawChart = [
      {"date": "01", "DLBZ": "58", "SRGN": "89", "FRBD": "45", "GZBD": "86", "GALI": "81", "DSWR": ""},
      {"date": "02", "DLBZ": "52", "SRGN": "54", "FRBD": "19", "GZBD": "85", "GALI": "96", "DSWR": "69"},
      {"date": "03", "DLBZ": "88", "SRGN": "20", "FRBD": "08", "GZBD": "32", "GALI": "77", "DSWR": "57"},
      {"date": "04", "DLBZ": "18", "SRGN": "01", "FRBD": "02", "GZBD": "95", "GALI": "26", "DSWR": "95"},
      {"date": "05", "DLBZ": "44", "SRGN": "02", "FRBD": "30", "GZBD": "68", "GALI": "37", "DSWR": "59"},
      {"date": "06", "DLBZ": "71", "SRGN": "25", "FRBD": "88", "GZBD": "69", "GALI": "94", "DSWR": "78"},
      {"date": "07", "DLBZ": "61", "SRGN": "17", "FRBD": "02", "GZBD": "02", "GALI": "10", "DSWR": "67"},
      {"date": "08", "DLBZ": "84", "SRGN": "83", "FRBD": "71", "GZBD": "93", "GALI": "64", "DSWR": "92"},
      {"date": "09", "DLBZ": "18", "SRGN": "15", "FRBD": "29", "GZBD": "93", "GALI": "69", "DSWR": "54"},
      {"date": "10", "DLBZ": "52", "SRGN": "12", "FRBD": "15", "GZBD": "72", "GALI": "40", "DSWR": "93"},
      {"date": "11", "DLBZ": "59", "SRGN": "32", "FRBD": "72", "GZBD": "98", "GALI": "34", "DSWR": "40"},
      {"date": "12", "DLBZ": "81", "SRGN": "42", "FRBD": "65", "GZBD": "16", "GALI": "35", "DSWR": "46"},
      {"date": "13", "DLBZ": "55", "SRGN": "48", "FRBD": "74", "GZBD": "47", "GALI": "72", "DSWR": "02"},
      {"date": "14", "DLBZ": "86", "SRGN": "34", "FRBD": "30", "GZBD": "50", "GALI": "87", "DSWR": "35"},
      {"date": "15", "DLBZ": "46", "SRGN": "28", "FRBD": "24", "GZBD": "19", "GALI": "83", "DSWR": "89"},
      {"date": "16", "DLBZ": "68", "SRGN": "94", "FRBD": "21", "GZBD": "42", "GALI": "91", "DSWR": "31"},
      {"date": "17", "DLBZ": "99", "SRGN": "50", "FRBD": "38", "GZBD": "34", "GALI": "73", "DSWR": "90"},
      {"date": "18", "DLBZ": "84", "SRGN": "38", "FRBD": "36", "GZBD": "03", "GALI": "50", "DSWR": "49"},
      {"date": "19", "DLBZ": "24", "SRGN": "20", "FRBD": "21", "GZBD": "86", "GALI": "07", "DSWR": "35"},
      {"date": "20", "DLBZ": "47", "SRGN": "80", "FRBD": "84", "GZBD": "24", "GALI": "66", "DSWR": "32"},
      {"date": "21", "DLBZ": "62", "SRGN": "08", "FRBD": "71", "GZBD": "70", "GALI": "32", "DSWR": "01"},
      {"date": "22", "DLBZ": "03", "SRGN": "98", "FRBD": "42", "GZBD": "50", "GALI": "00", "DSWR": "73"},
      {"date": "23", "DLBZ": "92", "SRGN": "10", "FRBD": "00", "GZBD": "42", "GALI": "02", "DSWR": "35"},
      {"date": "24", "DLBZ": "27", "SRGN": "48", "FRBD": "38", "GZBD": "32", "GALI": "90", "DSWR": "26"},
      {"date": "25", "DLBZ": "44", "SRGN": "68", "FRBD": "08", "GZBD": "63", "GALI": "37", "DSWR": "86"},
      {"date": "26", "DLBZ": "55", "SRGN": "43", "FRBD": "09", "GZBD": "18", "GALI": "66", "DSWR": "48"},
      {"date": "27", "DLBZ": "35", "SRGN": "07", "FRBD": "61", "GZBD": "66", "GALI": "64", "DSWR": "81"},
      {"date": "28", "DLBZ": "66", "SRGN": "90", "FRBD": "58", "GZBD": "03", "GALI": "03", "DSWR": "49"},
      {"date": "29", "DLBZ": "", "SRGN": "", "FRBD": "", "GZBD": "", "GALI": "", "DSWR": "43"},
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
            var docRef = historyCol.doc("2026-09_${dt}_$market");
            batch.set(docRef, {
              'market': market,
              'number': num,
              'date': dt,
              'monthYear': "09-2026",
              'timestamp': Timestamp.fromDate(fakeTimestamp),
            });
          }
        }

        addEntry("DELHI BAZAR", row['DLBZ']);
        addEntry("SHREE GANESH", row['SRGN']);
        addEntry("FARIDABAD", row['FRBD']);
        addEntry("GHAZIABAD", row['GZBD']);
        addEntry("GALI", row['GALI']);
        addEntry("DISAWAR", row['DSWR']);
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.green, content: Text("29 Dinon Ka Pura Chart Upload Ho Gaya!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  String _getDefaultGameDate(String marketName) {
    DateTime now = DateTime.now();
    if (marketName == "GALI" && now.hour < 4) {
      DateTime yesterday = now.subtract(const Duration(days: 1));
      return yesterday.day.toString().padLeft(2, '0');
    }
    return now.day.toString().padLeft(2, '0');
  }

  void _clearWrongDateResult(BuildContext context, String marketName) {
    final TextEditingController dateCtrl = TextEditingController(text: "30");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text("Galat Entry Hatao: $marketName", style: const TextStyle(color: Colors.redAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Jis tarikh me se result hatana hai, wo tarikh dalein. Us mahine ke chart se wo entry delete ho jayegi.",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: dateCtrl,
              keyboardType: TextInputType.number,
              maxLength: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber),
              decoration: const InputDecoration(labelText: "Tarikh (Jaise: 30)", border: OutlineInputBorder(), counterText: ""),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              String dt = dateCtrl.text.trim();
              if (dt.isEmpty) return;
              Navigator.pop(ctx);

              DateTime now = DateTime.now();
              String curMonthYear = "${now.month.toString().padLeft(2, '0')}-${now.year}";

              try {
                await FirebaseFirestore.instance.collection('results_history').doc("${curMonthYear}_${dt}_$marketName").delete();
                await FirebaseFirestore.instance.collection('results_history').doc("${dt}_$marketName").delete();

                var liveDoc = await FirebaseFirestore.instance.collection('results').doc(marketName).get();
                if (liveDoc.exists && liveDoc.data()?['date'] == dt) {
                  await FirebaseFirestore.instance.collection('results').doc(marketName).set({
                    'number': 'XX',
                    'date': '',
                  });
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: Colors.green, content: Text("$marketName ki Tarikh $dt wali entry safalta se hata di gayi!")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("Error: $e")));
              }
            },
            child: const Text("HATAO (DELETE)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _declareResultAndDistribute(BuildContext context, String marketName) async {
    final TextEditingController numCtrl = TextEditingController();
    final TextEditingController dateCtrl = TextEditingController(text: _getDefaultGameDate(marketName));

    var currentResultDoc = await FirebaseFirestore.instance.collection('results').doc(marketName).get();
    String? existingResult = currentResultDoc.data()?['number']?.toString();
    bool isReDeclaration = existingResult != null && existingResult != "XX" && existingResult.isNotEmpty;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isProcessing = false;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: Text(
                isReDeclaration ? "CORRECT RESULT: $marketName" : "Result Declare: $marketName",
                style: TextStyle(color: isReDeclaration ? Colors.orangeAccent : Colors.amber),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isReDeclaration) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.redAccent)),
                      child: Text(
                        "⚠️ Is Market ka pehle se '$existingResult' khula hai.\n\nNaya number save karne par purana galat balance wapas katega aur naye winners ko rashi mil jayegi.",
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: dateCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                          decoration: const InputDecoration(labelText: "Tarikh (Date)", border: OutlineInputBorder(), counterText: ""),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: numCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.amber),
                          decoration: const InputDecoration(labelText: "Result (00-99)", border: OutlineInputBorder(), counterText: ""),
                        ),
                      ),
                    ],
                  ),
                  if (isProcessing) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(color: Colors.amber),
                    const SizedBox(height: 8),
                    const Text("Result Update Ho Raha Hai...", style: TextStyle(color: Colors.amberAccent, fontSize: 12)),
                  ]
                ],
              ),
              actions: [
                if (!isProcessing) ...[
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: isReDeclaration ? Colors.orange : Colors.green),
                    onPressed: () async {
                      String result = numCtrl.text.trim();
                      String chosenDate = dateCtrl.text.trim();

                      if (result.length != 2) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pura 2 anko ka number dalein (jaise 22)!")));
                        return;
                      }
                      if (chosenDate.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tarikh (Date) dalein!")));
                        return;
                      }

                      setDialogState(() => isProcessing = true);
                      var firestore = FirebaseFirestore.instance;
                      DateTime now = DateTime.now();
                      String curMonthYear = "${now.month.toString().padLeft(2, '0')}-${now.year}";

                      try {
                        await firestore.collection('results').doc(marketName).set({
                          'number': result,
                          'date': chosenDate,
                          'declaredAt': FieldValue.serverTimestamp(),
                          'wasCorrected': isReDeclaration,
                        });

                        await firestore.collection('results_history').doc("${curMonthYear}_${chosenDate}_$marketName").set({
                          'market': marketName,
                          'number': result,
                          'date': chosenDate,
                          'monthYear': curMonthYear,
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        var marketBets = await firestore
                            .collection('bets')
                            .where('market', isEqualTo: marketName)
                            .get();

                        if (isReDeclaration && existingResult != result) {
                          for (var doc in marketBets.docs) {
                            var data = doc.data();
                            String st = data['status']?.toString() ?? '';
                            if (st.contains('Won')) {
                              double prevWon = ((data['winningAmount'] ?? 0) as num).toDouble();
                              String uMob = data['userMobile'] ?? '';
                              if (prevWon > 0 && uMob.isNotEmpty) {
                                try {
                                  await firestore.collection('users').doc(uMob).update({
                                    'winningBalance': FieldValue.increment(-prevWon),
                                  });
                                } catch (_) {}
                              }
                            }
                            await doc.reference.update({
                              'status': 'Pending',
                              'winningAmount': 0.0,
                            });
                          }

                          var oldComms = await firestore
                            .collection('referral_commissions')
                            .where('market', isEqualTo: marketName)
                            .get();

                          for (var cDoc in oldComms.docs) {
                            double comm = ((cDoc.data()['commission'] ?? 0) as num).toDouble();
                            String refMob = cDoc.data()['toReferrer'] ?? '';
                            if (comm > 0 && refMob.isNotEmpty) {
                              try {
                                await firestore.collection('users').doc(refMob).update({
                                  'winningBalance': FieldValue.increment(-comm),
                                  'referralEarnings': FieldValue.increment(-comm),
                                });
                              } catch (_) {}
                            }
                            await cDoc.reference.delete();
                          }
                        }

                        String andarDigit = result.substring(0, 1);
                        String baharDigit = result.substring(1, 2);

                        var freshBets = await firestore
                            .collection('bets')
                            .where('market', isEqualTo: marketName)
                            .get();

                        int winnersCount = 0;

                        for (var doc in freshBets.docs) {
                          var bet = doc.data();
                          String type = bet['type'] ?? '';
                          String userMob = bet['userMobile'] ?? '';
                          String numbersStr = bet['numbers']?.toString() ?? '';
                          double betAmt = ((bet['amount'] ?? 0) as num).toDouble();
                          double winAmount = 0.0;

                          if (type == "Jodi") {
                            if (bet.containsKey('betMap') && bet['betMap'] != null) {
                              Map<String, dynamic> betMap = Map<String, dynamic>.from(bet['betMap']);
                              if (betMap.containsKey(result)) {
                                int betPoints = (betMap[result] as num).toInt();
                                winAmount += (betPoints * 90).toDouble();
                              }
                            } else if (numbersStr.contains(result)) {
                              RegExp regex = RegExp('$result\\s*\\(₹?([0-9]+)\\)');
                              var match = regex.firstMatch(numbersStr);
                              int pts = match != null ? int.parse(match.group(1)!) : 0;
                              if (pts > 0) {
                                winAmount += (pts * 90).toDouble();
                              }
                            }
                          }

                          if (type == "Harup") {
                            if (bet.containsKey('andarMap') && bet['andarMap'] != null) {
                              Map<String, dynamic> aMap = Map<String, dynamic>.from(bet['andarMap']);
                              if (aMap.containsKey(andarDigit)) {
                                int pts = (aMap[andarDigit] as num).toInt();
                                winAmount += (pts * 9.0);
                              }
                            }
                            if (bet.containsKey('baharMap') && bet['baharMap'] != null) {
                              Map<String, dynamic> bMap = Map<String, dynamic>.from(bet['baharMap']);
                              if (bMap.containsKey(baharDigit)) {
                                int pts = (bMap[baharDigit] as num).toInt();
                                winAmount += (pts * 9.0);
                              }
                            }
                          }

                          if (winAmount > 0 && userMob.isNotEmpty) {
                            winnersCount++;
                            try {
                              await firestore.collection('users').doc(userMob).set({
                                'winningBalance': FieldValue.increment(winAmount),
                              }, SetOptions(merge: true));

                              await doc.reference.update({
                                'status': 'Won ₹${winAmount.toStringAsFixed(0)}',
                                'winningAmount': winAmount,
                              });
                            } catch (e) {
                              debugPrint("Credit Error: $e");
                            }
                          } else {
                            await doc.reference.update({'status': 'Lost'});

                            try {
                              var uDoc = await firestore.collection('users').doc(userMob).get();
                              if (uDoc.exists) {
                                String refMobile = uDoc.data()?['referredBy'] ?? '';
                                if (refMobile.isNotEmpty && betAmt > 0) {
                                  double commission = (betAmt * 0.07);
                                  await firestore.collection('users').doc(refMobile).set({
                                    'winningBalance': FieldValue.increment(commission),
                                    'referralEarnings': FieldValue.increment(commission),
                                  }, SetOptions(merge: true));

                                  await firestore.collection('referral_commissions').add({
                                    'fromUser': userMob,
                                    'toReferrer': refMobile,
                                    'betAmount': betAmt,
                                    'commission': commission,
                                    'market': marketName,
                                    'timestamp': FieldValue.serverTimestamp(),
                                  });
                                }
                              }
                            } catch (e) {
                              debugPrint("Commission Error: $e");
                            }
                          }
                        }

                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text("$marketName Result Tarikh $chosenDate par '$result' Update Ho Gaya! ($winnersCount Winners)"),
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => isProcessing = false);
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text("Error Aaya", style: TextStyle(color: Colors.redAccent)),
                            content: Text("$e"),
                            actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("OK"))],
                          ),
                        );
                      }
                    },
                    child: Text(isReDeclaration ? "SUDHAR & PAY" : "Declare & Pay", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ]
              ],
            );
          },
        );
      },
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
          isScrollable: true,
          tabs: const [
            Tab(text: "Results"),
            Tab(text: "Live Bets"),
            Tab(text: "Deposits"),
            Tab(text: "Withdrawals"),
            Tab(text: "Settings"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: RESULTS
          ListView(
            padding: const EdgeInsets.all(12),
            children: [
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
                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('results').doc(m.name).snapshots(),
                  builder: (context, resSnap) {
                    String curNum = "XX";
                    if (resSnap.hasData && resSnap.data!.exists) {
                      curNum = resSnap.data!['number'] ?? "XX";
                    }

                    return Card(
                      color: const Color(0xFF1E293B),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text("${m.hindiName} (${m.name})", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                          subtitle: Text("Timing: ${m.resultTimeStr} | Current: $curNum"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 22),
                                tooltip: "Galat Tarikh Ka Entry Hatao",
                                onPressed: () => _clearWrongDateResult(context, m.name),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: curNum != "XX" ? Colors.orange : const Color(0xFF16A34A),
                                ),
                                onPressed: () => _declareResultAndDistribute(context, m.name),
                                child: Text(
                                  curNum != "XX" ? "Change ($curNum)" : "Declare",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ],
          ),

          // TAB 2: LIVE BETS
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

          // TAB 3: DEPOSITS
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
                                var uDoc = await FirebaseFirestore.instance.collection('users').doc(mob).get();
                                bool hasDepositedBefore = false;
                                if (uDoc.exists) {
                                  hasDepositedBefore = uDoc.data()?['hasDepositedBefore'] ?? false;
                                }

                                double finalCredit = amt;
                                String bonusMsg = "";

                                if (!hasDepositedBefore) {
                                  double bonus = (amt * 0.05);
                                  finalCredit = amt + bonus;
                                  bonusMsg = " (+5% Bonus ₹$bonus)";
                                }

                                await docs[i].reference.update({'status': 'Approved'});
                                await FirebaseFirestore.instance.collection('users').doc(mob).set({
                                  'depositBalance': FieldValue.increment(finalCredit),
                                  'hasDepositedBefore': true,
                                }, SetOptions(merge: true));

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(backgroundColor: Colors.green, content: Text("₹$finalCredit Approved$bonusMsg & Deposit Wallet Me Jod Diya!")),
                                );
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

          // TAB 4: WITHDRAWALS
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('withdrawals').orderBy('timestamp', descending: true).limit(50).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.amber));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Koi Withdrawal request nahi hai.", style: TextStyle(color: Colors.white54)));
              }

              var wDocs = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: wDocs.length,
                itemBuilder: (ctx, i) {
                  var w = wDocs[i].data() as Map<String, dynamic>;
                  String status = w['status'] ?? 'Pending';
                  double amt = ((w['amount'] ?? 0) as num).toDouble();
                  String mob = w['userMobile'] ?? '';
                  String name = w['userName'] ?? 'User';
                  String method = w['method'] ?? 'Transfer';
                  String accountDetails = w['account'] ?? 'N/A';
                  String date = w['date'] ?? '';
                  String time = w['time'] ?? '';

                  return Card(
                    color: const Color(0xFF1E293B),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("₹ ${amt.toStringAsFixed(0)}", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 20)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: status == "Paid" ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: status == "Paid" ? Colors.greenAccent : Colors.orangeAccent),
                                ),
                                child: Text(status, style: TextStyle(color: status == "Paid" ? Colors.greenAccent : Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text("User: $name (Mobile: $mob)", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text("Mode: $method", style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              accountDetails,
                              style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Req Time: $date $time", style: const TextStyle(color: Colors.white38, fontSize: 11)),
                              if (status == "Pending")
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                                  icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                                  label: const Text("MARK AS PAID", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  onPressed: () async {
                                    await wDocs[i].reference.update({'status': 'Paid'});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(backgroundColor: Colors.green, content: Text("₹$amt Mark ho gaya as Paid!")),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // TAB 5: REMOTE SETTINGS
          ListView(
            padding: const EdgeInsets.all(14),
            children: [
              Card(
                color: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("1. Live Market Timings (Close & Result)", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      const Text("Yahan se time badal kar Save karein, sabhi users ke app par turant naya time aur live timer count start ho jayega.", style: TextStyle(color: Colors.white54, fontSize: 11)),
                      const Divider(color: Colors.white12, height: 16),
                      ...appMarkets.map((m) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${m.hindiName} (${m.name})", style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _closeTimeControllers[m.name],
                                      decoration: const InputDecoration(labelText: "Close Time (e.g. 09:05 AM)", border: OutlineInputBorder(), isDense: true),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _resultTimeControllers[m.name],
                                      decoration: const InputDecoration(labelText: "Result Time (e.g. 09:10 AM)", border: OutlineInputBorder(), isDense: true),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      }),
                      const Divider(color: Colors.white12, height: 20),
                      const Text("2. Contact & Payment Info", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _whatsappCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: "WhatsApp Support Number (Jaise 917409989270)", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _upiCtrl,
                        decoration: const InputDecoration(labelText: "Deposit UPI ID (Jaise 9761630128@ybl)", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _noticeCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: "Home Alert / Notice (Khali chhodenge toh nahi dikhega)", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _apkUrlCtrl,
                        decoration: const InputDecoration(labelText: "Auto-Update APK Direct Link (Optional)", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      const Text("3. Terms & Conditions (नियम एवं शर्तें)", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _termsCtrl,
                        maxLines: 6,
                        decoration: const InputDecoration(labelText: "App Rules / Terms (Yahan edit karein)", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile(
                        title: const Text("Emergency Game Lock (Maintenance Mode)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        subtitle: const Text("On karne par sabhi markets me nayi bid lagna temporary pause ho jayega", style: TextStyle(color: Colors.white54, fontSize: 11)),
                        value: _emergencyLock,
                        activeColor: Colors.amber,
                        onChanged: (val) => setState(() => _emergencyLock = val),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                          icon: _isSavingSettings
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.cloud_done, color: Colors.white),
                          label: Text(
                            _isSavingSettings ? "SAVING..." : "SAVE SETTINGS LIVE",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          onPressed: _isSavingSettings ? null : _saveRemoteSettings,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ----------------- 17. MY PLAYED GAME SCREEN -----------------
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

// ----------------- 18. WITHDRAWAL LIST SCREEN -----------------
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
              String m = item['method'] ?? 'Transfer';
              String st = item['status'] ?? 'Pending';
              Color stCol = st == "Paid" ? Colors.greenAccent : Colors.amber;

              return Card(
                color: const Color(0xFF1E293B),
                child: ListTile(
                  title: Text("₹ ${item['amount'] ?? 0} ($m)", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text("Details: ${item['account'] ?? ''}\nStatus: $st", style: TextStyle(color: stCol)),
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

// ----------------- 19. TERMS & CONDITIONS SCREEN -----------------
class TermsAndConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("नियम एवं शर्तें")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          dynamicTermsText,
          style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.white70),
        ),
      ),
    );
  }
}
