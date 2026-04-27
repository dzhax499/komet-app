import 'package:equatable/equatable.dart';
import '../../../../core/models/assignment_model.dart';

abstract class AssignmentState extends Equatable {
  const AssignmentState();

  @override
  List<Object?> get props => [];
}

class AssignmentInitial extends AssignmentState {}

class AssignmentLoading extends AssignmentState {}

class AssignmentSuccess extends AssignmentState {
  final List<AssignmentModel> assignments;

  const AssignmentSuccess(this.assignments);

  @override
  List<Object?> get props => [assignments];
}

class AssignmentCreatedSuccess extends AssignmentState {
  final AssignmentModel assignment;

  const AssignmentCreatedSuccess(this.assignment);

  @override
  List<Object?> get props => [assignment];
}

class AssignmentFailure extends AssignmentState {
  final String message;

  const AssignmentFailure(this.message);

  @override
  List<Object?> get props => [message];
}
