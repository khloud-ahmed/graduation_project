import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';
import '../screens/home_screen.dart';
final logger = Logger();

class LoginPage extends StatefulWidget {
  final String? successMessage;

  const LoginPage({super.key, this.successMessage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
@override
void initState() {
  super.initState();
  if (widget.successMessage != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.successMessage!)),
      );
    });
  }
}
Future<void> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Google login successful")),
    );

    // Navigator.pushReplacement(...); // لو حابة تروحي لصفحة رئيسية بعد تسجيل الدخول

  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Google login error: $e")),
    );
  }
}
Future<void> signInWithEmail() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter both email and password")),
    );
    return;
  }

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Login successful")),
    );

    // هنا تروحي على الصفحة الرئيسية بعد تسجيل الدخول (عدليها حسب مشروعك)
   // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const home_screen()));
final user = FirebaseAuth.instance.currentUser!;

Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => HomeScreen(
      userId: user.uid,
      userName: user.displayName ?? "User",
    ),
  ),
);
  } on FirebaseAuthException catch (e) {
    if (!mounted) return;
    String errorMessage = "An error occurred";

    if (e.code == 'invalid-credential') {
      errorMessage = "Invalid email or password";
    } else if (e.code == 'user-not-found') {
      errorMessage = "No user found for that email";
    } else if (e.code == 'wrong-password') {
      errorMessage = "Wrong password provided";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  } catch (e) {
    logger.e('Login error: $e');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Something went wrong. Please try again.")),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            const Text("Welcome Back 👋", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Sign in to continue using the app", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: signInWithGoogle,
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: const Text("Continue with Google"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                filled: true,
                fillColor: Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: "Password",
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                   Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
      );

                },
                child: const Text("Forgot Password?", style: TextStyle(color: Colors.blue)),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: signInWithEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Login"),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpPage()),
    );
  },
  child: const Text("Sign Up", style: TextStyle(color: Colors.blue)),
)

              ],
            )
          ],
        ),
      ),
    );
  }
}
