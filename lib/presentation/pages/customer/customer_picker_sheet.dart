import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/customers/customers_controller.dart';

class CustomerPickerSheet extends ConsumerStatefulWidget {
  const CustomerPickerSheet({super.key});

  @override
  ConsumerState<CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends ConsumerState<CustomerPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersControllerProvider);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 8,
        ),
        child: customersAsync.when(
          loading: () => const SizedBox(height: 240, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => SizedBox(height: 240, child: Center(child: Text('Failed: $e'))),
          data: (state) {
            final q = _query.trim().toLowerCase();
            final filtered = q.isEmpty
                ? state.customers
                : state.customers
                    .where((c) => c.name.toLowerCase().contains(q) || c.phone.toLowerCase().contains(q))
                    .toList(growable: false);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Pick a customer',
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 420),
                  child: filtered.isEmpty
                      ? const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No matches.')))
                      : ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, i) {
                            final c = filtered[i];
                            return ListTile(
                              leading: CircleAvatar(child: Text(c.name.isEmpty ? '?' : c.name[0].toUpperCase())),
                              title: Text(c.name),
                              subtitle: Text(c.phone),
                              onTap: () => Navigator.of(context).pop(c.id),
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemCount: filtered.length,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
