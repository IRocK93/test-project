import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_mon/presentation/providers/auth_provider.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  final String email;
  
  const VerificationScreen({super.key, required this.email});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  bool _isResending = false;
  bool _isChecking = false;
  String? _message;

  Future<void> _resendVerification() async {
    setState(() {
      _isResending = true;
      _message = null;
    });
    
    try {
      await ref.read(authProvider.notifier).sendVerificationEmail(widget.email);
      if (mounted) setState(() => _message = 'Verification email sent! Check your inbox.');
    } catch (e) {
      if (mounted) setState(() => _message = 'Failed to send verification email. Please try again.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
      _message = null;
    });
    
    try {
      final isVerified = await ref.read(authProvider.notifier).checkEmailVerified();
      if (isVerified && mounted) {
        context.go('/home');
      } else if (mounted) {
        setState(() => _message = 'Email not yet verified. Please check your inbox and click the verification link.');
      }
    } catch (e) {
      if (mounted) setState(() => _message = 'Failed to check verification status. Please try again.');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.email_outlined, size: 80, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 24),
                Text('Verify Your Email', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text('We sent a verification email to:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(widget.email, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text('Please check your inbox and click the verification link to continue.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(_message!, style: TextStyle(color: _message!.contains('Failed') ? Colors.red : Colors.green), textAlign: TextAlign.center),
                  ),
                ElevatedButton(
                  onPressed: _isChecking ? null : _checkVerification,
                  child: _isChecking ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("I've Verified, Continue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _isResending ? null : _resendVerification,
                  child: _isResending ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Resend Verification Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 24),
                TextButton(onPressed: () => context.go('/login'), child: const Text('Back to Login')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}