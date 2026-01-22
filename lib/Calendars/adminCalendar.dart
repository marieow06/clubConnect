import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import '../classes/events.dart';

class admincalendar extends StatefulWidget {
  const admincalendar({super.key});

  @override
  State<admincalendar> createState() => _admincalendarState();
}

class _admincalendarState extends State<admincalendar> {
  // Tracks the currently focused day on the calendar
  DateTime _today = DateTime.now();

  // Tracks the day the user selected
  DateTime? _selectedDay;

  // Stores the admin's school ID (used to scope events)
  String? adminSchoolId;

  // Maps each date to a list of events on that date
  Map<DateTime, List<Events>> eventsMap = {};

  // Controllers for the "Add Event" dialog inputs
  TextEditingController _eventController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  // Notifier that updates the event list when the selected day changes
  late final ValueNotifier<List<Events>> _selectedEvents;

  @override
  void initState() {
    super.initState();

    // Load which school this admin belongs to
    _loadAdminSchool();

    // Default selected day is today
    _selectedDay = _today;

    // Initialize selected events list
    _selectedEvents = ValueNotifier([]);
  }

  @override
  void dispose() {
    // Clean up controllers to avoid memory leaks
    _eventController.dispose();
    _descriptionController.dispose();
    _selectedEvents.dispose();
    super.dispose();
  }

  // Normalizes a DateTime to remove time (00:00:00)
  // This allows dates to match correctly in maps
  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  // Called when a user selects a day on the calendar
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _today = focusedDay;
    });

    // Update the list of events for the selected day
    _selectedEvents.value =
        eventsMap[_normalizeDate(selectedDay)] ?? [];
  }

  // Loads the admin's school ID from Firestore
  Future<void> _loadAdminSchool() async {
    // Get the current logged-in user's UID
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Fetch the admin document
    final adminDoc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(uid)
        .get();

    if (!adminDoc.exists) {
      debugPrint('Admin document does not exist');
      return;
    }

    setState(() {
      // Supports both new and old Firestore schemas
      adminSchoolId =
      adminDoc.data()!.containsKey('schoolId')
          ? adminDoc['schoolId']
          : adminDoc['schoolIds']; // fallback
    });

    // Start listening to events once school ID is known
    if (adminSchoolId != null && adminSchoolId!.isNotEmpty) {
      _listenToEvents();
    }
  }

  // Listens in real-time to the events collection for this school
  void _listenToEvents() {
    if (adminSchoolId == null || adminSchoolId!.isEmpty) return;

    FirebaseFirestore.instance
        .collection('schools')
        .doc(adminSchoolId)
        .collection('events')
        .snapshots()
        .listen((snapshot) {

      // Temporary map to rebuild event data
      Map<DateTime, List<Events>> newEvents = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Skip events without a date
        if (data['date'] == null) continue;

        // Convert Firestore Timestamp to DateTime and normalize it
        final date =
        _normalizeDate((data['date'] as Timestamp).toDate());

        // Create list for date if it doesn't exist
        newEvents.putIfAbsent(date, () => []);

        // Add event to the date
        newEvents[date]!.add(
          Events(
            id: doc.id,
            title: data['title'] ?? '',
            description: data['description'] ?? '',
          ),
        );
      }

      // Update UI and selected events
      setState(() {
        eventsMap = newEvents;
        _selectedEvents.value =
            eventsMap[_normalizeDate(_selectedDay!)] ?? [];
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Top app bar
      appBar: AppBar(
        title: const Text(
          '~~~ Club Calendar ~~~',
          style: TextStyle(fontSize: 25),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFDC79),
      ),
      // Floating button to add a new event
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFFFDC79),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Opens the Add Event dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              scrollable: true,
              title: const Text('Add Event'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _eventController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Club Name',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Club Description',
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    // Prevent empty submissions
                    if (_eventController.text.isEmpty ||
                        adminSchoolId == null) return;

                    // Normalize selected day before saving
                    final normalizedDay =
                    _normalizeDate(_selectedDay!);

                    // Save event to Firestore
                    await FirebaseFirestore.instance
                        .collection('schools')
                        .doc(adminSchoolId)
                        .collection('events')
                        .add({
                      'title': _eventController.text,
                      'description': _descriptionController.text,
                      'date': Timestamp.fromDate(normalizedDay),
                      'createdBy':
                      FirebaseAuth.instance.currentUser!.email,
                      'schoolId': adminSchoolId,
                    });

                    // Clear input fields
                    _eventController.clear();
                    _descriptionController.clear();

                    // Close dialog
                    Navigator.of(context).pop();
                  },
                  child: const Text('Submit'),
                )
              ],
            ),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Calendar widget
            SizedBox(
              height: 400,
              child: TableCalendar(
                rowHeight: 60,
                availableGestures: AvailableGestures.all,
                calendarFormat: CalendarFormat.month,

                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),

                calendarStyle: CalendarStyle(
                  todayTextStyle: TextStyle(color: Colors.black),
                  selectedTextStyle: TextStyle(color: Colors.black),
                  defaultTextStyle: TextStyle(color: Colors.black),
                  weekendTextStyle: TextStyle(color: Colors.black),
                  selectedDecoration: BoxDecoration(
                    color: Colors.yellow[200],
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: const BoxDecoration(
                    color: Color(0xFFFFDC79),
                    shape: BoxShape.circle,
                  ),
                ),

                onDaySelected: _onDaySelected,
                selectedDayPredicate: (day) =>
                    isSameDay(day, _selectedDay),

                focusedDay: _today,
                firstDay: DateTime.utc(2025, 1, 1),
                lastDay: DateTime.utc(2030, 1, 1),

                // Determines whether a dot appears under a day
                eventLoader: (day) {
                  final normalizedDay = _normalizeDate(day);
                  if ((eventsMap[normalizedDay] ?? []).isNotEmpty) {
                    return [eventsMap[normalizedDay]!.first];
                  }
                  return [];
                },
              ),
            ),

            const Divider(color: Colors.grey, thickness: 1),

            // Event list for selected day
            Expanded(
              child: ValueListenableBuilder<List<Events>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  if (value.isEmpty) {
                    return const Center(
                      child: Text('No events for this day'),
                    );
                  }
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {

                      final event = value[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ListTile(
                          title: Text(event.title),
                          subtitle: Text(event.description),
                          // Delete event button
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Color(0xFFFFDC79),
                            ),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('schools')
                                  .doc(adminSchoolId)
                                  .collection('events')
                                  .doc(event.id)
                                  .delete();
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
