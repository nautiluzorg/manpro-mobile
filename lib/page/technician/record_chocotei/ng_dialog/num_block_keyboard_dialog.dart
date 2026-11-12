import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/ng_dropdown_model.dart';
import 'package:flutter_provider_data/provider/jobnumber_provider.dart';
import 'package:flutter_provider_data/provider/ng_provider.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'num_block.dart';

class NumBlockKeyboardDialog extends StatefulWidget {
  final String idProses;
  final String idEmployee;
  final String jobNumber;
  final String idRecordUpdate;
  final int qtyShoot;
  final String typeProduct;

  const NumBlockKeyboardDialog({
    super.key,
    required this.idProses,
    required this.idEmployee,
    required this.jobNumber,
    required this.idRecordUpdate,
    required this.qtyShoot,
    required this.typeProduct,
  });

  @override
  NumBlockKeyboardDialogState createState() => NumBlockKeyboardDialogState();
}

class NumBlockKeyboardDialogState extends State<NumBlockKeyboardDialog> {
  // ============================================================
  // DESIGN TOKENS: ubah di sini kalau mau fine-tuning
  // ============================================================
  static const double _pagePadding = 12; // jarak tepi layar
  static const double _gap = 12; // jarak antar elemen
  static const double _radius = 8; // radius card & tombol
  static const double _fieldRadius = 6; // radius input field
  static const double _fieldVPad = 16; // tinggi field (padding vertikal)
  static const double _btnHeight = 80; // tinggi tombol aksi
  static const double _btnFont = 22; // font tombol aksi
  static const double _stepperWidth = 176; // lebar kontrol +/- (Tab 2)
  static const double _stepperBtn = 40; // diameter tombol +/-

  final FocusNode _focusNode = FocusNode();
  bool _isNumBlockVisible = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      if (!mounted) return; // cek widget masih ada
      final ngProvider = context.read<NGProvider>();

      if (!ngProvider.hasLoadedForThisRecord) {
        ngProvider
            .loadNGList(
          productType: widget.typeProduct,
          idProses: widget.idProses,
        )
            .then((_) {
          ngProvider.hasLoadedForThisRecord = true;

          _initNgItemInputs(ngProvider);
          if (!mounted) return;
          setState(() {}); // rebuild UI supaya ListView muncul
        });
      }
    });

    // Listener untuk memantau fokus pada TextField
    _focusNode.addListener(() {
      setState(() {
        _isNumBlockVisible = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onNumPressed(String num) {
    final ngProvider = context.read<NGProvider>();
    final controller = ngProvider.quantityNgController;

    if (controller.text.length < 3) {
      controller.text += num;
      ngProvider.notifySubmitStateChanged(); // <-- update tombol submit
    }
  }

  void _backspace() {
    final ngProvider = context.read<NGProvider>();
    final controller = ngProvider.quantityNgController;

    setState(() {
      if (controller.text.isNotEmpty) {
        controller.text =
            controller.text.substring(0, controller.text.length - 1);
      }

      ngProvider.notifySubmitStateChanged();
    });
  }

  void _closeNumBlock() {
    setState(() {
      _isNumBlockVisible = false;
      _focusNode.unfocus();
    });
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  void _initNgItemInputs(NGProvider ngProvider) {
    ngProvider.ngItemInputs =
        ngProvider.listNG.map((ng) => NgItemInput(ngItem: ng)).toList();
  }

  // ============================================================
  // HELPER WIDGET (tampilan saja, tanpa logic)
  // ============================================================

  /// Placeholder untuk state loading / error / kosong di area dropdown
  Widget _buildStateBox(Widget child) {
    return SizedBox(
      height: 56,
      child: Center(child: child),
    );
  }

  /// Judul kecil di atas form
  Widget _buildSectionHeader() {
    return Row(
      children: [
        Icon(Icons.edit_note_rounded, size: 20, color: Colors.blue.shade800),
        const SizedBox(width: 8),
        Text(
          'Pilih item NG dan isi QTY',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton(Color color) {
    return SizedBox.expand(
      child: OutlinedButton(
        onPressed: _closeDialog,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: color, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(color.withValues(alpha: 0.1)),
        ),
        child: Text(
          "CANCEL",
          style: GoogleFonts.poppins(
            color: color,
            fontSize: _btnFont,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton({
    required bool enabled,
    required VoidCallback onPressed,
    required Color startColor,
    required Color endColor,
  }) {
    return SizedBox.expand(
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.transparent;
            }
            return Colors.white.withAlpha(25);
          }),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: enabled
                ? LinearGradient(
                    colors: [startColor, endColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              "SUBMIT",
              style: GoogleFonts.poppins(
                color: enabled ? Colors.white : Colors.grey.shade200,
                fontSize: _btnFont,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: _stepperBtn,
      height: _stepperBtn,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: color,
          elevation: 1,
          shape: const CircleBorder(),
        ),
        onPressed: onPressed,
        child: Icon(icon, size: 22, color: Colors.white),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          toolbarHeight: 56,
          title: Text(
            'ADD NG',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.blue.shade900],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(_radius),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(_radius),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.blue.shade50,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.blue.shade900,
                  unselectedLabelColor: Colors.white,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(
                      height: 42,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, size: 18),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "TAMBAH NG PER ITEM",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      height: 42,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.playlist_add, size: 18),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "TAMBAH NG SERENTAK",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // ============================
            // Tab 1: Single Input (DropdownSearch + QTY)
            // ============================
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(_pagePadding),
                child: Column(
                  children: [
                    // ---- Card form: mengisi sisa tinggi layar ----
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(_radius),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(),
                                const SizedBox(height: 4),
                                Divider(
                                  color: Colors.grey.shade300,
                                  height: 16,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Kiri: dropdown NG
                                    Expanded(
                                      flex: 7,
                                      child: Consumer<NGProvider>(
                                        builder: (context, ngProvider, child) {
                                          // === LOADING ===
                                          if (ngProvider.isLoading) {
                                            return _buildStateBox(
                                              const CircularProgressIndicator(),
                                            );
                                          }

                                          // === ERROR ===
                                          if (ngProvider.errorMessage != null) {
                                            return _buildStateBox(
                                              Text(
                                                ngProvider.errorMessage!,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.red,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            );
                                          }

                                          // === DATA KOSONG ===
                                          if (ngProvider.listNG.isEmpty) {
                                            return _buildStateBox(
                                              Text(
                                                "Tidak ada data NG tersedia.",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            );
                                          }

                                          // === TAMPILKAN DROPDOWN ===
                                          return DropdownSearch<
                                              NgDropdownModel>(
                                            items: (f, cs) => ngProvider.listNG,
                                            itemAsString:
                                                (NgDropdownModel? item) =>
                                                    item?.ngName ?? '',
                                            compareFn: (a, b) =>
                                                a.idNg == b.idNg,
                                            onChanged:
                                                (NgDropdownModel? selected) {
                                              if (selected != null) {
                                                ngProvider.selectedNgCode =
                                                    selected.idNg;
                                                ngProvider.selectedNgItem =
                                                    selected.ngName;

                                                logPrint(
                                                    'Selected: ${selected.idNg} - ${selected.ngName}');
                                              }
                                            },
                                            decoratorProps:
                                                DropDownDecoratorProps(
                                              decoration: InputDecoration(
                                                labelText: "NG ITEM",
                                                hintText: "PILIH NG",
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: _fieldVPad,
                                                ),
                                                labelStyle: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue.shade900,
                                                ),
                                                hintStyle: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.grey.shade600,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          _fieldRadius),
                                                ),
                                              ),
                                            ),
                                            popupProps: PopupProps.menu(
                                              showSearchBox: true,
                                              searchFieldProps: TextFieldProps(
                                                decoration: InputDecoration(
                                                  labelText: "Search NG",
                                                  hintText: "Search...",
                                                  labelStyle:
                                                      GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.blue.shade900,
                                                  ),
                                                  hintStyle:
                                                      GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  prefixIcon:
                                                      const Icon(Icons.search),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            _fieldRadius),
                                                  ),
                                                ),
                                                textCapitalization:
                                                    TextCapitalization
                                                        .characters,
                                                keyboardType:
                                                    TextInputType.text,
                                                autocorrect: false,
                                                enableSuggestions: false,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                              itemBuilder: (context, item,
                                                  isDisabled, isSelected) {
                                                return Card(
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 3.0,
                                                      horizontal: 8.0),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            _fieldRadius),
                                                  ),
                                                  elevation: 1.5,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.indigoAccent,
                                                          Colors
                                                              .indigo.shade900,
                                                        ],
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              _fieldRadius),
                                                    ),
                                                    child: ListTile(
                                                      dense: true,
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        horizontal: 16,
                                                        vertical: 6,
                                                      ),
                                                      title: Text(
                                                        item.ngName,
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 18.0,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop(item);
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                              scrollbarProps:
                                                  const ScrollbarProps(
                                                trackVisibility: true,
                                                thumbVisibility: true,
                                              ),
                                              constraints: BoxConstraints(
                                                maxHeight:
                                                    MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.64,
                                                minWidth: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.98,
                                              ),
                                              menuProps: const MenuProps(
                                                margin:
                                                    EdgeInsets.only(top: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(6)),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(width: _gap),

                                    // Kanan: QTY
                                    Expanded(
                                      flex: 3,
                                      child: Consumer<NGProvider>(
                                        builder: (context, ngProvider, child) {
                                          return TextField(
                                            controller:
                                                ngProvider.quantityNgController,
                                            readOnly: true,
                                            focusNode: _focusNode,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            decoration: InputDecoration(
                                              labelText: 'QTY',
                                              labelStyle: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue.shade900,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: _fieldVPad,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        _fieldRadius),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // NumBlock - ditempatkan di atas seluruh layout
                            if (_isNumBlockVisible) ...[
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: NumBlock(
                                    onNumPressed: _onNumPressed,
                                    onBackspace: _backspace,
                                    onClose: _closeNumBlock,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: _gap),

                    // ---- CANCEL & SUBMIT ----
                    SizedBox(
                      height: _btnHeight,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildCancelButton(Colors.red.shade700),
                          ),
                          const SizedBox(width: _gap),
                          Expanded(
                            child: Consumer<NGProvider>(
                              builder: (context, ngProvider, child) {
                                final jobProvider =
                                    context.read<JobNumberProvider>();

                                return _buildSubmitButton(
                                  enabled: ngProvider.isSubmitEnabled,
                                  startColor: Colors.indigoAccent,
                                  endColor: Colors.indigo.shade900,
                                  onPressed: () {
                                    final quantity = int.tryParse(ngProvider
                                            .quantityNgController.text) ??
                                        0;

                                    if (ngProvider.selectedNgCode != null &&
                                        ngProvider.selectedNgItem != null &&
                                        quantity > 0) {
                                      ngProvider.addOrUpdateNG(
                                        code: ngProvider.selectedNgCode!,
                                        name: ngProvider.selectedNgItem!,
                                        quantity: quantity,
                                        idRecord: widget.idRecordUpdate,
                                        idEmployee: widget.idEmployee,
                                        jobNumber: widget.jobNumber,
                                        qtyShoot: widget.qtyShoot,
                                      );

                                      ngProvider.selectedNgCode = null;
                                      ngProvider.selectedNgItem = null;
                                      ngProvider.quantityNgController.clear();

                                      jobProvider.updateQtyActualBasedOnNG(
                                          ngProvider.getTotalNG());

                                      Navigator.of(context).pop();
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ============================
            // Tab 2: Batch Input (pakai wrapper class NgItemInput)
            // ============================
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(_pagePadding),
                child: Consumer<NGProvider>(
                  builder: (context, ngProvider, child) {
                    // Initialize ngItemInputs hanya sekali
                    if (ngProvider.ngItemInputs.isEmpty &&
                        ngProvider.listNG.isNotEmpty) {
                      ngProvider.ngItemInputs = ngProvider.listNG
                          .map((ng) => NgItemInput(ngItem: ng))
                          .toList();
                    }

                    if (ngProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Column(
                      children: [
                        // ---- List NG: mengisi sisa tinggi layar ----
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 4),
                            itemCount: ngProvider.ngItemInputs.length,
                            itemBuilder: (context, index) {
                              final ngInput = ngProvider.ngItemInputs[index];
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(_radius),
                                ),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 2),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(_radius),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.indigoAccent,
                                        Colors.indigo.shade900
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Nama NG
                                      Expanded(
                                        child: Text(
                                          ngInput.ngItem.ngName,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Kontrol QTY (lebar tetap)
                                      SizedBox(
                                        width: _stepperWidth,
                                        child: Row(
                                          children: [
                                            _buildStepperButton(
                                              icon: Icons.remove,
                                              color: Colors.red.shade500,
                                              onPressed: () {
                                                ngProvider.decreaseQty(index);
                                              },
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: TextField(
                                                controller: ngInput.controller,
                                                keyboardType:
                                                    TextInputType.number,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: "QTY",
                                                  hintStyle:
                                                      GoogleFonts.poppins(
                                                    color: Colors.grey.shade500,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  isDense: true,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            _fieldRadius),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            _fieldRadius),
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .grey.shade400,
                                                        width: 1.5),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            _fieldRadius),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.blue,
                                                            width: 2),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    vertical: 11,
                                                    horizontal: 4,
                                                  ),
                                                ),
                                                onChanged: (value) {
                                                  ngProvider
                                                      .updateQtyFromTextField(
                                                          index, value);
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            _buildStepperButton(
                                              icon: Icons.add,
                                              color: Colors.green,
                                              onPressed: () {
                                                ngProvider.increaseQty(index);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: _gap),

                        // ---- CANCEL & SUBMIT ----
                        SizedBox(
                          height: _btnHeight,
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildCancelButton(Colors.blue.shade800),
                              ),
                              const SizedBox(width: _gap),
                              Expanded(
                                child: _buildSubmitButton(
                                  enabled: ngProvider.isAnyQtyMoreThanZero,
                                  startColor: Colors.blueAccent,
                                  endColor: Colors.blue.shade900,
                                  onPressed: () {
                                    ngProvider.submitNgItems(
                                      idRecord: widget.idRecordUpdate,
                                      idEmployee: widget.idEmployee,
                                      jobNumber: widget.jobNumber,
                                      qtyShoot: widget.qtyShoot,
                                    );

                                    int totalNG = ngProvider.getTotalNG();

                                    final jobProvider =
                                        Provider.of<JobNumberProvider>(context,
                                            listen: false);
                                    jobProvider
                                        .updateQtyActualBasedOnNG(totalNG);

                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/ng_dropdown_model.dart';
import 'package:flutter_provider_data/provider/jobnumber_provider.dart';
import 'package:flutter_provider_data/provider/ng_provider.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'num_block.dart';

class NumBlockKeyboardDialog extends StatefulWidget {
  final String idProses;
  final String idEmployee;
  final String jobNumber;
  final String idRecordUpdate;
  final int qtyShoot;
  final String typeProduct;

  const NumBlockKeyboardDialog({
    super.key,
    required this.idProses,
    required this.idEmployee,
    required this.jobNumber,
    required this.idRecordUpdate,
    required this.qtyShoot,
    required this.typeProduct,
  });

  @override
  NumBlockKeyboardDialogState createState() => NumBlockKeyboardDialogState();
}

class NumBlockKeyboardDialogState extends State<NumBlockKeyboardDialog> {
  // final TextEditingController _quantityNgController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isNumBlockVisible = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      if (!mounted) return; // cek widget masih ada
      final ngProvider = context.read<NGProvider>();

      if (!ngProvider.hasLoadedForThisRecord) {
        ngProvider
            .loadNGList(
          productType: widget.typeProduct,
          idProses: widget.idProses,
        )
            .then((_) {
          ngProvider.hasLoadedForThisRecord = true;

          _initNgItemInputs(ngProvider);
          setState(() {}); // rebuild UI supaya ListView muncul
        });
      }
    });

    // Listener untuk memantau fokus pada TextField
    _focusNode.addListener(() {
      setState(() {
        _isNumBlockVisible = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    // _quantityNgController.dispose();
    super.dispose();
  }

  void _onNumPressed(String num) {
    final ngProvider = context.read<NGProvider>();
    final controller = ngProvider.quantityNgController;

    if (controller.text.length < 3) {
      controller.text += num;
      ngProvider.notifySubmitStateChanged(); // <-- update tombol submit
    }
  }

  void _backspace() {
    final ngProvider = context.read<NGProvider>();
    final controller = ngProvider.quantityNgController;

    setState(() {
      if (controller.text.isNotEmpty) {
        controller.text =
            controller.text.substring(0, controller.text.length - 1);
      }

      ngProvider.notifySubmitStateChanged();
    });
  }

  void _closeNumBlock() {
    setState(() {
      _isNumBlockVisible = false;
      _focusNode.unfocus();
    });
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  void _initNgItemInputs(NGProvider ngProvider) {
    ngProvider.ngItemInputs =
        ngProvider.listNG.map((ng) => NgItemInput(ngItem: ng)).toList();
  }

  @override
  Widget build(BuildContext context) {
    //MENENTUKAN LEBAR APLIKASI****************
    double widthApp = MediaQuery.of(context).size.width;
    //MENENTUKAN TINGGI APLIKASI**********************
    double heightApp = MediaQuery.of(context).size.height;
    //MENENTUKAN TINGGI TOP APLIKASI PALING ATAS**********
    double paddingTop = MediaQuery.of(context).padding.top;

    double appBarHeight = 70 + 70; // toolbarHeight + bottom = 140
    double heightBody = heightApp - paddingTop - appBarHeight;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          toolbarHeight: 70, // ← tambah ini, default 56
          title: Text(
            'ADD NG',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.blue.shade900],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.blue.shade50,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.blue.shade900,
                  unselectedLabelColor: Colors.white,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(
                      height: 46,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, size: 20),
                          SizedBox(width: 6),
                          Text("TAMBAH NG PER ITEM"),
                        ],
                      ),
                    ),
                    Tab(
                      height: 46,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.playlist_add, size: 20),
                          SizedBox(width: 6),
                          Text("TAMBAH NG SERENTAK"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // ============================
            // Tab 1: Single Input (DropdownSearch + QTY)
            // ============================

            Container(
              padding: const EdgeInsets.all(5.0),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  width: widthApp * 1,
                  height: heightBody * 0.75,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey.shade700,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Stack(
                    children: [
                      // Bagian utama: Row yang berisi DropdownSearch dan TextField
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Bagian kiri: Konten teks
                          Expanded(
                            flex: 7,
                            child: Container(
                              alignment: Alignment.topCenter,
                              color: Colors.white,
                              padding: EdgeInsets.all(5.0),
                              child: Consumer<NGProvider>(
                                builder: (context, ngProvider, child) {
                                  // === LOADING ===
                                  if (ngProvider.isLoading) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  // === ERROR ===
                                  if (ngProvider.errorMessage != null) {
                                    return Center(
                                      child: Text(
                                        ngProvider.errorMessage!,
                                        style: GoogleFonts.poppins(
                                          color: Colors.red,
                                          fontSize: 14, // bisa disesuaikan
                                          fontWeight:
                                              FontWeight.w500, // optional
                                        ),
                                      ),
                                    );
                                  }

                                  // === DATA KOSONG ===
                                  if (ngProvider.listNG.isEmpty) {
                                    return Center(
                                      child: Text(
                                        "Tidak ada data NG tersedia.",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    );
                                  }

                                  // === TAMPILKAN DROPDOWN ===
                                  return DropdownSearch<NgDropdownModel>(
                                    items: (f, cs) => ngProvider.listNG,
                                    itemAsString: (NgDropdownModel? item) =>
                                        item?.ngName ?? '',
                                    compareFn: (a, b) => a.idNg == b.idNg,
                                    onChanged: (NgDropdownModel? selected) {
                                      if (selected != null) {
                                        ngProvider.selectedNgCode =
                                            selected.idNg;
                                        ngProvider.selectedNgItem =
                                            selected.ngName;

                                        logPrint(
                                            'Selected: ${selected.idNg} - ${selected.ngName}');
                                      }
                                    },
                                    decoratorProps: DropDownDecoratorProps(
                                      decoration: InputDecoration(
                                        labelText: "NG ITEM",
                                        hintText: "PILIH NG",
                                        labelStyle: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade900,
                                        ),
                                        hintStyle: GoogleFonts.poppins(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey.shade600,
                                        ),
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                    popupProps: PopupProps.menu(
                                      showSearchBox: true,
                                      searchFieldProps: TextFieldProps(
                                        decoration: InputDecoration(
                                          labelText: "Search NG",
                                          hintText: "Search...",
                                          labelStyle: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade900,
                                          ),
                                          hintStyle: GoogleFonts.poppins(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey.shade600,
                                          ),
                                          prefixIcon: const Icon(Icons.search),
                                          border: const OutlineInputBorder(),
                                        ),
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        keyboardType: TextInputType.text,
                                        autocorrect: false,
                                        enableSuggestions: false,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      itemBuilder: (context, item, isDisabled,
                                          isSelected) {
                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 10.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          elevation: 2,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.indigoAccent,
                                                  Colors.indigo.shade900,
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: ListTile(
                                                title: Text(
                                                  item.ngName,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 28.0,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .pop(item);
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      scrollbarProps: const ScrollbarProps(
                                        trackVisibility: true,
                                        thumbVisibility: true,
                                      ),
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                                0.64,
                                        minWidth:
                                            MediaQuery.of(context).size.width *
                                                0.98,
                                      ),
                                      menuProps: const MenuProps(
                                        margin: EdgeInsets.only(top: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4)),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Bagian kanan: Kolom dengan TextField
                          Expanded(
                            flex: 3,
                            child: Container(
                              alignment: Alignment.topCenter,
                              color: Colors.white,
                              padding: const EdgeInsets.all(5.0),
                              child: Consumer<NGProvider>(
                                builder: (context, ngProvider, child) {
                                  return Column(
                                    children: [
                                      TextField(
                                        controller:
                                            ngProvider.quantityNgController,
                                        readOnly: true,
                                        focusNode: _focusNode,
                                        style: GoogleFonts.poppins(),
                                        decoration: const InputDecoration(
                                          labelText: 'QTY',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      // NumBlock - ditempatkan di atas seluruh layout
                      if (_isNumBlockVisible) ...[
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: NumBlock(
                              onNumPressed: _onNumPressed,
                              onBackspace: _backspace,
                              onClose: _closeNumBlock,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                //Sampai sini ya *****************
                const SizedBox(height: 60.0),

                Container(
                  // width: widthApp * 1,
                  width: double.infinity,
                  height: heightBody * 0.12,
                  // height: heightBody * 0.12,
                  margin: const EdgeInsets.only(top: 10.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey.shade700,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2.0, vertical: 2.0),
                            width: constraints.maxWidth * 0.5,
                            height: constraints.maxHeight * 1,
                            color: Colors.white,
                            child: SizedBox.expand(
                              child: OutlinedButton(
                                onPressed: () {
                                  _closeDialog();
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: BorderSide(
                                    color: Colors.red.shade700, // ← merah
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ).copyWith(
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.red.withValues(
                                        alpha: 0.1), // ← efek tap merah
                                  ),
                                ),
                                child: Text(
                                  "CANCEL",
                                  style: GoogleFonts.poppins(
                                    color: Colors.red.shade700, // ← merah
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5.0),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2.0, vertical: 2.0),
                            width: constraints.maxWidth * 0.5,
                            height: constraints.maxHeight * 1,
                            child: Consumer<NGProvider>(
                              builder: (context, ngProvider, child) {
                                final jobProvider =
                                    context.read<JobNumberProvider>();

                                return SizedBox.expand(
                                  child: ElevatedButton(
                                    onPressed: ngProvider.isSubmitEnabled
                                        ? () {
                                            final quantity = int.tryParse(
                                                    ngProvider
                                                        .quantityNgController
                                                        .text) ??
                                                0;

                                            if (ngProvider.selectedNgCode != null &&
                                                ngProvider.selectedNgItem !=
                                                    null &&
                                                quantity > 0) {
                                              ngProvider.addOrUpdateNG(
                                                code:
                                                    ngProvider.selectedNgCode!,
                                                name:
                                                    ngProvider.selectedNgItem!,
                                                quantity: quantity,
                                                idRecord: widget.idRecordUpdate,
                                                idEmployee: widget.idEmployee,
                                                jobNumber: widget.jobNumber,
                                                qtyShoot: widget.qtyShoot,
                                              );

                                              ngProvider.selectedNgCode = null;
                                              ngProvider.selectedNgItem = null;
                                              ngProvider.quantityNgController
                                                  .clear();

                                              jobProvider
                                                  .updateQtyActualBasedOnNG(
                                                      ngProvider.getTotalNG());

                                              Navigator.of(context).pop();
                                            }
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: EdgeInsets.zero,
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                    ).copyWith(
                                      overlayColor:
                                          WidgetStateProperty.resolveWith(
                                              (states) {
                                        if (states
                                            .contains(WidgetState.disabled)) {
                                          return Colors.transparent;
                                        }
                                        return Colors.white.withAlpha(25);
                                      }),
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: ngProvider.isSubmitEnabled
                                            ? LinearGradient(
                                                colors: [
                                                  Colors.indigoAccent,
                                                  Colors.indigo.shade900
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              )
                                            : LinearGradient(
                                                colors: [
                                                  Colors.grey.shade400,
                                                  Colors.grey.shade500
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "SUBMIT",
                                          style: GoogleFonts.poppins(
                                            color: ngProvider.isSubmitEnabled
                                                ? Colors.white
                                                : Colors.grey.shade200,
                                            fontSize: 30,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ]),
            ),

            // ============================
            // Tab 2: Batch Input (pakai wrapper class NgItemInput)
            // ============================
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<NGProvider>(
                builder: (context, ngProvider, child) {
                  // Initialize ngItemInputs hanya sekali
                  if (ngProvider.ngItemInputs.isEmpty &&
                      ngProvider.listNG.isNotEmpty) {
                    ngProvider.ngItemInputs = ngProvider.listNG
                        .map((ng) => NgItemInput(ngItem: ng))
                        .toList();
                  }

                  return ngProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            SizedBox(
                              height: heightApp * 0.73,
                              child: ListView.builder(
                                itemCount: ngProvider.ngItemInputs.length,
                                itemBuilder: (context, index) {
                                  final ngInput =
                                      ngProvider.ngItemInputs[index];
                                  return Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 5),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 15),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.indigoAccent,
                                            Colors.indigo.shade900
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 8,
                                            child: Text(
                                              ngInput.ngItem.ngName,
                                              style: const TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            flex: 2,
                                            child: Row(
                                              children: [
                                                // Decrease
                                                SizedBox(
                                                  width: 32,
                                                  height: 32,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      backgroundColor:
                                                          Colors.red.shade500,
                                                      shape:
                                                          const CircleBorder(),
                                                    ),
                                                    onPressed: () {
                                                      ngProvider
                                                          .decreaseQty(index);
                                                    },
                                                    child: const Icon(
                                                        Icons.remove,
                                                        size: 18,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                // TextField
                                                Expanded(
                                                  child: TextField(
                                                    controller:
                                                        ngInput.controller,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                    decoration: InputDecoration(
                                                      hintText: "QTY",
                                                      hintStyle:
                                                          GoogleFonts.poppins(
                                                        color: Colors
                                                            .grey.shade500,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14,
                                                      ),
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8)),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey.shade400,
                                                            width: 1.5),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide:
                                                            const BorderSide(
                                                                color:
                                                                    Colors.blue,
                                                                width: 2),
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        vertical: 8,
                                                        horizontal: 8,
                                                      ),
                                                    ),
                                                    onChanged: (value) {
                                                      ngProvider
                                                          .updateQtyFromTextField(
                                                              index, value);
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                // Increase
                                                SizedBox(
                                                  width: 32,
                                                  height: 32,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      backgroundColor:
                                                          Colors.green,
                                                      shape:
                                                          const CircleBorder(),
                                                    ),
                                                    onPressed: () {
                                                      ngProvider
                                                          .increaseQty(index);
                                                    },
                                                    child: const Icon(Icons.add,
                                                        size: 18,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            // CANCEL & SUBMIT
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // CANCEL
                                Expanded(
                                  child: SizedBox(
                                    height: 100,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        side: BorderSide(
                                            color: Colors.blue.shade800,
                                            width: 2),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                      ),
                                      child: Text(
                                        "CANCEL",
                                        style: GoogleFonts.poppins(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade800),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                // SUBMIT
                                Expanded(
                                  child: SizedBox(
                                    height: 100,
                                    child: ElevatedButton(
                                      onPressed: ngProvider.isAnyQtyMoreThanZero
                                          ? () {
                                              ngProvider.submitNgItems(
                                                idRecord: widget.idRecordUpdate,
                                                idEmployee: widget.idEmployee,
                                                jobNumber: widget.jobNumber,
                                                qtyShoot: widget.qtyShoot,
                                              );

                                              int totalNG =
                                                  ngProvider.getTotalNG();

                                              final jobProvider = Provider.of<
                                                      JobNumberProvider>(
                                                  context,
                                                  listen: false);
                                              jobProvider
                                                  .updateQtyActualBasedOnNG(
                                                      totalNG);

                                              Navigator.of(context).pop();
                                            }
                                          : null,
                                      style: ButtonStyle(
                                        shape: WidgetStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                        padding: WidgetStateProperty.all(
                                            EdgeInsets.zero),
                                        backgroundColor:
                                            WidgetStateProperty.resolveWith(
                                                (states) {
                                          if (states
                                              .contains(WidgetState.disabled)) {
                                            return Colors.grey.shade400;
                                          }
                                          return null;
                                        }),
                                      ),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          gradient: ngProvider
                                                  .isAnyQtyMoreThanZero
                                              ? LinearGradient(
                                                  colors: [
                                                    Colors.blueAccent,
                                                    Colors.blue.shade900
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                )
                                              : LinearGradient(
                                                  colors: [
                                                    Colors.grey.shade400,
                                                    Colors.grey.shade500
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "SUBMIT",
                                            style: GoogleFonts.poppins(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w600,
                                              color: ngProvider
                                                      .isAnyQtyMoreThanZero
                                                  ? Colors.white
                                                  : Colors.grey.shade200,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

*/
