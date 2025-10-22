import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// This is a standalone script to create admin users in Firestore
// Run this script with: flutter run -t lib/admin_creator.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const AdminCreatorApp());
}

class AdminCreatorApp extends StatelessWidget {
  const AdminCreatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Creator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AdminCreatorScreen(),
    );
  }
}

class AdminCreatorScreen extends StatefulWidget {
  const AdminCreatorScreen({super.key});

  @override
  State<AdminCreatorScreen> createState() => _AdminCreatorScreenState();
}

class _AdminCreatorScreenState extends State<AdminCreatorScreen> {
  bool _isLoading = false;
  String _status = 'Ready to create admin users';
  final List<String> _logs = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Wait a moment for the app to fully initialize before creating admins
    Future.delayed(const Duration(seconds: 1), () {
      createAdminUsers();
    });
  }

  Future<void> createAdminUsers() async {
    setState(() {
      _isLoading = true;
      _status = 'Creating admin users...';
    });

    try {
      // Admin accounts to create
      final adminAccounts = [
        {'email': 'admin@example.com', 'name': 'Admin User'},
        {'email': 'admin2@gmail.com', 'name': 'Admin2 User'},
      ];

      for (final admin in adminAccounts) {
        final email = admin['email']!;
        final name = admin['name']!;
        
        // Generate consistent user ID based on email
        final userId = 'dev-${email.hashCode}';
        
        _addLog('Creating admin: $email (ID: $userId)');
        
        // First check if admin exists in users collection
        final userDoc = await _firestore.collection('users').doc(userId).get();
        
        if (userDoc.exists) {
          _addLog('User document already exists for $email');
          
          // Update to ensure admin role
          await _firestore.collection('users').doc(userId).update({
            'role': 'admin',
            'updatedAt': FieldValue.serverTimestamp(),
          });
          _addLog('Updated user document with admin role');
        } else {
          _addLog('User document does not exist for $email, creating now');
          
          // Create user document
          await _firestore.collection('users').doc(userId).set({
            'id': userId,
            'email': email,
            'name': name,
            'role': 'admin',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'isActive': true,
          });
          _addLog('Created user document for $email');
        }
        
        // Now check admins collection
        final adminDoc = await _firestore.collection('admins').doc(userId).get();
        
        if (adminDoc.exists) {
          _addLog('Admin document already exists for $email');
          
          // Update to ensure all fields are set correctly
          await _firestore.collection('admins').doc(userId).update({
            'email': email,
            'name': name,
            'role': 'admin',
            'updatedAt': FieldValue.serverTimestamp(),
          });
          _addLog('Updated admin document');
        } else {
          _addLog('Admin document does not exist for $email, creating now');
          
          // Create admin document
          await _firestore.collection('admins').doc(userId).set({
            'id': userId,
            'email': email,
            'name': name,
            'role': 'admin',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'isActive': true,
          });
          _addLog('Created admin document for $email');
        }
        
        // Verify documents exist
        final verifyUser = await _firestore.collection('users').doc(userId).get();
        final verifyAdmin = await _firestore.collection('admins').doc(userId).get();
        
        if (verifyUser.exists && verifyAdmin.exists) {
          _addLog('✅ Successfully created/updated admin $email in both collections');
        } else {
          _addLog('⚠️ Admin $email is missing from one or more collections!');
        }
      }
      
      setState(() {
        _status = 'Admin users created successfully';
      });
    } catch (e) {
      _addLog('❌ Error creating admin users: $e');
      setState(() {
        _status = 'Error creating admin users: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _addLog(String log) {
    setState(() {
      _logs.add('${DateTime.now().toString().split('.').first}: $log');
    });
    debugPrint(log);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Admin User Creator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: $_status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
            const Text('Logs:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) => Text(_logs[index]),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : createAdminUsers,
        tooltip: 'Create Admins',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}