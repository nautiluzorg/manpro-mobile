import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/provider/testing_provider.dart';

/// "NOTE" editor dialog. Extracted verbatim from record_testing.dart's
/// `_showNoteDialog` — same layout, same setNotes() call on SUBMIT.
void showNoteEditorDialog(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final provider = context.read<TestingProvider>();
  final noteController = TextEditingController(text: provider.notes);

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Note",
    pageBuilder: (_, __, ___) {
      return SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Material(
              borderRadius: BorderRadius.circular(10),
              elevation: 8,
              child: SizedBox(
                width: size.width * 0.9,
                height: size.height * 0.3,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "NOTE",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: TextField(
                          controller: noteController,
                          maxLines: null,
                          expands: true,
                          decoration: const InputDecoration(
                            hintText: "Masukkan catatan...",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            child: const Text("CLOSE"),
                          ),
                          const SizedBox(width: 8),
                          Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blueAccent, Colors.blue.shade800],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                context
                                    .read<TestingProvider>()
                                    .setNotes(noteController.text.trim());
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: const Text(
                                "SUBMIT",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
