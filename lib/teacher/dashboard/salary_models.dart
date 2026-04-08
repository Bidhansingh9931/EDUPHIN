class SalaryPageData {
  final BankAccount account;
  final List<SalaryRecord> salaries;

  SalaryPageData({required this.account, required this.salaries});

  factory SalaryPageData.fromJson(Map<String, dynamic> json) {
    return SalaryPageData(
      account: BankAccount.fromJson(json['account'] is Map ? json['account'] : {}),
      salaries: (json['salaries'] is List ? json['salaries'] as List : [])
          .where((s) => s != null && s is Map)
          .map((s) => SalaryRecord.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BankAccount {
  final String accountHolderName;
  final String? accountNumber;
  final String? ifscCode;
  final String? bankName;
  final String? branch;

  BankAccount({
    required this.accountHolderName,
    this.accountNumber,
    this.ifscCode,
    this.bankName,
    this.branch,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      accountHolderName: json['name'] ?? 'N/A', 
      accountNumber: json['bank_account_number']?.toString(),
      ifscCode: json['ifsc_code']?.toString(),
      bankName: json['bank_name']?.toString(),
      branch: json['branch_name']?.toString(), 
    );
  }
}

class SalaryRecord {
  final int id;
  final String? paymentDate;
  final String baseSalary;
  final String deduction;
  final String netSalary;
  final String status;

  SalaryRecord({
    required this.id,
    this.paymentDate,
    required this.baseSalary,
    required this.deduction,
    required this.netSalary,
    required this.status,
  });

  factory SalaryRecord.fromJson(Map<String, dynamic> json) {
    return SalaryRecord(
      id: json['id'] ?? 0,
      paymentDate: json['payment_date'],
      baseSalary: json['basic_salary']?.toString() ?? '0',
      deduction: json['deductions']?.toString() ?? '0', 
      netSalary: json['net_salary']?.toString() ?? '0',
      status: json['status'] ?? 'Paid',
    );
  }
}
