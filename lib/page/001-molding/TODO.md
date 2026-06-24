# Refactor reason_selected_massdialog.dart → Modular Structure (reason_dialog_mass)

## Status
- ✅ User approved detailed plan
- ✅ Created TODO.md for progress tracking
✅ **Phase 1: Create 10 modular files (10/10 DONE)**

## Phase 1: Directory Structure & Extract Components
```
reason_dialog_mass/
├── helpers/
│   ├── mass_reason_controller.dart     [ ]
│   └── mass_submit_helper.dart         [ ]
└── widgets/
    ├── mass_reason_dropdown.dart       [ ]
    ├── mass_employee_grid.dart         [ ]
    ├── mass_confirm_section.dart       [ ]
    ├── mass_employee_card.dart         [ ]
    ├── mass_info_line.dart             [ ]
    └── mass_action_buttons.dart        [ ]
```
- [ ] Refactor main file
- [ ] Update runninggridview.dart import

## Phase 2: Testing & Completion
- [ ] `flutter analyze`
- [ ] Test mass stop dialog (reason dropdown → QR confirm → submit)
- [ ] 🎉 Mark COMPLETE
