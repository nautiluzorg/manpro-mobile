import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/001-molding/continue_pending.dart';
import 'package:flutter_provider_data/page/001-molding/continue_pending_changemachine.dart';
import 'package:flutter_provider_data/page/001-molding/continue_pending_changeoperator.dart';
import 'package:flutter_provider_data/page/001-molding/continue_pending_workdayover.dart';

Future<bool?> showRunningDialog(
  BuildContext context,
  String idPending,
  String idReason,
  String idProses,
  String productType, {
  void Function(bool)? onSuccess,
}) {
  late final Widget targetPage;

  if (idReason == '02') {
    targetPage = ContinuePendingWorkdayOver(
      idPending: idPending,
      idProses: idProses,
      productType: productType,
      onSuccess: onSuccess,
    );
  } else if (idReason == '03') {
    targetPage = ContinuePendingChangeOperator(
      idPending: idPending,
      onSuccess: onSuccess,
    );
  } else if (idReason == '06') {
    targetPage = ContinuePendingChangeMachine(
      idPending: idPending,
      onSuccess: onSuccess,
    );
  } else {
    targetPage = ContinuePending(
      idPending: idPending,
      idProses: idProses,
      onSuccess: onSuccess,
    );
  }

  return Navigator.push<bool>(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => targetPage,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        return FadeTransition(opacity: curved, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
      fullscreenDialog: false,
    ),
  );
}
