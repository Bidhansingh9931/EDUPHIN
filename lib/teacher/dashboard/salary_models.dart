class SalaryPageData {
  final BankAccount account;
  final List<SalaryRecord> salaries;

  SalaryPageData({required this.account, required this.salaries});

  factory SalaryPageData.fromJson(Map<String, dynamic> json) {
    final accountJson = json['account'] ?? (json['data'] is Map ? json['data']['account'] : null) ?? {};
    final salariesRaw = json['salaries'] ?? (json['data'] is Map ? json['data']['salaries'] : (json['data'] is List ? json['data'] : [])) ?? [];
    
    final List<SalaryRecord> salariesList = [];
    if (salariesRaw is List) {
      for (var item in salariesRaw) {
        if (item is Map<String, dynamic>) {
          salariesList.add(SalaryRecord.fromJson(item));
        }
      }
    }

    return SalaryPageData(
      account: BankAccount.fromJson(accountJson is Map<String, dynamic> ? accountJson : {}),
      salaries: salariesList,
    );
  }
}

class BankAccount {
  final String accountHolderName;
  final String? accountNumber;
  final String? ifscCode;
  final String? bankName;
  final String? branch;
  final String? basicSalary;

  BankAccount({
    required this.accountHolderName,
    this.accountNumber,
    this.ifscCode,
    this.bankName,
    this.branch,
    this.basicSalary,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      accountHolderName: json['name']?.toString() ?? 'N/A',
      accountNumber: json['bank_account_number']?.toString(),
      ifscCode: json['ifsc_code']?.toString(),
      bankName: json['bank_name']?.toString(),
      branch: json['branch_name']?.toString(),
      basicSalary: (json['basic_salary'] ?? json['salary'])?.toString(),
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
      baseSalary: (json['basic_salary'] ?? json['salary'] ?? '0').toString(),
      deduction: json['deductions']?.toString() ?? '0', 
      netSalary: (json['net_salary'] ?? json['amount'] ?? '0').toString(),
      status: json['status'] ?? 'Paid',
    );
  }
}
