abstract final class AppStrings {
  // Brand & Header
  static const String appName = 'قطرة';
  static const String dashboardTitle = 'قطرة · لوحة الجهة المسؤولة';
  static const String prioritiesTab = 'الأولويات';
  static const String authorityBadge = 'الجهة المسؤولة';
  static const String authorityAvatarLetter = 'ج';
  static const String refreshData = 'تحديث البيانات';

  // Connection / Demo Mode
  static const String liveDataMode = 'متصل بالخادم';
  static const String demoDataMode = 'بيانات عرض تجريبية';
  static const String demoSubtitle = 'بيانات تجريبية للتوضيح';
  static const String liveSubtitle = 'مرتبة حسب الأولوية والقاعدة الذهبية';
  static const String loadDemoData = 'تشغيل بيانات العرض التجريبية';
  static const String reconnectLiveApi = 'الاتصال بالخادم المباشر';
  static const String offlineDemoHint =
      'تعذّر الوصول إلى خادم قطرة حالياً. يمكنك إعادة المحاولة أو استعراض اللوحة ببيانات تجريبية مطابقة للنظام.';

  // Priority List Sidebar
  static const String neighborhoodsByPriority = 'الأحياء حسب الأولوية';
  static const String filterAll = 'الكل';
  static const String filterUrgentHealth = 'عاجل صحي';
  static const String filterConfirmed = 'مؤكدة';
  static const String filterInProgress = 'قيد المتابعة';
  static const String noIncidentsMatchFilter =
      'لا توجد حالات مطابقة للتصفية المحددة.';
  static const String noActiveIncidents =
      'لا توجد أزمات مائية نشطة في الأحياء حالياً.';
  static const String goldenRuleTooltip =
      'القاعدة الذهبية: تتصدر حالات التلوث الصحي القائمة دائماً';

  // Priority Levels
  static const String priorityUrgentHealth = 'عاجل صحي';
  static const String priorityHigh = 'عالية';
  static const String priorityMedium = 'متوسطة';
  static const String priorityLow = 'منخفضة';

  // Incident States
  static const String stateNew = 'جديدة';
  static const String stateConfirmed = 'مؤكدة';
  static const String stateInProgress = 'قيد المتابعة';
  static const String stateResolved = 'تم الحل';
  static const String stateExpired = 'منتهية';

  // Flags & Issue Types
  static const String escalating = 'يتفاقم';
  static const String repeatIncident = 'متكررة';
  static const String contaminationIssue = 'مياه ملوثة';
  static const String outageIssue = 'انقطاع';
  static const String confidenceHigh = 'ثقة عالية';
  static const String confidenceMedium = 'ثقة متوسطة';
  static const String confidenceLow = 'ثقة منخفضة';

  // Interactive Map Panel
  static const String needMapTitle = 'خريطة الاحتياج';
  static const String mapInteractiveHint =
      'خريطة تفاعلية تعتمد على إحداثيات الأحياء — اضغط على أي حي لعرض حالته';
  static const String selectedNeighborhood = 'الحي المحدد';
  static const String openDetails = 'فتح التفاصيل';
  static const String noActiveIncidentInNeighborhood =
      'لا توجد بلاغات نشطة في هذا الحي حالياً';
  static const String resetMapView = 'إعادة ضبط العرض';

  // Incident Details Panel
  static const String backToMap = 'العودة إلى الخريطة';
  static const String explanationTitle = 'الشرح';
  static const String noExplanationAvailable =
      'لا يتوفر تبرير آلي لهذه الحالة حالياً.';
  static const String outOfHundred = 'من 100';
  static const String devicesKpiLabel = 'أجهزة فريدة';
  static const String maxOutageKpiLabel = 'أطول انقطاع';
  static const String lastReportKpiLabel = 'آخر بلاغ';
  static const String linkedReportsTitle = 'البلاغات المرتبطة';
  static const String noLinkedReports =
      'لا توجد بلاغات نصية مدمجة مسجّلة لهذه الحالة بعد.';
  static const String updateStateSectionTitle = 'إدارة حالة الأزمة';
  static const String moreStatesLabel = 'حالة أخرى';
  static const String stateUpdatedSuccess = 'تم تحديث حالة الأزمة بنجاح.';
  static const String stateUpdateFailed =
      'تعذّر تحديث حالة الأزمة. يرجى المحاولة مرة أخرى.';

  // Prediction Section
  static const String predictionTitle = 'تقدير دورة الضخ وكشف الأعطال';
  static const String predictionLoading = 'جارٍ تحميل مؤشرات التنبؤ للحي...';
  static const String predictionUnavailableTitle =
      'خدمة التنبؤ غير متاحة حالياً';
  static const String predictionUnavailableSubtitle =
      'يمكنك متابعة تفاصيل الحالة واتخاذ القرار بينما تُستعاد خدمة التنبؤ.';
  static const String abnormalDelayBadge =
      'تأخر غير طبيعي · اشتباه عطل في الشبكة';
  static const String normalCycleBadge = 'الدورة ضمن النطاق المعتاد';
  static const String cycleMeanLabel = 'متوسط الدورة';
  static const String ci90Label = 'نطاق الثقة 90%';
  static const String probArrival2dLabel = 'احتمال الوصول خلال يومين';
  static const String probLateLabel = 'احتمال التأخر';
  static const String basisLabel = 'الأساس';
  static const String notAvailableShort = 'غير متوفر';

  // Common Actions & Errors
  static const String retry = 'إعادة المحاولة';
  static const String loadingDashboard = 'جارٍ تحميل بيانات الأحياء والحالات...';
  static const String loadingDetails = 'جارٍ تحميل تفاصيل الحالة...';
  static const String unsupportedServerFormat =
      'صيغة البيانات الواردة من الخادم غير مدعومة.';
  static const String operationCompleted = 'تمت العملية بنجاح.';
  static const String genericError = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
  static const String connectionError =
      'تعذّر الاتصال بالخادم. تأكد من تشغيل خدمة API أو الاتصال بالإنترنت.';
  static const String requestCancelled = 'تم إلغاء الطلب.';
  static const String unableToLoadDashboard =
      'تعذّر تحميل بيانات لوحة التحكم. يرجى المحاولة مرة أخرى.';
  static const String unableToLoadIncidentDetails =
      'تعذّر تحميل تفاصيل الحالة. يرجى المحاولة مرة أخرى.';

  // Dynamic Formatters
  static String quietNeighborhoodsCount(int count) {
    if (count == 0) return 'جميع الأحياء لديها حالات مسجلة';
    if (count == 1) return 'حي واحد بلا بلاغات';
    if (count == 2) return 'حيّان بلا بلاغات';
    if (count >= 3 && count <= 10) return '$count أحياء بلا بلاغات';
    return '$count حي بلا بلاغات';
  }

  static String devicesCountLabel(int count) {
    if (count == 1) return 'جهاز واحد';
    if (count == 2) return 'جهازان';
    if (count >= 3 && count <= 10) return '$count أجهزة';
    return '$count جهاز';
  }

  static String daysDurationLabel(num days) {
    final formatted = days % 1 == 0
        ? days.toInt().toString()
        : days.toStringAsFixed(1);
    if (days == 1) return 'يوم واحد';
    if (days == 2) return 'يومان';
    if (days >= 3 && days <= 10) return '$formatted أيام';
    return '$formatted يوم';
  }

  static String percentageLabel(double value) {
    final normalized = value <= 1.0 ? value * 100 : value;
    return '${normalized.clamp(0, 100).toStringAsFixed(0)}%';
  }

  static String relativeTime(DateTime? dateTime) {
    if (dateTime == null) return notAvailableShort;
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      if (m == 1) return 'منذ دقيقة';
      if (m == 2) return 'منذ دقيقتين';
      if (m <= 10) return 'منذ $m دقائق';
      return 'منذ $m دقيقة';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      if (h == 1) return 'منذ ساعة';
      if (h == 2) return 'منذ ساعتين';
      if (h <= 10) return 'منذ $h ساعات';
      return 'منذ $h ساعة';
    }
    final d = diff.inDays;
    if (d == 1) return 'منذ يوم';
    if (d == 2) return 'منذ يومين';
    if (d <= 10) return 'منذ $d أيام';
    return 'منذ $d يوم';
  }
}
