import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'register_page.dart';
import '../../../finance/presentation/pages/main_navigation_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  late AnimationController _mascotController;
  late AnimationController _coinController;
  late Animation<double> _mascotBounce;
  late Animation<double> _coin1Float;
  late Animation<double> _coin2Float;

  @override
  void initState() {
    super.initState();
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _coinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _mascotBounce = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mascotController, curve: Curves.easeInOut),
    );
    _coin1Float = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _coinController, curve: Curves.easeInOut),
    );
    _coin2Float = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(
        parent: _coinController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _mascotController.dispose();
    _coinController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        SignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigationPage()),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEDF6EE),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ──────────────── HERO SECTION ────────────────
                _buildHeroSection(),

                // ──────────────── FORM CARD ────────────────
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return _buildForm(state is AuthLoading);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        children: [
          // Tên thương hiệu
          Text(
            'BeeSaving',
            style: GoogleFonts.quicksand(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // Mascot + floating coins
          SizedBox(
            width: 240,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Floating coin 1
                AnimatedBuilder(
                  animation: _coin1Float,
                  builder: (context, child) {
                    return Positioned(
                      top: 10 + _coin1Float.value,
                      right: 20,
                      child: const Icon(
                        Icons.monetization_on,
                        color: Color(0xFFfcd400),
                        size: 36,
                      ),
                    );
                  },
                ),
                // Floating coin 2
                AnimatedBuilder(
                  animation: _coin2Float,
                  builder: (context, child) {
                    return Positioned(
                      top: 80 + _coin2Float.value,
                      left: 16,
                      child: const Icon(
                        Icons.savings_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    );
                  },
                ),
                // Mascot bee/savings icon với bounce animation
                AnimatedBuilder(
                  animation: _mascotBounce,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _mascotBounce.value * -8),
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.primaryGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🍀', style: TextStyle(fontSize: 64)),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Speech Bubble
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryContainer, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Chào mừng bạn trở lại! Sẵn sàng thu thập thêm vàng hôm nay chưa? 🐝',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Đăng nhập',
            style: GoogleFonts.quicksand(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 24),

          // ── Email ──
          _buildInputLabel('Email'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
            decoration: _inputDecoration(
              hint: 'email@vi-du.com',
              icon: Icons.mail_outline_rounded,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Vui lòng nhập email';
              if (!v.contains('@')) return 'Email không hợp lệ';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ── Password ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInputLabel('Mật khẩu'),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Quên mật khẩu?',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
            decoration: _inputDecoration(
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey[500],
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
              if (v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ── Remember me ──
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (v) => setState(() => _rememberMe = v ?? false),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Ghi nhớ tôi',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Đăng nhập button ──
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _onSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Đăng nhập',
                          style: GoogleFonts.quicksand(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Link đăng ký ──
          Center(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
                children: [
                  const TextSpan(text: 'Chưa có hũ vàng nào? '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Đăng ký tài khoản mới',
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.quicksand(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
        letterSpacing: 0.2,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.quicksand(
        color: Colors.grey[400],
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFEDF6EE),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
