class ReportModel {
  final double totalIncome; // total_pemasukan
  final double totalExpense; // total_pengeluaran
  final double balance; // saldo

  ReportModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      totalIncome: double.tryParse(json['total_pemasukan'].toString()) ?? 0.0,
      totalExpense: double.tryParse(json['total_pengeluaran'].toString()) ?? 0.0,
      balance: double.tryParse(json['saldo'].toString()) ?? 0.0,
    );
  }

  // Fallback if balance is empty but income/expense exists
  factory ReportModel.fromJsonWithFallback(Map<String, dynamic> json) {
    double income = double.tryParse(json['total_pemasukan'].toString()) ?? 0.0;
    double expense = double.tryParse(json['total_pengeluaran'].toString()) ?? 0.0;
    double balance = double.tryParse(json['saldo'].toString()) ?? 0.0;

    if (balance == 0.0 && (income > 0 || expense > 0)) {
      balance = income - expense;
    }

    return ReportModel(
      totalIncome: income,
      totalExpense: expense,
      balance: balance,
    );
  }
}
