import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/customer.dart';
import '../../providers/customers/customers_controller.dart';
import '../../providers/customers/customer_by_id_provider.dart';

class CustomerFormPage extends ConsumerStatefulWidget {
  const CustomerFormPage({super.key, this.customerId});

  final String? customerId;

  @override
  ConsumerState<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends ConsumerState<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _company = TextEditingController();
  bool _didPopulate = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _company.dispose();
    super.dispose();
  }

  void _populate(Customer c) {
    if (_didPopulate) return;
    _name.text = c.name;
    _phone.text = c.phone;
    _email.text = c.email;
    _company.text = c.company;
    _didPopulate = true;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customerId != null;
    final customers = ref.read(customersControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Customer' : 'Add Customer')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isEditing
              ? ref.watch(customerByIdProvider(widget.customerId!)).when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Failed to load customer: $e')),
                    data: (customer) {
                      if (customer == null) {
                        return const Center(child: Text('Customer not found.'));
                      }
                      _populate(customer);
                      return _CustomerForm(
                        formKey: _formKey,
                        name: _name,
                        phone: _phone,
                        email: _email,
                        company: _company,
                        onSubmit: () async {
                          if (!_formKey.currentState!.validate()) return;
                          final now = DateTime.now();
                          await customers.updateCustomer(
                            customer.copyWith(
                              name: _name.text.trim(),
                              phone: _phone.text.trim(),
                              email: _email.text.trim(),
                              company: _company.text.trim(),
                              updatedAt: now,
                            ),
                          );
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      );
                    },
                  )
              : _CustomerForm(
                  formKey: _formKey,
                  name: _name,
                  phone: _phone,
                  email: _email,
                  company: _company,
                  onSubmit: () async {
                    if (!_formKey.currentState!.validate()) return;
                    await customers.add(
                      name: _name.text.trim(),
                      phone: _phone.text.trim(),
                      email: _email.text.trim(),
                      company: _company.text.trim(),
                    );
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
        ),
      ),
    );
  }
}

class _CustomerForm extends StatelessWidget {
  const _CustomerForm({
    required this.formKey,
    required this.name,
    required this.phone,
    required this.email,
    required this.company,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController email;
  final TextEditingController company;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: phone,
            decoration: const InputDecoration(labelText: 'Phone'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone is required' : null,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: email,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: company,
            decoration: const InputDecoration(labelText: 'Company'),
            textInputAction: TextInputAction.done,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
