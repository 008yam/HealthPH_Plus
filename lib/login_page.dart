import 'localization/app_translations.dart';
import 'package:flutter/material.dart';
import 'main_page.dart';
import 'theme/app_theme.dart';
import 'services/location_data_services.dart';
import 'services/healthph_api_services.dart';
import 'widgets/location_autocomplete_field.dart';
import 'services/profile_store.dart';
import 'pages/language_selection_page.dart';
import 'theme/responsive.dart';
import 'data/app_taxonomy.dart';
import 'pages/intro_tutorial_page.dart';
import 'services/app_settings_store.dart';
import 'services/biometric_auth_service.dart';
import 'services/api_config.dart';
import 'widgets/app_notice.dart';
import 'widgets/shake_field.dart';
import 'package:flutter/services.dart';
import 'widgets/auth/pin_login_dialog.dart';
import 'widgets/auth/password_requirements.dart';

class LoginPage extends StatefulWidget {
  final bool startAsRegistering;

  const LoginPage({super.key, this.startAsRegistering = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final fullNameShakeKey = GlobalKey<ShakeFieldState>();
  final emailShakeKey = GlobalKey<ShakeFieldState>();
  final passwordShakeKey = GlobalKey<ShakeFieldState>();
  final confirmPasswordShakeKey = GlobalKey<ShakeFieldState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  late bool isRegistering;
  bool obscurePassword = true;
  bool locationsLoaded = false;
  AppOption selectedRole = AppTaxonomy.roles.first;

  String? selectedLanguage;

  final List<String> languages = const [
    "English",
    "Filipino",
    "Cebuano",
    "Ilocano",
    "Hiligaynon",
  ];

  LocationOption? selectedRegion;
  LocationOption? selectedProvince;
  LocationOption? selectedCity;
  LocationOption? selectedBarangay;

  LocationDataService get locationService => LocationDataService.instance;
  bool get isNcrSelected => locationService.isNcr(selectedRegion?.code);

  List<LocationOption> get provinceOptions =>
      locationService.provincesForRegion(selectedRegion?.code);

  List<LocationOption> get cityOptions => locationService.citiesForProvince(
    selectedRegion?.code,
    selectedProvince?.code,
  );

  List<LocationOption> get barangayOptions => locationService.barangaysForCity(
    selectedRegion?.code,
    selectedProvince?.code,
    selectedCity?.code,
  );

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    isRegistering = widget.startAsRegistering;
    _loadLocations();
  }

  void _handleBackPressed() {
    if (isRegistering) {
      setState(() {
        isRegistering = false;
      });
      return;
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
  }

  Future<UserProfile?> _showPinLoginDialog({
    required HealthPhApiService api,
    required UserProfile profile,
  }) {
    return showDialog<UserProfile>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PinLoginDialog(api: api, profile: profile),
    );
  }

  Future<void> _loadLocations() async {
    await locationService.load();

    if (!mounted) return;

    setState(() {
      locationsLoaded = true;
    });
  }

  void _goToLanguageSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LanguageSelectionPage()),
    );
  }

  void _continueAsGuest() {
    ProfileStore.instance.saveProfile(
      UserProfile(
        fullName: "Guest User",
        email: AppTaxonomy.guestEmail,
        roleId: AppTaxonomy.guestRole.id,
        role: AppTaxonomy.guestRole.label,
        language: selectedLanguage ?? "English",
        regionCode: "",
        regionLabel: "",
        province: "",
        city: "",
        barangay: "",
      ),
    );

    _goToLanguageSelection();
  }

  void _shakeInvalidFields() {
    if (isRegistering &&
        _requiredValidator(fullNameController.text, 'your full name') != null) {
      fullNameShakeKey.currentState?.shake();
    }
    if (_emailValidator(emailController.text) != null) {
      emailShakeKey.currentState?.shake();
    }
    if (_passwordValidator(passwordController.text) != null) {
      passwordShakeKey.currentState?.shake();
    }
    if (isRegistering &&
        _confirmPasswordValidator(confirmPasswordController.text) != null) {
      confirmPasswordShakeKey.currentState?.shake();
    }
  }

  String _friendlyAuthenticationError(Object error) {
    final raw = error.toString().toLowerCase();

    if (raw.contains('invalid email or password') ||
        raw.contains('incorrect password') ||
        raw.contains('401')) {
      return "The email or password is incorrect.";
    }

    if (raw.contains('already registered') ||
        raw.contains('already exists') ||
        raw.contains('duplicate') ||
        raw.contains('409')) {
      return "An account already exists for this email address.";
    }

    if (raw.contains('422') || raw.contains('validation')) {
      return "Some account details were not accepted. Please review them.";
    }

    if (raw.contains('timed out') ||
        raw.contains('timeoutexception') ||
        raw.contains('timeout')) {
      return "The server is taking too long to respond. Please try again.";
    }

    if (raw.contains('socketexception') ||
        raw.contains('clientexception') ||
        raw.contains('failed host lookup') ||
        raw.contains('connection refused') ||
        raw.contains('network is unreachable') ||
        raw.contains('no route to host')) {
      return "Unable to connect to HealthPH+. Check your internet connection.";
    }

    if (raw.contains('500') ||
        raw.contains('502') ||
        raw.contains('503') ||
        raw.contains('504') ||
        raw.contains('service unavailable')) {
      return "HealthPH+ is temporarily unavailable. Please try again later.";
    }

    if (raw.contains('404') || raw.contains('not found')) {
      return "The account service is currently unavailable.";
    }

    return "Something went wrong. Please try again.";
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState?.validate() ?? false;

    if (!formValid) {
      _shakeInvalidFields();
      AppNotice.error(
        context,
        context.tr('Please correct the highlighted fields.'),
      );
      return;
    }

    final wasRegistering = isRegistering;

    if (isRegistering &&
        (selectedRegion == null ||
            (!isNcrSelected && selectedProvince == null) ||
            selectedCity == null ||
            selectedBarangay == null)) {
      AppNotice.warning(context, context.tr("Complete your address."));
      return;
    }

    try {
      final api = HealthPhApiService(baseUrl: ApiConfig.baseUrl);
      final UserProfile savedProfile;

      if (wasRegistering) {
        final profile = UserProfile(
          fullName: fullNameController.text.trim(),
          email: emailController.text.trim(),
          roleId: "user",
          role: "User",
          regionCode: selectedRegion!.code,
          regionLabel: selectedRegion!.label,
          language: selectedLanguage!,
          province: selectedProvince?.name ?? selectedRegion!.name,
          city: selectedCity!.name,
          barangay: selectedBarangay!.name,
        );

        await api.registerMobileUser(profile, passwordController.text.trim());
        savedProfile = await api.loginMobileUser(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        savedProfile = await api.loginMobileUser(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      }

      UserProfile profileForSession = savedProfile;

      if (!wasRegistering && savedProfile.pinConfigured) {
        final verifiedProfile = await _showPinLoginDialog(
          api: api,
          profile: savedProfile,
        );

        if (verifiedProfile == null) return;

        // Keep the account details returned by email/password login.
        // The PIN dialog must still complete successfully before continuing.
        profileForSession = savedProfile;
      }

      ProfileStore.instance.saveProfile(profileForSession);

      if (AppSettingsStore.instance.fingerprintLoginEnabled) {
        await BiometricAuthService.instance.saveProfileForBiometricLogin(
          profileForSession,
        );
      }

      await AppSettingsStore.instance.setLanguage(
        profileForSession.language.isNotEmpty
            ? profileForSession.language
            : selectedLanguage ?? "English",
      );

      if (!mounted) return;

      AppNotice.success(
        context,
        wasRegistering
            ? context.tr("Account Created.")
            : context.tr("Logged in."),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              wasRegistering ? const IntroTutorialPage() : const MainPage(),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('AUTHENTICATION ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      AppNotice.error(context, context.tr(_friendlyAuthenticationError(error)));
    }
  }

  Future<void> _loginWithBiometrics() async {
    final profile = await BiometricAuthService.instance.unlockSavedProfile();

    if (!mounted) return;

    if (profile == null) {
      AppNotice.warning(
        context,
        context.tr(
          "Biometric login is unavailable. Please use password login.",
        ),
      );
      return;
    }

    ProfileStore.instance.saveProfile(profile);

    await AppSettingsStore.instance.setLanguage(
      profile.language.isNotEmpty ? profile.language : "English",
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
  }

  void _showPasswordResetDialog() {
    final resetEmailController = TextEditingController(
      text: emailController.text,
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.tr("Reset Password")),
          content: TextField(
            controller: resetEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: context.tr("Email Address"),
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.tr("Cancel")),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                AppNotice.success(
                  context,
                  context.tr("Password reset link sent."),
                );
              },
              child: Text(context.tr("Send Link")),
            ),
          ],
        );
      },
    );
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return context.tr(
        'Enter {label}',
        parameters: {'label': context.tr(label)},
      );
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.tr("Enter your email");
    }

    if (!value.contains("@")) {
      return context.tr("Enter a valid email");
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return context.tr("Enter your password");
    }

    if (value.length < 6) {
      return context.tr("Password must contain at least 6 characters");
    }

    if (!RegExp(r'^[A-Za-z0-9@!%()#]+$').hasMatch(value)) {
      return context.tr(
        "Only letters, numbers, and these symbols are allowed: @ ! % ( ) #",
      );
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return context.tr("Password must contain at least one capital letter");
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return context.tr("Password must contain at least one lowercase letter");
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return context.tr("Password must contain at least one number");
    }

    if (!RegExp(r'[@!%()#]').hasMatch(value)) {
      return context.tr(
        "Password must contain at least one symbol: @ ! % ( ) #",
      );
    }

    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (!isRegistering) return null;

    if (value != passwordController.text) {
      return context.tr("Passwords do not match");
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  Responsive.pagePadding(context),
                  18,
                  Responsive.pagePadding(context),
                  24,
                ),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxWidth: Responsive.formMaxWidth(context),
                  ),
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.cardDecoration,
                  child: Theme(
                    data: AppTheme.lightTheme,
                    child: Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              tooltip: context.tr("Back"),
                              onPressed: _handleBackPressed,
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: AppTheme.navy,
                                size: 20,
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          const SizedBox(height: 18),
                          Text(
                            isRegistering
                                ? context.tr("Create Account")
                                : context.tr("User Login"),
                            style: const TextStyle(
                              color: AppTheme.navy,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isRegistering
                                ? context.tr(
                                    "Register your basic HeathPH+ profile.",
                                  )
                                : context.tr(
                                    "Sign in using your email and password.",
                                  ),
                            style: const TextStyle(
                              color: AppTheme.mutedText,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 18),

                          if (isRegistering) ...[
                            ShakeField(
                              key: fullNameShakeKey,
                              child: TextFormField(
                                controller: fullNameController,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: context.tr("Full Name"),
                                  prefixIcon: Icon(Icons.person_outlined),
                                ),
                                validator: (value) =>
                                    _requiredValidator(value, "your full name"),
                              ),
                            ),
                          ],

                          const SizedBox(height: 13),

                          ShakeField(
                            key: emailShakeKey,
                            child: TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: context.tr("Email"),
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: _emailValidator,
                            ),
                          ),

                          const SizedBox(height: 13),

                          ShakeField(
                            key: passwordShakeKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: obscurePassword,
                                  keyboardType: TextInputType.visiblePassword,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[A-Za-z0-9@!%()#]'),
                                    ),
                                  ],
                                  onChanged: (_) {
                                    if (isRegistering) {
                                      setState(() {});
                                    }
                                  },
                                  textInputAction: isRegistering
                                      ? TextInputAction.next
                                      : TextInputAction.done,
                                  decoration: InputDecoration(
                                    errorStyle: const TextStyle(
                                      height: 0,
                                      fontSize: 0,
                                    ),
                                    labelText: context.tr("Password"),
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          obscurePassword = !obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: _passwordValidator,
                                ),
                                if (isRegistering) ...[
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Column(
                                      children: [
                                        if (isRegistering) ...[
                                          const SizedBox(height: 8),
                                          PasswordRequirements(
                                            password: passwordController.text,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          if (isRegistering) ...[
                            const SizedBox(height: 12),
                            ShakeField(
                              key: confirmPasswordShakeKey,
                              child: TextFormField(
                                controller: confirmPasswordController,
                                obscureText: obscurePassword,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: context.tr("Confirm Password"),
                                  prefixIcon: Icon(Icons.lock_reset),
                                ),
                                validator: _confirmPasswordValidator,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<AppOption>(
                              initialValue: selectedRole,
                              decoration: InputDecoration(
                                labelText: context.tr("Role"),
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              items: AppTaxonomy.roles.map((role) {
                                return DropdownMenuItem<AppOption>(
                                  value: role,
                                  child: Text(context.tr(role.label)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedRole =
                                      value ?? AppTaxonomy.roles.first;
                                });
                              },
                            ),

                            const SizedBox(height: 12),

                            DropdownButtonFormField<String>(
                              initialValue: selectedLanguage,
                              decoration: InputDecoration(
                                labelText: context.tr("Preferred Language"),
                                prefixIcon: Icon(Icons.language),
                              ),
                              items: languages.map((language) {
                                return DropdownMenuItem<String>(
                                  value: language,
                                  child: Text(language),
                                );
                              }).toList(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return context.tr(
                                    "Select your preferred language",
                                  );
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  selectedLanguage = value;
                                });
                              },
                            ),
                            const SizedBox(height: 12),

                            //DROPDOWN
                            if (!locationsLoaded)
                              const Center(child: CircularProgressIndicator())
                            else ...[
                              LocationAutocompleteField(
                                label: "Region",
                                icon: Icons.map_outlined,
                                enabled: true,
                                value: selectedRegion,
                                options: locationService.regions,
                                onSelected: (value) {
                                  setState(() {
                                    selectedRegion = value;
                                    selectedProvince = null;
                                    selectedCity = null;
                                    selectedBarangay = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),

                              if (isNcrSelected) ...[
                                TextFormField(
                                  initialValue: "NCR",
                                  enabled: false,
                                  decoration: InputDecoration(
                                    labelText: context.tr("Province"),
                                    prefixIcon: Icon(
                                      Icons.location_city_outlined,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ] else ...[
                                LocationAutocompleteField(
                                  label: "Province",
                                  icon: Icons.location_city_outlined,
                                  enabled: selectedRegion != null,
                                  value: selectedProvince,
                                  options: provinceOptions,
                                  onSelected: (value) {
                                    setState(() {
                                      selectedProvince = value;
                                      selectedCity = null;
                                      selectedBarangay = null;
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                              ],
                              LocationAutocompleteField(
                                key: ValueKey(
                                  "login_city_${selectedRegion?.code}_${selectedProvince?.code}",
                                ),
                                label: "City / Municipality",
                                icon: Icons.apartment_outlined,
                                enabled: isNcrSelected
                                    ? selectedRegion != null
                                    : selectedProvince != null,
                                value: selectedCity,
                                options: cityOptions,
                                onSelected: (value) {
                                  setState(() {
                                    selectedCity = value;
                                    selectedBarangay = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              LocationAutocompleteField(
                                key: ValueKey(
                                  "login_barangay_${selectedRegion?.code}_${selectedProvince?.code}_${selectedCity?.code}",
                                ),
                                label: "Barangay",
                                icon: Icons.home_work_outlined,
                                enabled: selectedCity != null,
                                value: selectedBarangay,
                                options: barangayOptions,
                                onSelected: (value) {
                                  setState(() {
                                    selectedBarangay = value;
                                  });
                                },
                              ),
                            ],
                          ],

                          const SizedBox(height: 12),

                          if (!isRegistering) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showPasswordResetDialog,
                                child: Text(context.tr("Forgot password?")),
                              ),
                            ),
                          ],

                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: Responsive.buttonHeight(context),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _submit,
                              child: Text(
                                isRegistering
                                    ? context.tr("Register")
                                    : context.tr("Login"),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          if (!isRegistering &&
                              AppSettingsStore
                                  .instance
                                  .fingerprintLoginEnabled) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: Responsive.buttonHeight(context),
                              child: OutlinedButton.icon(
                                onPressed: _loginWithBiometrics,
                                icon: const Icon(Icons.fingerprint),
                                label: Text(
                                  context.tr("Login with Biometrics"),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),

                          if (!isRegistering) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              height: Responsive.buttonHeight(context),
                              child: OutlinedButton.icon(
                                onPressed: _continueAsGuest,
                                icon: const Icon(Icons.person_outline),
                                label: Text(
                                  context.tr("Continue as Guest"),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],

                          Center(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  isRegistering = !isRegistering;
                                });
                              },
                              child: Text(
                                isRegistering
                                    ? context.tr(
                                        "Already have an account? Login",
                                      )
                                    : context.tr("New User? Create an account"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
