import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/ad_provider.dart';
import '../../../models/ad_model.dart';

class AdEditDialog extends StatefulWidget {
  final AdModel ad;

  const AdEditDialog({super.key, required this.ad});

  @override
  State<AdEditDialog> createState() => _AdEditDialogState();
}

class _AdEditDialogState extends State<AdEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late int _durationSeconds;
  late List<String> _targetLocations;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.ad.title);
    _durationSeconds = widget.ad.durationSeconds;
    _targetLocations = List.from(widget.ad.targetLocations);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final adProvider = context.read<AdProvider>();
    final success = await adProvider.updateAd(
      id: widget.ad.id,
      title: _titleController.text.trim(),
      durationSeconds: _durationSeconds,
      targetLocations: _targetLocations,
    );

    if (mounted) {
      Navigator.of(context).pop(success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Ad'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Ad Title',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Duration
                Row(
                  children: [
                    const Text('Display Duration:'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Slider(
                        value: _durationSeconds.toDouble(),
                        min: 3,
                        max: 30,
                        divisions: 27,
                        label: '${_durationSeconds}s',
                        onChanged: (value) {
                          setState(() {
                            _durationSeconds = value.toInt();
                          });
                        },
                      ),
                    ),
                    Text('${_durationSeconds}s'),
                  ],
                ),
                const SizedBox(height: 16),

                // Status
                Row(
                  children: [
                    const Text('Status:'),
                    const SizedBox(width: 16),
                    Chip(
                      label: Text(
                        widget.ad.isEnabled ? 'Active' : 'Inactive',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: widget.ad.isEnabled ? Colors.green : Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
