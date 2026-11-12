import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/technician/record_chocotei/model/action_record.dart';
import 'package:google_fonts/google_fonts.dart';

class ActionPickerDialog extends StatelessWidget {
  const ActionPickerDialog({
    super.key,
    required this.parentAction,
  });

  final String parentAction;

  @override
  Widget build(BuildContext context) {
    final group = actionGroupFor(parentAction);
    final actions = actionsForGroup(parentAction);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      title: Row(
        children: [
          Expanded(
            child: Text(
              'PILIH ACTION ${group?.code ?? ''}',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade800,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Tutup',
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: Colors.blueGrey.shade700,
              size: 28,
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: actions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final action = actions[index];

            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.blue.shade900],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: SizedBox(
                height: 72,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                  onTap: () => Navigator.of(context).pop(action),
                  leading: const Icon(
                    Icons.task_alt,
                    color: Colors.white,
                    size: 30,
                  ),
                  title: Text(
                    action.label,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
