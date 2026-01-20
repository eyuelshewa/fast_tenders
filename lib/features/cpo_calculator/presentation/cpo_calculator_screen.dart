import 'package:fast_tenders/features/cpo_calculator/domain/cpo_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import 'widgets/cpo_result_card.dart';

class CpoCalculatorScreen extends StatefulWidget {
  const CpoCalculatorScreen({super.key});

  @override
  State<CpoCalculatorScreen> createState() => _CpoCalculatorScreenState();
}

class _CpoCalculatorScreenState extends State<CpoCalculatorScreen> {
  final _bidController = TextEditingController();
  final _valueController = TextEditingController(text: '1'); // Default 1%

  CpoType _selectedType = CpoType.percentage;
  double _calculatedCpo = 0;

  @override
  void initState() {
    super.initState();
    _bidController.addListener(_calculate);
    _valueController.addListener(_calculate);
  }

  @override
  void dispose() {
    _bidController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _calculate() {
    final bid = double.tryParse(_bidController.text.replaceAll(',', '')) ?? 0;
    final value =
        double.tryParse(_valueController.text.replaceAll(',', '')) ?? 0;

    setState(() {
      _calculatedCpo = CpoCalculator.calculate(
        bidAmount: bid,
        type: _selectedType,
        value: value,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CPO Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Calculate your Bid Bond (CPO) instantly.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Bid Amount Input
            TextField(
              controller: _bidController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Total Bid Amount',
                prefixText: 'ETB ',
                helperText: 'Enter the total amount of your offer',
              ),
            ),
            const SizedBox(height: 16),

            // Toggle Type
            Row(
              children: [
                Expanded(
                  child: RadioListTile<CpoType>(
                    title: const Text('Percentage (%)'),
                    value: CpoType.percentage,
                    groupValue: _selectedType,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                        // Set default percentage if switching back
                        if (_valueController.text.isEmpty ||
                            double.tryParse(_valueController.text)! > 100) {
                          _valueController.text = '1';
                        }
                        _calculate();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<CpoType>(
                    title: const Text('Fixed Amount'),
                    value: CpoType.fixed,
                    groupValue: _selectedType,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                        _valueController.text = ''; // Clear for fixed input
                        _calculate();
                      });
                    },
                  ),
                ),
              ],
            ),

            // Value Input (Percentage or Fixed Amount)
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: InputDecoration(
                labelText: _selectedType == CpoType.percentage
                    ? 'Percentage'
                    : 'Fixed Amount',
                suffixText: _selectedType == CpoType.percentage ? '%' : 'ETB',
                prefixText: _selectedType == CpoType.fixed ? 'ETB ' : null,
              ),
            ),
            const SizedBox(height: 32),

            // Result
            CpoResultCard(amount: _calculatedCpo),

            const SizedBox(height: 24),

            // Action Button
            ElevatedButton.icon(
              onPressed: _calculatedCpo > 0
                  ? () {
                      // TODO: Generate PDF
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Generating CPO Request Letter... (Coming Soon)',
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generate Bank CPO Request Letter'),
            ),
          ],
        ),
      ),
    );
  }
}
