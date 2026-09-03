import 'package:flutter/material.dart';

void main() {
  runApp(const RegisterPage());
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF287548),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

// ============================================================
// LOGIN PAGE
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool _obscurePassword = true;

  // Warna hijau utama
  static const Color primaryGreen = Color(0xFF287548);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ==========================================================
  // LOGIN
  // ==========================================================

  void _login() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login berhasil diproses'),
        ),
      );

      
      // Hubungkan ke API / Firebase / database di sini.
    }
  }

  // ==========================================================
  // FORGOT PASSWORD
  // ==========================================================

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Halaman lupa password'),
      ),
    );
  }

  // ==========================================================
  // REGISTER
  // ==========================================================

  void _register() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Halaman pendaftaran'),
      ),
    );
  }

  // ==========================================================
  // TEXT FIELD
  // ==========================================================

  InputDecoration _inputDecoration({
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF999999),
        fontSize: 12,
      ),
      filled: false,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),

      suffixIcon: suffixIcon,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Color(0xFF999999),
          width: 1,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Color(0xFF999999),
          width: 1,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: primaryGreen,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  // ==========================================================
  // LABEL
  // ==========================================================

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 13,
        bottom: 6,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF333333),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),

                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 38,
                  ),

                  child: Form(
                    key: _formKey,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,

                      children: [

                        // ==================================================
                        // BACK BUTTON
                        // ==================================================

                        Align(
                          alignment: Alignment.centerLeft,

                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 20,
                            ),

                            child: IconButton(
                              padding: EdgeInsets.zero,

                              constraints:
                                  const BoxConstraints(),

                              onPressed: () {
                                Navigator.maybePop(context);
                              },

                              icon: const Icon(
                                Icons.arrow_back,
                                size: 23,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                        ),

                        // ==================================================
                        // LOGO
                        // ==================================================

                        const SizedBox(height: 54),

                        Center(
                          child: SizedBox(
                            width: 125,
                            height: 90,

                            child: CustomPaint(
                              painter: ShoppingBagPainter(),
                            ),
                          ),
                        ),

                        // ==================================================
                        // TITLE
                        // ==================================================

                        const SizedBox(height: 2),

                        const Text(
                          'Selamat Datang !',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        // ==================================================
                        // SUBTITLE
                        // ==================================================

                        const SizedBox(height: 3),

                        const Text(
                          'Masuk untuk melanjutkan',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF444444),
                          ),
                        ),

                        // ==================================================
                        // SPACING
                        // ==================================================

                        const SizedBox(height: 40),

                        // ==================================================
                        // EMAIL
                        // ==================================================

                        _label('Email'),

                        TextFormField(
                          controller: emailController,

                          keyboardType:
                              TextInputType.emailAddress,

                          textInputAction:
                              TextInputAction.next,

                          style: const TextStyle(
                            fontSize: 13,
                          ),

                          decoration:
                              _inputDecoration(),

                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Email wajib diisi';
                            }

                            if (!value.contains('@')) {
                              return 'Masukkan email yang valid';
                            }

                            return null;
                          },
                        ),

                        // ==================================================
                        // PASSWORD
                        // ==================================================

                        const SizedBox(height: 13),

                        _label('Password'),

                        TextFormField(
                          controller: passwordController,

                          obscureText: _obscurePassword,

                          textInputAction:
                              TextInputAction.done,

                          onFieldSubmitted: (_) {
                            _login();
                          },

                          style: const TextStyle(
                            fontSize: 13,
                          ),

                          decoration: _inputDecoration(
                            hintText:
                                'Masukkan password',

                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword =
                                      !_obscurePassword;
                                });
                              },

                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,

                                size: 19,

                                color: const Color(
                                  0xFF999999,
                                ),
                              ),
                            ),
                          ),

                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'Password wajib diisi';
                            }

                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }

                            return null;
                          },
                        ),

                        // ==================================================
                        // FORGOT PASSWORD
                        // ==================================================

                        Align(
                          alignment: Alignment.centerRight,

                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 7,
                            ),

                            child: GestureDetector(
                              onTap: _forgotPassword,

                              child: const Text(
                                'Lupa password ?',

                                style: TextStyle(
                                  color: primaryGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ==================================================
                        // LOGIN BUTTON
                        // ==================================================

                        const SizedBox(height: 70),

                        SizedBox(
                          height: 28,

                          child: ElevatedButton(
                            onPressed: _login,

                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  primaryGreen,

                              foregroundColor:
                                  Colors.white,

                              elevation: 0,

                              padding:
                                  EdgeInsets.zero,

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(7),
                              ),
                            ),

                            child: const Text(
                              'MASUK',

                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // ==================================================
                        // REGISTER
                        // ==================================================

                        const SizedBox(height: 11),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [

                            const Text(
                              'Belum punya akun? ',

                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF333333),
                              ),
                            ),

                            GestureDetector(
                              onTap: _register,

                              child: const Text(
                                'Daftar di sini',

                                style: TextStyle(
                                  fontSize: 12,
                                  color: primaryGreen,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// SHOPPING BAG LOGO
// ============================================================

class ShoppingBagPainter extends CustomPainter {
  final Color color = const Color(0xFF287548);

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double centerX = size.width / 2;

    // ========================================================
    // HANDLE LUAR
    // ========================================================

    final Path handleOuter = Path();

    handleOuter.moveTo(
      centerX - 19,
      32,
    );

    handleOuter.cubicTo(
      centerX - 19,
      16,
      centerX - 12,
      9,
      centerX,
      9,
    );

    handleOuter.cubicTo(
      centerX + 12,
      9,
      centerX + 19,
      16,
      centerX + 19,
      32,
    );

    canvas.drawPath(
      handleOuter,
      paint,
    );

    // ========================================================
    // HANDLE DALAM
    // ========================================================

    final Path handleInner = Path();

    handleInner.moveTo(
      centerX - 14,
      31,
    );

    handleInner.lineTo(
      centerX - 14,
      22,
    );

    handleInner.cubicTo(
      centerX - 14,
      14,
      centerX - 8,
      12,
      centerX,
      12,
    );

    handleInner.cubicTo(
      centerX + 8,
      12,
      centerX + 14,
      14,
      centerX + 14,
      22,
    );

    handleInner.lineTo(
      centerX + 14,
      31,
    );

    canvas.drawPath(
      handleInner,
      paint,
    );

    // ========================================================
    // BADAN TAS
    // ========================================================

    final Path bag = Path();

    bag.moveTo(
      centerX - 27,
      31,
    );

    bag.cubicTo(
      centerX - 32,
      32,
      centerX - 34,
      35,
      centerX - 34,
      40,
    );

    bag.lineTo(
      centerX - 38,
      73,
    );

    bag.cubicTo(
      centerX - 39,
      81,
      centerX - 35,
      84,
      centerX - 27,
      84,
    );

    bag.lineTo(
      centerX + 27,
      84,
    );

    bag.cubicTo(
      centerX + 35,
      84,
      centerX + 39,
      81,
      centerX + 38,
      73,
    );

    bag.lineTo(
      centerX + 34,
      40,
    );

    bag.cubicTo(
      centerX + 34,
      35,
      centerX + 32,
      32,
      centerX + 27,
      31,
    );

    canvas.drawPath(
      bag,
      paint,
    );

    // ========================================================
    // PENGHUBUNG HANDLE KIRI
    // ========================================================

    final Path leftConnector = Path();

    leftConnector.moveTo(
      centerX - 27,
      31,
    );

    leftConnector.lineTo(
      centerX - 27,
      25,
    );

    leftConnector.lineTo(
      centerX - 21,
      25,
    );

    canvas.drawPath(
      leftConnector,
      paint,
    );

    // ========================================================
    // PENGHUBUNG HANDLE KANAN
    // ========================================================

    final Path rightConnector = Path();

    rightConnector.moveTo(
      centerX + 27,
      31,
    );

    rightConnector.lineTo(
      centerX + 27,
      25,
    );

    rightConnector.lineTo(
      centerX + 21,
      25,
    );

    canvas.drawPath(
      rightConnector,
      paint,
    );

    // ========================================================
    // DAUN
    // ========================================================

    final Paint leafPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Batang daun
    final Paint stemPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(centerX, 57),
      Offset(centerX, 68),
      stemPaint,
    );

    // ========================================================
    // DAUN UTAMA KIRI
    // ========================================================

    final Path leafLeft = Path();

    leafLeft.moveTo(
      centerX,
      64,
    );

    leafLeft.cubicTo(
      centerX - 7,
      63,
      centerX - 9,
      59,
      centerX - 8,
      55,
    );

    leafLeft.cubicTo(
      centerX - 3,
      56,
      centerX + 1,
      59,
      centerX,
      64,
    );

    leafLeft.close();

    canvas.drawPath(
      leafLeft,
      leafPaint,
    );

    // ========================================================
    // DAUN UTAMA KANAN
    // ========================================================

    final Path leafRight = Path();

    leafRight.moveTo(
      centerX,
      64,
    );

    leafRight.cubicTo(
      centerX + 7,
      63,
      centerX + 9,
      59,
      centerX + 8,
      55,
    );

    leafRight.cubicTo(
      centerX + 3,
      56,
      centerX - 1,
      59,
      centerX,
      64,
    );

    leafRight.close();

    canvas.drawPath(
      leafRight,
      leafPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}