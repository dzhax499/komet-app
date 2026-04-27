import '../../../../core/base/base_use_case.dart';
import '../../../../core/models/kelas_model.dart';
import '../../../../core/models/user_model.dart';

abstract class KelasRepository {
  KometResult<KelasModel> createKelas(String nama, String guruId);

  KometResult<List<KelasModel>> getKelasGuru(String guruId);

  KometResult<List<KelasModel>> getKelasSiswa(String siswaId);

  KometResult<KelasModel> joinKelas(String kodeKelas, String siswaId);

  KometResult<KelasModel> getKelasById(String kelasId);

  KometResult<void> deleteKelas(String kelasId);
  
  KometResult<List<UserModel>> getSiswaInKelas(String kelasId);

  KometResult<void> leaveKelas(String kelasId, String siswaId);
}
