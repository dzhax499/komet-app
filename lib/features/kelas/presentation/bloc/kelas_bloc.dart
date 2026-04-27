import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/kelas_model.dart';
import '../../domain/usecases/kelas_usecases.dart';
import '../../domain/usecases/get_kelas_by_id_use_case.dart';

// EVENTS
abstract class KelasEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class KelasFetchGuruRequested extends KelasEvent {
  final String guruId;
  KelasFetchGuruRequested(this.guruId);
  @override
  List<Object?> get props => [guruId];
}

class KelasFetchSiswaRequested extends KelasEvent {
  final String siswaId;
  KelasFetchSiswaRequested(this.siswaId);
  @override
  List<Object?> get props => [siswaId];
}

class KelasCreateRequested extends KelasEvent {
  final String nama;
  final String guruId;
  KelasCreateRequested({required this.nama, required this.guruId});
  @override
  List<Object?> get props => [nama, guruId];
}

class KelasJoinRequested extends KelasEvent {
  final String kodeKelas;
  final String siswaId;
  KelasJoinRequested({required this.kodeKelas, required this.siswaId});
  @override
  List<Object?> get props => [kodeKelas, siswaId];
}

class KelasDeleteRequested extends KelasEvent {
  final String kelasId;
  final String guruId; 
  KelasDeleteRequested({required this.kelasId, required this.guruId});
  @override
  List<Object?> get props => [kelasId, guruId];
}

class KelasLeaveRequested extends KelasEvent {
  final String kelasId;
  final String siswaId;
  KelasLeaveRequested({required this.kelasId, required this.siswaId});
  @override
  List<Object?> get props => [kelasId, siswaId];
}

class KelasFetchDetailRequested extends KelasEvent {
  final String kelasId;
  KelasFetchDetailRequested(this.kelasId);
  @override
  List<Object?> get props => [kelasId];
}

// STATES 
abstract class KelasState extends Equatable {
  @override
  List<Object?> get props => [];
}

class KelasInitial extends KelasState {}
class KelasLoading extends KelasState {}
class KelasLoaded extends KelasState {
  final List<KelasModel> kelasList;
  KelasLoaded(this.kelasList);
  @override
  List<Object?> get props => [kelasList];
}
class KelasError extends KelasState {
  final String message;
  KelasError(this.message);
  @override
  List<Object?> get props => [message];
}
class KelasActionSuccess extends KelasState {
  final String message;
  KelasActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class KelasDetailLoaded extends KelasState {
  final KelasModel kelas;
  KelasDetailLoaded(this.kelas);
  @override
  List<Object?> get props => [kelas];
}

// BLOC
class KelasBloc extends Bloc<KelasEvent, KelasState> {
  final CreateKelasUseCase createKelasUseCase;
  final GetKelasGuruUseCase getKelasGuruUseCase;
  final GetKelasSiswaUseCase getKelasSiswaUseCase;
  final JoinKelasUseCase joinKelasUseCase;
  final DeleteKelasUseCase deleteKelasUseCase;
  final LeaveKelasUseCase leaveKelasUseCase;
  final GetKelasByIdUseCase getKelasByIdUseCase;

  KelasBloc({
    required this.createKelasUseCase,
    required this.getKelasGuruUseCase,
    required this.getKelasSiswaUseCase,
    required this.joinKelasUseCase,
    required this.deleteKelasUseCase,
    required this.getKelasByIdUseCase,
    required this.leaveKelasUseCase,
  }) : super(KelasInitial()) {
    on<KelasFetchGuruRequested>(_onFetchGuru);
    on<KelasFetchSiswaRequested>(_onFetchSiswa);
    on<KelasCreateRequested>(_onCreate);
    on<KelasJoinRequested>(_onJoin);
    on<KelasDeleteRequested>(_onDelete);
    on<KelasLeaveRequested>(_onLeave);
    on<KelasFetchDetailRequested>(_onFetchDetail);
  }


  Future<void> _onFetchGuru(KelasFetchGuruRequested event, Emitter<KelasState> emit) async {
    emit(KelasLoading());
    final result = await getKelasGuruUseCase(event.guruId);
    if (result.data != null) {
      emit(KelasLoaded(result.data!));
    } else {
      emit(KelasError(result.failure?.message ?? 'Gagal memuat daftar kelas'));
    }
  }

  Future<void> _onFetchSiswa(KelasFetchSiswaRequested event, Emitter<KelasState> emit) async {
    emit(KelasLoading());
    final result = await getKelasSiswaUseCase(event.siswaId);
    if (result.data != null) {
      emit(KelasLoaded(result.data!));
    } else {
      emit(KelasError(result.failure?.message ?? 'Gagal memuat daftar kelas'));
    }
  }

  Future<void> _onCreate(KelasCreateRequested event, Emitter<KelasState> emit) async {
    emit(KelasLoading());
    final result = await createKelasUseCase(CreateKelasParams(nama: event.nama, guruId: event.guruId));
    if (result.data != null) {
      emit(KelasActionSuccess('Kelas "${event.nama}" berhasil dibuat'));
      add(KelasFetchGuruRequested(event.guruId));
    } else {
      emit(KelasError(result.failure?.message ?? 'Gagal membuat kelas'));
    }
  }

  Future<void> _onJoin(KelasJoinRequested event, Emitter<KelasState> emit) async {
    emit(KelasLoading());
    final result = await joinKelasUseCase(JoinKelasParams(kodeKelas: event.kodeKelas, siswaId: event.siswaId));
    if (result.data != null) {
      emit(KelasActionSuccess('Berhasil bergabung ke kelas "${result.data!.nama}"'));
      add(KelasFetchSiswaRequested(event.siswaId));
    } else {
      emit(KelasError(result.failure?.message ?? 'Gagal bergabung ke kelas'));
    }
  }

  Future<void> _onDelete(KelasDeleteRequested event, Emitter<KelasState> emit) async {
    emit(KelasLoading());
    final result = await deleteKelasUseCase(event.kelasId);
    if (result.failure == null) {
      emit(KelasActionSuccess('Kelas berhasil dihapus'));
      add(KelasFetchGuruRequested(event.guruId));
    } else {
      emit(KelasError(result.failure!.message));
    }
  }

  Future<void> _onLeave(KelasLeaveRequested event, Emitter<KelasState> emit) async {
    emit(KelasLoading());
    final result = await leaveKelasUseCase(LeaveKelasParams(kelasId: event.kelasId, siswaId: event.siswaId));
    if (result.failure == null) {
      emit(KelasActionSuccess('Berhasil keluar dari kelas'));
      add(KelasFetchSiswaRequested(event.siswaId));
    } else {
      emit(KelasError(result.failure!.message));
    }
  }

  Future<void> _onFetchDetail(KelasFetchDetailRequested event, Emitter<KelasState> emit) async {
    emit(KelasLoading());
    final result = await getKelasByIdUseCase(event.kelasId);
    if (result.data != null) {
      emit(KelasDetailLoaded(result.data!));
    } else {
      emit(KelasError(result.failure?.message ?? 'Gagal memuat detail kelas'));
    }
  }
}
