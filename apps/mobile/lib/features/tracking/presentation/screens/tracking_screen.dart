import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/activity.dart';
import '../providers/activity_provider.dart';
import '../widgets/activity_card.dart';
import '../widgets/activity_type_selector.dart';
import '../widgets/add_activity_sheet.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().loadActivities();
    });
  }

  void _showAddActivitySheet(ActivityType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddActivitySheet(type: type),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddActivitySheet(ActivityType.feeding),
        icon: const Icon(Icons.add),
        label: const Text('Add Activity'),
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.activities.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadActivities(type: provider.filterType),
            child: provider.activities.isEmpty
                ? const Center(
                    child: Text(
                      'No activities yet. Start tracking!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: provider.activities.length,
                    itemBuilder: (context, index) {
                      final activity = provider.activities[index];
                      return ActivityCard(
                        activity: activity,
                        onDelete: () => provider.deleteActivity(activity.id),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ActivityTypeSelector(
        selectedType: context.read<ActivityProvider>().filterType,
        onTypeSelected: (type) {
          Navigator.pop(context);
          context.read<ActivityProvider>().loadActivities(type: type);
        },
      ),
    );
  }
}