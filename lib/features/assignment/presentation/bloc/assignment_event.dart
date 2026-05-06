import 'package:equatable/equatable.dart';
import '../../../../core/models/assignment_model.dart';

abstract class AssignmentEvent extends Equatable {
  const AssignmentEvent();

  @override
  List<Object?> get props => [];
}

class CreateAssignmentEvent extends AssignmentEvent {
  final AssignmentModel assignment;

  const CreateAssignmentEvent(this.assignment);

  @override
  List<Object?> get props => [assignment];
}

class GetAssignmentsByClassEvent extends AssignmentEvent {
  final String kelasId;

  const GetAssignmentsByClassEvent(this.kelasId);

  @override
  List<Object?> get props => [kelasId];
}

class UpdateAssignmentEvent extends AssignmentEvent {
  final AssignmentModel assignment;

  const UpdateAssignmentEvent(this.assignment);

  @override
  List<Object?> get props => [assignment];
}

class DeleteAssignmentEvent extends AssignmentEvent {
  final String assignmentId;

  const DeleteAssignmentEvent(this.assignmentId);

  @override
  List<Object?> get props => [assignmentId];
}
