import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'models/user_profile.dart';

class ScheduleSessionScreen extends StatefulWidget {
  final UserProfile chatUser;

  const ScheduleSessionScreen({super.key, required this.chatUser});

  @override
  State<ScheduleSessionScreen> createState() => _ScheduleSessionScreenState();
}

class _ScheduleSessionScreenState extends State<ScheduleSessionScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _topicController = TextEditingController();

  Map<String, dynamic>? targetAvailability;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTargetAvailability();
  }

  Future<void> _fetchTargetAvailability() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(widget.chatUser.id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('availability')) {
          setState(() {
            targetAvailability = data['availability'] as Map<String, dynamic>;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching availability: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatAmPm(String time24) {
    final parts = time24.split(':');
    if (parts.length != 2) return time24;
    int h = int.parse(parts[0]);
    int m = int.parse(parts[1]);
    final dt = DateTime(2000, 1, 1, h, m);
    return DateFormat.jm().format(dt);
  }

  bool _isValidTime() {
    if (_selectedDate == null || _selectedTime == null) return false;
    if (targetAvailability == null) return true; // No constraints
    
    final String daysLimit = targetAvailability!['days'] ?? 'Everyday';
    final String startStr = targetAvailability!['startTime'] ?? '00:00';
    final String endStr = targetAvailability!['endTime'] ?? '23:59';
    
    // Check Day constraint
    int weekday = _selectedDate!.weekday; // 1 = Mon, 7 = Sun
    bool isWeekend = (weekday == DateTime.saturday || weekday == DateTime.sunday);
    
    if (daysLimit == 'Weekdays' && isWeekend) return false;
    if (daysLimit == 'Weekends' && !isWeekend) return false;
    
    // Check Time constraint
    final startParts = startStr.split(':');
    final endParts = endStr.split(':');
    if (startParts.length == 2 && endParts.length == 2) {
      int startH = int.parse(startParts[0]);
      int startM = int.parse(startParts[1]);
      int endH = int.parse(endParts[0]);
      int endM = int.parse(endParts[1]);
      
      int userTimeMins = _selectedTime!.hour * 60 + _selectedTime!.minute;
      int limitStartMins = startH * 60 + startM;
      int limitEndMins = endH * 60 + endM;
      
      if (limitEndMins < limitStartMins) limitEndMins += 24 * 60; 
      
      if (userTimeMins < limitStartMins || userTimeMins > limitEndMins) {
        return false;
      }
    }
    
    return true;
  }

  void _confirmSession() {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Date and Time.')));
      return;
    }
    if (_topicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a topic.')));
      return;
    }
    
    if (!_isValidTime()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Invalid Time Selected"),
          content: Text("${widget.chatUser.name} is not available during your selected time. Please check their availability box and choose again."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("OK", style: TextStyle(color: Colors.indigo))
            ),
          ],
        ),
      );
      return;
    }
    
    // Success
    final String dateFormatted = DateFormat('MMM dd, yyyy').format(_selectedDate!);
    final String timeFormatted = _selectedTime!.format(context);
    final String topic = _topicController.text.trim();
    
    Navigator.pop(context, {
      'date': dateFormatted,
      'time': timeFormatted,
      'topic': topic,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session Scheduled!')));
  }

  @override
  Widget build(BuildContext context) {
    String availabilityText = "Loading availability...";
    if (!isLoading) {
      if (targetAvailability != null) {
        String startStr = _formatAmPm(targetAvailability!['startTime'] ?? '00:00');
        String endStr = _formatAmPm(targetAvailability!['endTime'] ?? '23:59');
        availabilityText = "Available: ${targetAvailability!['days']}\nBetween $startStr & $endStr";
      } else {
        availabilityText = "Available anytime";
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Schedule Session",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
              // User Card with Availability
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(widget.chatUser.photo),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.chatUser.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.info_outline, size: 12, color: Colors.green.shade700),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    availabilityText,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Date Picker
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16, color: Colors.indigo.shade300),
                  const SizedBox(width: 8),
                  const Text("Date", style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null ? "Select Date" : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                        style: TextStyle(color: _selectedDate == null ? Colors.grey : Colors.black87, fontSize: 16),
                      ),
                      Icon(Icons.calendar_today_outlined, color: Colors.black54, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Time Picker
              Row(
                children: [
                  Icon(Icons.access_time_outlined, size: 16, color: Colors.indigo.shade300),
                  const SizedBox(width: 8),
                  const Text("Time", style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime == null ? "Select Time" : _selectedTime!.format(context),
                        style: TextStyle(color: _selectedTime == null ? Colors.grey : Colors.black87, fontSize: 16),
                      ),
                      Icon(Icons.access_time_outlined, color: Colors.black54, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Topic Text
              Row(
                children: [
                  Icon(Icons.menu_book_outlined, size: 16, color: Colors.indigo.shade300),
                  const SizedBox(width: 8),
                  const Text("Topic", style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _topicController,
                decoration: InputDecoration(
                  hintText: "e.g. React Hooks deep dive",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.indigo.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              
              const Spacer(),
              
              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Confirm Session",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
