import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<String> _selectedDaysList = [];
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);
  bool isLoading = true;
  bool isSaving = false;

  final List<String> _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _fetchAvailability();
  }

  Future<void> _fetchAvailability() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          if (data.containsKey('availability') && data['availability'] != null) {
            final availMap = data['availability'] as Map<String, dynamic>;
            setState(() {
              // Backward compatibility with previous structure
              String savedDays = availMap['days'] ?? 'Everyday';
              if (savedDays == 'Everyday') {
                _selectedDaysList = List.from(_allDays);
              } else if (savedDays == 'Weekdays') {
                _selectedDaysList = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
              } else if (savedDays == 'Weekends') {
                _selectedDaysList = ['Sat', 'Sun'];
              } else {
                _selectedDaysList = savedDays.split(', ').where((d) => d.isNotEmpty).toList();
              }

              if (availMap['startTime'] != null) {
                final parts = availMap['startTime'].toString().split(':');
                startTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
              }
              if (availMap['endTime'] != null) {
                final parts = availMap['endTime'].toString().split(':');
                endTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
              }
            });
          } else {
            // Default Everyday
            _selectedDaysList = List.from(_allDays);
          }
        }
      } catch (e) {
        debugPrint("Error fetching availability: $e");
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  String _formatTimeAmPm(TimeOfDay time) {
    int hour = time.hourOfPeriod;
    if (hour == 0) hour = 12;
    String minute = time.minute.toString().padLeft(2, '0');
    String period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Colors.indigo.shade600),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  Future<void> _saveAvailability() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    if (_selectedDaysList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one day"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // Unchanged functionality structure from original backend layout
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'availability': {
          'days': _selectedDaysList.join(', '),
          'startTime': _formatTimeOfDay(startTime),
          'endTime': _formatTimeOfDay(endTime),
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Availability Updated!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDaysList.contains(day)) {
        _selectedDaysList.remove(day);
      } else {
        _selectedDaysList.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Availability",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Box
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.indigo.shade100, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade500,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                              ]
                            ),
                            child: const Icon(Icons.access_time_filled, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Manage your time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                const SizedBox(height: 4),
                                Text("Set your preferred teaching hours.", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // AVAILABLE DAYS
                    Row(
                      children: [
                        Icon(Icons.calendar_month_outlined, size: 16, color: Colors.indigo.shade400),
                        const SizedBox(width: 8),
                        Text("AVAILABLE DAYS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo.shade400, letterSpacing: 1.2)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))]
                      ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 16,
                        children: _allDays.map((day) {
                          bool isSelected = _selectedDaysList.contains(day);
                          return GestureDetector(
                            onTap: () => _toggleDay(day),
                            child: Container(
                              width: 55,
                              height: 55,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.indigo.shade500 : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: isSelected ? null : Border.all(color: Colors.grey.shade200),
                                boxShadow: isSelected ? [BoxShadow(color: Colors.indigo.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : [],
                              ),
                              child: Text(
                                day,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.blueGrey.shade400,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // LEARNING HOURS
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.indigo.shade400),
                        const SizedBox(width: 8),
                        Text("LEARNING HOURS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo.shade400, letterSpacing: 1.2)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))]
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectTime(context, true),
                                  child: Container(
                                    color: Colors.transparent, // Ensure clickable area
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("START TIME", style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(_formatTimeAmPm(startTime), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                                            Icon(Icons.access_time_filled, size: 16, color: Colors.grey.shade300),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(height: 40, width: 1, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 20)),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectTime(context, false),
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("END TIME", style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(_formatTimeAmPm(endTime), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                                            Icon(Icons.access_time_filled, size: 16, color: Colors.grey.shade300),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.indigo.shade400, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "This schedule will apply to all selected days.",
                                    style: TextStyle(color: Colors.indigo.shade400, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Button Layer
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          shadowColor: Colors.indigo.withOpacity(0.4),
                        ),
                        onPressed: isSaving ? null : _saveAvailability,
                        child: isSaving 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Save Schedule", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        "You can change your availability at any time.",
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
