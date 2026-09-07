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
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/intro_tutorial_page.dart';

class LoginPage extends StatefulWidget {
  final bool startAsRegistering;

  const LoginPage({super.key, this.startAsRegistering = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

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

  Future<void> _loadLocations() async {
    await locationService.load();

    if (!mounted) return;

    setState(() {
      locationsLoaded = true;
    });
  }

  void _goToLanguageSelection() {
    Navigator.pushReplacement(
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final wasRegistering = isRegistering;

    if (isRegistering &&
        (selectedRegion == null ||
            (!isNcrSelected && selectedProvince == null) ||
            selectedCity == null ||
            selectedBarangay == null)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Complete your address.")));
      return;
    }

    try {
      final api = HealthPhApiService(baseUrl: "http://127.0.0.1:8000");
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

        savedProfile = await api.registerMobileUser(
          profile,
          passwordController.text.trim(),
        );
      } else {
        savedProfile = await api.loginMobileUser(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      }

      ProfileStore.instance.saveProfile(savedProfile);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        "healthph_selected_language",
        savedProfile.language.isNotEmpty
            ? savedProfile.language
            : selectedLanguage ?? "English",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(wasRegistering ? "Account Created." : "Logged in."),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => wasRegistering ? const IntroTutorialPage() : const MainPage(),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst("Exception: ", "")),
        ),
      );
    }
  }

  void _showPasswordResetDialog() {
    final resetEmailController = TextEditingController(
      text: emailController.text,
    );

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reset Password"),
          content: TextField(
            controller: resetEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Email Address",
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Pass reset link sent.")),
                );
              },
              child: const Text("Send Link"),
            ),
          ],
        );
      },
    );
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return "Enter $label";
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Enter your email";
    }

    if (!value.contains("@")) {
      return "Enter a valid email";
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter your password";
    }

    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (!isRegistering) return null;

    if (value != passwordController.text) {
      return "Passowrd do not match";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBlue,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Backdrop1.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.15),
            ),
          ),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            tooltip: "Back",
                            onPressed: _handleBackPressed,
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: AppTheme.navy,
                              size: 20,
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        Center(
                          child: Image.asset(
                            'assets/images/healthphplusbarlogo.png',
                            height: Responsive.logoHeight(context),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          isRegistering ? "Create Account" : "User Login",
                          style: const TextStyle(
                            color: AppTheme.navy,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isRegistering
                              ? "Register your basic HeathPH+ profile."
                              : "Sign in using your email and password.",
                          style: const TextStyle(
                            color: AppTheme.mutedText,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 18),

                        if (isRegistering) ...[
                          TextFormField(
                            controller: fullNameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: "Full Name",
                              prefixIcon: Icon(Icons.person_outlined),
                            ),
                            validator: (value) =>
                                _requiredValidator(value, "your full name"),
                          ),
                          const SizedBox(height: 12),
                        ],

                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: _emailValidator,
                        ),
                        const SizedBox(height: 13),

                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          textInputAction: isRegistering
                              ? TextInputAction.next
                              : TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: "Password",
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
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: obscurePassword,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: "Confirm Password",
                              prefixIcon: Icon(Icons.lock_reset),
                            ),
                            validator: _confirmPasswordValidator,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<AppOption>(
                            initialValue: selectedRole,
                            decoration: const InputDecoration(
                              labelText: "Role",
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            items: AppTaxonomy.roles.map((role) {
                              return DropdownMenuItem<AppOption>(
                                value: role,
                                child: Text(role.label),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedRole = value ?? AppTaxonomy.roles.first;
                              });
                            },
                          ),

                          const SizedBox(height: 12),
                          
                          DropdownButtonFormField<String>(
                            initialValue: selectedLanguage,
                            decoration: const InputDecoration(
                              labelText: "Preferred Language",
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
                                return "Select your preferred language";
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
                                  labelText: "Province",
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
                              child: const Text("Forgot password?"),
                            ),
                          ),
                        ],

                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: Responsive.buttonHeight(context),
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: Text(
                              isRegistering ? "Register" : "Login",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (!isRegistering) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: Responsive.buttonHeight(context),
                            child: OutlinedButton.icon(
                              onPressed: _continueAsGuest,
                              icon: const Icon(Icons.person_outline),
                              label: const Text(
                                "Continue as Guest",
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
                                  ? "Already have an account? Login"
                                  : "New User? Create an account",
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
        ],
      ),
    );
  }
}
