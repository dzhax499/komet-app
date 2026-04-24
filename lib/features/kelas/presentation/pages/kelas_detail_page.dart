import 'package:flutter/material.dart';
import '../widgets/submission_card.dart';
import '../widgets/task_card.dart';
import '../widgets/create_task_dialog.dart'; 

class KelasDetailPage extends StatefulWidget {
  const KelasDetailPage({super.key});

  @override
  State<KelasDetailPage> createState() => _KelasDetailPageState();
}

class _KelasDetailPageState extends State<KelasDetailPage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF86B3C0),
              Color(0xFFE3E2E0),
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Column(
          children: [
            _buildCustomHeader(context),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 100,
                ),
                itemCount: _selectedTabIndex == 0 ? 4 : 1,
                itemBuilder: (context, index) {
                  return _selectedTabIndex == 0
                      ? const TaskCard()
                      : const SubmissionCard();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedTabIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierColor: Colors.black.withValues(alpha: 0.2),
                  builder: (context) => CreateTaskDialog(
                    onCreated: (taskName, deadline) {
                      // Logic simpan data nanti di sini
                      debugPrint('Task: $taskName, Deadline: $deadline');
                    },
                  ),
                );
              },
              backgroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 28),
            )
          : null,
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.only(top: 40, left: 24, right: 24, bottom: 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B7E25), Color(0xFF1F410F)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: const Border(bottom: BorderSide(color: Colors.white, width: 2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Back to Hub',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '2C',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                'Class Code : ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                'MZCP2F',
                style: TextStyle(
                  color: Color(0xFF6CB5B8),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTabIndex = 0;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      'Task',
                      style: TextStyle(
                        color: _selectedTabIndex == 0
                            ? Colors.white
                            : Colors.white70,
                        fontSize: 16,
                        fontWeight: _selectedTabIndex == 0
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 4,
                      width: 50,
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 0
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTabIndex = 1;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      'Submission',
                      style: TextStyle(
                        color: _selectedTabIndex == 1
                            ? Colors.white
                            : Colors.white70,
                        fontSize: 16,
                        fontWeight: _selectedTabIndex == 1
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 4,
                      width: 90,
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 1
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 