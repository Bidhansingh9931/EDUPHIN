import 'package:flutter/material.dart';

class MySalaryPage extends StatefulWidget{
  const MySalaryPage({super.key});

  @override
  State<MySalaryPage> createState() => _MySalaryPageState();
}

class _MySalaryPageState extends State<MySalaryPage> {
  @override
  Widget build(BuildContext context) {
    final data = {
      "bank_account": "111122223333",
      "ifsc": "UN11100010",
      "bank_name": "Unity Bank",
      "employer_branch": "Unity Branch - Sector 2",
      "zone": "Sector 2",
    };
    return Scaffold(
      appBar: AppBar(
        title: Text("Salary and Bank Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SectionCard(
                title: "Banking Information",
                icon: Icons.account_balance,
                children: [
                  CustomTextField(label: "Bank Account Number", controller: TextEditingController(text: data['bank_account']!), editable: true),
                  CustomTextField(label: "IFSC Code", controller: TextEditingController(text: data['ifsc']!), editable: true),
                  CustomTextField(label: "Bank Name", controller: TextEditingController(text: data['bank_name']!), editable: true),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24),
                  CustomTextField(label: "Employer Branch", controller: TextEditingController(text: data['employer_branch']!), editable: true),
                  CustomTextField(label: "Zone / Sector", controller: TextEditingController(text: data['zone']!), editable: true),
                ],
              ),
              const SizedBox(height: 16),
              SectionCard(title: "Past Salary Record", icon: Icons.access_time_sharp, children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("May 2024",style: TextStyle(fontSize: 16,color: Colors.white),),
                        Row(
                          children: [
                            Icon(Icons.currency_rupee,size: 20,color: Colors.green,),
                            Text("75,000",style: TextStyle(fontSize: 16,color: Colors.green),),
                  ]
                        )
                      ],
                    ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("paid on 31 May 2024",style: TextStyle(fontSize: 14,color: Colors.grey),),
                          Text("View Details",style: TextStyle(fontSize: 14,color: Colors.lightBlue),)
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("April 2024",style: TextStyle(fontSize: 16,color: Colors.white),),
                          Row(
                              children: [
                                Icon(Icons.currency_rupee,size: 20,color: Colors.green,),
                                Text("75,000",style: TextStyle(fontSize: 16,color: Colors.green),),
                              ]
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("paid on 30 April 2024",style: TextStyle(fontSize: 14,color: Colors.grey),),
                          Text("View Details",style: TextStyle(fontSize: 14,color: Colors.lightBlue),)
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("March 2024",style: TextStyle(fontSize: 16,color: Colors.white),),
                          Row(
                              children: [
                                Icon(Icons.currency_rupee,size: 20,color: Colors.green,),
                                Text("75,000",style: TextStyle(fontSize: 16,color: Colors.green),),
                              ]
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("paid on 31 Mar 2024",style: TextStyle(fontSize: 14,color: Colors.grey),),
                          Text("View Details",style: TextStyle(fontSize: 14,color: Colors.lightBlue),)
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("February 2024",style: TextStyle(fontSize: 16,color: Colors.white),),
                          Row(
                              children: [
                                Icon(Icons.currency_rupee,size: 20,color: Colors.green,),
                                Text("75,000",style: TextStyle(fontSize: 16,color: Colors.green),),
                              ]
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("paid on 29 Feb 2024",style: TextStyle(fontSize: 14,color: Colors.grey),),
                          Text("View Details",style: TextStyle(fontSize: 14,color: Colors.lightBlue),)
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const SectionCard({super.key, required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool editable;
  final IconData? icon;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.editable = true,
    this.icon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: editable ? const Color(0xFF0D1B2A) : Colors.white10,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            enabled: editable,
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: icon != null ? Icon(icon, color: Colors.white54) : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}