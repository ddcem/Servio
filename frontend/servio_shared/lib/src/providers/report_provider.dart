import 'dart:typed_data';

import 'package:intl/intl.dart';

import '../api/api_client.dart';
import '../models/reports.dart';

class ReportProvider {
  ReportProvider(this.api);

  final ApiClient api;
  static final _date = DateFormat('yyyy-MM-dd');

  Map<String, dynamic> _period(DateTime from, DateTime to) => {'from': _date.format(from), 'to': _date.format(to)};

  Future<SalesReport> getSales(DateTime from, DateTime to) async =>
      SalesReport.fromJson(await api.get('reports/sales', query: _period(from, to)) as Map<String, dynamic>);

  Future<StaffReport> getStaff(DateTime from, DateTime to) async =>
      StaffReport.fromJson(await api.get('reports/staff', query: _period(from, to)) as Map<String, dynamic>);

  Future<Uint8List> getSalesPdf(DateTime from, DateTime to) => api.getBytes('reports/sales/pdf', query: _period(from, to));

  Future<Uint8List> getStaffPdf(DateTime from, DateTime to) => api.getBytes('reports/staff/pdf', query: _period(from, to));
}
