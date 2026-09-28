import 'package:flutter/material.dart';

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
        primaryColor: Color(0xFFFFB300), // Royal Gold/Amber
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

// Global Wallet State
double userWalletBalance = 0.0;
String currentLoggedInUser = "";

// ----------------- WIDGET: APP BRAND LOGO -----------------
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
      SizedBox(height: 12),
      Text(
        "DisawarKingApp",
        style: TextStyle(
          color: Color(0xFFFFB300),
          fontSize: 26,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      Text(
        "Official Gaming Portal",
        style: TextStyle(color: Colors.white54, fontSize: 12),
      ),
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

  void _login() {
    if (_mobileController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kripya 10 anko ka Mobile Number darj karein!")));
      return;
    }
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password darj karein!")));
      return;
    }
    currentLoggedInUser = _mobileController.text;
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
                SizedBox(height: 35),
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
                      SizedBox(height: 20),
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
                      SizedBox(height: 14),
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
                        height: 50,
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
                SizedBox(height: 20),
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

// ----------------- 2. REGISTRATION FLOW (OTP -> DETAILS -> ID CREATED) -----------------
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
    setState(() {
      isOtpSent = true;
    });
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
          "Aapki ID safaltapoorvak ban gayi hai!\n\nAapka User ID: ${_mobileController.text}\nPassword: ${_passController.text}",
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
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
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
                        labelText: "Aapka Naam",
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
                    SizedBox(height: 20),
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
            )
          ],
        ),
      ),
    );
  }
}

// ----------------- 3. FORGOT PASSWORD (OTP BASED) -----------------
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
      SnackBar(backgroundColor: Colors.green, content: Text("Password safaltapoorvak badal diya gaya! Ab Login karein.")),
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

// ----------------- 5. HOME SCREEN (LIVE RESULTS & RECENT WINNING NUMBERS) -----------------
class HomeLiveResultsScreen extends StatelessWidget {
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
      appBar: AppBar(
        title: Text("DisawarKing Live"),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text(
                "₹ ${userWalletBalance.toStringAsFixed(2)}",
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(14),
        children: [
          Container(
            padding: EdgeInsets.all(16),
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
                    Text("LIVE RESULT DASHBOARD", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 4),
                    Text("Sabse Tej Live Result Updates", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                Icon(Icons.flash_on, color: Colors.amber, size: 36),
              ],
            ),
          ),
          SizedBox(height: 14),
          Text("Aaj Ka Taaza Result", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
          SizedBox(height: 10),
          ...liveResults.map((item) {
            bool isWaiting = item['status'] == "Waiting";
            return Card(
              color: Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(item['market']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                subtitle: Text("Timing: ${item['time']}", style: TextStyle(color: Colors.white54, fontSize: 12)),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isWaiting ? Colors.grey[800] : Color(0xFFFFB300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['result']!,
                    style: TextStyle(
                      fontSize: 20,
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
    );
  }
}

// ----------------- 6. PLAY GAME MARKET LIST -----------------
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
              subtitle: Text("Open-Close: ${game['time']}", style: TextStyle(color: Colors.white54, fontSize: 12)),
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

// ----------------- 7. GAME MODE SELECT (JODI, HARUP, CROSSING) -----------------
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
                    Text("10 = 950", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                Container(height: 35, width: 1, color: Colors.white24),
                Column(
                  children: [
                    Text("Harup Rate", style: TextStyle(color: Colors.white60, fontSize: 13)),
                    Text("10 = 95", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
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

// ----------------- 8. JODI SCREEN (SUBMIT CUT FIX) -----------------
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
        SnackBar(backgroundColor: Colors.red, content: Text("Wallet me paryapt balance nahi hai! Add Money karein.")),
      );
      return;
    }
    setState(() {
      userWalletBalance -= totalAmount;
    });
    for (var c in _controllers) c.clear();
    _calculateTotal();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.green, content: Text("Bid Successfully Lag Gayi! ₹$totalAmount cut ho gaye.")),
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

// ----------------- 9. HARUP SCREEN -----------------
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Harup Bids Placed!")));
                    },
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

// ----------------- 10. CROSSING SCREEN -----------------
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
          ],
        ),
      ),
    );
  }
}

// ----------------- 11. RESULTS HISTORY SCREEN -----------------
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

// ----------------- 12. WALLET & PAYMENTS (ADD MONEY & WITHDRAW) -----------------
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
                  Text("Payment Options Supported", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
                  SizedBox(height: 12),
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

// ----------------- 13. ADD MONEY SCREEN (QR & UTR SUBMIT) -----------------
class AddMoneyPaymentScreen extends StatefulWidget {
  @override
  _AddMoneyPaymentScreenState createState() => _AddMoneyPaymentScreenState();
}

class _AddMoneyPaymentScreenState extends State<AddMoneyPaymentScreen> {
  final _amount = TextEditingController();
  final _utr = TextEditingController();

  final String adminUpiId = "disawarking@upi";

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
                decoration: InputDecoration(labelText: "Kitne Paise Transfer Kiye? (₹)", border: OutlineInputBorder()),
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
                    if (_amount.text.isNotEmpty && _utr.text.length >= 8) {
                      double val = double.tryParse(_amount.text) ?? 0.0;
                      userWalletBalance += val;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(backgroundColor: Colors.green, content: Text("₹$val Add Request Submitted! Balance updated.")),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Amount aur 12-digit UTR No. enter karein!")));
                    }
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

// ----------------- 14. WITHDRAW SCREEN -----------------
class WithdrawRequestScreen extends StatefulWidget {
  @override
  _WithdrawRequestScreenState createState() => _WithdrawRequestScreenState();
}

class _WithdrawRequestScreenState extends State<WithdrawRequestScreen> {
  final _amount = TextEditingController();
  final _upiOrAccount = TextEditingController();

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
              Text("Available Balance: ₹${userWalletBalance.toStringAsFixed(2)}", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              TextField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Withdrawal Amount (₹)", border: OutlineInputBorder()),
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
                  onPressed: () {
                    double amt = double.tryParse(_amount.text) ?? 0.0;
                    if (amt <= 0 || amt > userWalletBalance) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Paryapt balance nahi hai")));
                      return;
                    }
                    userWalletBalance -= amt;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(backgroundColor: Colors.green, content: Text("Withdrawal request lag gayi hai! 30 min me paise mil jayenge.")),
                    );
                    Navigator.pop(context);
                  },
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

// ----------------- 15. MORE MENU -----------------
class MoreMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("DisawarKing Menu")),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Color(0xFF1E1E1E),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.person, color: Colors.black)),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("User ID: $currentLoggedInUser", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    Text("Verified Member", style: TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          ListTile(leading: Icon(Icons.history, color: Colors.amber), title: Text("My Game Bets"), onTap: () {}),
          ListTile(leading: Icon(Icons.receipt_long, color: Colors.amber), title: Text("Passbook / Ledger"), onTap: () {}),
          ListTile(leading: Icon(Icons.support_agent, color: Colors.amber), title: Text("WhatsApp Support"), onTap: () {}),
          ListTile(
            leading: Icon(Icons.power_settings_new, color: Colors.red),
            title: Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => LoginScreen()));
            },
          ),
        ],
      ),
    );
  }
}
