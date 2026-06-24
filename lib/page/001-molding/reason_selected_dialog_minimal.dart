import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ================================================================
// MINIMAL REPRODUCIBLE EXAMPLE — ReasonSelectDialog Debug Version
// Focus: String → Map type mismatch debugging
// ================================================================

/// ------------------------------------------------------------
/// MOCK MODELS (disederhanakan dari project asli)
/// ------------------------------------------------------------
class MockReasonDropdownModel {
  final String idReason;
  final String nameReason;
  MockReasonDropdownModel({required this.idReason, required this.nameReason});
  factory MockReasonDropdownModel.fromJson(dynamic json) {
    // FIX: Tangani jika json adalah String, bukan Map
    if (json is String) {
      debugPrint('[ERROR] ReasonDropdownModel.fromJson received String: $json');
      return MockReasonDropdownModel(idReason: '', nameReason: json);
    }
    final map = json as Map<String, dynamic>;
    return MockReasonDropdownModel(
      idReason: map['id_reason']?.toString() ?? '',
      nameReason: map['name_reason']?.toString() ?? '',
    );
  }
}

class MockRecordDetailModel {
  final String idRecord;
  final String jobNumber;
  final int shootQty;
  MockRecordDetailModel({
    required this.idRecord,
    required this.jobNumber,
    required this.shootQty,
  });
  factory MockRecordDetailModel.fromJson(dynamic json) {
    if (json is String) {
      debugPrint('[ERROR] RecordDetailModel.fromJson received String: $json');
      return MockRecordDetailModel(idRecord: json, jobNumber: '', shootQty: 0);
    }
    final map = json as Map<String, dynamic>;
    return MockRecordDetailModel(
      idRecord: map['id_record']?.toString() ?? '',
      jobNumber: map['job_number']?.toString() ?? '',
      shootQty: (map['shoot_qty'] is int)
          ? map['shoot_qty']
          : int.tryParse(map['shoot_qty']?.toString() ?? '0') ?? 0,
    );
  }
}

class MockRunningDetailModel {
  final String idRecord;
  final List<MockRecordDetailModel> detailsRecord;
  // ⚠️ POTENTIAL BUG SOURCE: ngData bisa String dari API!
  final dynamic ngDataRaw;

  MockRunningDetailModel({
    required this.idRecord,
    required this.detailsRecord,
    required this.ngDataRaw,
  });

  factory MockRunningDetailModel.fromJson(dynamic json) {
    debugPrint('[DEBUG] MockRunningDetailModel.fromJson called');
    debugPrint('[DEBUG] Input runtimeType: ${json.runtimeType}');

    if (json is String) {
      debugPrint('[CRITICAL] Expected Map but got String! Value: $json');
      // Attempt to parse if it's a stringified JSON
      try {
        final parsed = jsonDecode(json);
        return MockRunningDetailModel.fromJson(parsed);
      } catch (e) {
        throw Exception('Cannot parse String to Map: $json');
      }
    }

    final map = json as Map<String, dynamic>;

    // DEBUG: Print all keys and their types
    map.forEach((key, value) {
      debugPrint(
          '[DEBUG] Key: $key | Type: ${value.runtimeType} | Value: $value');
    });

    // Parse details_record
    var detailsJson = map['details_record'];
    List<MockRecordDetailModel> detailsList = [];
    if (detailsJson is List) {
      detailsList =
          detailsJson.map((e) => MockRecordDetailModel.fromJson(e)).toList();
    } else if (detailsJson is String) {
      debugPrint('[WARNING] details_record is String, attempting parse...');
      try {
        final parsed = jsonDecode(detailsJson);
        if (parsed is List) {
          detailsList =
              parsed.map((e) => MockRecordDetailModel.fromJson(e)).toList();
        }
      } catch (e) {
        debugPrint('[ERROR] Failed to parse details_record: $e');
      }
    }

    return MockRunningDetailModel(
      idRecord: map['id_record']?.toString() ?? '',
      detailsRecord: detailsList,
      ngDataRaw: map['ng_data'], // Keep raw for debugging
    );
  }

  /// Safe getter: Convert ng_data to List<Map<String, dynamic>>
  List<Map<String, dynamic>> get ngDataAsList {
    debugPrint('[DEBUG] ngDataAsList called');
    debugPrint('[DEBUG] ngDataRaw type: ${ngDataRaw.runtimeType}');
    debugPrint('[DEBUG] ngDataRaw value: $ngDataRaw');

    if (ngDataRaw == null) {
      debugPrint('[DEBUG] ngDataRaw is null, returning empty list');
      return [];
    }

    // FIX: Handle String case (API might return stringified JSON)
    if (ngDataRaw is String) {
      debugPrint('[WARNING] ngDataRaw is String! Attempting jsonDecode...');
      try {
        final decoded = jsonDecode(ngDataRaw);
        return _convertToMapList(decoded);
      } catch (e) {
        debugPrint('[ERROR] jsonDecode failed for ngDataRaw: $e');
        return [];
      }
    }

    return _convertToMapList(ngDataRaw);
  }

  List<Map<String, dynamic>> _convertToMapList(dynamic data) {
    if (data is List) {
      return data.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        } else if (item is String) {
          // FIX: If individual item is String, try to parse
          debugPrint('[WARNING] ng_data item is String: $item');
          try {
            return jsonDecode(item) as Map<String, dynamic>;
          } catch (e) {
            return {'raw_value': item};
          }
        } else {
          debugPrint('[ERROR] Unknown ng_data item type: ${item.runtimeType}');
          return {'raw_value': item.toString()};
        }
      }).toList();
    }
    debugPrint('[ERROR] ng_data is not a List, it is: ${data.runtimeType}');
    return [];
  }
}

/// ------------------------------------------------------------
/// MOCK PROVIDER (disederhanakan)
/// ------------------------------------------------------------
class MockRunningProvider extends ChangeNotifier {
  List<MockRunningDetailModel> _recordDetails = [];
  List<MockRunningDetailModel> get recordDetails => _recordDetails;

  List<MockReasonDropdownModel> _reasonItems = [];
  List<MockReasonDropdownModel> get reasonItems => _reasonItems;

  MockReasonDropdownModel? _selectedReason;
  MockReasonDropdownModel? get selectedReason => _selectedReason;

  bool isLoadingDetails = false;
  bool isLoadingReason = false;
  String? detailErrorMessage;
  String? reasonErrorMessage;

  // Simulate API call with potential String → Map error
  Future<void> loadRecordDetail(String idRecord) async {
    isLoadingDetails = true;
    detailErrorMessage = null;
    notifyListeners();

    try {
      // Simulated API response with various problematic formats
      final mockResponse = _getMockResponse(idRecord);

      debugPrint('=== [DEBUG] loadRecordDetail ===');
      debugPrint('Raw response type: ${mockResponse.runtimeType}');
      debugPrint('Raw response: $mockResponse');

      // CRITICAL: Check if response itself is a String
      if (mockResponse is String) {
        debugPrint('[CRITICAL] API returned String instead of Map!');
        throw Exception('API response is String, expected Map: $mockResponse');
      }

      // Parse the response
      final detail = MockRunningDetailModel.fromJson(mockResponse);
      _recordDetails = [detail];

      debugPrint(
          '[DEBUG] Parsed successfully. Records count: ${_recordDetails.length}');
      debugPrint('[DEBUG] NG Data count: ${detail.ngDataAsList.length}');
    } catch (e, stackTrace) {
      debugPrint('[ERROR] loadRecordDetail failed: $e');
      debugPrint('[STACK] $stackTrace');
      detailErrorMessage = e.toString();
      _recordDetails = [];
    }

    isLoadingDetails = false;
    notifyListeners();
  }

  Future<void> loadReasonItems() async {
    isLoadingReason = true;
    reasonErrorMessage = null;
    notifyListeners();

    try {
      // Simulate API returning List<dynamic> with potential String entries
      final mockReasons = [
        {'id_reason': '01', 'name_reason': 'Normal Stop'},
        {'id_reason': '03', 'name_reason': 'Change Operator'},
        {'id_reason': '06', 'name_reason': 'Change Machine'},
      ];

      debugPrint('=== [DEBUG] loadReasonItems ===');
      _reasonItems = mockReasons.map((e) {
        debugPrint('[DEBUG] Parsing reason: $e | Type: ${e.runtimeType}');
        return MockReasonDropdownModel.fromJson(e);
      }).toList();
    } catch (e, stackTrace) {
      debugPrint('[ERROR] loadReasonItems failed: $e');
      debugPrint('[STACK] $stackTrace');
      reasonErrorMessage = e.toString();
    }

    isLoadingReason = false;
    notifyListeners();
  }

  void setSelectedReason(MockReasonDropdownModel? reason) {
    _selectedReason = reason;
    notifyListeners();
  }

  /// Simulate various problematic API responses
  dynamic _getMockResponse(String idRecord) {
    // Toggle these to test different scenarios:
    const scenario = 'normal'; // 'normal', 'string_ng_data', 'string_response'

    switch (scenario) {
      case 'normal':
        return {
          'id_record': idRecord,
          'details_record': [
            {
              'id_record': idRecord,
              'job_number': 'JOB-001',
              'shoot_qty': 100,
            }
          ],
          'ng_data': [
            {'id_ng': 'NG01', 'qty': 5, 'jobnumber': 'JOB-001'},
          ],
        };

      case 'string_ng_data':
        // ⚠️ SIMULATED BUG: ng_data is a JSON string instead of List
        return {
          'id_record': idRecord,
          'details_record': [
            {
              'id_record': idRecord,
              'job_number': 'JOB-001',
              'shoot_qty': 100,
            }
          ],
          // THIS CAUSES: type 'String' is not a subtype of type 'Map<String, dynamic>'
          'ng_data': jsonEncode([
            {'id_ng': 'NG01', 'qty': 5, 'jobnumber': 'JOB-001'},
          ]),
        };

      case 'string_response':
        // ⚠️ SIMULATED BUG: Entire response is a String
        return jsonEncode({
          'id_record': idRecord,
          'details_record': [],
          'ng_data': [],
        });

      default:
        return {};
    }
  }
}

/// ------------------------------------------------------------
/// MINIMAL WIDGET
/// ------------------------------------------------------------
class ReasonSelectDialogMinimal extends StatefulWidget {
  final String idRecord;
  const ReasonSelectDialogMinimal({super.key, required this.idRecord});

  @override
  State<ReasonSelectDialogMinimal> createState() =>
      _ReasonSelectDialogMinimalState();
}

class _ReasonSelectDialogMinimalState extends State<ReasonSelectDialogMinimal> {
  // ⚠️ POTENTIAL BUG: This is List<Map<String, String>>
  // But API ng_data is List<Map<String, dynamic>>
  List<Map<String, String>> ngDataList = [];

  final TextEditingController ngQtyController = TextEditingController();
  String? selectedNgCode;
  String? selectedNgName;

  @override
  void initState() {
    super.initState();
    debugPrint('=== [DEBUG] initState ===');
    debugPrint('idRecord: ${widget.idRecord}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MockRunningProvider>();
      provider.loadRecordDetail(widget.idRecord);
      provider.loadReasonItems();
    });
  }

  /// Demonstrate the String → Map conversion with full debug logging
  void _debugAddNgData(dynamic rawNgItem) {
    debugPrint('=== [DEBUG] _debugAddNgData ===');
    debugPrint('Input rawNgItem: $rawNgItem');
    debugPrint('Input runtimeType: ${rawNgItem.runtimeType}');

    // Step 1: Convert to Map<String, dynamic> first
    Map<String, dynamic> ngMap;
    if (rawNgItem is String) {
      debugPrint('[WARNING] rawNgItem is String, decoding...');
      try {
        ngMap = jsonDecode(rawNgItem);
      } catch (e) {
        debugPrint('[ERROR] Cannot decode String: $e');
        return;
      }
    } else if (rawNgItem is Map<String, dynamic>) {
      ngMap = rawNgItem;
    } else {
      debugPrint('[ERROR] Unknown type: ${rawNgItem.runtimeType}');
      return;
    }

    // Step 2: Safely extract values
    final idNg = ngMap['id_ng']?.toString() ?? '';
    final qty = ngMap['qty']?.toString() ?? '0';
    final jobnumber = ngMap['jobnumber']?.toString() ?? '';

    debugPrint(
        '[DEBUG] Extracted - idNg: $idNg, qty: $qty, jobnumber: $jobnumber');

    // Step 3: Store as Map<String, String> (local state)
    setState(() {
      ngDataList.add({
        'id_ng': idNg,
        'qty': qty,
        'jobnumber': jobnumber,
      });
    });

    debugPrint('[DEBUG] ngDataList after add: $ngDataList');
  }

  /// Convert local List<Map<String, String>> to API format List<Map<String, dynamic>>
  List<Map<String, dynamic>> _buildNgDataForApi() {
    debugPrint('=== [DEBUG] _buildNgDataForApi ===');
    debugPrint('ngDataList length: ${ngDataList.length}');

    final result =
        ngDataList.where((item) => item['id_ng'] != null).map((item) {
      debugPrint('[DEBUG] Mapping item: $item | Type: ${item.runtimeType}');

      // FIX: Safely convert String values to proper types
      return {
        'id_ng': item['id_ng'] ?? '',
        'qty': int.tryParse(item['qty'] ?? '0') ?? 0, // String → int
        'jobnumber': item['jobnumber'] ?? '',
      };
    }).toList();

    debugPrint('[DEBUG] API payload: $result');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MockRunningProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Debug: Reason Select')),
        body: Consumer<MockRunningProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingDetails || provider.isLoadingReason) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.detailErrorMessage != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Error: ${provider.detailErrorMessage}'),
                    const SizedBox(height: 8),
                    const Text(
                      'Check debug console for details',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            if (provider.recordDetails.isEmpty) {
              return const Center(child: Text('No Data'));
            }

            final data = provider.recordDetails.first;
            final ngDataFromApi = data.ngDataAsList;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === RECORD INFO ===
                  Text('Record ID: ${data.idRecord}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  if (data.detailsRecord.isNotEmpty)
                    Text('Job Number: ${data.detailsRecord.first.jobNumber}'),
                  if (data.detailsRecord.isNotEmpty)
                    Text('Shoot Qty: ${data.detailsRecord.first.shootQty}'),
                  const Divider(height: 32),

                  // === NG DATA FROM API ===
                  Text('NG Data from API (${ngDataFromApi.length} items):',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...ngDataFromApi.map((ng) => Card(
                        child: ListTile(
                          title: Text('ID: ${ng['id_ng']}'),
                          subtitle: Text(
                              'Qty: ${ng['qty']} | Job: ${ng['jobnumber']}'),
                          trailing: Text('Type: ${ng.runtimeType}',
                              style: const TextStyle(fontSize: 10)),
                        ),
                      )),
                  const Divider(height: 32),

                  // === REASON DROPDOWN ===
                  Text('Select Reason:',
                      style: Theme.of(context).textTheme.titleMedium),
                  DropdownButton<MockReasonDropdownModel>(
                    isExpanded: true,
                    value: provider.selectedReason,
                    hint: const Text('Choose Reason'),
                    items: provider.reasonItems.map((reason) {
                      return DropdownMenuItem(
                        value: reason,
                        child: Text(reason.nameReason),
                      );
                    }).toList(),
                    onChanged: (selected) {
                      debugPrint(
                          '[DEBUG] Selected reason: ${selected?.nameReason}');
                      provider.setSelectedReason(selected);
                    },
                  ),
                  const SizedBox(height: 16),

                  // === MANUAL NG INPUT (Simulating user input) ===
                  Text('Add NG Data (Manual):',
                      style: Theme.of(context).textTheme.titleMedium),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ngQtyController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'NG Qty',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Simulate adding NG data
                          _debugAddNgData({
                            'id_ng': 'NG-${ngDataList.length + 1}',
                            'qty': int.tryParse(ngQtyController.text) ?? 0,
                            'jobnumber': data.detailsRecord.isNotEmpty
                                ? data.detailsRecord.first.jobNumber
                                : '',
                          });
                          ngQtyController.clear();
                        },
                        child: const Text('ADD'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // === LOCAL NG LIST ===
                  Text('Local NG List (${ngDataList.length} items):',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...ngDataList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Card(
                      child: ListTile(
                        title: Text('ID: ${item['id_ng']}'),
                        subtitle: Text('Qty: ${item['qty']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => ngDataList.removeAt(index));
                          },
                        ),
                      ),
                    );
                  }),
                  const Divider(height: 32),

                  // === BUILD API PAYLOAD ===
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('BUILD API PAYLOAD (DEBUG)'),
                      onPressed: () {
                        final apiPayload = _buildNgDataForApi();
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('API Payload'),
                            content: SingleChildScrollView(
                              child: Text(
                                const JsonEncoder.withIndent('  ')
                                    .convert(apiPayload),
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // === EXPLANATION ===
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.yellow.shade100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Common Causes of String→Map Error:',
                            style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        const Text(
                            '1. API returns ng_data as JSON string instead of List'),
                        const Text(
                            '2. Response body is stringified instead of parsed Map'),
                        const Text(
                            '3. Mixing Map<String,String> with Map<String,dynamic>'),
                        const SizedBox(height: 8),
                        Text('Fix: Always validate runtimeType before casting!',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ================================================================
// STANDALONE RUNNER (for testing)
// Replace main.dart temporarily to test:
// void main() => runApp(MaterialApp(home: ReasonSelectDialogMinimal(idRecord: 'TEST-001')));
// ================================================================
