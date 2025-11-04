import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'heart_rate_tab.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//noti plug
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(ElderlyCareApp());
}

/// Home Page
class ElderlyCareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ElderNest App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),

      /// Routes
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => BottomTabScreen(),
        '/register': (context) => RegisterScreen(),
        '/menu': (context) => MenuTab(),
      },
    );
  }
}

/// Bottom Panel

class BottomTabScreen extends StatefulWidget {
  final bool showWelcome;

  const BottomTabScreen({Key? key, this.showWelcome = false}) : super(key: key);

  @override
  _BottomTabScreenState createState() => _BottomTabScreenState();
}

class _BottomTabScreenState extends State<BottomTabScreen> {
  int _currentIndex = 0;
  late final HomeTab _homeTab;
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _homeTab = HomeTab(showWelcome: widget.showWelcome);

    _screens = [
      _homeTab,
      HeartRateTab(),
      MedicineTab(),
      ProfileTab(),
      MenuTab(),
    ];
  }

  // frnted
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Heart'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medicine',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }
}

/// Home Tab

class HomeTab extends StatefulWidget {
  final bool showWelcome;

  const HomeTab({Key? key, this.showWelcome = false}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  bool _showWelcomeOverlay = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String _uniqueCode = '';

  @override
  void initState() {
    super.initState();
    loadUniqueCode();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    if (widget.showWelcome) {
      setState(() {
        _showWelcomeOverlay = true;
      });

      _controller.forward();

      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          _controller.reverse().then((_) {
            setState(() {
              _showWelcomeOverlay = false;
            });
          });
        }
      });
    }
  }

  void loadUniqueCode() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('uniqueCode') ?? 'Not found';
    setState(() {
      _uniqueCode = code;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🏘 Home'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Unique Code Card
                Container(
                  color: Colors.teal[50],
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('UC :', style: TextStyle(fontSize: 18)),
                      Row(
                        children: [
                          Text(
                            _uniqueCode,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.volunteer_activism, color: Colors.teal),
                        ],
                      ),
                    ],
                  ),
                ),

                // Info Cards
                _infoCard(Icons.medical_services, "Total Children Added", "2"),
                _infoCard(Icons.medication, "Active Prescriptions", "5"),
                _infoCard(
                  Icons.warning,
                  "Upcoming Doses Today",
                  "3",
                  iconColor: Colors.red,
                ),

                // Care of Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Care of",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Card(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text("Elder Nest..."),
                  ),
                ),
              ],
            ),
          ),

          // Welcome Overlay
          if (_showWelcomeOverlay)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Welcome to ElderNest!',
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        CircularProgressIndicator(color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoCard(
    IconData icon,
    String label,
    String value, {
    Color iconColor = Colors.black,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: iconColor),
            SizedBox(width: 16),
            Expanded(child: Text(label, style: TextStyle(fontSize: 16))),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// Medicine Tab

class MedicineTab extends StatefulWidget {
  @override
  _MedicineTabState createState() => _MedicineTabState();
}

class _MedicineTabState extends State<MedicineTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('👨🏾‍⚕️ Medicine'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Medicine',
                hintText: 'Enter medicine name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {},
              onSubmitted: (value) {},
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(Icons.alarm),
              label: Text('Set Reminder'),
              onPressed: () {},
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.medical_services),
              label: Text('View Medicines'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

//profile
class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String name = '';
  String email = '';
  String uniqueCode = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'NA';
      email = prefs.getString('email') ?? 'NA';
      uniqueCode = prefs.getString('uniqueCode') ?? 'NA';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('👤 Profile'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            SizedBox(height: 20),

            // Name Card
            _profileInfoCard(Icons.badge, 'Name', name),

            // Email Card
            _profileInfoCard(Icons.email, 'Email', email),

            // Unique Code Card
            _profileInfoCard(Icons.qr_code, 'Unique Code', uniqueCode),

            SizedBox(height: 30),
            Divider(thickness: 1.2),
            Text(
              'View and edit your profile.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileInfoCard(IconData icon, String title, String value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.teal),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

class MenuTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📝 Menu'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Section Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'User Actions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Logout Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Log out of your account',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.exit_to_app),
                      label: Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (Route<dynamic> route) => false,
                        );
                      },
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
}
