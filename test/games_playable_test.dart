import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobquebracodigo/games/connect4/connect4_page.dart';
import 'package:mobquebracodigo/games/flow/flow_page.dart';
import 'package:mobquebracodigo/games/minesweeper/minesweeper_page.dart';
import 'package:mobquebracodigo/theme/qc_theme.dart';

void main() {
  Future<void> open(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(theme: QcTheme.dark(), home: page));
    await tester.pump();
  }

  testWidgets('Connect 4 aceita jogada e responde', (tester) async {
    await open(tester, const Connect4Page());
    expect(find.text('Connect 4'), findsWidgets);
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Minesweeper revela a primeira casa', (tester) async {
    await open(tester, const MinesweeperPage());
    expect(find.text('Minesweeper'), findsWidgets);
    await tester.tap(find.byType(InkWell).at(20));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('Flow Free monta o tabuleiro', (tester) async {
    await open(tester, const FlowPage());
    expect(find.text('Flow Free'), findsWidgets);
    expect(find.text('1/100'), findsOneWidget);
    final board = find.descendant(
      of: find.byType(GestureDetector),
      matching: find.byType(CustomPaint),
    );
    await tester.drag(board, const Offset(80, 0));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Flow Free avanca de fase ao concluir', (tester) async {
    await open(tester, const FlowPage());
    expect(find.text('1/100'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Dica'));
      await tester.pump();
    }
    expect(find.text('Proxima'), findsNothing);
    expect(find.text('1/100'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('2/100'), findsOneWidget);
  });
}
