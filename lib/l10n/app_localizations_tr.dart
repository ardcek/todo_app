// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Yapılacaklar';

  @override
  String get tasks => 'Görevler';

  @override
  String get addTask => 'Görev Ekle';

  @override
  String get editTask => 'Görevi Düzenle';

  @override
  String get taskTitle => 'Ne yapılması gerekiyor?';

  @override
  String get taskDescription => 'Açıklama';

  @override
  String get taskDueDate => 'Bitiş Tarihi';

  @override
  String get taskPriority => 'Öncelik';

  @override
  String get taskProject => 'Proje';

  @override
  String get notSet => 'Ayarlanmadı';

  @override
  String get reminder => 'Hatırlatıcı';

  @override
  String clearField(String field) {
    return '$field\'i temizle';
  }

  @override
  String get projectHelperText =>
      'Projeler ilgili görevleri bir arada organize etmenize yardımcı olur';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'İptal';

  @override
  String get delete => 'Sil';

  @override
  String get markComplete => 'Tamamlandı Olarak İşaretle';

  @override
  String get markIncomplete => 'Tamamlanmadı Olarak İşaretle';

  @override
  String get highPriority => 'Yüksek';

  @override
  String get mediumPriority => 'Orta';

  @override
  String get lowPriority => 'Düşük';

  @override
  String get noTasks => 'Henüz görev yok';

  @override
  String get addYourFirstTask => 'İlk görevini ekle';

  @override
  String get search => 'Görevleri ara';

  @override
  String get filterTasks => 'Görevleri filtrele';

  @override
  String get sortTasks => 'Görevleri sırala';

  @override
  String get settings => 'Ayarlar';

  @override
  String get darkMode => 'Karanlık Mod';

  @override
  String get language => 'Dil';

  @override
  String get english => 'İngilizce';

  @override
  String get turkish => 'Türkçe';

  @override
  String get today => 'Bugün';

  @override
  String get tomorrow => 'Yarın';

  @override
  String get next7Days => 'Gelecek 7 Gün';

  @override
  String get all => 'Tümü';

  @override
  String get completed => 'Tamamlanan';

  @override
  String get incomplete => 'Tamamlanmayan';

  @override
  String get noResults => 'Sonuç bulunamadı';

  @override
  String get noTasksDescription =>
      'Görev listeniz boş. İlk görevinizi ekleyerek başlayın.';
}
