import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../constants/images.dart';
import '../hive_registrar.g.dart';
import '../models/normal_game_stats/normal_game_stats.dart';
import '../models/quick_game_stats/quick_game_stats.dart';
import '../models/settings/settings.dart';
import '../models/time_game_stats/time_game_stats.dart';
import 'logger_service.dart';

class HiveService implements Disposable {
  final LoggerService logger;

  HiveService({
    required this.logger,
  });

  ///
  /// VARIABLES
  ///

  late final Box<NormalGameStats> normalGameStatsBox;
  late final Box<QuickGameStats> quickGameStatsBox;
  late final Box<TimeGameStats> timeGameStatsBox;
  late final Box<SettingsHive> settingsBox;

  ///
  /// INIT
  ///

  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapters();

    normalGameStatsBox = await Hive.openBox<NormalGameStats>('normalGameStatsBox');
    quickGameStatsBox = await Hive.openBox<QuickGameStats>('quickGameStatsBox');
    timeGameStatsBox = await Hive.openBox<TimeGameStats>('timeGameStatsBox');
    settingsBox = await Hive.openBox<SettingsHive>('settingsBox');
  }

  ///
  /// DISPOSE
  ///

  @override
  Future<void> onDispose() async {
    await normalGameStatsBox.close();
    await quickGameStatsBox.close();
    await timeGameStatsBox.close();
    await settingsBox.close();

    await Hive.close();
  }

  ///
  /// METHODS
  ///

  /// Called to add a new [NormalGameStats] value to [Hive]
  Future<void> addNormalGameStatsToBox({required NormalGameStats normalGameStats}) async => normalGameStatsBox.add(normalGameStats);

  /// Called to get all [NormalGameStats] values from [Hive]
  List<NormalGameStats> getNormalGameStatsFromBox() => normalGameStatsBox.values.toList();

  /// Called to add a new [QuickGameStats] value to [Hive]
  Future<void> addQuickGameStatsToBox({required QuickGameStats quickGameStats}) async => quickGameStatsBox.add(quickGameStats);

  /// Called to get all [QuickGameStats] values from [Hive]
  List<QuickGameStats> getQuickGameStatsFromBox() => quickGameStatsBox.values.toList();

  /// Called to add a new [TimeGameStats] value to [Hive]
  Future<void> addTimeGameStatsToBox({required TimeGameStats timeGameStats}) async => timeGameStatsBox.add(timeGameStats);

  /// Called to get all [TimeGameStats] values from [Hive]
  List<TimeGameStats> getTimeGameStatsFromBox() => timeGameStatsBox.values.toList();

  /// Called to add a new `Settings` value to [Hive]
  Future<void> addSettingsToBox(SettingsHive settingsHive) async => settingsBox.put(0, settingsHive);

  /// Called to get `Settings` from [Hive]
  SettingsHive getSettingsFromBox() =>
      settingsBox.get(0) ??
      SettingsHive(
        background: ModerniAliasImages.starsStandard,
        useDynamicBackgrounds: true,
        useCircularTimer: false,
      );
}
