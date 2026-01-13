import 'package:flutter/material.dart';

class AddReviewsPage extends StatefulWidget{
  const AddReviewsPage({super.key});

  @override
  State<AddReviewsPage> createState() => _AddReviewsPageState();
}

class _AddReviewsPageState extends State<AddReviewsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
    appBar: AppBar(
      title: Text("Add Reviews",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
    ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                    children:[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset("assets/images/girl_image.webp",width: 100,height: 100,fit: BoxFit.cover)
                      ),
                      Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(Icons.camera_alt_rounded,color: theme.colorScheme.onPrimary,size: 20,)),
                ],
                ),
              ),
              const SizedBox(height: 30,),
              Text("Full Name",style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person),
                  hintText: "Amelia Johnson",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              Text("Designation",style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.connect_without_contact),
                  hintText: "Parent, Grade 10",
                      border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              Text("Message",style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              TextField(
                maxLines: 5,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 90,left: 10),
                  child: Icon(Icons.message,size: 30,),
                ),
                hintText: "Enter review message here...",
                    border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
              )
              ),
              ),
              const SizedBox(height: 20,),
              SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(onPressed: (){}, child: const Text("Send Reviews",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)))),

            ],
          ),
        ),
      ),
    );
  }
}
