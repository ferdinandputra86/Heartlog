import 'package:heartlog/models/diary_entry.dart';
import 'package:heartlog/services/diary_storage_service.dart';

class WriteController {
  final DiaryStorageService _diaryStorage = DiaryStorageService();

  // Save a diary entry
  Future<void> saveDiaryEntry(DiaryEntry entry) async {
    return _diaryStorage.saveEntry(entry);
  }

  // Get a suggestion based on the selected emotion
  String getSuggestionForEmotion(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'senang':
        return 'Bagus sekali! Cobalah untuk mengingat hal-hal positif yang terjadi hari ini dan bagaimana kamu bisa membuat hari esok lebih baik lagi.';
      case 'sedih':
        return 'Tidak apa-apa merasa sedih. Cobalah melakukan aktivitas yang kamu sukai, berbicara dengan teman, atau istirahat yang cukup.';
      case 'takut':
        return 'Rasa takut adalah emosi yang normal. Tarik napas dalam-dalam, fokus pada saat ini, dan ingat bahwa kamu lebih kuat dari yang kamu pikir.';
      case 'marah':
        return 'Saat marah, cobalah tarik napas dalam beberapa kali dan hitung sampai 10 sebelum bertindak. Mungkin juga membantu untuk menulis apa yang kamu rasakan.';
      default:
        return 'Terima kasih telah berbagi perasaanmu. Teruslah menulis dan memahami emosimu setiap hari.';
    }
  }
}
