# Refactor scanGoldPill - Separation of Concerns
Current Working Directory: /home/androidlinux/MANPRO/mobile/flutter_provider_data

## Steps (0/7 completed)

### 1. [ ] Create TODO.md (IN PROGRESS)
### 2. [x] Edit material_provider.dart: Remove scanGoldPill(BuildContext context)
### 3. [x] Edit recordprocess.dart: Refactor Gold Pill onIconTap with Navigator + try-catch + error handling
### 4. [x] Check recordtesting.dart: Already correctly using scanGoldPillFromCode with Navigator in widget (good)
### 5. [ ] Test valid QR scan: success snackbar, data filled
### 6. [ ] Test invalid QR: error snackbar, data cleared
### 7. [ ] Test API error: fetchError snackbar
### 6. [ ] Test invalid QR: error snackbar, data cleared
### 7. [ ] Test API error: fetchError snackbar
### 8. [ ] Flutter pub get && run to verify

**Notes:**  
- Provider: Pure logic only (no context/Navigator)  
- Widget: Handles Navigator, error UI (CustomSnackbar)  
- context.mounted checks after await  
- Consumer auto-fills controller
