import 'package:flutter/material.dart';

class EditFinePage extends StatefulWidget{
  const EditFinePage({super.key});

  @override
  State<StatefulWidget> createState() => _EditFinePageState();
}

class _EditFinePageState extends State<EditFinePage>{
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Edit Fine"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: theme.primaryColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16,),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Reason",style: TextStyle(fontSize: 16,color: theme.colorScheme.onPrimary),),
                        const SizedBox(height: 8,),
                        TextField(
                          decoration: InputDecoration(
                            hintText: "e.g., Late Fee Payment",
                            hintStyle: TextStyle(color: Colors.grey.shade700),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16,),
                        Text("Amount",style: TextStyle(fontSize: 16,color: theme.colorScheme.onPrimary),),
                        const SizedBox(height: 8,),
                        TextField(
                          decoration: InputDecoration(
                            hintText: "200",
                            hintStyle: TextStyle(color: Colors.grey.shade700),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16,),
                        Text("Remarks",style: TextStyle(fontSize: 16,color: theme.colorScheme.onPrimary),),
                        const SizedBox(height: 8,),
                        TextField(
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Add any additional remarks",
                            hintStyle: TextStyle(color: Colors.grey.shade700),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16,16,16,55),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(onPressed: (){
                    Navigator.pop(context);
                  },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withAlpha(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Cancel",style: TextStyle(color: Colors.red,fontSize: 16),)),
                ),
              ),
              const SizedBox(width: 16,),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(onPressed: (){},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.withAlpha(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Update Fine",style: TextStyle(color: Colors.blue,fontSize: 16),)),
                ),
              ),
            ],
          ),
        ),
    );
  }


}