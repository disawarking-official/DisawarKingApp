import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
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
        scaffoldBackgroundColor: Color(0xFF121212),
        primaryColor: Color(0xFFFFB300),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFFFFB300),
          secondary: Color(0xFFFFA000),
          surface: Color(0xFF1E1E1E),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 2,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFB300)),
          iconTheme: IconThemeData(color: Color(0xFFFFB300)),
        ),
      ),
      home: LoginScreen(),
    );
  }
}

double userWalletBalance = 0.0;
String currentLoggedInUserMobile = "7409989270";
String currentLoggedInUserName = "Sheelu Bhartiya";
final String officialWhatsAppNumber = "917409989270";

List<Map<String, dynamic>> playedGamesHistory = [];
List<Map<String, dynamic>> withdrawalHistory = [];

Future<void> openWhatsAppChat({String message = "Namaste DisawarKing Support, mujhe sahayata chahiye."}) async {
  final Uri url = Uri.parse("https://wa.me/$officialWhatsAppNumber?text=${Uri.encodeComponent(message)}");
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {}
}

Widget buildAppLogo() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 20, spreadRadius: 3),
          ],
        ),
        child: Icon(Icons.workspace_premium, size: 55, color: Colors.black),
      ),
      SizedBox(height: 10),
      Text(
        "DisawarKingApp",
        style: TextStyle(
          color: Color(0xFFFFB300),
          fontSize: 26,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      Text("Official Gaming Portal", style: TextStyle(color: Colors.white54, fontSize: 12)),
    ],
  );
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    if (_mobileController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("10 anko ka Mobile Number darj karein!")));
      return;
    }
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password darj karein!")));
      return;
    }
    currentLoggedInUserMobile = _mobileController.text;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                buildAppLogo(),
                SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Login", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
                      Text("Apne Mobile Number se Login karein", style: TextStyle(color: Colors.white60, fontSize: 13)),
                      SizedBox(height: 18),
                      TextField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.phone_android, color: Colors.amber),
                          hintText: "Mobile Number (User ID)",
                          counterText: "",
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.amber),
                          hintText: "Password",
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (c) => ForgotPasswordOtpScreen()));
                          },
                          child: Text("Forgot Password?", style: TextStyle(color: Colors.amberAccent, fontSize: 13)),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFB300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _login,
                          child: Text("LOGIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => RegisterOtpScreen()));
                  },
                  child: RichText(
                    text: TextSpan(
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

class RegisterOtpScreen extends StatefulWidget {
  @override
  _RegisterOtpScreenState createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  final _passController = TextEditingController();

  bool isOtpSent = false;
  String generatedDemoOtp = "123456";

  void _sendOtp() {
    if (_mobileController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("10 digit ka valid Mobile Number dalein")));
      return;
    }
    setState(() => isOtpSent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text("OTP bhej diya gaya hai! Demo OTP: $generatedDemoOtp"),
        duration: Duration(seconds: 5),
      ),
    );
  }

  void _verifyAndCreate() {
    if (_otpController.text != generatedDemoOtp) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Galat OTP! Kripya sahi OTP enter karein.")));
      return;
    }
    if (_nameController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Naam aur Password dono bharein.")));
      return;
    }

    currentLoggedInUserName = _nameController.text;
    currentLoggedInUserMobile = _mobileController.text;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("Registration Successful", style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Text(
          "Aapki ID ban chuki hai!\n\nNaam: $currentLoggedInUserName\nUser ID (Mobile): $currentLoggedInUserMobile",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text("Login Karein", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Naya Account Register")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                enabled: !isOtpSent,
                decoration: InputDecoration(
                  labelText: "Mobile Number",
                  prefixIcon: Icon(Icons.phone, color: Colors.amber),
                  counterText: "",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              if (!isOtpSent)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    onPressed: _sendOtp,
                    child: Text("OTP Bhejo", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              if (isOtpSent) ...[
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: "Enter 6-Digit OTP",
                    prefixIcon: Icon(Icons.security, color: Colors.amber),
                    counterText: "",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Aapka Pura Naam",
                    prefixIcon: Icon(Icons.person, color: Colors.amber),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Apna Password Banayein",
                    prefixIcon: Icon(Icons.lock, color: Colors.amber),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    onPressed: _verifyAndCreate,
                    child: Text("OTP Verify & ID Banayein", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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

class ForgotPasswordOtpScreen extends StatefulWidget {
  @override
  _ForgotPasswordOtpScreenState createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPassController = TextEditingController();

  bool isOtpSent = false;
  String demoOtp = "654321";

  void _sendOtp() {
    if (_mobileController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("10 anko ka Mobile Number dalein")));
      return;
    }
    setState(() => isOtpSent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.green, content: Text("Reset OTP bhej diya gaya hai! Demo OTP: $demoOtp")),
    );
  }

  void _resetPassword() {
    if (_otpController.text != demoOtp) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Galat OTP enter kiya hai.")));
      return;
    }
    if (_newPassController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password kam se kam 4 digit ka banayein.")));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.green, content: Text("Password badal diya gaya hai! Ab Login karein.")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                enabled: !isOtpSent,
                decoration: InputDecoration(
                  labelText: "Registered Mobile Number",
                  prefixIcon: Icon(Icons.phone, color: Colors.amber),
                  counterText: "",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              if (!isOtpSent)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    onPressed: _sendOtp,
                    child: Text("OTP Bhejo", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              if (isOtpSent) ...[
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: "Enter OTP",
                    prefixIcon: Icon(Icons.sms, color: Colors.amber),
                    counterText: "",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _newPassController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Naya Password Dalein",
                    prefixIcon: Icon(Icons.lock_reset, color: Colors.amber),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    onPressed: _resetPassword,
                    child: Text("Submit Naya Password", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
        selectedItemColor: Color(0xFFFFB300),
        unselectedItemColor: Colors.white54,
        backgroundColor: Color(0xFF181818),
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
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

class HomeLiveResultsScreen extends StatefulWidget {
  @override
  _HomeLiveResultsScreenState createState() => _HomeLiveResultsScreenState();
}

class _HomeLiveResultsScreenState extends State<HomeLiveResultsScreen> {
  final List<Map<String, String>> liveResults = [
    {"market": "DISAWAR", "result": "84", "time": "05:00 AM", "status": "Declared"},
    {"market": "FARIDABAD", "result": "12", "time": "06:15 PM", "status": "Declared"},
    {"market": "GHAZIABAD", "result": "67", "time": "08:30 PM", "status": "Declared"},
    {"market": "GALI", "result": "XX", "time": "11:00 PM", "status": "Waiting"},
    {"market": "SHREE GANESH", "result": "39", "time": "04:30 PM", "status": "Declared"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
                border: Border(bottom: BorderSide(color: Colors.amber.withOpacity(0.3))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.amber,
                        child: Icon(Icons.person, color: Colors.black, size: 24),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentLoggedInUserName,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                          ),
                          Text(
                            "+91 $currentLoggedInUserMobile",
                            style: TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.withOpacity(0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Wallet", style: TextStyle(color: Colors.white54, fontSize: 10)),
                            Text("₹ ${userWalletBalance.toStringAsFixed(2)}", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      InkWell(
                        onTap: () => openWhatsAppChat(message: "Namaste DisawarKing Support! Meri ID hai: $currentLoggedInUserMobile"),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF25D366),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 8)],
                          ),
                          child: Icon(Icons.chat, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(12),
                children: [
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF2C2202), Color(0xFF1E1E1E)]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("DISAWAR KING LIVE RESULTS", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
                            SizedBox(height: 4),
                            Text("Sabse Tej aur 100% Sahi Updates", style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                        Icon(Icons.flash_on, color: Colors.amber, size: 30),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Text("Aaj Ka Taaza Result", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white70)),
                  SizedBox(height: 8),
                  ...liveResults.map((item) {
                    bool isWaiting = item['status'] == "Waiting";
                    return Card(
                      color: Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(item['market']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                        subtitle: Text("Time: ${item['time']}", style: TextStyle(color: Colors.white54, fontSize: 11)),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isWaiting ? Colors.grey[800] : Color(0xFFFFB300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['result']!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isWaiting ? Colors.white : Colors.black,
                            ),
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

class GameMarketsListScreen extends StatelessWidget {
  final List<Map<String, String>> games = [
    {"name": "DISAWAR", "time": "06:21 am - 04:35 am"},
    {"name": "FARIDABAD", "time": "06:21 am - 05:55 pm"},
    {"name": "GHAZIABAD", "time": "06:21 am - 09:35 pm"},
    {"name": "GALI", "time": "06:21 am - 11:00 pm"},
    {"name": "SHREE GANESH", "time": "06:21 am - 03:45 pm"},
    {"name": "MUMBAI SPECIAL", "time": "06:21 am - 01:30 am"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Markets")),
      body: ListView.separated(
        padding: EdgeInsets.all(12),
        itemCount: games.length,
        separatorBuilder: (_, __) => SizedBox(height: 8),
        itemBuilder: (context, index) {
          final game = games[index];
          return Card(
            color: Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(game['name']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),
              subtitle: Text("Timing: ${game['time']}", style: TextStyle(color: Colors.white54, fontSize: 12)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GameModeSelectScreen(gameName: game['name']!)),
                  );
                },
                child: Text("Play Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GameModeSelectScreen extends StatelessWidget {
  final String gameName;
  GameModeSelectScreen({required this.gameName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(gameName)),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            color: Color(0xFF1E1E1E),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text("Jodi Rate", style: TextStyle(color: Colors.white60, fontSize: 13)),
                    Text("10 ka 950 ₹", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                Container(height: 35, width: 1, color: Colors.white24),
                Column(
                  children: [
                    Text("Haruff Rate", style: TextStyle(color: Colors.white60, fontSize: 13)),
                    Text("10 ka 95 ₹", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          _menuTile(context, "Jodi (01 to 100)", Icons.grid_on, () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => JodiSelectionScreen(gameName: gameName)));
          }),
          _menuTile(context, "Harup (Andar / Bahar)", Icons.swap_horiz, () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => HarupSelectionScreen(gameName: gameName)));
          }),
          _menuTile(context, "Crossing Game", Icons.shuffle, () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => CrossingSelectionScreen(gameName: gameName)));
          }),
        ],
      ),
    );
  }

  Widget _menuTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        tileColor: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(icon, color: Colors.amber),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }
}

class JodiSelectionScreen extends StatefulWidget {
  final String gameName;
  JodiSelectionScreen({required this.gameName});

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

  void _submitBids() {
    if (totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kripya kisi number par points lagayein")));
      return;
    }
    if (totalAmount > userWalletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text("Wallet balance kam hai! Pehle Add Money karein.")),
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

    playedGamesHistory.insert(0, {
      "market": widget.gameName,
      "type": "Jodi (01-100)",
      "numbers": chosenNumbers.join(", "),
      "amount": totalAmount,
      "time": DateTime.now().toString().substring(11, 16),
      "date": "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
    });

    setState(() {
      userWalletBalance -= totalAmount;
    });

    for (var c in _controllers) c.clear();
    _calculateTotal();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.green, content: Text("Game Safalta se Lag Gaya! 'My Play Game' me save ho gaya.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.gameName} - Jodi"),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text("Bal: ₹${userWalletBalance.toStringAsFixed(2)}", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                      color: Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    padding: EdgeInsets.all(4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(displayNum, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amber)),
                        SizedBox(
                          height: 24,
                          child: TextField(
                            controller: _controllers[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.white),
                            onChanged: (_) => _calculateTotal(),
                            decoration: InputDecoration(
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                border: Border(top: BorderSide(color: Colors.amber.withOpacity(0.3))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Amount", style: TextStyle(color: Colors.white60, fontSize: 12)),
                        Text("₹ $totalAmount", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 20)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFB300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _submitBids,
                      child: Text("SUBMIT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
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

class HarupSelectionScreen extends StatefulWidget {
  final String gameName;
  HarupSelectionScreen({required this.gameName});

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

  void _submitHarup() {
    if (total <= 0) return;
    if (total > userWalletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("Paryapt Balance nahi hai!")));
      return;
    }
    playedGamesHistory.insert(0, {
      "market": widget.gameName,
      "type": "Harup (A/B)",
      "numbers": "Andar/Bahar Harup Selected",
      "amount": total,
      "time": DateTime.now().toString().substring(11, 16),
      "date": "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
    });
    setState(() {
      userWalletBalance -= total;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text("Harup Bids Placed!")));
    Navigator.pop(context);
  }

  Widget _buildBox(String label, List<TextEditingController> list) {
    return Card(
      color: Color(0xFF1E1E1E),
      margin: EdgeInsets.all(12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
            SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 10,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, childAspectRatio: 1.2, crossAxisSpacing: 6, mainAxisSpacing: 6),
              itemBuilder: (c, i) => Container(
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(6)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("$i", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                    SizedBox(
                      height: 22,
                      child: TextField(
                        controller: list[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (_) => _calc(),
                        decoration: InputDecoration(hintText: "-", border: InputBorder.none, isDense: true),
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
      appBar: AppBar(title: Text("${widget.gameName} - Harup")),
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Color(0xFF1A1A1A),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Amount", style: TextStyle(color: Colors.white60, fontSize: 12)),
                        Text("₹ $total", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 20)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    onPressed: _submitHarup,
                    child: Text("SUBMIT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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

class CrossingSelectionScreen extends StatefulWidget {
  final String gameName;
  CrossingSelectionScreen({required this.gameName});

  @override
  _CrossingSelectionScreenState createState() => _CrossingSelectionScreenState();
}

class _CrossingSelectionScreenState extends State<CrossingSelectionScreen> {
  final _num1 = TextEditingController();
  final _num2 = TextEditingController();
  final _amount = TextEditingController();
  final List<Map<String, dynamic>> _list = [];

  void _submitCrossing() {
    int total = _list.fold(0, (sum, i) => sum + (int.tryParse(i['amt']) ?? 0));
    if (total <= 0) return;
    if (total > userWalletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("Paryapt Balance nahi hai!")));
      return;
    }
    playedGamesHistory.insert(0, {
      "market": widget.gameName,
      "type": "Crossing",
      "numbers": _list.map((e) => e['pair']).join(", "),
      "amount": total,
      "time": DateTime.now().toString().substring(11, 16),
      "date": "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
    });
    setState(() {
      userWalletBalance -= total;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text("Crossing Game Lag Gaya!")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.gameName} - Crossing")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Color(0xFF1E1E1E),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(controller: _num1, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Number 1")),
                    SizedBox(height: 8),
                    TextField(controller: _num2, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Number 2")),
                    SizedBox(height: 8),
                    TextField(controller: _amount, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Points / Amount")),
                    SizedBox(height: 14),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: Size(double.infinity, 44)),
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
                      child: Text("+ Add Entry", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            ..._list.map((e) => Card(
                  color: Color(0xFF1E1E1E),
                  child: ListTile(
                    title: Text(e['pair']),
                    trailing: Text("₹ ${e['amt']}", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  ),
                )),
            if (_list.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: _submitCrossing,
                    child: Text("SUBMIT CROSSING GAME", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ResultsHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Game Results")),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: 15,
        itemBuilder: (context, index) {
          return Card(
            color: Color(0xFF1E1E1E),
            child: ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.amber, size: 20),
              title: Text("Date: 28-09-2026", style: TextStyle(color: Colors.white70, fontSize: 13)),
              subtitle: Text("DISAWAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              trailing: Text("84", style: TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("DisawarKing Wallet")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF2B2002), Color(0xFF1A1A1A)]),
              ),
              child: Column(
                children: [
                  Text("Available Balance", style: TextStyle(color: Colors.white60, fontSize: 14)),
                  SizedBox(height: 6),
                  Text("₹ ${userWalletBalance.toStringAsFixed(2)}", style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.amber)),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text("Add Money", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (c) => AddMoneyPaymentScreen())).then((_) => setState(() {}));
                        },
                      ),
                      SizedBox(width: 14),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                        icon: Icon(Icons.arrow_upward, color: Colors.black),
                        label: Text("Withdraw", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (c) => WithdrawRequestScreen())).then((_) => setState(() {}));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Rules & Payment Limits:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
                  SizedBox(height: 8),
                  Text("• Kam se kam ADD MONEY: ₹50", style: TextStyle(color: Colors.white70)),
                  Text("• Kam se kam WITHDRAWAL: ₹500", style: TextStyle(color: Colors.white70)),
                  Text("• Withdrawal Timing: Subah 8:00 AM se 2:00 PM tak", style: TextStyle(color: Colors.white70)),
                  Text("• Jeeti hui rashi ko agle din hi withdraw kiya ja sakta hai.", style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 14),
                  Text("Payment Modes Supported:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _payIcon("Google Pay", Icons.account_balance_wallet),
                      _payIcon("PhonePe", Icons.phone_android),
                      _payIcon("Paytm", Icons.payment),
                      _payIcon("Bank UPI", Icons.account_balance),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _payIcon(String name, IconData icon) {
    return Column(
      children: [
        CircleAvatar(radius: 24, backgroundColor: Color(0xFF1E1E1E), child: Icon(icon, color: Colors.amber)),
        SizedBox(height: 6),
        Text(name, style: TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class AddMoneyPaymentScreen extends StatefulWidget {
  @override
  _AddMoneyPaymentScreenState createState() => _AddMoneyPaymentScreenState();
}

class _AddMoneyPaymentScreenState extends State<AddMoneyPaymentScreen> {
  final _amount = TextEditingController();
  final _utr = TextEditingController();
  final String adminUpiId = "7409989270@upi";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Money (Deposit)")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Text("Scan QR ya UPI par Pay Karein", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 12),
              Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.qr_code_2, size: 140, color: Colors.black),
              ),
              SizedBox(height: 10),
              SelectableText("UPI ID: $adminUpiId", style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              TextField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Kitne Paise Transfer Kiye? (Min ₹50)",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _utr,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "12-Digit UTR / Reference Number", border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  onPressed: () {
                    double val = double.tryParse(_amount.text) ?? 0.0;
                    if (val < 50) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kam se kam Add Money ₹50 hai!")));
                      return;
                    }
                    if (_utr.text.length < 8) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Valid UTR Number daalein!")));
                      return;
                    }
                    userWalletBalance += val;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(backgroundColor: Colors.green, content: Text("₹$val Add Request Submitted! Balance updated.")),
                    );
                    Navigator.pop(context);
                  },
                  child: Text("PAYMENT SUBMIT KAREIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WithdrawRequestScreen extends StatefulWidget {
  @override
  _WithdrawRequestScreenState createState() => _WithdrawRequestScreenState();
}

class _WithdrawRequestScreenState extends State<WithdrawRequestScreen> {
  final _amount = TextEditingController();
  final _upiOrAccount = TextEditingController();

  void _submitWithdraw() {
    double amt = double.tryParse(_amount.text) ?? 0.0;
    if (amt < 500) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kam se kam ₹500 hi Withdraw kar sakte hain!")));
      return;
    }
    if (amt > userWalletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Paryapt balance nahi hai")));
      return;
    }
    if (_upiOrAccount.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bank Account ya UPI ID enter karein")));
      return;
    }

    withdrawalHistory.insert(0, {
      "amount": amt,
      "account": _upiOrAccount.text,
      "date": "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
      "status": "Pending (Subah 8 se 2 baje ke beech clear hoga)",
    });

    setState(() {
      userWalletBalance -= amt;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.green, content: Text("Withdrawal Request Lag Gayi Hai! List me check karein.")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Withdraw Money")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Available Balance: ₹${userWalletBalance.toStringAsFixed(2)}", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 6),
              Text("Note: Subah 8 baje se 2 baje tak hi withdraw kar sakte hain.", style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
              SizedBox(height: 16),
              TextField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Withdrawal Amount (Min ₹500)", border: OutlineInputBorder()),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _upiOrAccount,
                decoration: InputDecoration(labelText: "UPI ID ya Bank Account No. / IFSC", border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  onPressed: _submitWithdraw,
                  child: Text("WITHDRAW REQUEST BHEJO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MoreMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("More Menu")),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Color(0xFF1E1E1E),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: Colors.amber, radius: 24, child: Icon(Icons.person, color: Colors.black, size: 28)),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentLoggedInUserName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    Text("User ID: $currentLoggedInUserMobile", style: TextStyle(color: Colors.amber, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.sports_esports, color: Colors.amber),
            title: Text("My Played Game"),
            subtitle: Text("Aapke dwara lagaye gaye games"),
            trailing: Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => MyPlayGameScreen())),
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet_outlined, color: Colors.amber),
            title: Text("Withdrawal List"),
            subtitle: Text("Nikaasi ki request status"),
            trailing: Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => WithdrawalListScreen())),
          ),
          ListTile(
            leading: Icon(Icons.chat, color: Color(0xFF25D366)),
            title: Text("Help & Support (WhatsApp)"),
            subtitle: Text("Chat karein: 7409989270"),
            trailing: Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => openWhatsAppChat(message: "Namaste DisawarKing Support, mujhe help chahiye."),
          ),
          ListTile(
            leading: Icon(Icons.lock_reset, color: Colors.amber),
            title: Text("Change Password"),
            trailing: Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ForgotPasswordOtpScreen())),
          ),
          ListTile(
            leading: Icon(Icons.share, color: Colors.amber),
            title: Text("Share & Earn"),
            subtitle: Text("Company ke munafey par 7% aur 5% bonus"),
            trailing: Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ShareAndEarnScreen())),
          ),
          ListTile(
            leading: Icon(Icons.description, color: Colors.amber),
            title: Text("Terms & Conditions"),
            subtitle: Text("Game aur payment ke niyam"),
            trailing: Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => TermsAndConditionsScreen())),
          ),
          Divider(color: Colors.white24),
          ListTile(
            leading: Icon(Icons.power_settings_new, color: Colors.red),
            title: Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => LoginScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class MyPlayGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Played Game")),
      body: playedGamesHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 60, color: Colors.white30),
                  SizedBox(height: 12),
                  Text("Aapne abhi tak koi game nahi lagaya hai", style: TextStyle(color: Colors.white54)),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: playedGamesHistory.length,
              itemBuilder: (context, index) {
                final item = playedGamesHistory[index];
                return Card(
                  color: Color(0xFF1E1E1E),
                  margin: EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['market'], style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("₹ ${item['amount']}", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text("Game Type: ${item['type']}", style: TextStyle(color: Colors.white70, fontSize: 13)),
                        Text("Selected: ${item['numbers']}", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Divider(color: Colors.white12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Time: ${item['time']}", style: TextStyle(color: Colors.white38, fontSize: 11)),
                            Text("Date: ${item['date']}", style: TextStyle(color: Colors.white38, fontSize: 11)),
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

class WithdrawalListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Withdrawal History")),
      body: withdrawalHistory.isEmpty
          ? Center(
              child: Text("Koi withdrawal request nahi hai", style: TextStyle(color: Colors.white54)),
            )
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: withdrawalHistory.length,
              itemBuilder: (context, index) {
                final item = withdrawalHistory[index];
                return Card(
                  color: Color(0xFF1E1E1E),
                  child: ListTile(
                    title: Text("₹ ${item['amount']}", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text("A/C: ${item['account']}\nStatus: ${item['status']}", style: TextStyle(color: Colors.white70)),
                    trailing: Text(item['date'], style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ),
                );
              },
            ),
    );
  }
}

class ShareAndEarnScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Share & Earn")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF2B2002), Color(0xFF1E1E1E)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.card_giftcard, size: 60, color: Colors.amber),
                  SizedBox(height: 12),
                  Text("SHARE THE APP AND EARN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
                  SizedBox(height: 8),
                  Text("ऐप को शेयर करें और पाएं लाइफ टाइम कंपनी के मुनाफे पर 7% बोनस!", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.white70)),
                  SizedBox(height: 6),
                  Text("SHARE THE APP AND GET 5% ON COMPANY'S PROFIT", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.amberAccent)),
                ],
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF25D366)),
                icon: Icon(Icons.share, color: Colors.white),
                label: Text("WhatsApp Par Doston Ko Share Karein", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  openWhatsAppChat(message: "DisawarKing Official App download karein aur khelein! Referral Code: $currentLoggedInUserMobile");
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TermsAndConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Terms & Conditions")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _ruleCard(
            title: "Game Timing & Rules",
            text: "• सभी गेम सुबह 6 बजे से शुरू होंगे |\n• गेम के अंतिम समय से 2 घंटे पहले अनलिमिटेड प्ले कर सकते हैं |\n• मान लो फरीदाबाद में गेम लगाने का अंतिम समय 05:50 PM का है तो 03:50 PM से पहले अनलिमिटेड लगायें, परन्तु 03:50 PM के बाद और 05:50 PM तक अधिकतम ₹200 की गेम ही मान्य होगी |",
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
            text: "• कम से कम ADD MONEY: ₹50 है |\n• JODI RATE: 10 का 950 ₹\n• HARUFF RATE: 10 का 95 ₹",
          ),
          _ruleCard(
            title: "Share & Earn Scheme",
            text: "• ऐप को शेयर करें और पाएं लाइफ टाइम कंपनी के मुनाफे पर 7% बोनस |\n• SHARE THE APP AND GET 5% ON COMPANY'S PROFIT",
          ),
        ],
      ),
    );
  }

  Widget _ruleCard({required String title, required String text}) {
    return Card(
      color: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
            SizedBox(height: 8),
            Text(text, style: TextStyle(fontSize: 13, height: 1.5, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
