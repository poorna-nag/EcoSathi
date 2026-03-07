import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/partner_bloc.dart';
import '../bloc/partner_event.dart';
import '../bloc/partner_state.dart';
import '../../../pickup/data/models/pickup_model.dart';
import 'package:intl/intl.dart';

class PartnerTasksScreen extends StatelessWidget {
  const PartnerTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Active Tasks',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: BlocBuilder<PartnerBloc, PartnerState>(
        builder: (context, state) {
          final tasks = state is PartnerLoaded ? state.tasks : <PickupModel>[];

          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const TabBar(
                  isScrollable: true,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: [
                    Tab(text: 'Assigned'),
                    Tab(text: 'Picked Up'),
                    Tab(text: 'Completed'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTaskList(
                        context,
                        tasks
                            .where((t) => t.status == PickupStatus.assigned)
                            .toList(),
                      ),
                      _buildTaskList(
                        context,
                        tasks
                            .where((t) => t.status == PickupStatus.picked)
                            .toList(),
                      ),
                      _buildTaskList(
                        context,
                        tasks
                            .where((t) => t.status == PickupStatus.completed)
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<PickupModel> tasks) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks in this category'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _buildTaskCard(context, tasks[index]);
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, PickupModel task) {
    final statusColor = _getStatusColor(task.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  task.status.name.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '#PK-${task.id.substring(0, 5).toUpperCase()}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            task.plasticType,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.address,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Time',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(task.scheduledTime),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Est. Weight',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  Text(
                    '${task.estimatedWeight} kg',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          if (task.status != PickupStatus.completed) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final nextStatus = task.status == PickupStatus.assigned
                      ? PickupStatus.picked
                      : PickupStatus.completed;

                  context.read<PartnerBloc>().add(
                    UpdateTaskStatusEvent(task.id, nextStatus),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  task.status == PickupStatus.assigned
                      ? 'Update to Picked'
                      : 'Complete Task',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(PickupStatus status) {
    switch (status) {
      case PickupStatus.assigned:
        return Colors.blue;
      case PickupStatus.picked:
        return Colors.orange;
      case PickupStatus.completed:
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }
}
