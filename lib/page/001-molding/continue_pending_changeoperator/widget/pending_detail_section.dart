import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/ng_operator_model.dart';
import 'package:flutter_provider_data/model/record_pending_detail_model.dart';
import 'package:flutter_provider_data/utils/logger.dart';

class PendingDetailSection extends StatelessWidget {
  final RecordPendingDetailModel data;

  const PendingDetailSection({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _pendingInfoTable(data),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                _pendingNgSection(data),
              ],
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _pendingInfoTable(RecordPendingDetailModel data) {
    final rows = [
      ('JOBNUMBER', data.jobnumber.toString(), true),
      ('MACHINE', data.machineName, false),
      ('BCODE', data.bcode, false),
      ('QTY', data.qty.toString(), false),
      ('START JOB', formatDateTime(data.startTime), false),
      ('PENDING TIME', formatDateTime(data.startPending), false),
      ('REASON', data.reason.toString(), false),

      // Shoot
      ('TOTAL SHOOT', data.shootQty.toString(), false),
      ('DONE SHOOT', data.lastQtyShoot.toString(), false),
      ('SISA SHOOT', data.sisaShoot.toString(), false),
    ];

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FixedColumnWidth(20),
        2: FlexColumnWidth(2),
      },
      children: List.generate(rows.length, (index) {
        final item = rows[index];

        final bool isReason = item.$1 == 'REASON';
        final bool isSisaShoot = item.$1 == 'SISA SHOOT';

        return _tableRow(
          label: item.$1,
          value: item.$2,
          isBold: isReason || isSisaShoot,
          valueColor: isReason
              ? Colors.red
              : isSisaShoot
                  ? Colors.orange.shade800
                  : null,
          index: index,
        );
      }),
    );
  }

  TableRow _tableRow({
    required String label,
    required String value,
    required int index,
    bool isBold = false,
    Color? valueColor,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        color: index.isEven
            ? Colors.indigo.shade200.withValues(alpha: 0.15)
            : Colors.white,
        border: const Border(
          bottom: BorderSide(color: Colors.grey),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(6),
          child: Text(
            ':',
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _pendingNgSection(RecordPendingDetailModel data) {
    final ngList = data.ngList;

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              children: [
                const TextSpan(
                  text: 'NG LIST OLEH OPERATOR ',
                ),
                TextSpan(
                  text: data.employeeName,
                  style: const TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          if (ngList.length == 1 &&
              ngList[0].idNg == '000000' &&
              ngList[0].ngName.toUpperCase() == 'NO NG')
            Text(
              'SO FAR IS GOOD NO NG FOUND.',
              style: TextStyle(
                color: Colors.green.shade800,
              ),
            )
          else
            _ngTable(ngList),
        ],
      ),
    );
  }

  Widget _ngTable(List<NgOperatorModel> ngList) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: Table(
              border: TableBorder.all(
                color: Colors.grey.shade400,
              ),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(4),
                2: FlexColumnWidth(1),
              },
              children: [
                _ngHeaderRow(),
                ...ngList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ng = entry.value;
                  final bool isEven = index.isEven;

                  return TableRow(
                    decoration: BoxDecoration(
                      color: isEven
                          ? Colors.indigo.shade200.withValues(alpha: 0.15)
                          : Colors.white,
                    ),
                    children: [
                      _ngCell(
                        (index + 1).toString(),
                        alignCenter: true,
                      ),
                      _ngCell(ng.ngName),
                      _ngCell(
                        ng.qty.toString(),
                        alignCenter: true,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  TableRow _ngHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueAccent,
            Colors.blue.shade900,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      children: [
        _ngHeaderCell('NO'),
        _ngHeaderCell('NG NAME'),
        _ngHeaderCell('QTY'),
      ],
    );
  }

  Widget _ngHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _ngCell(
    String text, {
    bool alignCenter = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: alignCenter ? TextAlign.center : TextAlign.left,
      ),
    );
  }
}
