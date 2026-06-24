import 'package:flutter/material.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:google_fonts/google_fonts.dart';

/// DataTable untuk menampilkan list NG yang sudah di-add.
class NgDataTable extends StatelessWidget {
  final List<Map<String, String>> ngDataList;
  final void Function(int index) onDelete;

  const NgDataTable({
    super.key,
    required this.ngDataList,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      width: double.infinity,
      height: 500,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.blue.shade800),
          columnSpacing: 32,
          columns: [
            DataColumn(
              label: SizedBox(
                width: 30,
                child: Text(
                  'NO',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 90,
                child: Text(
                  'OPERATOR',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 220,
                child: Text(
                  'NG NAME',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 40,
                child: Text(
                  'QTY',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 80,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'DELETE',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
          rows: List.generate(ngDataList.length, (index) {
            final item = ngDataList[index];
            return DataRow(
              color: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  return index.isEven
                      ? Colors.blue.shade100.withValues(alpha: 0.5)
                      : Colors.white;
                },
              ),
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(
                  Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          "${AppConfig.baseUrl}/media/img/employee/${item['idEmployee'] ?? 'default'}.png",
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person, size: 40);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item['nmEmployee'] ?? 'No Name',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(Text(item['ngName']!)),
                DataCell(Text(item['qty']!)),
                DataCell(
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDelete(index),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
