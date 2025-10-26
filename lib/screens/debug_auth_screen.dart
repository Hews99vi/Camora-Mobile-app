import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/debug_helper.dart';

class DebugAuthScreen extends StatefulWidget {
  const DebugAuthScreen({super.key});

  @override
  State<DebugAuthScreen> createState() => _DebugAuthScreenState();
}

class _DebugAuthScreenState extends State<DebugAuthScreen> {
  final TextEditingController _emailController = TextEditingController(text: "test_user@example.com");
  final TextEditingController _passwordController = TextEditingController(text: "password123");
  final TextEditingController _nameController = TextEditingController(text: "Test User");
  
  String _statusMessage = '';
  bool _isLoading = false;
  
  Map<String, dynamic> _debugResults = {
    'firestoreUsers': <Map<String, dynamic>>[],
    'sharedPrefUsers': <Map<String, dynamic>>[],
    'firestoreCount': 0,
    'sharedPrefCount': 0,
  };
  
  bool _showDebugResults = false;

  @override
  void initState() {
    super.initState();
    // Run a debug check when the screen loads
    _debugAllUsers();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createTestUser() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Creating test user...';
      _showDebugResults = false;
    });

    try {
      final user = await DebugHelper.createAndVerifyUser(
        _emailController.text,
        _passwordController.text,
        _nameController.text
      );

      if (user != null) {
        setState(() {
          _statusMessage = 'Successfully created user: ${user.email}';
        });
        
        // Refresh debug info after creating user
        await _debugAllUsers();
      } else {
        setState(() {
          _statusMessage = 'Failed to create user - see console for details';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _debugAllUsers() async {
    setState(() {
      _isLoading = true;
      if (!_showDebugResults) {
        _statusMessage = 'Checking all users...';
      }
    });

    try {
      final results = await DebugHelper.debugAllUsers();
      setState(() {
        _debugResults = results;
        _statusMessage = 'Found ${results['firestoreCount']} users in Firestore and ${results['sharedPrefCount']} in SharedPreferences';
        _showDebugResults = true;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _fixUserStorage() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Fixing user storage...';
      _showDebugResults = false;
    });

    try {
      final success = await DebugHelper.fixUserStorage();
      
      if (success) {
        setState(() {
          _statusMessage = 'Successfully fixed user storage';
        });
        
        // Refresh debug info
        await _debugAllUsers();
      } else {
        setState(() {
          _statusMessage = 'Failed to fix user storage - see console for details';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Authentication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Debug Authentication',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Storage status card
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Storage Status',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Firestore users: ${_debugResults['firestoreCount']}'),
                          Text('SharedPrefs users: ${_debugResults['sharedPrefCount']}'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _debugAllUsers,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text('Refresh'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _fixUserStorage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              child: const Text('Fix Storage'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Create user card
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create Test User',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createTestUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Create Test User'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Debug results
              if (_showDebugResults)
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User List',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('Firestore Users:'),
                        const SizedBox(height: 4),
                        for (var user in _debugResults['firestoreUsers'] as List<dynamic>)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('• ${user['email']} (${user['id']})'),
                          ),
                        const SizedBox(height: 16),
                        const Text('SharedPreferences Users:'),
                        const SizedBox(height: 4),
                        for (var user in _debugResults['sharedPrefUsers'] as List<dynamic>)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('• ${user['email']} (${user['userId']})'),
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              
              ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Back to Login'),
              ),
              const SizedBox(height: 24),
              if (_statusMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey.shade200,
                  child: Text(
                    _statusMessage,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}