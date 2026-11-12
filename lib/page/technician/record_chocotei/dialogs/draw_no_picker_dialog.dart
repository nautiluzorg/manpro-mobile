import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/master/product_model.dart';
import 'package:flutter_provider_data/service/product_service.dart';
import 'package:google_fonts/google_fonts.dart';

class DrawNoPickerDialog extends StatefulWidget {
  const DrawNoPickerDialog({super.key});

  @override
  State<DrawNoPickerDialog> createState() => _DrawNoPickerDialogState();
}

class _DrawNoPickerDialogState extends State<DrawNoPickerDialog> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  CancelToken? _cancelToken;
  List<ProductModel> _products = const [];
  String _query = '';
  String? _errorMessage;
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cancelToken?.cancel('Draw No picker closed');
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    _debounce?.cancel();
    _cancelToken?.cancel('Search query changed');

    setState(() {
      _query = query;
      _products = const [];
      _errorMessage = null;
      _hasSearched = false;
      _isLoading = false;
    });

    if (query.length < 2) return;

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _searchProducts(query);
    });
  }

  Future<void> _searchProducts(String query) async {
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final products = await _productService.getProductDropdown(
        search: query,
        cancelToken: cancelToken,
      );

      if (!mounted ||
          cancelToken.isCancelled ||
          !identical(_cancelToken, cancelToken)) {
        return;
      }

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } on DioException catch (error) {
      if (!mounted ||
          error.type == DioExceptionType.cancel ||
          cancelToken.isCancelled ||
          !identical(_cancelToken, cancelToken)) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal mencari Draw No. Silakan coba lagi.';
      });
    } catch (_) {
      if (!mounted ||
          cancelToken.isCancelled ||
          !identical(_cancelToken, cancelToken)) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data Draw No.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = math.min(media.size.width - 24, 820.0);
    final height = math.min(media.size.height - 48, 680.0);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: width,
        height: height,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchField(),
              Expanded(child: _buildResults()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.blue.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'PILIH DRAW NO',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Tutup',
            onPressed: () => Navigator.of(context).pop(),
            icon:
                const Icon(Icons.close_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        autocorrect: false,
        enableSuggestions: false,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.blueGrey.shade800,
        ),
        decoration: InputDecoration(
          labelText: 'Cari Draw No / BCode',
          hintText: 'Ketik minimal 2 karakter...',
          prefixIcon: const Icon(Icons.search_rounded, size: 26),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  onPressed: _searchController.clear,
                  icon: const Icon(Icons.clear_rounded),
                ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blueGrey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue.shade700, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _messageState(
        icon: Icons.cloud_off_rounded,
        message: _errorMessage!,
      );
    }

    if (_query.length < 2) {
      return _messageState(
        icon: Icons.search_rounded,
        message: 'Ketik minimal 2 karakter untuk mencari Draw No.',
      );
    }

    if (_hasSearched && _products.isEmpty) {
      return _messageState(
        icon: Icons.search_off_rounded,
        message: 'Draw No tidak ditemukan.',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      itemCount: _products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final product = _products[index];
        return _productTile(product);
      },
    );
  }

  Widget _productTile(ProductModel product) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.of(context).pop(product),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueGrey.shade100),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withAlpha(18),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.blue.shade900],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.drawingNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BCODE: ${product.bcode}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blueGrey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.productCategory} • ${product.productType}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blueGrey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.blue.shade700),
            ],
          ),
        ),
      ),
    );
  }

  Widget _messageState({required IconData icon, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 52, color: Colors.blueGrey.shade300),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.blueGrey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
