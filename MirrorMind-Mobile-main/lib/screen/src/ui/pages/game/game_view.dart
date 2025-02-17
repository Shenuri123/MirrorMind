import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirrormind/screen/home/home.dart';
import 'package:mirrormind/screen/nav/nav.dart';
import 'package:mirrormind/screen/src/domain/models/move_to.dart';
import 'package:mirrormind/screen/src/ui/pages/game/controller/game_controller.dart';
import 'package:mirrormind/screen/src/ui/pages/game/widgets/background.dart';
import 'package:mirrormind/screen/src/ui/pages/game/widgets/game_app_bar.dart';
import 'package:mirrormind/screen/src/ui/pages/game/widgets/game_buttons.dart';
import 'package:mirrormind/screen/src/ui/pages/game/widgets/puzzle_interactor.dart';
import 'package:mirrormind/screen/src/ui/pages/game/widgets/puzzle_options.dart';
import 'package:mirrormind/screen/src/ui/pages/game/widgets/time_and_moves.dart';
import 'package:mirrormind/screen/src/ui/pages/game/widgets/winner_dialog.dart';
import 'package:mirrormind/screen/src/ui/utils/responsive.dart';
import 'package:provider/provider.dart';

import '../../../../explore/explore.dart';


class GameView extends StatelessWidget {
  const GameView({Key? key}) : super(key: key);

  void _onKeyBoardEvent(BuildContext context, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final moveTo = event.logicalKey.keyLabel.moveTo;
      if (moveTo != null) {
        context.read<GameController>().onMoveByKeyboard(moveTo);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final width = responsive.width;
    return ChangeNotifierProvider(
      create: (_) {
        final controller = GameController();
        controller.onFinish.listen(
          (_) {
            Timer(
              const Duration(
                milliseconds: 200,
              ),
              () {
                showWinnerDialog(
                  context,
                  moves: controller.state.moves,
                  time: controller.time.value,
                );
              },
            );
          },
        );
        return controller;
      },
      builder: (context, child) => RawKeyboardListener(
        autofocus: true,
        includeSemantics: false,
        focusNode: FocusNode(),
        onKey: (event) => _onKeyBoardEvent(context, event),
        child: child!,
      ),
      child: GameBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          // appBar: AppBar(
          //   leading: IconButton(
          //     icon: Icon(
          //       Icons.arrow_back,
          //       color: Colors.black, // Change arrow color to black
          //     ),
          //     onPressed: () {
          //        Navigator.pop(context);
          //     },
          //   ),
          //   backgroundColor: Colors.transparent,
          //   elevation: 0,
          // ),
          body: SafeArea(
            child: OrientationBuilder(
              builder: (_, orientation) {
                final isPortrait = orientation == Orientation.portrait;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const GameAppBar(),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (_, constraints) {
                          final height = constraints.maxHeight;
                          final puzzleHeight =
                              (isPortrait ? height * 0.45 : height * 0.5)
                                  .clamp(250, 700)
                                  .toDouble();
                          final optionsHeight =
                              (isPortrait ? height * 0.25 : height * 0.2)
                                  .clamp(120, 200)
                                  .toDouble();

                          return SizedBox(
                            height: height,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: optionsHeight,
                                    child: PuzzleOptions(
                                      width: width,
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.1,
                                  ),
                                  const TimeAndMoves(),
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: SizedBox(
                                      height: puzzleHeight,
                                      child: const AspectRatio(
                                        aspectRatio: 1,
                                        child: PuzzleInteractor(),
                                      ),
                                    ),
                                  ),
                                  const GameButtons(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
