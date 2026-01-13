import 'package:eduphin/moderator_dashboard/moderator_dashboard.dart';
import 'package:eduphin/moderator_dashboard/dashboard_cards/active_institutes/institutes.dart';
import 'package:flutter/material.dart';

class ViewInstitutePage extends StatelessWidget {
  final Institute institute;

  const ViewInstitutePage({super.key, required this.institute});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                institute.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
                onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ModeratorDashboardPage())),
                child: const Icon(
                  Icons.home_sharp,
                  size: 30,
                )),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: theme.cardColor,
                    ),
                    child: const Icon(
                      Icons.school_outlined,
                      size: 60,
                    )),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(institute.name,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Status: ",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Container(
                      height: 20,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.green,
                      ),
                      child: const Center(
                          child: Text("Active",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white)))),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              UiHelp.customContainer(context, Icons.person_outline_sharp,
                  "Chairman", institute.chairman),
              const SizedBox(
                height: 10,
              ),
              UiHelp.customContainer(
                  context, Icons.book_outlined, "Institute Code", institute.code),
              const SizedBox(
                height: 10,
              ),
              UiHelp.customContainer(context, Icons.location_on_outlined,
                  "Address", institute.address),
              const SizedBox(
                height: 10,
              ),
              UiHelp.customContainer(
                  context, Icons.email_outlined, "Email", institute.email),
              const SizedBox(
                height: 10,
              ),
              UiHelp.customContainer(context, Icons.phone_outlined, "Phone Number",
                  institute.phone),
              const SizedBox(
                height: 10,
              ),
              UiHelp.customContainer(context, Icons.web_outlined, "Website",
                  institute.website),
              const SizedBox(
                height: 10,
              ),
              UiHelp.customContainer(context, Icons.corporate_fare_outlined,
                  "Affiliation", institute.affiliation),
              const SizedBox(height: 10),
              UiHelp.customContainer(
                  context, Icons.credit_card_outlined, "Pan", institute.pan),
            ],
          ),
        ),
      ),
    );
  }
}

class UiHelp {
  static customContainer(
    BuildContext context,
    IconData icon,
    String text,
    String value,
  ) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: theme.primaryColor,
              size: 30,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
