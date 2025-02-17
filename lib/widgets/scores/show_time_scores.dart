import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/enums.dart';
import '../../constants/text_styles.dart';
import '../../models/played_word/played_word.dart';
import '../../models/round/round.dart';
import '../../models/team/team.dart';
import '../../screens/time_game/time_game_controller.dart';
import '../../services/background_image_service.dart';
import '../../util/dependencies.dart';
import '../animated_column.dart';
import '../animated_list_view.dart';
import 'highscore_value.dart';
import 'played_word_value.dart';

void showTimeScores(
  BuildContext context, {
  required List<PlayedWord> playedWords,
  bool dismissible = true,
  bool roundEnd = false,
  bool gameFinished = false,
}) =>
    showModalBottomSheet(
      context: context,
      isDismissible: dismissible,
      builder: (context) => TimeScoresModal(
        playedWords: playedWords,
        roundEnd: roundEnd,
        gameFinished: gameFinished,
      ),
    );

class TimeScoresModal extends WatchingWidget {
  final List<PlayedWord> playedWords;
  final bool roundEnd;
  final bool gameFinished;

  const TimeScoresModal({
    required this.playedWords,
    this.roundEnd = false,
    this.gameFinished = false,
  });

  String calculateName({
    required int index,
    required List<Team> teams,
    List<Round>? rounds,
  }) {
    if (gameFinished) {
      return teams[index].name;
    }

    final calculatedRounds = List.from(rounds ?? []);

    if ((calculatedRounds.length) > index) {
      return calculatedRounds[index].playingTeam?.name ?? teams[index].name;
    } else {
      return teams[index].name;
    }
  }

  String calculatePoints({
    required int index,
    required List<Team> teams,
    List<Round>? rounds,
  }) {
    final calculatedRounds = List<Round>.from(rounds ?? []);

    final currentTeam = teams[index];
    late Round? currentRound;
    try {
      currentRound = calculatedRounds.firstWhere(
        (round) => round.playingTeam == currentTeam,
      );
    } catch (e) {
      currentRound = null;
    }

    final duration = Duration(seconds: currentRound?.durationSeconds ?? 0);
    return '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final backgroundImage = watchIt<BackgroundImageService>().value;

    final rounds = getIt.get<TimeGameController>().timeGameStats.rounds;

    final state = watchIt<TimeGameController>().value;
    final teams = state.teams;
    final timeGameDuration = state.timeGameDuration;
    final gameState = state.gameState;
    final currentlyPlayingTeamIndex = state.teams.indexWhere(
      (team) => team.name == state.playingTeam.name,
    );

    final duration = '${timeGameDuration.inMinutes.toString().padLeft(2, '0')}:${(timeGameDuration.inSeconds % 60).toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 36,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: AnimatedColumn(
          fastAnimations: true,
          mainAxisSize: MainAxisSize.min,
          children: [
            ///
            /// CURRENT SCORES
            ///
            Text(
              'scoresModalString'.tr(),
              style: ModerniAliasTextStyles.scoresTitle,
            ),
            AnimationLimiter(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 24,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: teams.length,
                itemBuilder: (_, index) => AnimatedListView(
                  fastAnimations: true,
                  index: index,
                  child: HighscoreValue(
                    teamName: calculateName(
                      rounds: rounds,
                      teams: teams,
                      index: index,
                    ),
                    points: currentlyPlayingTeamIndex == index && (roundEnd || gameState == GameState.playing)
                        ? duration
                        : calculatePoints(
                            rounds: rounds,
                            teams: teams,
                            index: index,
                          ),
                  ),
                ),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
              ),
            ),

            ///
            /// WORDS FROM LAST ROUND
            ///
            if (playedWords.isNotEmpty) ...[
              Text(
                'playedWordsModalString'.tr(),
                style: ModerniAliasTextStyles.scoresTitle,
              ),
              AnimationLimiter(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 56,
                    vertical: 24,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: playedWords.length,
                  itemBuilder: (_, index) => AnimatedListView(
                    fastAnimations: true,
                    index: index,
                    child: PlayedWordValue(
                      word: playedWords[index].word,
                      chosenAnswer: playedWords[index].chosenAnswer,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
