import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/submission_model.dart';
import '../../../submission/presentation/bloc/submission_bloc.dart';
import '../../../submission/presentation/bloc/submission_event.dart';
import '../../../submission/presentation/bloc/submission_state.dart';
import '../../../../core/local_storage/hive_service.dart';
import '../../../../core/models/user_model.dart';
import 'submission_canvas_page.dart';

class ReviewSubmissionPage extends StatefulWidget {
  final SubmissionModel submission;
  final String assignmentTitle;
  const ReviewSubmissionPage({
    super.key,
    required this.submission,
    required this.assignmentTitle,
  });

  @override
  State<ReviewSubmissionPage> createState() => _ReviewSubmissionPageState();
}

class _ReviewSubmissionPageState extends State<ReviewSubmissionPage> {
  double _assessmentValue = 0;
  final TextEditingController _feedbackController = TextEditingController();
  late SubmissionBloc _submissionBloc;
  UserModel? _studentUser;

  @override
  void initState() {
    super.initState();
    _submissionBloc = sl<SubmissionBloc>();
    _assessmentValue = (widget.submission.nilai ?? 0).toDouble();
    _feedbackController.text = widget.submission.komentarUmum ?? '';
    _studentUser = sl<HiveService>().userBoxInstance.get(widget.submission.siswaId);
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _submissionBloc,
      child: BlocListener<SubmissionBloc, SubmissionState>(
        listener: (context, state) {
          if (state is SubmissionGradedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Penilaian berhasil disimpan!')),
            );
            Navigator.pop(context);
          } else if (state is SubmissionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal menilai: ${state.message}')),
            );
          }
        },
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF86B3C0), Color(0xFFE3E2E0)],
                stops: [0.0, 1.0],
              ),
            ),
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
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
          colors: [Color(0xFF6B7E25), Color(0xFF1F410F)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: const Border(bottom: BorderSide(color: Colors.white, width: 2)),
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
                child: Row(
                  children: [
                    Image.asset('assets/images/logo.png', height: 20),
                    SizedBox(width: 8),
                    Text(
                      'Teacher Hub',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 22,
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
            child: Row(
              children: [
                Icon(Icons.reply, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  'Review Submission',
                  style: GoogleFonts.nunito(
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
        color: const Color(0xFF758837),
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
                colors: [Color(0xFF1A3C0A), Color(0xFF758837)],
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
                  backgroundImage: _studentUser?.photoUrl != null
                      ? (_studentUser!.photoUrl!.startsWith('http')
                          ? NetworkImage(_studentUser!.photoUrl!) as ImageProvider
                          : null)
                      : null,
                  child: _studentUser?.photoUrl == null || !_studentUser!.photoUrl!.startsWith('http')
                      ? Icon(Icons.person, color: Colors.blueGrey, size: 36)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _studentUser?.nama ?? 'Student ${widget.submission.siswaId.substring(0, 8)}',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${widget.submission.status.name}',
                        style: GoogleFonts.nunito(
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
                _buildTableRow('Task', widget.assignmentTitle),
                _buildTableRow(
                  'Blok',
                  '${widget.submission.storyDataJson.split('<block').length - 1}',
                ),
                _buildTableRow(
                  'Submit',
                  widget.submission.submittedAt != null
                      ? () {
                          final dt = widget.submission.submittedAt!;
                          final d = dt.day.toString().padLeft(2, '0');
                          final m = dt.month.toString().padLeft(2, '0');
                          final y = dt.year;
                          final h = dt.hour.toString().padLeft(2, '0');
                          final min = dt.minute.toString().padLeft(2, '0');
                          return "$d/$m/$y $h:$min";
                        }()
                      : '-',
                ),
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
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.nunito(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioPlayerCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: _submissionBloc,
              child: SubmissionCanvasPage(
                assignmentId: widget.submission.assignmentId,
                assignmentTitle: widget.assignmentTitle,
                deadline: '',
                studentId: widget.submission.siswaId,
                isReviewMode: true,
                initialSubmission: widget.submission,
              ),
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: -10,
                left: -10,
                right: -10,
                height: 10,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  height: 48,
                  width: 48,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1A3C0A), Color(0xFF758837)],
                    ).createShader(bounds),
                    child: const Stack(
                      children: [
                        Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 48,
                        ),
                        Positioned(
                          left: 10,
                          top: 10.5,
                          child: ColoredBox(
                            color: Colors.white,
                            child: SizedBox(width: 2.0, height: 27),
                          ),
                        ),
                      ],
                    ),
                  ),
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
        color: const Color(0xFF758837),
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
                colors: [Color(0xFF1A3C0A), Color(0xFF758837)],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
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
                    Text(
                      'Assessment',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '${_assessmentValue.toInt()}/100',
                        style: GoogleFonts.nunito(
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
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: TextField(
                  controller: _feedbackController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: GoogleFonts.nunito(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Feedback...',
                    hintStyle: GoogleFonts.nunito(color: Colors.grey[400]),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
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
        color: const Color(0xFF1A3C0A),
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
          onTap: () {
            _submissionBloc.add(
              GradeSubmissionEvent(
                submissionId: widget.submission.id,
                grade: _assessmentValue.toInt(),
                teacherComment: _feedbackController.text,
                status: SubmissionStatus.reviewed,
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Approve',
                style: GoogleFonts.nunito(
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
        border: Border.all(color: const Color(0xFF1A3C0A), width: 1.5),
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
          onTap: () {
            _submissionBloc.add(
              GradeSubmissionEvent(
                submissionId: widget.submission.id,
                grade: _assessmentValue.toInt(),
                teacherComment: _feedbackController.text,
                status: SubmissionStatus.needsRevision,
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Revision',
                style: GoogleFonts.nunito(
                  color: Color(0xFF1A3C0A),
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

