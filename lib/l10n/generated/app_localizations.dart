import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// App name, shown as the home screen's AppBar title and OS-level app title.
  ///
  /// In en, this message translates to:
  /// **'Beyond Widgets'**
  String get appTitle;

  /// No description provided for @demo01Title.
  ///
  /// In en, this message translates to:
  /// **'Naive Overlay'**
  String get demo01Title;

  /// No description provided for @demo01Subtitle.
  ///
  /// In en, this message translates to:
  /// **'CameraPreview + Stack + naive scaling — watch it break'**
  String get demo01Subtitle;

  /// No description provided for @demo02Title.
  ///
  /// In en, this message translates to:
  /// **'Coordinate Transform'**
  String get demo02Title;

  /// No description provided for @demo02Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Detect → Normalize → Rotate → Scale → Offset'**
  String get demo02Subtitle;

  /// No description provided for @demo03Title.
  ///
  /// In en, this message translates to:
  /// **'Camera Pipeline & Sync'**
  String get demo03Title;

  /// No description provided for @demo03Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Naive queueing vs. latest-frame back pressure'**
  String get demo03Subtitle;

  /// No description provided for @demo04Title.
  ///
  /// In en, this message translates to:
  /// **'Rendering Performance'**
  String get demo04Title;

  /// No description provided for @demo04Subtitle.
  ///
  /// In en, this message translates to:
  /// **'setState() everything vs. Listenable + CustomPainter'**
  String get demo04Subtitle;

  /// No description provided for @demo05Title.
  ///
  /// In en, this message translates to:
  /// **'Interactive Overlay'**
  String get demo05Title;

  /// No description provided for @demo05Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Bidirectional transform: tap → image coordinates'**
  String get demo05Subtitle;

  /// No description provided for @demo06Title.
  ///
  /// In en, this message translates to:
  /// **'Beyond the Phone Screen'**
  String get demo06Title;

  /// No description provided for @demo06Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Real OCR → translation → Even G2 via Even Hub SDK'**
  String get demo06Subtitle;

  /// No description provided for @fitCover.
  ///
  /// In en, this message translates to:
  /// **'cover'**
  String get fitCover;

  /// No description provided for @fitContain.
  ///
  /// In en, this message translates to:
  /// **'contain'**
  String get fitContain;

  /// No description provided for @realMlKitOcr.
  ///
  /// In en, this message translates to:
  /// **'Real ML Kit OCR'**
  String get realMlKitOcr;

  /// No description provided for @switchCameraTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get switchCameraTooltip;

  /// No description provided for @naiveOverlayHint.
  ///
  /// In en, this message translates to:
  /// **'scaleX/scaleY only — no rotation or BoxFit-crop compensation. Rotate the device or switch to \"contain\" to see it break.'**
  String get naiveOverlayHint;

  /// No description provided for @correctedTransformTitle.
  ///
  /// In en, this message translates to:
  /// **'Corrected transform pipeline'**
  String get correctedTransformTitle;

  /// No description provided for @correctedTransformOnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Detect → Normalize → Rotate → Scale → Offset'**
  String get correctedTransformOnSubtitle;

  /// No description provided for @correctedTransformOffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Naive scaleX/scaleY (same as demo 01)'**
  String get correctedTransformOffSubtitle;

  /// No description provided for @pacingNaiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Naive: process every frame'**
  String get pacingNaiveLabel;

  /// No description provided for @pacingLatestFrameLabel.
  ///
  /// In en, this message translates to:
  /// **'Latest frame + back pressure'**
  String get pacingLatestFrameLabel;

  /// No description provided for @simulatedAnalysisTime.
  ///
  /// In en, this message translates to:
  /// **'Simulated analysis time: {ms} ms (capture is fixed at ~30 fps / 33 ms)'**
  String simulatedAnalysisTime(int ms);

  /// No description provided for @statProcessed.
  ///
  /// In en, this message translates to:
  /// **'Processed'**
  String get statProcessed;

  /// No description provided for @statQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get statQueued;

  /// No description provided for @statDropped.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get statDropped;

  /// No description provided for @statLastLatency.
  ///
  /// In en, this message translates to:
  /// **'Last latency'**
  String get statLastLatency;

  /// No description provided for @latencyMs.
  ///
  /// In en, this message translates to:
  /// **'{ms}ms'**
  String latencyMs(int ms);

  /// No description provided for @naiveQueueExplanation.
  ///
  /// In en, this message translates to:
  /// **'Every captured frame is queued. If analysis is slower than capture, the queue grows without bound and latency keeps climbing.'**
  String get naiveQueueExplanation;

  /// No description provided for @latestFrameExplanation.
  ///
  /// In en, this message translates to:
  /// **'Only the newest frame is kept while one is being analyzed; anything captured in between is dropped, so latency stays bounded.'**
  String get latestFrameExplanation;

  /// No description provided for @queueMore.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String queueMore(int count);

  /// No description provided for @renderNaiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Naive: setState() everything'**
  String get renderNaiveLabel;

  /// No description provided for @renderBetterLabel.
  ///
  /// In en, this message translates to:
  /// **'Listenable + CustomPainter'**
  String get renderBetterLabel;

  /// No description provided for @statHeavyTreeBuilds.
  ///
  /// In en, this message translates to:
  /// **'Heavy tree builds'**
  String get statHeavyTreeBuilds;

  /// No description provided for @statAvgFrameBuild.
  ///
  /// In en, this message translates to:
  /// **'Avg frame build'**
  String get statAvgFrameBuild;

  /// No description provided for @avgFrameBuildValue.
  ///
  /// In en, this message translates to:
  /// **'{ms} ms'**
  String avgFrameBuildValue(String ms);

  /// No description provided for @tapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a box to convert screen -> image coordinates.'**
  String get tapHint;

  /// No description provided for @noBoxAtPoint.
  ///
  /// In en, this message translates to:
  /// **'No box at image point ({x}, {y})'**
  String noBoxAtPoint(int x, int y);

  /// No description provided for @hitBoxAtPoint.
  ///
  /// In en, this message translates to:
  /// **'Hit \"{label}\" at image point ({x}, {y})'**
  String hitBoxAtPoint(String label, int x, int y);

  /// No description provided for @noCameraAvailable.
  ///
  /// In en, this message translates to:
  /// **'No camera available on this device.'**
  String get noCameraAvailable;

  /// No description provided for @bridgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Bridge'**
  String get bridgeLabel;

  /// No description provided for @bridgeListening.
  ///
  /// In en, this message translates to:
  /// **'ws://127.0.0.1:{port}'**
  String bridgeListening(int port);

  /// No description provided for @bridgeStopped.
  ///
  /// In en, this message translates to:
  /// **'stopped'**
  String get bridgeStopped;

  /// No description provided for @evenHubClientsLabel.
  ///
  /// In en, this message translates to:
  /// **'Even Hub clients'**
  String get evenHubClientsLabel;

  /// No description provided for @recognizedLabel.
  ///
  /// In en, this message translates to:
  /// **'Recognized (OCR)'**
  String get recognizedLabel;

  /// No description provided for @sentToG2Label.
  ///
  /// In en, this message translates to:
  /// **'Sent to G2'**
  String get sentToG2Label;

  /// No description provided for @noValuePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'–'**
  String get noValuePlaceholder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
