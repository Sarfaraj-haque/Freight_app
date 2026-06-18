import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../shared/models/freight_record.dart';
import '../../../../shared/providers/records_provider.dart';
import '../widgets/freight_calculator_banner.dart';
import '../widgets/number_field_row.dart';
import '../widgets/section_label.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key, this.existingRecord});
  final FreightRecord? existingRecord;

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late final TextEditingController _dateController;
  late final TextEditingController _truckController;
  late final TextEditingController _driverController;
  late final TextEditingController _qtyController;
  late final TextEditingController _challanQtyController;
  late final TextEditingController _rateController;
  late final TextEditingController _dieselController;
  late final TextEditingController _advanceController;
  late final TextEditingController _unloadingController;
  late final TextEditingController _shortController;

  RecordStatus _status = RecordStatus.pending;

  double get _calculatedFreight {
    final qty = double.tryParse(_qtyController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0;
    final diesel = double.tryParse(_dieselController.text) ?? 0;
    final advance = double.tryParse(_advanceController.text) ?? 0;
    final unloading = double.tryParse(_unloadingController.text) ?? 0;
    final shortAmt = double.tryParse(_shortController.text) ?? 0;
    return (qty * rate) - diesel - advance - unloading - shortAmt;
  }

  @override
  void initState() {
    super.initState();
    final r = widget.existingRecord;
    _dateController = TextEditingController(
        text: r != null
            ? AppUtils.formatDateForInput(r.date)
            : AppUtils.formatDateForInput(DateTime.now()));
    _truckController = TextEditingController(text: r?.truckNumber ?? '');
    _driverController = TextEditingController(text: r?.driverName ?? '');
    _qtyController =
        TextEditingController(text: r != null ? r.quantity.toString() : '');
    _challanQtyController = TextEditingController(
        text: r != null ? r.challanQuantity.toString() : '');
    _rateController =
        TextEditingController(text: r != null ? r.rate.toInt().toString() : '');
    _dieselController = TextEditingController(
        text: r != null ? r.diesel.toInt().toString() : '');
    _advanceController = TextEditingController(
        text: r != null ? r.advance.toInt().toString() : '');
    _unloadingController = TextEditingController(
        text: r != null ? r.unloading.toInt().toString() : '');
    _shortController = TextEditingController(
        text: r != null ? r.shortAmount.toInt().toString() : '');
    if (r != null) _status = r.status;

    for (final c in [
      _qtyController,
      _rateController,
      _dieselController,
      _advanceController,
      _unloadingController,
      _shortController,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [
      _dateController,
      _truckController,
      _driverController,
      _qtyController,
      _challanQtyController,
      _rateController,
      _dieselController,
      _advanceController,
      _unloadingController,
      _shortController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final record = FreightRecord(
      id: widget.existingRecord?.id ?? _uuid.v4(),
      date: AppUtils.parseDate(_dateController.text) ?? DateTime.now(),
      truckNumber: _truckController.text.trim().toUpperCase(),
      driverName: _driverController.text.trim(),
      quantity: double.tryParse(_qtyController.text) ?? 0,
      challanQuantity: double.tryParse(_challanQtyController.text) ?? 0,
      rate: double.tryParse(_rateController.text) ?? 0,
      diesel: double.tryParse(_dieselController.text) ?? 0,
      advance: double.tryParse(_advanceController.text) ?? 0,
      unloading: double.tryParse(_unloadingController.text) ?? 0,
      shortAmount: double.tryParse(_shortController.text) ?? 0,
      status: _status,
    );

    final provider = context.read<RecordsProvider>();
    if (widget.existingRecord != null) {
      await provider.updateRecord(record);
    } else {
      await provider.addRecord(record);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingRecord != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Record' : 'Add Record'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(70, 36),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              FreightCalculatorBanner(freight: _calculatedFreight),
              const SizedBox(height: 24),
              const SectionLabel(label: 'BASIC INFO'),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Date (YYYY-MM-DD)',
                controller: _dateController,
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: AppUtils.parseDate(_dateController.text) ??
                        DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context)
                            .colorScheme
                            .copyWith(primary: AppColors.primary),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    _dateController.text = AppUtils.formatDateForInput(picked);
                  }
                },
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Truck Number *',
                hint: 'MH12AB1234',
                controller: _truckController,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Driver / Party Name *',
                hint: 'Ramesh Kumar',
                controller: _driverController,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              const SectionLabel(label: 'QUANTITY'),
              const SizedBox(height: 12),
              NumberFieldRow(
                leftLabel: 'Quantity (Tonnes) *',
                leftHint: '0.0',
                leftController: _qtyController,
                leftSuffix: 'T',
                rightLabel: 'Challan Quantity (Tonnes)',
                rightHint: '0.0',
                rightController: _challanQtyController,
                rightSuffix: 'T',
                isDecimal: true,
              ),
              const SizedBox(height: 24),
              const SectionLabel(label: 'FINANCIAL DETAILS'),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Rate (₹ per Tonne) *',
                hint: '0',
                controller: _rateController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                suffix: const Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 12, 0),
                  child: Text('₹/T',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              NumberFieldRow(
                leftLabel: 'Diesel (₹)',
                leftHint: '0',
                leftController: _dieselController,
                leftSuffix: '₹',
                rightLabel: 'Advance (₹)',
                rightHint: '0',
                rightController: _advanceController,
                rightSuffix: '₹',
              ),
              const SizedBox(height: 14),
              NumberFieldRow(
                leftLabel: 'Unloading (₹)',
                leftHint: '0',
                leftController: _unloadingController,
                leftSuffix: '₹',
                rightLabel: 'Short Amount (₹)',
                rightHint: '0',
                rightController: _shortController,
                rightSuffix: '₹',
              ),
              // const SizedBox(height: 24),
              // const SectionLabel(label: 'STATUS'),
              // const SizedBox(height: 12),
              // StatusSelector(
              //   status: _status,
              //   onChanged: (s) => setState(() => _status = s),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
