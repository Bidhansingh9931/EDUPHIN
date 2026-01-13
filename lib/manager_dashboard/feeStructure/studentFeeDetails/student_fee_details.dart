import 'package:flutter/material.dart';

import 'fee_details.dart';

class StudentFeeDetailsPage extends StatefulWidget{
  const StudentFeeDetailsPage({super.key});

  @override
  State<StatefulWidget> createState() => _StudentFeeDetailsPageState();
}

class _StudentFeeDetailsPageState extends State<StudentFeeDetailsPage>{
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var selectClass = "Class 1";
    var selectSection = "Section A";
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Fee Details"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16,16,16,100),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Class",
                          style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onPrimary),
                        ),
                        const SizedBox(height: 8),
                        DropDownBox(
                          key: ValueKey(selectClass),
                          initialValue: selectClass,
                          items: const [
                            "Class 1",
                            "Class 2",
                            "Class 3",
                            "Class 4",
                            "Class 5",
                            "Class 6",
                            "Class 7",
                            "Class 8",
                            "Class 9",
                            "Class 10",
                            "Class 11",
                            "Class 12"
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectClass = value;
                              });
                            }
                          },
                          hintText: "--Select Subject",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Section",
                          style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onPrimary),
                        ),
                        const SizedBox(height: 8),
                        DropDownBox(
                          key: ValueKey(selectSection),
                          initialValue: selectSection,
                          items: const [
                            "Section A",
                            "Section B",
                            "Section C",
                            "Section D",
                            "Section E",
                            "Section F"

                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectSection = value;
                              });
                            }
                          },
                          hintText: "--Select Section",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16,),
              CustomStudentInfoFeeDetailContainerBox(
                heading: "Ananya Sharma",
                subHeading: "Reg. No: S-1024, Class: 10-A",
                isActive: "Active",
              ),
              SizedBox(height: 16,),
              CustomStudentInfoFeeDetailContainerBox(
                heading: "Rohan Verma",
                subHeading: "Reg. No: S-1025, Class: 10-A",
                isActive: "Active",
              ),
              SizedBox(height: 16,),
              CustomStudentInfoFeeDetailContainerBox(
                heading: "Priya Singh",
                subHeading: "Reg. No: S-1026, Class: 10-A",
                isActive: "Inactive",
              ),

              SizedBox(height: 16,),
            ],
          ),
        ),
      ),
    );
  }


}

class DropDownBox extends StatelessWidget {
  final String initialValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? hintText;

  const DropDownBox({
    super.key,
    required this.initialValue,
    required this.items,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
        initialValue: initialValue,
        isExpanded: true,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ));
  }
}

class CustomStudentInfoFeeDetailContainerBox extends StatefulWidget {
  final String heading;
  final String subHeading;
  final String isActive;

  const CustomStudentInfoFeeDetailContainerBox({
    super.key,
    required this.heading,
    required this.subHeading,
    required this.isActive,
  });

  @override
  State<CustomStudentInfoFeeDetailContainerBox> createState() => _CustomStudentInfoFeeDetailContainerBoxState();
}

class _CustomStudentInfoFeeDetailContainerBoxState extends State<CustomStudentInfoFeeDetailContainerBox> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = widget.isActive == "Active";

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                    child: Image(image: AssetImage("assets/images/random_boy.jpg"),height: 50,width: 50,)),
                SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.heading,
                          style:
                          TextStyle(color: theme.colorScheme.onPrimary, fontSize: 20)),
                      Text(widget.subHeading,
                          style:
                          TextStyle(color: theme.colorScheme.onPrimary.withAlpha(150), fontSize: 14)),
                    ],
                  ),
                ),
                Container(
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green.withAlpha(700)
                          : Colors.blue.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        widget.isActive,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ))
              ],
            ),
            SizedBox(height: 8,),
            SizedBox(
              width: double.infinity,
              height: 30,
              child: ElevatedButton(onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeeDetailsPage()),
                );
              },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text("Fee Details",style: TextStyle(color: Colors.white,fontSize: 16),)),
            ),
          ],
        ),
      ),
    );
  }
}