import 'dart:convert';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_colors.dart';
import 'package:fast_tenders/core/providers/tender_provider.dart';
import '../features/auth/data/auth_controller.dart';

class BusinessProfileScreen extends ConsumerStatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  ConsumerState<BusinessProfileScreen> createState() =>
      _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends ConsumerState<BusinessProfileScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 7;
  bool _isLoading = true;

  // Form Data State
  Map<String, dynamic> _formData = {
    // Step 1
    'businessName': '',
    'businessType': 'Supplier',
    'sectors': <String>[],
    // Step 2
    'licenseCategory': null,
    'licenseGrade': null,
    'vatRegistered': null,
    'taxCompliance': 'Unknown',
    // Step 3
    'maxContractSize': '< 500k ETB',
    'bidBondComfort': 'Up to 20k',
    // Step 4
    'yearsInOperation': '',
    'projectsCompleted': '',
    'majorClient': '',
    // Step 5
    'preferredInstitutions': <String>[],
    'operatingRegions': <String>[],
    // Step 6
    'alertMatch': true,
    'alertFavorite': true,
    'alertDeadline': false,
    'alertCompetitor': false,
  };

  @override
  void initState() {
    super.initState();
    _loadSavedProgress();
  }

  Future<void> _loadSavedProgress() async {
    // Wait for the user to be available from the provider
    final userAsync = ref.read(currentUserProvider);
    final user = userAsync.value;

    // 1. Try to load from Supabase first (source of truth for existing profile)
    if (user != null) {
      try {
        final profile = await Supabase.instance.client
            .from('business_profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle()
            .timeout(const Duration(seconds: 10));

        if (profile != null) {
          setState(() {
            _formData = {
              ..._formData,
              'businessName': profile['business_name'] ?? '',
              'businessType': profile['business_type'] ?? 'Supplier',
              'sectors': List<String>.from(profile['sectors'] ?? []),
              'licenseCategory': profile['license_category'],
              'licenseGrade': profile['license_grade'],
              'vatRegistered': profile['vat_registered'],
              'taxCompliance': profile['tax_compliance'] ?? 'Unknown',
              'maxContractSize': profile['max_contract_size'] ?? '< 500k ETB',
              'bidBondComfort': profile['bid_bond_comfort'] ?? 'Up to 20k',
              'yearsInOperation': profile['years_in_operation'] ?? '',
              'projectsCompleted': profile['projects_completed'] ?? '',
              'majorClient': profile['major_client'] ?? '',
              'preferredInstitutions': List<String>.from(
                profile['preferred_institutions'] ?? [],
              ),
              'operatingRegions': List<String>.from(
                profile['operating_regions'] ?? [],
              ),
              'alertMatch': profile['alert_match'] ?? true,
              'alertFavorite': profile['alert_favorite'] ?? true,
              'alertDeadline': profile['alert_deadline'] ?? false,
              'alertCompetitor': profile['alert_competitor'] ?? false,
            };
          });
        }
      } catch (e) {
        debugPrint('Error fetching existing profile: $e');
      }
    }

    // 2. Override with local draft if it exists (user was in the middle of an update)
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('business_profile_draft');
      if (savedData != null) {
        final decoded = jsonDecode(savedData) as Map<String, dynamic>;
        setState(() {
          _formData = {
            ..._formData,
            ...decoded,
            // Restore typed lists correctly
            'sectors': List<String>.from(decoded['sectors'] ?? []),
            'preferredInstitutions': List<String>.from(
              decoded['preferredInstitutions'] ?? [],
            ),
            'operatingRegions': List<String>.from(
              decoded['operatingRegions'] ?? [],
            ),
          };
        });
      }
    } catch (e) {
      debugPrint('Error loading saved profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('business_profile_draft', jsonEncode(_formData));
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentStep = index;
    });
  }

  void _updateFormData(String key, dynamic value) {
    setState(() {
      _formData[key] = value;
    });
    _saveProgress();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final progress = (_currentStep + 1) / _totalSteps;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Setup Profile',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        actions: [
          if (_currentStep > 2 && _currentStep < 6)
            TextButton(onPressed: _nextStep, child: const Text('Skip')),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // Force navigation via buttons
        onPageChanged: _onPageChanged,
        children: [
          _BusinessBasicsStep(formData: _formData, onChanged: _updateFormData),
          _LegalLicenseStep(formData: _formData, onChanged: _updateFormData),
          _FinancialCapacityStep(
            formData: _formData,
            onChanged: _updateFormData,
          ),
          _ExperienceSnapshotStep(
            formData: _formData,
            onChanged: _updateFormData,
          ),
          _TargetInstitutionsStep(
            formData: _formData,
            onChanged: _updateFormData,
          ),
          _AlertPreferencesStep(
            formData: _formData,
            onChanged: _updateFormData,
          ),
          _ReviewActivateStep(
            formData: _formData,
            onActivate: () async {
              try {
                await ref
                    .read(authControllerProvider.notifier)
                    .updateBusinessProfile(_formData);

                // Invalidate personalized feed provider to force refresh with new sectors
                ref.invalidate(myTendersProvider);

                // Clear saved draft on success
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('business_profile_draft');

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile Updated! Your feed is syncing...'),
                    ),
                  );
                  context.go('/feed');
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating profile: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: _currentStep < 6
          ? Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(_currentStep == 6 ? 'Finish' : 'Next'),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

// -----------------------------------------------------------------------------
// STEP 1: Business Basics
// -----------------------------------------------------------------------------
class _BusinessBasicsStep extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(String, dynamic) onChanged;

  const _BusinessBasicsStep({required this.formData, required this.onChanged});

  @override
  State<_BusinessBasicsStep> createState() => _BusinessBasicsStepState();
}

class _BusinessBasicsStepState extends State<_BusinessBasicsStep>
    with AutomaticKeepAliveClientMixin {
  final _businessTypes = ['Supplier', 'Contractor', 'Consultant'];
  final _sectors = [
    'IT & electronics',
    'Construction',
    'Office supplies',
    'Medical supplies',
    'Consulting',
    'Vehicles & machinery',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final selectedSectors = widget.formData['sectors'] as List<String>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            'Business Basics',
            'Tell us about your company so we can find the right tenders.',
          ),

          const SizedBox(height: 24),
          TextFormField(
            initialValue: widget.formData['businessName'],
            decoration: const InputDecoration(
              labelText: 'Business Name',
              hintText: 'e.g., Ethio Tech Solutions',
              prefixIcon: Icon(Icons.business),
            ),
            onChanged: (val) => widget.onChanged('businessName', val),
          ),

          const SizedBox(height: 24),
          Text(
            'Business Type',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _businessTypes.map((type) {
              final isSelected = widget.formData['businessType'] == type;
              return ChoiceChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) widget.onChanged('businessType', type);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          Text(
            'Primary Sector (Select all that apply)',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'We use this to recommend tenders you can actually win.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sectors.map((sector) {
              final isSelected = selectedSectors.contains(sector);
              return FilterChip(
                label: Text(sector),
                selected: isSelected,
                onSelected: (selected) {
                  final newSectors = List<String>.from(selectedSectors);
                  if (selected) {
                    newSectors.add(sector);
                  } else {
                    newSectors.remove(sector);
                  }
                  widget.onChanged('sectors', newSectors);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// STEP 2: Legal & License Info
// -----------------------------------------------------------------------------
class _LegalLicenseStep extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(String, dynamic) onChanged;

  const _LegalLicenseStep({required this.formData, required this.onChanged});

  @override
  State<_LegalLicenseStep> createState() => _LegalLicenseStepState();
}

class _LegalLicenseStepState extends State<_LegalLicenseStep>
    with AutomaticKeepAliveClientMixin {
  final _categories = [
    'General Trading',
    'Manufacturing',
    'Service',
    'Construction',
  ];
  final _grades = ['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'N/A'];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            'Legal & License Info',
            'Help us verify your eligibility.',
          ),

          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: widget.formData['licenseCategory'],
            decoration: const InputDecoration(
              labelText: 'Trade License Category',
            ),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) => widget.onChanged('licenseCategory', val),
          ),

          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: widget.formData['licenseGrade'],
            decoration: const InputDecoration(
              labelText: 'License Grade (if applicable)',
            ),
            items: _grades
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (val) => widget.onChanged('licenseGrade', val),
          ),

          const SizedBox(height: 24),
          Text(
            'VAT Registered?',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Yes'),
                  value: true,
                  groupValue: widget.formData['vatRegistered'],
                  onChanged: (val) => widget.onChanged('vatRegistered', val),
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('No'),
                  value: false,
                  groupValue: widget.formData['vatRegistered'],
                  onChanged: (val) => widget.onChanged('vatRegistered', val),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text(
              'I declare my tax compliance status is up to date.',
            ),
            subtitle: const Text('Trust-based declaration.'),
            value: widget.formData['taxCompliance'] == 'Compliant',
            onChanged: (val) => widget.onChanged(
              'taxCompliance',
              val == true ? 'Compliant' : 'Unknown',
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// STEP 3: Financial Capacity
// -----------------------------------------------------------------------------
class _FinancialCapacityStep extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(String, dynamic) onChanged;

  const _FinancialCapacityStep({
    required this.formData,
    required this.onChanged,
  });

  @override
  State<_FinancialCapacityStep> createState() => _FinancialCapacityStepState();
}

class _FinancialCapacityStepState extends State<_FinancialCapacityStep>
    with AutomaticKeepAliveClientMixin {
  final _contractSizes = ['< 500k ETB', '500k – 2M', '2M – 10M', '10M+'];
  final _bidBonds = ['Up to 20k', 'Up to 100k', '100k+'];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            'Financial Capacity',
            'This silently filters out impossible tenders.',
          ),

          const SizedBox(height: 24),
          Text(
            'Max contract size you can handle',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ..._contractSizes.map(
            (size) => RadioListTile<String>(
              title: Text(size),
              value: size,
              groupValue: widget.formData['maxContractSize'],
              onChanged: (val) => widget.onChanged('maxContractSize', val),
              contentPadding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Typical bid bond comfort',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ..._bidBonds.map(
            (bond) => RadioListTile<String>(
              title: Text(bond),
              value: bond,
              groupValue: widget.formData['bidBondComfort'],
              onChanged: (val) => widget.onChanged('bidBondComfort', val),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// STEP 4: Experience Snapshot
// -----------------------------------------------------------------------------
class _ExperienceSnapshotStep extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(String, dynamic) onChanged;

  const _ExperienceSnapshotStep({
    required this.formData,
    required this.onChanged,
  });

  @override
  State<_ExperienceSnapshotStep> createState() =>
      _ExperienceSnapshotStepState();
}

class _ExperienceSnapshotStepState extends State<_ExperienceSnapshotStep>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            'Experience Snapshot',
            'Completing this increases your tender match accuracy by 30%.',
          ),

          const SizedBox(height: 24),
          TextFormField(
            initialValue: widget.formData['yearsInOperation'],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Years in Operation',
              prefixIcon: Icon(Icons.history),
            ),
            onChanged: (val) => widget.onChanged('yearsInOperation', val),
          ),

          const SizedBox(height: 16),
          TextFormField(
            initialValue: widget.formData['projectsCompleted'],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Number of similar projects completed',
              prefixIcon: Icon(Icons.work_outline),
            ),
            onChanged: (val) => widget.onChanged('projectsCompleted', val),
          ),

          const SizedBox(height: 16),
          TextFormField(
            initialValue: widget.formData['majorClient'],
            decoration: const InputDecoration(
              labelText: 'Major past client (optional)',
              prefixIcon: Icon(Icons.apartment),
            ),
            onChanged: (val) => widget.onChanged('majorClient', val),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// STEP 5: Target Institutions & Regions
// -----------------------------------------------------------------------------
class _TargetInstitutionsStep extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(String, dynamic) onChanged;

  const _TargetInstitutionsStep({
    required this.formData,
    required this.onChanged,
  });

  @override
  State<_TargetInstitutionsStep> createState() =>
      _TargetInstitutionsStepState();
}

class _TargetInstitutionsStepState extends State<_TargetInstitutionsStep>
    with AutomaticKeepAliveClientMixin {
  final _institutions = ['Ministries', 'Universities', 'NGOs', 'SOEs'];
  final _regions = ['Addis Ababa', 'Oromia', 'Amhara', 'Nationwide'];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final selectedInstitutions =
        widget.formData['preferredInstitutions'] as List<String>;
    final selectedRegions = widget.formData['operatingRegions'] as List<String>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            'Target Institutions & Regions',
            'Hyper-relevant notifications, less spam.',
          ),

          const SizedBox(height: 24),
          Text(
            'Preferred Institutions',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          Wrap(
            spacing: 8,
            children: _institutions.map((inst) {
              final isSelected = selectedInstitutions.contains(inst);
              return FilterChip(
                label: Text(inst),
                selected: isSelected,
                onSelected: (selected) {
                  final list = List<String>.from(selectedInstitutions);
                  selected ? list.add(inst) : list.remove(inst);
                  widget.onChanged('preferredInstitutions', list);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          Text(
            'Operating Regions',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          Wrap(
            spacing: 8,
            children: _regions.map((reg) {
              final isSelected = selectedRegions.contains(reg);
              return FilterChip(
                label: Text(reg),
                selected: isSelected,
                onSelected: (selected) {
                  final list = List<String>.from(selectedRegions);
                  selected ? list.add(reg) : list.remove(reg);
                  widget.onChanged('operatingRegions', list);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// STEP 6: Alert Preferences
// -----------------------------------------------------------------------------
class _AlertPreferencesStep extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(String, dynamic) onChanged;

  const _AlertPreferencesStep({
    required this.formData,
    required this.onChanged,
  });

  @override
  State<_AlertPreferencesStep> createState() => _AlertPreferencesStepState();
}

class _AlertPreferencesStepState extends State<_AlertPreferencesStep>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Alert Preferences', 'Let users control noise early.'),

          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Matching tender published'),
            subtitle: const Text('Notify me when a tender matches my profile'),
            value: widget.formData['alertMatch'],
            onChanged: (val) => widget.onChanged('alertMatch', val),
          ),
          SwitchListTile(
            title: const Text('Favorite institution posts'),
            subtitle: const Text(
              'Notify me when my preferred institutions post',
            ),
            value: widget.formData['alertFavorite'],
            onChanged: (val) => widget.onChanged('alertFavorite', val),
          ),
          SwitchListTile(
            title: const Text('Deadline approaching'),
            subtitle: const Text('Notify me 48h before deadline'),
            value: widget.formData['alertDeadline'],
            onChanged: (val) => widget.onChanged('alertDeadline', val),
          ),
          SwitchListTile(
            title: const Text('Competitor wins'),
            subtitle: const Text(
              'Notify me when a competitor wins a similar tender',
            ),
            value: widget.formData['alertCompetitor'],
            onChanged: (val) => widget.onChanged('alertCompetitor', val),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// STEP 7: Review & Activate
// -----------------------------------------------------------------------------
class _ReviewActivateStep extends ConsumerWidget {
  final Map<String, dynamic> formData;
  final VoidCallback onActivate;

  const _ReviewActivateStep({required this.formData, required this.onActivate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(FontAwesomeIcons.rocket, size: 60, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            'Profile Ready to Sync',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Your preferences will be used to filter and recommend tenders.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),

          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildStrengthRow(
                  Icons.check_circle,
                  'Personalized tender feed',
                ),
                const SizedBox(height: 12),
                _buildStrengthRow(Icons.check_circle, 'Customized alerts'),
                const SizedBox(height: 12),
                _buildStrengthRow(
                  Icons.check_circle,
                  'Sector-specific matching',
                ),
                const SizedBox(height: 24),
                LinearProgressIndicator(
                  value: 0.9,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.success,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  'Configuration Status: Complete',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onActivate,
            icon: const Icon(Icons.sync),
            label: const Text('Save & Update My Feed'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 32),
          Text(
            'Preview of matches for your sectors:',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildTenderPreviewCard(),
        ],
      ),
    );
  }

  Widget _buildStrengthRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildTenderPreviewCard() {
    // Placeholder for "Instant Value"
    return Card(
      elevation: 0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(FontAwesomeIcons.building, size: 20),
        ),
        title: const Text('Office Supplies Procurement'),
        subtitle: const Text('Ministry of Education • 2 Days left'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

Widget _buildHeader(String title, String subtitle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        subtitle,
        style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
      ),
    ],
  );
}
