import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/provider/testing_provider.dart';
import '../dialogs/note_dialog.dart';

/// "ADD NOTE" button + the read-only note preview box below it.
/// Extracted verbatim from record_testing.dart.
class NotePanel extends StatelessWidget {
  const NotePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TestingProvider>(
      builder: (context, provid, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.blue.shade800],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => showNoteEditorDialog(context),
                    icon: const Icon(Icons.sticky_note_2_outlined,
                        color: Colors.white),
                    label: const Text(
                      "ADD NOTE",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Container(
              constraints: const BoxConstraints(minHeight: 80),
              padding: const EdgeInsets.only(top: 10, bottom: 40),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blueGrey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  provid.notes.isNotEmpty ? provid.notes : "No note added",
                  style: TextStyle(
                    fontSize: 12,
                    color: provid.notes.isNotEmpty
                        ? Colors.black87
                        : Colors.grey.shade200,
                    fontStyle: provid.notes.isNotEmpty
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
