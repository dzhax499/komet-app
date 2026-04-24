import 'package:flutter/material.dart';

class ReviewSubmissionPage extends StatefulWidget {
  const ReviewSubmissionPage({super.key});

  @override
  State<ReviewSubmissionPage> createState() => _ReviewSubmissionPageState();
}

class _ReviewSubmissionPageState extends State<ReviewSubmissionPage> {
  double _assessmentValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF86B3C0), // Light blue-grey
              Color(0xFFE3E2E0), // Light grey
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    _buildStudentInfoCard(),
                    const SizedBox(height: 20),
                    _buildAudioPlayerCard(),
                    const SizedBox(height: 20),
                    _buildAssessmentCard(),
                    const SizedBox(height: 24),
                    _buildApproveButton(),
                    const SizedBox(height: 12),
                    _buildRevisionButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B7E25),
            Color(0xFF1F410F),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: const Border(
          bottom: BorderSide(color: Colors.white, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
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
                    Icon(Icons.school_outlined, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Teacher Hub',
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
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Row(
              children: [
                Icon(Icons.reply, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  'Review Submission',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF6F8226),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF19320C),
                  Color(0xFF4C661D),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue[100],
                  child: const Icon(Icons.person, color: Colors.blueGrey, size: 36),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Andi\'s Story',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'andi@gmail.com',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Table(
              border: const TableBorder(
                horizontalInside: BorderSide(color: Colors.white54, width: 1),
                verticalInside: BorderSide(color: Colors.white54, width: 1),
              ),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2.5),
              },
              children: [
                _buildTableRow('Task', 'Create Story About Yourself'),
                _buildTableRow('Blok', '15'),
                _buildTableRow('Submit', '13/04/2026 13:45'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioPlayerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          height: 36,
          width: 36,
          child: Stack(
            children: [
              const Icon(
                Icons.play_arrow,
                color: Color(0xFF4C661D),
                size: 36,
              ),
              Positioned(
                left: 7,
                top: 8,
                child: Container(
                  width: 3,
                  height: 20,
                  color: const Color(0xFF4C661D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF6F8226),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF19320C),
                  Color(0xFF4C661D),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Assessment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '${_assessmentValue.toInt()}/100',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF86B3C0),
                    inactiveTrackColor: Colors.white,
                    thumbColor: const Color(0xFF86B3C0),
                    trackHeight: 3.0,
                    trackShape: const CustomTrackShape(),
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    value: _assessmentValue,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    onChanged: (value) {
                      setState(() {
                        _assessmentValue = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Feedback...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApproveButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF19320C),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Approve',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRevisionButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFD3D8CA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF19320C), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Revision',
                style: TextStyle(
                  color: Color(0xFF19320C),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  const CustomTrackShape();
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 2.0;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}