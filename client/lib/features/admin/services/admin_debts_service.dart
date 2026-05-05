import 'package:app/core/services/api_client.dart';
import 'package:dio/dio.dart';

class AdminDebtModel {
  final String id;
  final String clientId;
  final String clientName;
  final String appointmentId;
  final String serviceName;
  final DateTime appointmentDate;
  final double amount;
  final int status; // 0=Pending, 1=Paid, 2=Canceled
  final DateTime createdAt;

  const AdminDebtModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.appointmentId,
    required this.serviceName,
    required this.appointmentDate,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory AdminDebtModel.fromJson(Map<String, dynamic> json) {
    return AdminDebtModel(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      clientName: json['clientName'] as String,
      appointmentId: json['appointmentId'] as String,
      serviceName: json['serviceName'] as String,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class AdminClientDebtSummary {
  final String clientId;
  final String clientName;
  final double totalAmount;
  final List<AdminDebtModel> debts;

  AdminClientDebtSummary({
    required this.clientId,
    required this.clientName,
    required this.totalAmount,
    required this.debts,
  });
}

class AdminDebtsService {
  final Dio _client = ApiClient.client;

  Future<List<AdminClientDebtSummary>> getPendingDebts() async {
    try {
      final response = await _client.get('/payments/debts');

      if (response.data is! List) {
        return const [];
      }

      final models = (response.data as List)
          .map((item) => AdminDebtModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final map = <String, List<AdminDebtModel>>{};
      for (final debt in models) {
        map.putIfAbsent(debt.clientId, () => []).add(debt);
      }

      return map.entries.map((e) {
        final debts = e.value;
        final total = debts.fold(0.0, (sum, item) => sum + item.amount);
        return AdminClientDebtSummary(
          clientId: e.key,
          clientName: debts.first.clientName,
          totalAmount: total,
          debts: debts,
        );
      }).toList();
    } on DioException catch (e) {
      throw Exception('Falha ao carregar débitos pendentes: ${e.message}');
    } catch (e) {
      throw Exception('Falha ao carregar débitos pendentes.');
    }
  }

  Future<void> payDebts({
    required String clientId,
    required List<String> debtIds,
  }) async {
    try {
      await _client.post(
        '/payments/debts/pay',
        data: {
          'clientId': clientId,
          'debtIds': debtIds,
        },
      );
    } on DioException catch (e) {
      throw Exception('Falha ao registrar pagamento: ${e.message}');
    } catch (e) {
      throw Exception('Falha ao registrar pagamento.');
    }
  }

  Future<void> cancelDebts({
    required String clientId,
    required List<String> debtIds,
  }) async {
    try {
      await _client.post(
        '/payments/debts/cancel',
        data: {
          'clientId': clientId,
          'debtIds': debtIds,
        },
      );
    } on DioException catch (e) {
      throw Exception('Falha ao cancelar débito: ${e.message}');
    } catch (e) {
      throw Exception('Falha ao cancelar débito.');
    }
  }
}
