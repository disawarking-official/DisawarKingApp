import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init: $e");
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
      home: LoginScreen(),
    );
  }
}

// ----------------- GLOBAL APP STATE & MARKETS CONFIG -----------------
double userWalletBalance = 0.0;
String currentLoggedInUserMobile = "";
String currentLoggedInUserName = "";
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

  bool isOpen() {
    DateTime now = DateTime.now();
    DateTime closeTime = DateTime(now.year, now.month, now.day, closeHour, closeMin);
    if (closeHour < 6 && now.hour >= 6) {
      closeTime = closeTime.add(const Duration(days: 1));
    }
    return now.isBefore(closeTime);
  }

  bool isWithin2Hours() {
    DateTime now = DateTime.now();
    DateTime closeTime = DateTime(now.year, now.month, now.day, closeHour, closeMin);
    if (closeHour < 6 && now.hour >= 6) {
      closeTime = closeTime.add(const Duration(days: 1));
    }
    Duration diff = closeTime.difference(now);
    return diff.inMinutes > 0 && diff.inMinutes <= 120;
  }
}

final List<MarketConfig> appMarkets = [
  MarketConfig(name: "DELHI BAZAR", hindiName: "दिल्ली बाजार", closeHour: 14, closeMin: 50, closeTimeStr: "02:50 PM", resultTimeStr: "03:15 PM"),
  MarketConfig(name: "SHREE GANESH", hindiName: "श्री गणेश", closeHour: 16, closeMin: 00, closeTimeStr: "04:00 PM", resultTimeStr: "04:30 PM"),
  MarketConfig(name: "FARIDABAD", hindiName: "फ़रीदाबाद", closeHour: 17, closeMin: 50, closeTimeStr: "05:50 PM", resultTimeStr: "06:15 PM"),
  MarketConfig(name: "GHAZIABAD", hindiName: "गाज़ियाबाद", closeHour: 21, closeMin: 20, closeTimeStr: "09:20 PM", resultTimeStr: "09:45 PM"),
  MarketConfig(name: "GALI", hindiName: "गली", closeHour: 23, closeMin: 25, closeTimeStr: "11:25 PM", resultTimeStr: "11:55 PM"),
  MarketConfig(name: "DISAWAR", hindiName: "दिसावर", closeHour: 4, closeMin: 00, closeTimeStr: "04:00 AM", resultTimeStr: "05:00 AM"),
];

List<Map<String, dynamic>> playedGamesHistory = [];
List<Map<String, dynamic>> withdrawalHistory = [];

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
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Aapka account nahi mila! Pehle 'Register Now' par click karein."),
          ),
        );
        return;
      }

      var data = userDoc.data()!;
      if (data['password'] != pass) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.redAccent, content: Text("Galat Password! Sahi password dalein.")),
        );
        return;
      }

      currentLoggedInUserMobile = mobile;
      currentLoggedInUserName = data['name'] ?? "User";
      userWalletBalance = (data['balance'] ?? 0).toDouble();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigationScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.redAccent, content: Text("Internet ya Server error! Dobara check karein.")),
      );
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

// ----------------- 2. DIRECT REGISTER SCREEN -----------------
class DirectRegisterScreen extends StatefulWidget {
  @override
  _DirectRegisterScreenState createState() => _DirectRegisterScreenState();
}

class _DirectRegisterScreenState extends State<DirectRegisterScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passController = TextEditingController();
  bool _isSaving = false;

  void _submitRegistration() async {
    String name = _nameController.text.trim();
    String mobile = _mobileController.text.trim();
    String pass = _passController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aapka pura naam dalein!")));
      return;
    }
    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("10 anko ka Mobile Number dalein!")));
      return;
    }
    if (pass.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password kam se kam 4 anko ka banayein!")));
      return;
    }

    setState(() => _isSaving = true);

    try {
      var checkUser = await FirebaseFirestore.instance.collection('users').doc(mobile).get();
      if (checkUser.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.redAccent, content: Text("Yeh Mobile pehle se registered hai! Seedha Login karein.")),
        );
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
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text("Registration Done", style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: Text(
            "Account ban gaya hai!\n\nNaam: $name\nUser ID: $mobile\n\nAb login karein.",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text("Login Karein", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.redAccent, content: Text("Database error: $e")),
      );
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
              const Text("Naam, Mobile aur Password bharein", style: TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 18),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Aapka Pura Naam",
                  prefixIcon: Icon(Icons.person, color: Colors.amber),
                  filled: true,
                  fillColor: Color(0xFF0F172A),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: "Mobile Number",
                  prefixIcon: Icon(Icons.phone, color: Colors.amber),
                  counterText: "",
                  filled: true,
                  fillColor: Color(0xFF0F172A),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Apna Password Banayein",
                  prefixIcon: Icon(Icons.lock, color: Colors.amber),
                  filled: true,
                  fillColor: Color(0xFF0F172A),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  onPressed: _isSaving ? null : _submitRegistration,
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Text("REGISTER KAREIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
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
  final _newPassController = TextEditingController();
  bool _isLoading = false;

  void _resetPassword() async {
    String mobile = _mobileController.text.trim();
    String newPass = _newPassController.text.trim();

    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("10 anko ka Mobile Number dalein!")));
      return;
    }
    if (newPass.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Naya Password kam se kam 4 anko ka ho!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(mobile).get();
      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.redAccent, content: Text("Yeh Mobile registered nahi hai! Pehle account banayein.")),
        );
        setState(() => _isLoading = false);
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(mobile).update({
        'password': newPass,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.green, content: Text("Password Safalta se Badal Diya Gaya! Ab Login karein.")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.redAccent, content: Text("Update nahi hua: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
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
              const Text("Apna Naya Password Banayein", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
              const SizedBox(height: 16),
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: "Registered Mobile Number",
                  prefixIcon: Icon(Icons.phone, color: Colors.amber),
                  counterText: "",
                  filled: true,
                  fillColor: Color(0xFF0F172A),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _newPassController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Naya Password Dalein",
                  prefixIcon: Icon(Icons.lock_reset, color: Colors.amber),
                  filled: true,
                  fillColor: Color(0xFF0F172A),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  onPressed: _isLoading ? null : _resetPassword,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Text("PASSWORD CHANGE KAREIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
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
                          Text(
                            currentLoggedInUserName.isEmpty ? "User" : currentLoggedInUserName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                          ),
                          Text(
                            "+91 $currentLoggedInUserMobile",
                            style: const TextStyle(fontSize: 12, color: Colors.amberAccent, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
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
                            Text("₹ ${userWalletBalance.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => openWhatsAppChat(message: "Namaste DisawarKing Support! Meri ID hai: $currentLoggedInUserMobile"),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 8)],
                          ),
                          child: const Icon(Icons.chat, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
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
                            Text("Sabhi markets ke taaza parinam", style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                        Icon(Icons.flash_on, color: Color(0xFFF59E0B), size: 30),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text("Aaj Ka Taaza Result", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white70)),
                  const SizedBox(height: 8),
                  ...appMarkets.map((market) {
                    return Card(
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text("${market.hindiName} (${market.name})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                        subtitle: Text("Close: ${market.closeTimeStr} | Result: ${market.resultTimeStr}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "84",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- 6. PLAY GAME MARKET LIST -----------------
class GameMarketsListScreen extends StatelessWidget {
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
                        Text("Last Time: ${market.closeTimeStr}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        Text("Result Time: ${market.resultTimeStr}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
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
                      child: const Text(
                        "CLOSED",
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
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
    if (totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kripya kisi number par points dalein!")));
      return;
    }

    if (widget.market.isWithin2Hours()) {
      for (int i = 0; i < 100; i++) {
        int val = int.tryParse(_controllers[i].text) ?? 0;
        if (val > 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text("Antim 2 ghante me max ₹200 hi lag sakta hai!"),
            ),
          );
          return;
        }
      }
    }

    if (totalAmount > userWalletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text("Wallet balance kam hai! Pehle Add Money karein.")),
      );
      return;
    }

    List<String> chosenNumbers = [];
    for (int i = 0; i < 100; i++) {
      int val = int.tryParse(_controllers[i].text) ?? 0;
      if (val > 0) {
        String numStr = (i + 1) < 10 ? "0${i + 1}" : "${i + 1}";
        chosenNumbers.add("$numStr (₹$val)");
      }
    }

    Map<String, dynamic> gameData = {
      "userMobile": currentLoggedInUserMobile,
      "userName": currentLoggedInUserName,
      "market": "${widget.market.hindiName} (${widget.market.name})",
      "type": "Jodi (01-100)",
      "numbers": chosenNumbers.join(", "),
      "amount": totalAmount,
      "time": DateTime.now().toString().substring(11, 16),
      "date": "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
      "timestamp": FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('bets').add(gameData);
      await FirebaseFirestore.instance.collection('users').doc(currentLoggedInUserMobile).update({
        'balance': FieldValue.increment(-totalAmount),
      });
    } catch (_) {}

    playedGamesHistory.insert(0, gameData);
    setState(() => userWalletBalance -= totalAmount);

    for (var c in _controllers) {
      c.clear();
    }
    _calculateTotal();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(backgroundColor: Colors.green, content: Text("Game Safalta se Lag Gaya!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.market.hindiName} - Jodi"),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text("Bal: ₹${userWalletBalance.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.market.isWithin2Hours())
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.amber.withOpacity(0.2),
                child: const Text(
                  "⚠️ Antim 2 Ghante: Adhiktam ₹200 limit lagu hai",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1.15,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 100,
                itemBuilder: (context, index) {
                  int num = index + 1;
                  String displayNum = num < 10 ? "0$num" : "$num";
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
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
                            decoration: const InputDecoration(
                              hintText: "-",
                              hintStyle: TextStyle(color: Colors.white30),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                            ),
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
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                border: Border(top: BorderSide(color: Colors.amber.withOpacity(0.3))),
              ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
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
    for (var c in _andar) {
      sum += int.tryParse(c.text) ?? 0;
    }
    for (var c in _bahar) {
      sum += int.tryParse(c.text) ?? 0;
    }
    setState(() => total = sum);
  }

  void _submitHarup() async {
    if (total <= 0) return;
    if (widget.market.isWithin2Hours() && total > 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Antim 2 ghante me max ₹200 hi lag sakta hai!")));
      return;
    }
    if (total > userWalletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text("Paryapt Balance nahi hai!")));
      return;
    }

    Map<String, dynamic> gameData = {
      "userMobile": currentLoggedInUserMobile,
      "userName": currentLoggedInUserName,
      "market": "${widget.market.hindiName} (${widget.market.name})",
      "type": "Harup (A/B)",
      "numbers": "Andar/Bahar Harup Selected",
      "amount": total,
      "time": DateTime.now().toString().substring(11, 16),
      "date": "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
      "timestamp": FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('bets').add(gameData);
      await FirebaseFirestore.instance.collection('users').doc(currentLoggedInUserMobile).update({
        'balance': FieldValue.increment(-total),
      });
    } catch (_) {}

    playedGamesHistory.insert(0, gameData);
    setState(() => userWalletBalance -= total);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Harup Game Lag Gaya!")));
    Navigator.pop(context);
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
            Expanded(
              child: ListView(
                children: [
                  _buildBox("Andar Harup", _andar),
                  _buildBox("Bahar Harup", _bahar),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF0F172A),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Amount", style: TextStyle(color: Colors.white60, fontSize: 12)),
                        Text("₹ $total", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 20)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                    onPressed: _submitHarup,
                    child: const Text("SUBMIT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  )
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
                    TextField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Points / Amount")),
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
            const SizedBox(height: 12),
            ..._list.map((e) => Card(
                  color: const Color(0xFF1E293B),
                  child: ListTile(
                    title: Text(e['pair']),
                    trailing: Text("₹ ${e['amt']}", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ----------------- 11. RESULTS SCREEN -----------------
class ResultsHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Game Results")),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: appMarkets.length,
        itemBuilder: (context, index) {
          final m = appMarkets[index];
          return Card(
            color: const Color(0xFF1E293B),
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Color(0xFFF59E0B), size: 20),
              title: Text("Timing: ${m.resultTimeStr}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
              subtitle: Text("${m.hindiName} (${m.name})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              trailing: const Text("84", style: TextStyle(color: Color(0xFFF59E0B), fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}

// ----------------- 12. WALLET SCREEN -----------------
class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF312E81), Color(0xFF1E293B)]),
              ),
              child: Column(
                children: [
                  const Text("Available Balance", style: TextStyle(color: Colors.white60, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text("₹ ${userWalletBalance.toStringAsFixed(2)}", style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text("Add Money", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (c) => AddMoneyPaymentScreen())).then((_) => setState(() {}));
                        },
                      ),
                      const SizedBox(width: 14),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                        icon: const Icon(Icons.arrow_upward, color: Colors.black),
                        label: const Text("Withdraw", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (c) => WithdrawRequestScreen())).then((_) => setState(() {}));
                        },
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
                  Text("• Jeeti hui rashi agle din hi withdraw hogi.", style: TextStyle(color: Colors.white70)),
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

  final String qrCodeUrl = "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=upi://pay%3Fpa=9761630128@ybl%26pn=DisawarKing%26cu=INR";

  void _submitDeposit() async {
    double val = double.tryParse(_amount.text) ?? 0.0;
    if (val < 50) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kam se kam Add Money ₹50 hai!")));
      return;
    }
    if (_utr.text.trim().length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sahi UTR number dalein!")));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('deposits').add({
        'userMobile': currentLoggedInUserMobile,
        'userName': currentLoggedInUserName,
        'amount': val,
        'utr': _utr.text.trim(),
        'status': 'Pending Approval',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {}

    userWalletBalance += val;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.green, content: Text("₹$val Payment Request Bhej Di Gayi Hai!")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Money (Deposit)")),
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
            children: [
              const Text("Scan QR Code to Pay", style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Image.network(
                  qrCodeUrl,
                  height: 200,
                  width: 200,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 200,
                      width: 200,
                      child: Center(child: CircularProgressIndicator(color: Colors.amber)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              const Text("PhonePe / Google Pay / Paytm se scan karein", style: TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 20),

              TextField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Kitne Paise Transfer Kiye? (Min ₹50)",
                  filled: true,
                  fillColor: Color(0xFF0F172A),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _utr,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "12-Digit UTR / Reference Number",
                  filled: true,
                  fillColor: Color(0xFF0F172A),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                  onPressed: _submitDeposit,
                  child: const Text("PAYMENT SUBMIT KAREIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
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
  final _upiOrAccount = TextEditingController();

  void _submitWithdraw() async {
    double amt = double.tryParse(_amount.text) ?? 0.0;
    if (amt < 500) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kam se kam ₹500 hi Withdraw hoga!")));
      return;
    }
    if (amt > userWalletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Paryapt balance nahi hai")));
      return;
    }

    String acct = _upiOrAccount.text.isEmpty ? "Direct Transfer" : _upiOrAccount.text;
    Map<String, dynamic> withData = {
      "userMobile": currentLoggedInUserMobile,
      "userName": currentLoggedInUserName,
      "amount": amt,
      "account": acct,
      "date": "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
      "status": "Pending (Subah 8 se 2 PM ke beech clear hoga)",
      "timestamp": FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('withdrawals').add(withData);
      await FirebaseFirestore.instance.collection('users').doc(currentLoggedInUserMobile).update({
        'balance': FieldValue.increment(-amt),
      });
    } catch (_) {}

    withdrawalHistory.insert(0, withData);
    setState(() => userWalletBalance -= amt);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(backgroundColor: Colors.green, content: Text("Withdrawal Request Lag Gayi Hai!")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Withdraw Money")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Available Balance: ₹${userWalletBalance.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              TextField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Withdrawal Amount (Min ₹500)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _upiOrAccount,
                decoration: const InputDecoration(labelText: "UPI ID ya Bank Account No.", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                  onPressed: _submitWithdraw,
                  child: const Text("WITHDRAW REQUEST BHEJO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------- 15. MORE MENU SCREEN -----------------
class MoreMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("More Menu")),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E293B),
            child: Row(
              children: [
                const CircleAvatar(backgroundColor: Color(0xFFF59E0B), radius: 24, child: Icon(Icons.person, color: Color(0xFF0F172A), size: 28)),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentLoggedInUserName.isEmpty ? "User" : currentLoggedInUserName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    Text("User ID: $currentLoggedInUserMobile", style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.sports_esports, color: Color(0xFFF59E0B)),
            title: const Text("My Played Game"),
            subtitle: const Text("Aapke lagaye gaye games"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => MyPlayGameScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFF59E0B)),
            title: const Text("Withdrawal List"),
            subtitle: const Text("Nikaasi ka status"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => WithdrawalListScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.chat, color: Color(0xFF25D366)),
            title: const Text("Help & Support (WhatsApp)"),
            subtitle: const Text("Contact: 7409989270"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => openWhatsAppChat(),
          ),
          ListTile(
            leading: const Icon(Icons.lock_reset, color: Color(0xFFF59E0B)),
            title: const Text("Change Password"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => DirectResetPasswordScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Color(0xFFF59E0B)),
            title: const Text("Share & Earn"),
            subtitle: const Text("7% Company Profit Commission"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ShareAndEarnScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.description, color: Color(0xFFF59E0B)),
            title: const Text("Terms & Conditions"),
            subtitle: const Text("Game ke niyam aur shartein"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => TermsAndConditionsScreen())),
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.power_settings_new, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => LoginScreen()));
            },
          ),
        ],
      ),
    );
  }
}

// ----------------- 16. MY PLAYED GAME SCREEN -----------------
class MyPlayGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Played Game")),
      body: playedGamesHistory.isEmpty
          ? const Center(child: Text("Aapne abhi koi game nahi lagaya hai", style: TextStyle(color: Colors.white54)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: playedGamesHistory.length,
              itemBuilder: (context, index) {
                final item = playedGamesHistory[index];
                return Card(
                  color: const Color(0xFF1E293B),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['market'], style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("₹ ${item['amount']}", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("Type: ${item['type']}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        Text("Numbers: ${item['numbers']}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        const Divider(color: Colors.white12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Time: ${item['time']}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
                            Text("Date: ${item['date']}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ----------------- 17. WITHDRAWAL LIST SCREEN -----------------
class WithdrawalListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Withdrawal History")),
      body: withdrawalHistory.isEmpty
          ? const Center(child: Text("Koi withdrawal request nahi hai", style: TextStyle(color: Colors.white54)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: withdrawalHistory.length,
              itemBuilder: (context, index) {
                final item = withdrawalHistory[index];
                return Card(
                  color: const Color(0xFF1E293B),
                  child: ListTile(
                    title: Text("₹ ${item['amount']}", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text("A/C: ${item['account']}\nStatus: ${item['status']}", style: const TextStyle(color: Colors.white70)),
                    trailing: Text(item['date'], style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ),
                );
              },
            ),
    );
  }
}

// ----------------- 18. SHARE & EARN SCREEN -----------------
class ShareAndEarnScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Share & Earn")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF312E81), Color(0xFF1E293B)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.card_giftcard, size: 60, color: Color(0xFFF59E0B)),
              SizedBox(height: 12),
              Text("SHARE THE APP AND EARN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
              SizedBox(height: 8),
              Text("ऐप को शेयर करें और पाएं लाइफ टाइम कंपनी के मुनाफे पर 7% बोनस / कमीशन!", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.white)),
              SizedBox(height: 6),
              Text("SHARE THE APP AND GET 7% ON COMPANY'S PROFIT", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.amberAccent, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------- 19. TERMS & CONDITIONS SCREEN -----------------
class TermsAndConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms & Conditions")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ruleCard(
            title: "Game Timing & Rules",
            text: "• सभी गेम सुबह 6 बजे से शुरू होंगे |\n• गेम के अंतिम समय से 2 घंटे पहले अनलिमिटेड प्ले कर सकते हैं |\n• मान लो फ़रीदाबाद में गेम लगाने का अंतिम समय 05:50 PM का है तो 03:50 PM से पहले अनलिमिटेड लगायें, परन्तु 03:50 PM के बाद और 05:50 PM तक अधिकतम ₹200 की गेम ही मान्य होगी |",
          ),
          _ruleCard(
            title: "Withdrawal Condition & Limit",
            text: "• सुबह 8 बजे से 2 बजे तक ही Withdrawal कर सकते हैं |\n• कम से कम ₹500 रुपये Withdrawal कर सकते हैं |\n• जीती हुई राशि को अगले दिन ही Withdrawal किया जा सकता है |",
          ),
          _ruleCard(
            title: "Payment Holiday (भुगतान अवकाश)",
            text: "• हर महीने की 1 और 15 तारीख को भुगतान बंद रहेगा |\n• कुछ सरकारी छुट्टी पर भी भुगतान बंद हो सकते हैं |\n• महीने के हर आखिरी दिन छुट्टी होती है |",
          ),
          _ruleCard(
            title: "Rates & Deposit Limit",
            text: "• कम से कम ADD MONEY: ₹50 है |\n• JODI RATE: 10 का 950 ₹\n• HARUFF RATE: 10 ka 95 ₹",
          ),
          _ruleCard(
            title: "Share & Earn Commission",
            text: "• ऐप को शेयर करें और पाएं लाइफ टाइम कंपनी के मुनाफे पर 7% बोनस |\n• SHARE THE APP AND GET 7% ON COMPANY'S PROFIT",
          ),
        ],
      ),
    );
  }

  Widget _ruleCard({required String title, required String text}) {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
