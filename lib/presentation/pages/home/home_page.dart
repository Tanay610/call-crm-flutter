import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/customers/customers_controller.dart';
import '../../providers/customers/customers_state.dart';
import '../customer/customer_detail_page.dart';
import '../customer/customer_form_page.dart';
import '../customer/customer_picker_sheet.dart';
import '../sync/sync_progress_dialog.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _selectedCustomerId;

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            tooltip: 'Sync to Cloud',
            onPressed: () async {
              await showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (context) => const SyncProgressDialog(),
              );
            },
            icon: const Icon(Icons.cloud_upload_outlined),
          ),
          IconButton(
            tooltip: 'Add customer',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CustomerFormPage()),
              );
            },
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'call_fab',
        onPressed: () async {
          final picked = await showModalBottomSheet<String>(
            context: context,
            showDragHandle: true,
            isScrollControlled: true,
            builder: (_) => const CustomerPickerSheet(),
          );
          if (!context.mounted || picked == null) return;
          setState(() => _selectedCustomerId = picked);
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CustomerDetailPage(customerId: picked)),
          );
        },
        icon: const Icon(Icons.call),
        label: const Text('Call'),
      ),
      body: customersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load customers: $e')),
        data: (state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 840;
              final list = _CustomersList(
                state: state,
                selectedCustomerId: _selectedCustomerId,
                onSelect: (id) async {
                  if (isWide) {
                    setState(() => _selectedCustomerId = id);
                  } else {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => CustomerDetailPage(customerId: id)),
                    );
                  }
                },
              );

              if (!isWide) return list;

              final selected = _selectedCustomerId ??
                  (state.customers.isEmpty ? null : state.customers.first.id);

              return Row(
                children: [
                  SizedBox(width: 380, child: list),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: selected == null
                        ? const _EmptyWideDetail()
                        : CustomerDetailPage(customerId: selected, embedded: true),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyWideDetail extends StatelessWidget {
  const _EmptyWideDetail();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Select a customer to view details'),
    );
  }
}

class _CustomersList extends ConsumerWidget {
  const _CustomersList({
    required this.state,
    required this.selectedCustomerId,
    required this.onSelect,
  });

  final CustomersState state;
  final String? selectedCustomerId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(customersControllerProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: controller.setQuery,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search name / phone / company',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<CustomerSort>(
                tooltip: 'Sort',
                initialValue: state.sort,
                onSelected: controller.setSort,
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: CustomerSort.lastCalled,
                    child: Text('Last called'),
                  ),
                  PopupMenuItem(
                    value: CustomerSort.mostRecorded,
                    child: Text('Most recorded'),
                  ),
                  PopupMenuItem(
                    value: CustomerSort.newest,
                    child: Text('Newest'),
                  ),
                ],
                child: const Icon(Icons.sort),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: state.customers.isEmpty
              ? const _EmptyCustomers()
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, i) {
                    final c = state.customers[i];
                    final stats = state.statsByCustomerId[c.id];
                    final selected = c.id == selectedCustomerId;
                    return ListTile(
                      selected: selected,
                      leading: CircleAvatar(
                        child: Text(c.name.isEmpty ? '?' : c.name[0].toUpperCase()),
                      ),
                      title: Text(c.name),
                      subtitle: Text('${c.phone} • ${c.company}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${stats?.recordingCount ?? 0} recordings'),
                          Text(
                            'Updated ${Formatters.dateTime(c.updatedAt)}',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                      onTap: () => onSelect(c.id),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemCount: state.customers.length,
                ),
        ),
      ],
    );
  }
}

class _EmptyCustomers extends StatelessWidget {
  const _EmptyCustomers();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No customers yet.\nTap the + person icon to add your first customer.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
