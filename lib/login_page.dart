import 'package:flutter/material.dart';
import 'main_page.dart';
import 'theme/app_theme.dart';
import 'services/location_data_services.dart';
import 'widgets/location_autocomplete_field.dart';
import 'services/profile_store.dart';
import 'pages/language_selection_page.dart';
import 'theme/responsive.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();


  bool isRegistering = false;
  bool obscurePassword = true;
  bool locationsLoaded = false;
  String selectedRole = "Citizen";
  LocationOption? selectedRegion;
  LocationOption? selectedProvince;
  LocationOption? selectedCity;
  LocationOption? selectedBarangay;

  LocationDataService get locationService => LocationDataService.instance;
  bool get isNcrSelected => locationService.isNcr(selectedRegion?.code);

  List<LocationOption> get provinceOptions =>
    locationService.provincesForRegion(selectedRegion?.code);

  List<LocationOption> get cityOptions =>
    locationService.citiesForProvince(
      selectedRegion?.code,
      selectedProvince?.code,
    );

  List<LocationOption> get barangayOptions =>
    locationService.barangaysForCity(
      selectedRegion?.code,
      selectedProvince?.code,
      selectedCity?.code,
    );

  final List<String> roles = const [
    "Citizen",
    "Field Health Worker",
    "LGU/DOH User",
  ];

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
      const UserProfile(
        fullName: "Guest User",
        email: "guest@healthphplus.local",
        role: "Guest Tester",
        regionCode: "",
        regionLabel: "",
        province: "",
        city: "",
        barangay: "",
      ),
    );

    _goToLanguageSelection();
  }

  void _submit() {
    if(!_formKey.currentState!.validate()) return;
    if (isRegistering &&
        (selectedRegion == null ||
            (!isNcrSelected && selectedProvince == null) ||
            selectedCity == null ||
            selectedBarangay == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete your address.")),
      );
      return;
    }
  

    ScaffoldMessenger.of(context).showSnackBar (
      SnackBar(
       content: Text(isRegistering ? "Account created." : "Logging in ..."),
    ),
    );

    if (isRegistering) {
      ProfileStore.instance.saveProfile(
        UserProfile(
          fullName: fullNameController.text.trim(),
          email: emailController.text.trim(),
          role: selectedRole,
          regionCode: selectedRegion!.code,
          regionLabel: selectedRegion!.label,
          province: selectedProvince?.name ?? selectedRegion!.name,
          city: selectedCity!.name,
          barangay: selectedBarangay!.name,
          ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isRegistering ? "Account Created." : "Logging in ..."),
        ),
    );

  _goToLanguageSelection();

   if (isRegistering) {
    ProfileStore.instance.saveProfile(
      UserProfile(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        role: selectedRole,
        regionCode: selectedRegion!.code,
        regionLabel: selectedRegion!.label,
        province: selectedProvince?.name ?? selectedRegion!.name,
        city: selectedCity!.name,
        barangay: selectedBarangay!.name,
      ),
    );
   }
  }

  void _showPasswordResetDialog(){
    final resetEmailController = TextEditingController(text: emailController.text);

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
      return"Enter a valid email";
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    if(value == null || value.isEmpty) {
      return "Enter your password";
    }

    if (value.length < 6) {
      return "Password must be at least 6 characters";
    } 
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if(!isRegistering) return null;

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
                  constraints: BoxConstraints(maxWidth: Responsive.formMaxWidth(context)),
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
                          DropdownButtonFormField<String>(
                            initialValue: selectedRole,
                            decoration: const InputDecoration(
                              labelText: "Role",
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            items: roles.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            onChanged: (value) {
                                setState(() {
                                  selectedRole = value ?? "Citizen";
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
                          
                          if (!isNcrSelected) ...[
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
                            label: "City / Municipality",
                            icon: Icons.apartment_outlined,
                            enabled: isNcrSelected ? selectedRegion != null : selectedProvince != null,
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

                        if(!isRegistering) ...[
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