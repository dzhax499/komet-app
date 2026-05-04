import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/email_masker.dart';
import '../bloc/auth_bloc.dart';

class ForgotPasswordOtpPage extends StatefulWidget {
  final String email;

  const ForgotPasswordOtpPage({super.key, required this.email});

  @override
  State<ForgotPasswordOtpPage> createState() => _ForgotPasswordOtpPageState();
}

class _ForgotPasswordOtpPageState extends State<ForgotPasswordOtpPage> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maskedEmail = EmailMasker.maskEmail(widget.email);

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthOtpVerified) {
            context.push(KometRoutes.forgotPasswordReset, extra: widget.email);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verifikasi Kode',
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Kode 6 digit telah dikirimkan ke email Anda:\n$maskedEmail',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: 'Masukkan 6 Digit OTP',
                    hintStyle: GoogleFonts.nunito(color: AppColors.textSecondary, fontSize: 14),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  style: GoogleFonts.nunito(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8.0,
                    color: AppColors.textPrimary
                  ),
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              if (_otpController.text.length != 6) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Masukkan 6 digit kode OTP'), backgroundColor: AppColors.error),
                                );
                                return;
                              }
                              context.read<AuthBloc>().add(
                                AuthVerifyOtpRequested(
                                  email: widget.email, 
                                  otp: _otpController.text
                                )
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 0,
                      ),
                      child: state is AuthLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Verifikasi',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
