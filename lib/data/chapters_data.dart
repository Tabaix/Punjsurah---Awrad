// lib/data/chapters_data.dart
// Defines chapters from BOTH content sources:
//   1. PanjSurah Shareef APK  → assets/panjsurah/{folder}/{n}.webp
//   2. Majmua Awrad wa Wazaif → assets/pages/{n}.webp (vFlat scans)

enum ContentSource { panjsurah, awrad, text }

class Chapter {
  final String id;
  final String titleUrdu;
  final String titleEnglish;
  final String icon;
  final ContentSource source;

  final String? folderName;
  final int? totalPngPages;

  final int? startPage;
  final int? endPage;
  
  final bool isTextOnly;

  const Chapter({
    required this.id,
    required this.titleUrdu,
    required this.titleEnglish,
    required this.icon,
    required this.source,
    this.folderName,
    this.totalPngPages,
    this.startPage,
    this.endPage,
    this.isTextOnly = false,
  });

  int get pageCount {
    if (source == ContentSource.panjsurah) {
      return totalPngPages ?? 0;
    } else {
      return (endPage ?? 0) - (startPage ?? 0) + 1;
    }
  }

  /// Returns asset path for a given page (1-based within this chapter)
  String getPageAsset(int pageInChapter) {
    if (source == ContentSource.panjsurah) {
      return 'assets/panjsurah/$folderName/$pageInChapter.png';
    } else {
      final globalPage = (startPage ?? 1) + pageInChapter - 1;
      return 'assets/pages/$globalPage.webp';
    }
  }
}

// =============================================================
// SOURCE 1: PanjSurah Shareef APK Content  (30 sections)
// =============================================================

const List<Chapter> panjsurahChapters = [
  Chapter(id: 'ps_yaseen', titleUrdu: 'سورۂ یٰسٓ', titleEnglish: 'Surah Ya-Seen', icon: '💚', source: ContentSource.panjsurah, folderName: 'yaseen', totalPngPages: 12),
  Chapter(id: 'ps_kehf', titleUrdu: 'سورۂ کہف', titleEnglish: 'Surah Al-Kahf', icon: '🏔', source: ContentSource.panjsurah, folderName: 'kehf', totalPngPages: 26),
  Chapter(id: 'ps_rehman', titleUrdu: 'سورۂ الرحمٰن', titleEnglish: 'Surah Ar-Rahman', icon: '💝', source: ContentSource.panjsurah, folderName: 'rehman', totalPngPages: 8),
  Chapter(id: 'ps_waqia', titleUrdu: 'سورۂ الواقعہ', titleEnglish: "Surah Al-Waqi'ah", icon: '⚡', source: ContentSource.panjsurah, folderName: 'waqia', totalPngPages: 8),
  Chapter(id: 'ps_mulk', titleUrdu: 'سورۂ الملک', titleEnglish: 'Surah Al-Mulk', icon: '👑', source: ContentSource.panjsurah, folderName: 'mulk', totalPngPages: 7),
  Chapter(id: 'ps_fatah', titleUrdu: 'سورۂ الفتح', titleEnglish: 'Surah Al-Fath', icon: '🏆', source: ContentSource.panjsurah, folderName: 'fatah', totalPngPages: 11),
  Chapter(id: 'ps_muzzamil', titleUrdu: 'سورۂ المزمل', titleEnglish: 'Surah Al-Muzzammil', icon: '🌃', source: ContentSource.panjsurah, folderName: 'muzzamil', totalPngPages: 4),
  Chapter(id: 'ps_deen', titleUrdu: 'سورۂ زلزال و مفصل', titleEnglish: 'Surah Az-Zilzal & Mufassal', icon: '🌍', source: ContentSource.panjsurah, folderName: 'deen', totalPngPages: 9),
  Chapter(id: 'ps_baqrah', titleUrdu: 'سورۂ البقرة (آخری آیات)', titleEnglish: 'Surah Al-Baqarah (Last Verses)', icon: '🐄', source: ContentSource.panjsurah, folderName: 'baqrah', totalPngPages: 2),
  Chapter(id: 'ps_fatiha', titleUrdu: 'سورۂ فاتحہ', titleEnglish: 'Surah Al-Fatiha', icon: '📖', source: ContentSource.panjsurah, folderName: 'fatiha', totalPngPages: 1),
  Chapter(id: 'ps_falaq', titleUrdu: 'سورۂ الفلق', titleEnglish: 'Surah Al-Falaq', icon: '🌅', source: ContentSource.panjsurah, folderName: 'falaq', totalPngPages: 1),
  Chapter(id: 'ps_kursi', titleUrdu: 'آیۃ الکرسی', titleEnglish: 'Ayat Al-Kursi', icon: '🕋', source: ContentSource.panjsurah, folderName: 'kursi', totalPngPages: 1),
  Chapter(id: 'ps_hashar', titleUrdu: 'سورۂ الحشر (آخری آیات)', titleEnglish: 'Surah Al-Hashr (Last Verses)', icon: '🌄', source: ContentSource.panjsurah, folderName: 'hashar', totalPngPages: 1),
  Chapter(id: 'ps_kalma', titleUrdu: 'چھ کلمے', titleEnglish: 'Six Kalmas', icon: '☪️', source: ContentSource.panjsurah, folderName: 'kalma', totalPngPages: 3),
  Chapter(id: 'ps_kalmaastaghfar', titleUrdu: 'کلمہ استغفار', titleEnglish: 'Kalma Astaghfar', icon: '🤲', source: ContentSource.panjsurah, folderName: 'kalmaastaghfar', totalPngPages: 2),
  Chapter(id: 'ps_darood', titleUrdu: 'درود شریف', titleEnglish: 'Darood Shareef', icon: '✨', source: ContentSource.panjsurah, folderName: 'darood', totalPngPages: 4),
  Chapter(id: 'ps_dua', titleUrdu: 'دعائیں', titleEnglish: 'Duas', icon: '🤲', source: ContentSource.panjsurah, folderName: 'dua', totalPngPages: 3),
  Chapter(id: 'ps_nama', titleUrdu: 'نماز', titleEnglish: 'Namaz / Salah', icon: '🕌', source: ContentSource.panjsurah, folderName: 'nama', totalPngPages: 2),
  Chapter(id: 'ps_nimzazkar', titleUrdu: 'نماز اذکار', titleEnglish: 'Namaz Azkar', icon: '📿', source: ContentSource.panjsurah, folderName: 'nimzazkar', totalPngPages: 2),
  Chapter(id: 'ps_zikar', titleUrdu: 'ذکر و اذکار', titleEnglish: 'Zikar / Dhikr', icon: '🌺', source: ContentSource.panjsurah, folderName: 'zikar', totalPngPages: 3),
  Chapter(id: 'ps_kafal', titleUrdu: 'سورۂ کافرون', titleEnglish: 'Surah Al-Kafirun', icon: '🔘', source: ContentSource.panjsurah, folderName: 'kafal', totalPngPages: 2),
  Chapter(id: 'ps_hajat', titleUrdu: 'صلاۃ الحاجت', titleEnglish: 'Salat al-Hajat', icon: '🙏', source: ContentSource.panjsurah, folderName: 'hajat', totalPngPages: 1),
  Chapter(id: 'ps_khajgan', titleUrdu: 'خواجگان', titleEnglish: 'Khajgan', icon: '⭐', source: ContentSource.panjsurah, folderName: 'khajgan', totalPngPages: 1),
  Chapter(id: 'ps_kull2', titleUrdu: 'کلیات', titleEnglish: 'Kulliyat', icon: '📜', source: ContentSource.panjsurah, folderName: 'kull2', totalPngPages: 2),
  Chapter(id: 'ps_bakhsish', titleUrdu: 'بخشش', titleEnglish: 'Bakhshish', icon: '💛', source: ContentSource.panjsurah, folderName: 'bakhsish', totalPngPages: 1),
  Chapter(id: 'ps_izkar', titleUrdu: 'اذکار', titleEnglish: 'Azkar', icon: '🌙', source: ContentSource.panjsurah, folderName: 'izkar', totalPngPages: 1),
  Chapter(id: 'ps_sawab', titleUrdu: 'ثواب', titleEnglish: 'Sawab / Rewards', icon: '🌟', source: ContentSource.panjsurah, folderName: 'sawab', totalPngPages: 2),
  Chapter(id: 'ps_shifamahi', titleUrdu: 'شفاء ماہی', titleEnglish: 'Shifa Mahi', icon: '🐟', source: ContentSource.panjsurah, folderName: 'shifamahi', totalPngPages: 1),
  Chapter(id: 'ps_tajtunjina', titleUrdu: 'تاج النجینا', titleEnglish: 'Taj-un-Najina', icon: '👸', source: ContentSource.panjsurah, folderName: 'tajtunjina', totalPngPages: 2),
  Chapter(id: 'ps_mufassil', titleUrdu: 'مفصل سورتیں', titleEnglish: 'Mufassal Surahs', icon: '📚', source: ContentSource.panjsurah, folderName: 'mufassil', totalPngPages: 1),
];

// =============================================================
// SOURCE 2: Majmua Awrad wa Wazaif (vFlat scanned book, 530 pages)
// =============================================================

const List<Chapter> awradChapters = [
  Chapter(id: 'aw_full_book', titleUrdu: 'مکمل کتاب (صفحہ وار)', titleEnglish: 'Full Book Mode', icon: '📚', source: ContentSource.awrad, startPage: 1, endPage: 530),
  Chapter(id: 'aw_cover', titleUrdu: 'سرورق و تعارف', titleEnglish: 'Cover', icon: '📗', source: ContentSource.awrad, startPage: 1, endPage: 5),
  Chapter(id: 'aw_darood', titleUrdu: 'درود شریف', titleEnglish: 'Darood Shareef', icon: '✨', source: ContentSource.awrad, startPage: 6, endPage: 6),
  Chapter(id: 'aw_fatiha', titleUrdu: 'سورۂ فاتحہ', titleEnglish: 'Surah Fatiha', icon: '📖', source: ContentSource.awrad, startPage: 7, endPage: 7),
  Chapter(id: 'aw_mutfarriq', titleUrdu: 'متفرق سورتیں', titleEnglish: 'Various Surahs', icon: '📿', source: ContentSource.awrad, startPage: 8, endPage: 16),
  Chapter(id: 'aw_maghfirat', titleUrdu: 'دعائے مغفرت', titleEnglish: 'Dua Maghfirat', icon: '🤲', source: ContentSource.awrad, startPage: 17, endPage: 17),
  Chapter(id: 'aw_noor', titleUrdu: 'دعائے نور', titleEnglish: 'Dua Noor', icon: '💡', source: ContentSource.awrad, startPage: 18, endPage: 19),
  Chapter(id: 'aw_hadith', titleUrdu: 'حدیث مبارکہ', titleEnglish: 'Hadith Mubaraka', icon: '🌙', source: ContentSource.awrad, startPage: 20, endPage: 23),
  Chapter(id: 'aw_raat', titleUrdu: 'رات کے عملیات', titleEnglish: 'Night Deeds', icon: '🌠', source: ContentSource.awrad, startPage: 24, endPage: 24),
  Chapter(id: 'aw_lohqurani', titleUrdu: 'لوح قرآنی', titleEnglish: 'Loh-e-Qurani', icon: '🕌', source: ContentSource.awrad, startPage: 25, endPage: 25),
  Chapter(id: 'aw_hafiza', titleUrdu: 'قوت حافظہ', titleEnglish: 'Memory Duas', icon: '🧠', source: ContentSource.awrad, startPage: 26, endPage: 26),
  Chapter(id: 'aw_fazilat', titleUrdu: 'تلاوت کی فضیلت', titleEnglish: 'Quran Virtues', icon: '⭐', source: ContentSource.awrad, startPage: 27, endPage: 28),
  Chapter(id: 'aw_kahf', titleUrdu: 'سورۂ کہف', titleEnglish: 'Surah Kahf', icon: '🏔', source: ContentSource.awrad, startPage: 29, endPage: 43),
  Chapter(id: 'aw_sajda', titleUrdu: 'سورۂ سجدہ', titleEnglish: 'Surah Sajda', icon: '🕋', source: ContentSource.awrad, startPage: 44, endPage: 47),
  Chapter(id: 'aw_yaseen', titleUrdu: 'سورۂ یٰسٓ', titleEnglish: 'Surah Yaseen', icon: '💚', source: ContentSource.awrad, startPage: 48, endPage: 54),
  Chapter(id: 'aw_dukhan', titleUrdu: 'سورۂ الدخان', titleEnglish: 'Surah Dukhan', icon: '☁️', source: ContentSource.awrad, startPage: 55, endPage: 58),
  Chapter(id: 'aw_muhammad', titleUrdu: 'سورۂ محمد ﷺ', titleEnglish: 'Surah Muhammad', icon: '🌟', source: ContentSource.awrad, startPage: 59, endPage: 63),
  Chapter(id: 'aw_fath', titleUrdu: 'سورۂ الفتح', titleEnglish: 'Surah Fath', icon: '🏆', source: ContentSource.awrad, startPage: 64, endPage: 70),
  Chapter(id: 'aw_qaf', titleUrdu: 'سورۂ قٓ', titleEnglish: 'Surah Qaf', icon: '📜', source: ContentSource.awrad, startPage: 71, endPage: 74),
  Chapter(id: 'aw_rahman', titleUrdu: 'سورۂ الرحمٰن', titleEnglish: 'Surah Rahman', icon: '💝', source: ContentSource.awrad, startPage: 75, endPage: 78),
  Chapter(id: 'aw_waqia', titleUrdu: 'سورۂ الواقعہ', titleEnglish: 'Surah Waqiah', icon: '⚡', source: ContentSource.awrad, startPage: 79, endPage: 83),
  Chapter(id: 'aw_hashr', titleUrdu: 'سورۂ الحشر', titleEnglish: 'Surah Hashr', icon: '🌄', source: ContentSource.awrad, startPage: 84, endPage: 88),
  Chapter(id: 'aw_jumua', titleUrdu: 'سورۂ الجمعہ', titleEnglish: 'Surah Jumuah', icon: '🕌', source: ContentSource.awrad, startPage: 89, endPage: 90),
  Chapter(id: 'aw_taghabun', titleUrdu: 'سورۂ التغابن', titleEnglish: 'Surah Taghabun', icon: '📊', source: ContentSource.awrad, startPage: 91, endPage: 93),
  Chapter(id: 'aw_mulk', titleUrdu: 'سورۂ الملک', titleEnglish: 'Surah Mulk', icon: '👑', source: ContentSource.awrad, startPage: 94, endPage: 96),
  Chapter(id: 'aw_muzzamil', titleUrdu: 'سورۂ المزمل', titleEnglish: 'Surah Muzzammil', icon: '🌃', source: ContentSource.awrad, startPage: 97, endPage: 99),
  Chapter(id: 'aw_muddathir', titleUrdu: 'سورۂ المدثر', titleEnglish: 'Surah Muddathir', icon: '🧥', source: ContentSource.awrad, startPage: 100, endPage: 103),
  Chapter(id: 'aw_naba', titleUrdu: 'سورۂ النباء', titleEnglish: 'Surah Naba', icon: '📢', source: ContentSource.awrad, startPage: 104, endPage: 104),
  Chapter(id: 'aw_fajr', titleUrdu: 'سورۂ الفجر', titleEnglish: 'Surah Fajr', icon: '🌅', source: ContentSource.awrad, startPage: 105, endPage: 106),
  Chapter(id: 'aw_shams_nas', titleUrdu: 'سورۂ الشّمس تا النّاس', titleEnglish: 'Surah Shams to Nas', icon: '🌞', source: ContentSource.awrad, startPage: 107, endPage: 122),
  Chapter(id: 'aw_asma_husna', titleUrdu: 'اسماء الحسنیٰ', titleEnglish: 'Asma-ul-Husna', icon: '🤍', source: ContentSource.awrad, startPage: 123, endPage: 125),
  Chapter(id: 'aw_asma_nabi', titleUrdu: 'اسماء النبی ﷺ', titleEnglish: 'Asma-un-Nabi', icon: '☀️', source: ContentSource.awrad, startPage: 126, endPage: 129),
  Chapter(id: 'aw_ahd_nama', titleUrdu: 'عہد نامہ', titleEnglish: 'Ahd Nama', icon: '📝', source: ContentSource.awrad, startPage: 130, endPage: 131),
  Chapter(id: 'aw_darood_taj', titleUrdu: 'درود تاج', titleEnglish: 'Darood Taj', icon: '👸', source: ContentSource.awrad, startPage: 132, endPage: 133),
  Chapter(id: 'aw_darood_tanjina', titleUrdu: 'درود تنجینا', titleEnglish: 'Darood Tanjina', icon: '⛵', source: ContentSource.awrad, startPage: 134, endPage: 134),
  Chapter(id: 'aw_darood_mahi', titleUrdu: 'درود ماہی', titleEnglish: 'Darood Mahi', icon: '🐟', source: ContentSource.awrad, startPage: 135, endPage: 137),
  Chapter(id: 'aw_darood_muqaddas', titleUrdu: 'درود مقدس', titleEnglish: 'Darood Muqaddas', icon: '✨', source: ContentSource.awrad, startPage: 138, endPage: 143),
  Chapter(id: 'aw_darood_nukti', titleUrdu: 'درود نکتی', titleEnglish: 'Darood Nukti', icon: '💫', source: ContentSource.awrad, startPage: 144, endPage: 149),
  Chapter(id: 'aw_darood_akbar', titleUrdu: 'درود اکبر', titleEnglish: 'Darood Akbar', icon: '🌠', source: ContentSource.awrad, startPage: 150, endPage: 192),
  Chapter(id: 'aw_haft_haikal', titleUrdu: 'ہفت ہیکل', titleEnglish: 'Haft Haikal', icon: '🔮', source: ContentSource.awrad, startPage: 193, endPage: 197),
  Chapter(id: 'aw_shash_qifl', titleUrdu: 'شش قفل', titleEnglish: 'Shash Qifl', icon: '🔐', source: ContentSource.awrad, startPage: 198, endPage: 200),
  Chapter(id: 'aw_ilaj_azam', titleUrdu: 'علاج اعظم', titleEnglish: 'Ilaj Azam', icon: '💊', source: ContentSource.awrad, startPage: 201, endPage: 212),
  Chapter(id: 'aw_evil_eye', titleUrdu: 'علاج چشم و نظر بد', titleEnglish: 'Nazar-e-Bad', icon: '👁', source: ContentSource.awrad, startPage: 213, endPage: 214),
  Chapter(id: 'aw_ayat_shifa', titleUrdu: 'آیات شفاء', titleEnglish: 'Ayat Shifa', icon: '💚', source: ContentSource.awrad, startPage: 215, endPage: 217),
  Chapter(id: 'aw_aqiqah', titleUrdu: 'عقیقہ', titleEnglish: 'Aqiqah', icon: '🐑', source: ContentSource.awrad, startPage: 218, endPage: 222),
  Chapter(id: 'aw_ganj', titleUrdu: 'دعائے گنج العرش', titleEnglish: 'Ganj-ul-Arsh', icon: '🤲', source: ContentSource.awrad, startPage: 223, endPage: 232),
  Chapter(id: 'aw_qadah', titleUrdu: 'دعائے قدح معظم', titleEnglish: 'Qadah Moazzam', icon: '📿', source: ContentSource.awrad, startPage: 233, endPage: 242),
  Chapter(id: 'aw_habib', titleUrdu: 'دعائے حبیب', titleEnglish: 'Dua Habib', icon: '💞', source: ContentSource.awrad, startPage: 243, endPage: 243),
  Chapter(id: 'aw_mutafarriq2', titleUrdu: 'دیگر روزمرہ دعائیں', titleEnglish: 'Other Duas', icon: '📿', source: ContentSource.awrad, startPage: 244, endPage: 402),
  Chapter(id: 'aw_akhir', titleUrdu: 'قصیدہ غوثیہ و دیگر', titleEnglish: 'Qasida & More', icon: '📜', source: ContentSource.awrad, startPage: 403, endPage: 530),
];
