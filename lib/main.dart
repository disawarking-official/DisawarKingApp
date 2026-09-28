import 'package:flutter/material.dart';

void main() {
  runApp(MatkaApp());
}

class MatkaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Game of Satta',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: LoginScreen(),
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

  void _login() {
    if (_mobileController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigationScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mobile number aur password enter karein!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.stars_rounded, size: 80, color: Colors.orange),
                    SizedBox(height: 12),
                    Text(
                      "Game of Satta",
                      style: TextStyle(color: Colors.orange, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Login", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("Please Sign in to Continue", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 18),
                  TextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "Mobile Number",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _login,
                      child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterScreen()),
                        );
                      },
                      child: Text("Don't have an account? Register Now", style: TextStyle(color: Colors.orange)),
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

// ----------------- 2. REGISTER SCREEN -----------------
class RegisterScreen extends StatelessWidget {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passController = TextEditingController();
  final _refController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  "Game of Satta",
                  style: TextStyle(color: Colors.orange, fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Create Account", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("Create a New Account", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 14),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(hintText: "Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(hintText: "Mobile Number", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _passController,
                    obscureText: true,
                    decoration: InputDecoration(hintText: "Password", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _refController,
                    decoration: InputDecoration(hintText: "Referral (optional)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () => Navigator.pop(context),
                      child: Text("Register", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Already have an account? Sign In", style: TextStyle(color: Colors.orange)),
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

// ----------------- 3. MAIN NAVIGATION SCREEN -----------------
class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    GameListScreen(),
    GameListScreen(),
    Center(child: Text("Results Screen", style: TextStyle(fontSize: 18))),
    WalletScreen(),
    MoreMenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: "Play Game"),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Results"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "More"),
        ],
      ),
    );
  }
}

// ----------------- 4. GAME LIST SCREEN -----------------
class GameListScreen extends StatelessWidget {
  final List<Map<String, String>> games = [
    {"name": "MUMBAI SPECIAL", "time": "06:21 am - 01:30 am"},
    {"name": "MANIKARAN", "time": "06:21 am - 01:45 am"},
    {"name": "DISAWAR", "time": "06:21 am - 04:35 am"},
    {"name": "SHREE GANESH", "time": "06:21 am - 03:45 pm"},
    {"name": "FARIDABAD", "time": "06:21 am - 05:55 pm"},
    {"name": "GHAZIABAD", "time": "06:21 am - 09:35 pm"},
    {"name": "GALI", "time": "06:21 am - 11:00 pm"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Game", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: ListView.separated(
        itemCount: games.length,
        separatorBuilder: (_, __) => Divider(height: 1),
        itemBuilder: (context, index) {
          final game = games[index];
          return ListTile(
            title: Text(game['name']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text(game['time']!, style: TextStyle(color: Colors.orange, fontSize: 12)),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameModeSelectScreen(gameName: game['name']!)),
                );
              },
              child: Text("Play Now", style: TextStyle(color: Colors.white)),
            ),
          );
        },
      ),
    );
  }
}

// ----------------- 5. GAME RATE & TYPE SELECTION -----------------
class GameModeSelectScreen extends StatelessWidget {
  final String gameName;
  GameModeSelectScreen({required this.gameName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(gameName, style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16, top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("0.00", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                Text("Total Balance", style: TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            color: Colors.white,
            child: Column(
              children: [
                Text("Game Rate", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Jodi ₹ 10 = ₹ 950", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    Text("Haraf ₹ 10 = ₹ 95", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          _menuButton(context, "Jodi", () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => JodiSelectionScreen(gameName: gameName)));
          }),
          _menuButton(context, "Harup", () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => HarupSelectionScreen(gameName: gameName)));
          }),
          _menuButton(context, "Crossing", () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => CrossingSelectionScreen(gameName: gameName)));
          }),
        ],
      ),
    );
  }

  Widget _menuButton(BuildContext context, String title, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onPressed: onTap,
        child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ----------------- 6. HARUP SCREEN (ANDAR / BAHAR 0-9) -----------------
class HarupSelectionScreen extends StatefulWidget {
  final String gameName;
  HarupSelectionScreen({required this.gameName});

  @override
  _HarupSelectionScreenState createState() => _HarupSelectionScreenState();
}

class _HarupSelectionScreenState extends State<HarupSelectionScreen> {
  final List<TextEditingController> _andarControllers = List.generate(10, (_) => TextEditingController());
  final List<TextEditingController> _baharControllers = List.generate(10, (_) => TextEditingController());
  int totalAmount = 0;

  void _calculateTotal() {
    int sum = 0;
    for (var c in _andarControllers) {
      sum += int.tryParse(c.text) ?? 0;
    }
    for (var c in _baharControllers) {
      sum += int.tryParse(c.text) ?? 0;
    }
    setState(() {
      totalAmount = sum;
    });
  }

  Widget _buildSection(String title, List<TextEditingController> controllers) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 10,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Text("$index", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 28,
                      child: TextField(
                        controller: controllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (_) => _calculateTotal(),
                        decoration: InputDecoration(isDense: true, border: UnderlineInputBorder()),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(widget.gameName, style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16, top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("0.00", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                Text("Total Balance", style: TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildSection("Andar", _andarControllers),
                _buildSection("Bahar", _baharControllers),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Text("$totalAmount", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text("Total Amount", style: TextStyle(color: Colors.grey, fontSize: 12)),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Harup Bids Placed! Total: ₹$totalAmount")),
                      );
                    },
                    child: Text("Submit", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ----------------- 7. JODI SCREEN (01 SE 100) -----------------
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
    setState(() {
      totalAmount = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(widget.gameName, style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16, top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("0.00", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                Text("Total Balance", style: TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1.1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 100,
              itemBuilder: (context, index) {
                int num = index + 1;
                String displayNum = num < 10 ? "0$num" : "$num";
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(displayNum, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(
                      height: 30,
                      child: TextField(
                        controller: _controllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (_) => _calculateTotal(),
                        decoration: InputDecoration(hintText: "-", isDense: true, contentPadding: EdgeInsets.zero, border: UnderlineInputBorder()),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Points:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("₹ $totalAmount", style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Bids Submitted! Total: ₹$totalAmount")),
                      );
                    },
                    child: Text("Submit", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ----------------- 8. CROSSING SCREEN -----------------
class CrossingSelectionScreen extends StatefulWidget {
  final String gameName;
  CrossingSelectionScreen({required this.gameName});

  @override
  _CrossingSelectionScreenState createState() => _CrossingSelectionScreenState();
}

class _CrossingSelectionScreenState extends State<CrossingSelectionScreen> {
  bool jodiCut = false;
  final _num1 = TextEditingController();
  final _num2 = TextEditingController();
  final _amount = TextEditingController();
  final List<Map<String, dynamic>> _addedList = [];

  void _addEntry() {
    int amt = int.tryParse(_amount.text) ?? 0;
    if (_num1.text.isNotEmpty && _num2.text.isNotEmpty && amt > 0) {
      setState(() {
        _addedList.add({
          "type": jodiCut ? "Jodi Cut" : "Crossing",
          "pair": "${_num1.text} X ${_num2.text}",
          "amount": amt,
        });
        _num1.clear();
        _num2.clear();
        _amount.clear();
      });
    }
  }

  int get totalAmount => _addedList.fold(0, (sum, item) => sum + (item['amount'] as int));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(widget.gameName, style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16, top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("0.00", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                Text("Total Balance", style: TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: jodiCut,
                    activeColor: Colors.orange,
                    onChanged: (val) => setState(() => jodiCut = val ?? false),
                  ),
                  Text("Jodi Cut", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _num1,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Number", hintText: "Number"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("X", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      TextField(
                        controller: _num2,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Number", hintText: "Number"),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: _amount,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Amount", hintText: "Amount"),
                      ),
                      SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          onPressed: _addEntry,
                          child: Text("+ Add", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Number Type", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Number", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Amount", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Divider(),
                      if (_addedList.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text("No entries added yet", style: TextStyle(color: Colors.grey)),
                        )
                      else
                        ..._addedList.map((item) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item['type']),
                                  Text(item['pair']),
                                  Text("₹ ${item['amount']}"),
                                ],
                              ),
                            )),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("₹ $totalAmount", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------- 9. WALLET SCREEN -----------------
class WalletScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wallet", style: TextStyle(color: Colors.white)), backgroundColor: Colors.black),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 30),
            color: Colors.orange,
            child: Column(
              children: [
                Text("0.00", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                Text("Available Balance", style: TextStyle(color: Colors.white70)),
                SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () {},
                  child: Text("Add Money", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Withdraw", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(12),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildCard("Bank", Icons.account_balance),
                _buildCard("Paytm", Icons.account_balance_wallet),
                _buildCard("Google Pay", Icons.g_mobiledata),
                _buildCard("PhonePe", Icons.phone_android),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCard(String title, IconData icon) {
    return Card(
      elevation: 2,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ----------------- 10. MORE MENU SCREEN -----------------
class MoreMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("More Menu", style: TextStyle(color: Colors.white)), backgroundColor: Colors.black),
      body: ListView(
        children: [
          ListTile(leading: Icon(Icons.videogame_asset_outlined, color: Colors.blue), title: Text("My Play Game"), onTap: () {}),
          ListTile(leading: Icon(Icons.account_balance_wallet_outlined, color: Colors.blue), title: Text("Add Money List"), onTap: () {}),
          ListTile(leading: Icon(Icons.outbox, color: Colors.blue), title: Text("Withdraw List"), onTap: () {}),
          ListTile(leading: Icon(Icons.support_agent, color: Colors.green), title: Text("Help"), onTap: () {}),
          ListTile(leading: Icon(Icons.lock_outline, color: Colors.blue), title: Text("Change Password"), onTap: () {}),
          ListTile(leading: Icon(Icons.share, color: Colors.green), title: Text("Share & Earn"), onTap: () {}),
          ListTile(leading: Icon(Icons.description_outlined, color: Colors.blue), title: Text("Terms & Condition"), onTap: () {}),
          ListTile(
            leading: Icon(Icons.power_settings_new, color: Colors.red),
            title: Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          ),
        ],
      ),
    );
  }
}
