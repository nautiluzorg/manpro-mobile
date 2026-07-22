/// A single row in the MOLD SETUP / VACUM JIG SETUP checklist tables.
class ChecklistItem {
  final String item;
  final List<String> remarks;

  const ChecklistItem({required this.item, required this.remarks});
}

/// Business content for the "MOLD SETUP" checklist.
///
/// IMPORTANT: index here maps 1:1 to
/// `TestingProvider.isCheckedMold(index)` / `updateCheckMold(index, value)`.
/// Do not reorder without updating the provider's checkbox state list.
const List<ChecklistItem> moldSetupChecklist = [
  ChecklistItem(
    item: 'PIN BUSH',
    remarks: [
      'OK JIKA PIN BUSH LENGKAP SEBANYAK 4 PCS',
      'OK JIKA PIN BUSH TIDAK DAMAGE/SCRATCH/SHIFTING',
      'OK JIKA PIN BUSH SUDAH TERLUMASI GREASE',
    ],
  ),
  ChecklistItem(
    item: 'GUIDE BUSH',
    remarks: [
      'OK JIKA GUIDE BUSH LENGKAP SEBANYAK 4 PCS',
      'OK JIKA PERMUKAAN GUIDE BUSH SAMA DAN TIDAK MIRING',
      'OK JIKA GUIDE BUSH SUDAH TERLUMASI GREASE',
    ],
  ),
  ChecklistItem(
    item: 'SPRING SAFETY',
    remarks: ['OK JIKA SPRING SAFETY BERSIH DARI BURRY DAN KENCANG'],
  ),
  ChecklistItem(
    item: 'SPRING HEIGHT',
    remarks: [
      'PASTIKAN TINGGI SPRING MESIN SAMA ATAU SEJAJAR (UNTUK PANSTONE SINGLE LAYER)',
    ],
  ),
  ChecklistItem(
    item: 'POSITIONING',
    remarks: [
      'PENGENCANGAN SETIAP BAUT DILAKUKAN SETELAH PEMANASAN MOLD',
    ],
  ),
  ChecklistItem(
    item: 'MOLD CONDITION',
    remarks: [
      'PERIKSA KEMBALI KONDISI MOLD, APAKAH TERDAPAT SCRATCH DAN PASTIKAN TIDAK ADA SOFT BURRY DI DALAM CONTACT POINT.',
    ],
  ),
  ChecklistItem(
    item: 'PLATING MOLD & JIG',
    remarks: [
      'PERIKSA KONDISI PLATING APAKAH ADA YANG TERKELUPAS ATAU BERTAMBAH TIPIS ATAU TIDAK.',
    ],
  ),
  ChecklistItem(
    item: 'BOLT CONDITION',
    remarks: ['OK JIKA BAUT MOLD DIPASANG LENGKAP DAN TIDAK AUS'],
  ),
  ChecklistItem(
    item: 'PACKING RUBBER',
    remarks: [
      'PERIKSA KONDISI PACKING RUBBER,APAKAH ADA YANG ROBEK & WARNA PACKING RUBBER SESUAI ATURAN.',
      'OK JIKA PACKING RUBBER SUDAH TERLUMASI GREASE',
    ],
  ),
  ChecklistItem(
    item: 'MOLD OPENING ANGLE',
    remarks: [
      'OK JIKA SUDUT BUKAAN MOLD HARUS TERBUKA DI RANGE 80-90 DERAJAT DAN DIUKUR MENGGUNAKAN ALAT UKUR DIGITAL BUSUR DERAJAT.',
    ],
  ),
];

/// Business content for the "VACUM JIG SETUP" checklist.
///
/// IMPORTANT: index here maps 1:1 to
/// `TestingProvider.isCheckedVacum(index)` / `updateCheckVacum(index, value)`.
const List<ChecklistItem> vacumJigChecklist = [
  ChecklistItem(
    item: 'STOPPER',
    remarks: [
      'OK JIKA STOPPER LENGKAP SEBANYAK 4 PCS DAN TIDAK GOYANG SERTA TINGGINYA SAMA.',
    ],
  ),
  ChecklistItem(
    item: 'GUIDE BUSH DI TOP',
    remarks: [
      'OK JIKA GUIDE BUSH LENGKAP SEBANYAK 4 PCS, TIDAK KENDOR DAN BENTUK TAMPILANNYA BAGUS.',
    ],
  ),
  ChecklistItem(
    item: 'SUCTION PIN',
    remarks: [
      'OK JIKA SEMUA PIN LENGKAP, BISA MENGANGKAT PILL, TAMPILAN PIN BAGUS DAN TIDAK GOMPAL.',
    ],
  ),
  ChecklistItem(
    item: 'GUIDE PIN ON BOTTOM VACUUM',
    remarks: [
      'OK JIKA STOPPER LENGKAP SEBANYAK 4 PCS, TIDAK KENDOR DAN TAMPILAN BAGUS (TIDAK GOMPAL).',
    ],
  ),
  ChecklistItem(
    item: 'TOP VACUUM NO BENDING',
    remarks: [
      'OK JIKA VACUUM JIG RATA PADA SAAT DIMASUKAN KE BOTTOM VACUUM DAN KE MOLD',
    ],
  ),
];
