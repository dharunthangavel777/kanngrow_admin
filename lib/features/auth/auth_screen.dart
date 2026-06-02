import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/admin_auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    final provider = context.read<AdminAuthProvider>();
    if (_emailController.text.trim().isEmpty) return;
    
    final success = await provider.sendOtp(_emailController.text.trim());
    if (success && mounted) {
      setState(() {
        _isOtpSent = true;
      });
    }
  }

  void _verifyOtp() async {
    final provider = context.read<AdminAuthProvider>();
    if (_otpController.text.trim().isEmpty) return;

    final success = await provider.verifyOtp(
      _emailController.text.trim(),
      _otpController.text.trim(),
    );
    if (success && mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AdminAuthProvider>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo or Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.admin_panel_settings, size: 48, color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Kangrow Admin',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isOtpSent ? 'Enter the 6-digit code sent to your email.' : 'Sign in securely with an OTP to access the control center.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      if (authProvider.error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authProvider.error!,
                                  style: const TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (!_isOtpSent) ...[
                        // Email Field
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Admin Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Send OTP Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading ? null : _sendOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: authProvider.isLoading 
                              ? const SizedBox(
                                  height: 24, 
                                  width: 24, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                )
                              : const Text('Send OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ] else ...[
                        // OTP Field
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, letterSpacing: 8),
                          decoration: InputDecoration(
                            labelText: 'OTP Code',
                            counterText: '',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Verify OTP Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading ? null : _verifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: authProvider.isLoading 
                              ? const SizedBox(
                                  height: 24, 
                                  width: 24, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                )
                              : const Text('Verify & Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isOtpSent = false;
                              _otpController.clear();
                              // Optionally clear error state in provider here
                            });
                          },
                          child: const Text('Use a different email'),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
