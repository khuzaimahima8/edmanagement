import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ============================================================
// APP
// ============================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login & Registrasi',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Arial',
      ),
      home: const LoginScreen(),
    );
  }
}

// ============================================================
// WARNA
// ============================================================

const Color hijau = Color(0xFF287548);

// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool passwordTampil = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ==========================================================
  // LOGIN
  // ==========================================================

  void prosesLogin() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login berhasil'),
        ),
      );
    }
  }

  // ==========================================================
  // INPUT
  // ==========================================================

  InputDecoration inputStyle({
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,

      hintStyle: const TextStyle(
        fontSize: 12,
        color: Color(0xFF999999),
      ),

      suffixIcon: suffixIcon,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Color(0xFF999999),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Color(0xFF999999),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: hijau,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Colors.red,
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

  Widget label(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        bottom: 5,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  // ==========================================================
  // LOGIN UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
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
                  // TOMBOL KEMBALI
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
                        painter: LogoTasPainter(),
                      ),
                    ),
                  ),

                  // ==================================================
                  // JUDUL
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
                  // SUB JUDUL
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
                  // JARAK
                  // ==================================================

                  const SizedBox(height: 40),

                  // ==================================================
                  // EMAIL
                  // ==================================================

                  label('Email'),

                  TextFormField(
                    controller: emailController,

                    keyboardType:
                        TextInputType.emailAddress,

                    textInputAction:
                        TextInputAction.next,

                    style: const TextStyle(
                      fontSize: 13,
                    ),

                    decoration: inputStyle(),

                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Email wajib diisi';
                      }

                      if (!value.contains('@')) {
                        return 'Email tidak valid';
                      }

                      return null;
                    },
                  ),

                  // ==================================================
                  // PASSWORD
                  // ==================================================

                  const SizedBox(height: 13),

                  label('Password'),

                  TextFormField(
                    controller:
                        passwordController,

                    obscureText:
                        !passwordTampil,

                    textInputAction:
                        TextInputAction.done,

                    onFieldSubmitted: (_) {
                      prosesLogin();
                    },

                    style: const TextStyle(
                      fontSize: 13,
                    ),

                    decoration: inputStyle(
                      hintText: 'Masukkan password',

                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            passwordTampil =
                                !passwordTampil;
                          });
                        },

                        icon: Icon(
                          passwordTampil
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,

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
                  // LUPA PASSWORD
                  // ==================================================

                  Align(
                    alignment:
                        Alignment.centerRight,

                    child: Padding(
                      padding:
                          const EdgeInsets.only(
                        top: 7,
                      ),

                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Halaman lupa password',
                              ),
                            ),
                          );
                        },

                        child: const Text(
                          'Lupa password ?',

                          style: TextStyle(
                            fontSize: 12,
                            color: hijau,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // TOMBOL MASUK
                  // ==================================================

                  const SizedBox(height: 70),

                  SizedBox(
                    height: 28,

                    child: ElevatedButton(
                      onPressed: prosesLogin,

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor: hijau,
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                        padding:
                            EdgeInsets.zero,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            7,
                          ),
                        ),
                      ),

                      child: const Text(
                        'MASUK',

                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // LINK DAFTAR
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
                          color:
                              Color(0xFF333333),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (context) =>
                                  const RegisterScreen(),
                            ),
                          );
                        },

                        child: const Text(
                          'Daftar di sini',

                          style: TextStyle(
                            fontSize: 12,
                            color: hijau,
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
      ),
    );
  }
}

// ============================================================
// REGISTER SCREEN
// ============================================================

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController namaController =
      TextEditingController();

  final TextEditingController handphoneController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController alamatController =
      TextEditingController();

  bool passwordTampil = false;

  @override
  void dispose() {
    namaController.dispose();
    handphoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    alamatController.dispose();

    super.dispose();
  }

  // ==========================================================
  // REGISTER
  // ==========================================================

  void prosesDaftar() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registrasi berhasil',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // INPUT STYLE
  // ==========================================================

  InputDecoration inputStyle({
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,

      hintStyle: const TextStyle(
        fontSize: 12,
        color: Color(0xFF999999),
      ),

      suffixIcon: suffixIcon,

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),

        borderSide: const BorderSide(
          color: Color(0xFF999999),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),

        borderSide: const BorderSide(
          color: Color(0xFF999999),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),

        borderSide: const BorderSide(
          color: hijau,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),

        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),

      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),

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

  Widget label(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 11,
        bottom: 5,
      ),

      child: Text(
        text,

        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  // ==========================================================
  // REGISTER UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
            ),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,

                children: [

                  // ==================================================
                  // HEADER
                  // ==================================================

                  Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 19,
                    ),

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [

                        // TOMBOL KEMBALI
                        IconButton(
                          padding:
                              EdgeInsets.zero,

                          constraints:
                              const BoxConstraints(),

                          onPressed: () {
                            Navigator.pop(
                              context,
                            );
                          },

                          icon: const Icon(
                            Icons.arrow_back,
                            size: 22,
                            color:
                                Color(0xFF333333),
                          ),
                        ),

                        // TOMBOL LANJUT
                        IconButton(
                          padding:
                              EdgeInsets.zero,

                          constraints:
                              const BoxConstraints(),

                          onPressed:
                              prosesDaftar,

                          icon: const Icon(
                            Icons.arrow_forward,
                            size: 22,
                            color:
                                Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // LOGO
                  // ==================================================

                  const SizedBox(height: 65),

                  Center(
                    child: SizedBox(
                      width: 105,
                      height: 78,

                      child: CustomPaint(
                        painter:
                            LogoTasPainter(),
                      ),
                    ),
                  ),

                  // ==================================================
                  // JUDUL
                  // ==================================================

                  const SizedBox(height: 3),

                  const Text(
                    'Selamat Datang !',

                    textAlign:
                        TextAlign.center,

                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  // ==================================================
                  // JARAK
                  // ==================================================

                  const SizedBox(height: 57),

                  // ==================================================
                  // NAMA
                  // ==================================================

                  label('Nama'),

                  TextFormField(
                    controller:
                        namaController,

                    textInputAction:
                        TextInputAction.next,

                    style: const TextStyle(
                      fontSize: 13,
                    ),

                    decoration:
                        inputStyle(),

                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Nama wajib diisi';
                      }

                      return null;
                    },
                  ),

                  // ==================================================
                  // NO HANDPHONE
                  // ==================================================

                  const SizedBox(height: 11),

                  label('No handphone'),

                  TextFormField(
                    controller:
                        handphoneController,

                    keyboardType:
                        TextInputType.phone,

                    textInputAction:
                        TextInputAction.next,

                    style: const TextStyle(
                      fontSize: 13,
                    ),

                    decoration:
                        inputStyle(),

                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return
                            'No handphone wajib diisi';
                      }

                      if (value.length < 10) {
                        return
                            'No handphone tidak valid';
                      }

                      return null;
                    },
                  ),

                  // ==================================================
                  // EMAIL
                  // ==================================================

                  const SizedBox(height: 11),

                  label('Email'),

                  TextFormField(
                    controller:
                        emailController,

                    keyboardType:
                        TextInputType.emailAddress,

                    textInputAction:
                        TextInputAction.next,

                    style: const TextStyle(
                      fontSize: 13,
                    ),

                    decoration:
                        inputStyle(),

                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return
                            'Email wajib diisi';
                      }

                      if (!value.contains('@')) {
                        return
                            'Email tidak valid';
                      }

                      return null;
                    },
                  ),

                  // ==================================================
                  // PASSWORD
                  // ==================================================

                  const SizedBox(height: 11),

                  label('Password'),

                  TextFormField(
                    controller:
                        passwordController,

                    obscureText:
                        !passwordTampil,

                    textInputAction:
                        TextInputAction.next,

                    style: const TextStyle(
                      fontSize: 13,
                    ),

                    decoration:
                        inputStyle(
                      hintText:
                          'Masukkan password',

                      suffixIcon:
                          IconButton(
                        onPressed: () {
                          setState(() {
                            passwordTampil =
                                !passwordTampil;
                          });
                        },

                        icon: Icon(
                          passwordTampil
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,

                          size: 19,

                          color:
                              const Color(
                            0xFF999999,
                          ),
                        ),
                      ),
                    ),

                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return
                            'Password wajib diisi';
                      }

                      if (value.length < 6) {
                        return
                            'Password minimal 6 karakter';
                      }

                      return null;
                    },
                  ),

                  // ==================================================
                  // ALAMAT
                  // ==================================================

                  const SizedBox(height: 11),

                  label('Alamat Lengkap'),

                  TextFormField(
                    controller:
                        alamatController,

                    textInputAction:
                        TextInputAction.done,

                    style: const TextStyle(
                      fontSize: 13,
                    ),

                    decoration:
                        inputStyle(),

                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return
                            'Alamat wajib diisi';
                      }

                      return null;
                    },
                  ),

                  // ==================================================
                  // TOMBOL DAFTAR
                  // ==================================================

                  const SizedBox(height: 48),

                  SizedBox(
                    height: 29,

                    child: ElevatedButton(
                      onPressed:
                          prosesDaftar,

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            hijau,

                        foregroundColor:
                            Colors.white,

                        elevation: 0,

                        padding:
                            EdgeInsets.zero,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            7,
                          ),
                        ),
                      ),

                      child: const Text(
                        'DAFTAR',

                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOGO TAS
// ============================================================

class LogoTasPainter
    extends CustomPainter {

  final Color color =
      const Color(0xFF287548);

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Paint paint = Paint()
      ..color = color
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap =
          StrokeCap.round
      ..strokeJoin =
          StrokeJoin.round;

    final double centerX =
        size.width / 2;

    // ========================================================
    // HANDLE LUAR
    // ========================================================

    final Path handleOuter =
        Path();

    handleOuter.moveTo(
      centerX - 18,
      31,
    );

    handleOuter.cubicTo(
      centerX - 18,
      16,
      centerX - 11,
      9,
      centerX,
      9,
    );

    handleOuter.cubicTo(
      centerX + 11,
      9,
      centerX + 18,
      16,
      centerX + 18,
      31,
    );

    canvas.drawPath(
      handleOuter,
      paint,
    );

    // ========================================================
    // HANDLE DALAM
    // ========================================================

    final Path handleInner =
        Path();

    handleInner.moveTo(
      centerX - 13,
      30,
    );

    handleInner.lineTo(
      centerX - 13,
      21,
    );

    handleInner.cubicTo(
      centerX - 13,
      14,
      centerX - 7,
      12,
      centerX,
      12,
    );

    handleInner.cubicTo(
      centerX + 7,
      12,
      centerX + 13,
      14,
      centerX + 13,
      21,
    );

    handleInner.lineTo(
      centerX + 13,
      30,
    );

    canvas.drawPath(
      handleInner,
      paint,
    );

    // ========================================================
    // BADAN TAS
    // ========================================================

    final Path bag =
        Path();

    bag.moveTo(
      centerX - 25,
      30,
    );

    bag.cubicTo(
      centerX - 30,
      31,
      centerX - 32,
      35,
      centerX - 32,
      40,
    );

    bag.lineTo(
      centerX - 36,
      71,
    );

    bag.cubicTo(
      centerX - 37,
      78,
      centerX - 33,
      82,
      centerX - 25,
      82,
    );

    bag.lineTo(
      centerX + 25,
      82,
    );

    bag.cubicTo(
      centerX + 33,
      82,
      centerX + 37,
      78,
      centerX + 36,
      71,
    );

    bag.lineTo(
      centerX + 32,
      40,
    );

    bag.cubicTo(
      centerX + 32,
      35,
      centerX + 30,
      31,
      centerX + 25,
      30,
    );

    canvas.drawPath(
      bag,
      paint,
    );

    // ========================================================
    // KONEKTOR KIRI
    // ========================================================

    final Path leftConnector =
        Path();

    leftConnector.moveTo(
      centerX - 25,
      30,
    );

    leftConnector.lineTo(
      centerX - 25,
      24,
    );

    leftConnector.lineTo(
      centerX - 19,
      24,
    );

    canvas.drawPath(
      leftConnector,
      paint,
    );

    // ========================================================
    // KONEKTOR KANAN
    // ========================================================

    final Path rightConnector =
        Path();

    rightConnector.moveTo(
      centerX + 25,
      30,
    );

    rightConnector.lineTo(
      centerX + 25,
      24,
    );

    rightConnector.lineTo(
      centerX + 19,
      24,
    );

    canvas.drawPath(
      rightConnector,
      paint,
    );

    // ========================================================
    // DAUN
    // ========================================================

    final Paint leafPaint =
        Paint()
          ..color = color
          ..style =
              PaintingStyle.fill;

    final Paint stemPaint =
        Paint()
          ..color = color
          ..style =
              PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..strokeCap =
              StrokeCap.round;

    // BATANG DAUN
    canvas.drawLine(
      Offset(centerX, 54),
      Offset(centerX, 66),
      stemPaint,
    );

    // ========================================================
    // DAUN KIRI
    // ========================================================

    final Path leafLeft =
        Path();

    leafLeft.moveTo(
      centerX,
      62,
    );

    leafLeft.cubicTo(
      centerX - 7,
      61,
      centerX - 8,
      57,
      centerX - 7,
      54,
    );

    leafLeft.cubicTo(
      centerX - 2,
      55,
      centerX + 1,
      58,
      centerX,
      62,
    );

    leafLeft.close();

    canvas.drawPath(
      leafLeft,
      leafPaint,
    );

    // ========================================================
    // DAUN KANAN
    // ========================================================

    final Path leafRight =
        Path();

    leafRight.moveTo(
      centerX,
      62,
    );

    leafRight.cubicTo(
      centerX + 7,
      61,
      centerX + 8,
      57,
      centerX + 7,
      54,
    );

    leafRight.cubicTo(
      centerX + 2,
      55,
      centerX - 1,
      58,
      centerX,
      62,
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