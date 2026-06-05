import 'package:flutter/material.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _launchURL('https://eduphin.com/privacy-policy'),
            tooltip: 'Open Full Policy',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.responsive(16.0, tablet: 24.0, desktop: 32.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(theme, 'Official Policy'),
            _buildSectionBody(theme, 
              'This is a summary of our Privacy Policy. For the full legal document, please visit our website:'),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _launchURL('https://eduphin.com/privacy-policy'),
              child: Text(
                'https://eduphin.com/privacy-policy',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 32),

            _buildSectionTitle(theme, '1. Information We Collect'),
            _buildSubHeader(theme, 'a. Personal Information'),
            _buildBulletPoint(theme, 'Names: Student, parent, teacher, and staff names for records.'),
            _buildBulletPoint(theme, 'Contact Details: Email, phone numbers, and home addresses help in communication.'),
            _buildBulletPoint(theme, 'Date of Birth, Gender, IDs: Used for identification, age verification, and academic classification.'),
            _buildBulletPoint(theme, 'Relationships: Links between students and parents/guardians for communication and academic oversight.'),
            _buildBulletPoint(theme, 'Employment Records: Information on staff (qualifications, experience, etc.) used for HR and payroll.'),
            
            _buildSubHeader(theme, 'b. Academic & Administrative Information'),
            _buildBulletPoint(theme, 'Admission Details: For enrollment, class allocation, and official records.'),
            _buildBulletPoint(theme, 'Attendance: Daily student and staff attendance for tracking and reports.'),
            _buildBulletPoint(theme, 'Grades & Reports: For exams, assessments, report cards, etc.'),
            _buildBulletPoint(theme, 'Fee Records: For generating bills, tracking payments, and sending reminders.'),
            _buildBulletPoint(theme, 'Disciplinary Records: Tracks behavior and school rule violations.'),

            _buildSubHeader(theme, 'c. Usage Data'),
            _buildBulletPoint(theme, 'Login Logs: Who logged in, from where, and when.'),
            _buildBulletPoint(theme, 'Device Information: Type of device/browser to improve compatibility.'),
            _buildBulletPoint(theme, 'Activity Logs: Tracks what users do inside the system for security and analytics.'),

            _buildSectionTitle(theme, '2. How We Use the Information'),
            _buildBulletPoint(theme, 'Manage Admin and Academic Tasks: Timetables, class assignments, HR, etc.'),
            _buildBulletPoint(theme, 'Facilitate Communication: Messaging, notifications, circulars between schools and parents/students.'),
            _buildBulletPoint(theme, 'Generate Reports: For performance, attendance, fees, etc.'),
            _buildBulletPoint(theme, 'Improve ERP System: Usage patterns help improve features and usability.'),
            _buildBulletPoint(theme, 'Legal Compliance: Ensures alignment with education laws.'),

            _buildSectionTitle(theme, '3. Data Sharing and Disclosure'),
            _buildBulletPoint(theme, 'With School Staff: To perform duties (like a teacher viewing grades).'),
            _buildBulletPoint(theme, 'With Trusted Third Parties: Like payment gateways or SMS providers, under confidentiality.'),
            _buildBulletPoint(theme, 'Legal Requests: If demanded by law enforcement or courts.'),
            _buildBulletPoint(theme, 'Business Changes: If Eduphin is merged or sold, data may be transferred (you\'ll be notified).'),

            _buildSectionTitle(theme, '4. Data Security'),
            _buildBulletPoint(theme, 'Encryption: Protects data while being stored (at rest) and transferred (in transit).'),
            _buildBulletPoint(theme, 'Role-Based Access: Only authorized users can access certain data.'),
            _buildBulletPoint(theme, 'Security Audits: Regular checks for vulnerabilities.'),
            _buildBulletPoint(theme, 'Secure Hosting: Hosting providers are carefully chosen for compliance and safety.'),

            _buildSectionTitle(theme, '5. Data Retention'),
            _buildBulletPoint(theme, 'We only keep data for as long as needed—for academics, law, or user service.'),
            _buildBulletPoint(theme, 'After its purpose is fulfilled or on request, data is deleted securely.'),

            _buildSectionTitle(theme, '6. User Rights'),
            _buildBulletPoint(theme, 'Access: Ask to see what data is stored about you.'),
            _buildBulletPoint(theme, 'Correction: Fix any mistakes in your data.'),
            _buildBulletPoint(theme, 'Deletion: Ask to delete data (unless legally required to retain it).'),
            _buildBulletPoint(theme, 'Withdraw Consent: You can withdraw permission where applicable.'),

            _buildSectionTitle(theme, '7. Cookies and Tracking'),
            _buildBulletPoint(theme, 'Help track login sessions, preferences, and usage patterns.'),
            _buildBulletPoint(theme, 'Improve speed, security, and user experience.'),
            _buildBulletPoint(theme, 'You can disable them in your browser, but some features may not work well.'),

            _buildSectionTitle(theme, '8. Children’s Privacy'),
            _buildBulletPoint(theme, 'Eduphin respects and protects children\'s data.'),
            _buildBulletPoint(theme, 'Data of students under 18 is only managed under school supervision and with parental/legal guardian awareness.'),
            _buildBulletPoint(theme, 'We never knowingly collect more than necessary.'),

            _buildSectionTitle(theme, '9. Changes to Privacy Policy'),
            _buildBulletPoint(theme, 'If we update the policy (for legal or business reasons), we\'ll inform you.'),
            _buildBulletPoint(theme, 'Notice may be given through email, system notifications, or on our website.'),

            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _launchURL('https://eduphin.com/privacy-policy'),
                icon: const Icon(Icons.language),
                label: const Text('Read Full Policy on Website'),
              ),
            ),
            
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Last Updated: May 2024',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSubHeader(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
      child: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildSectionBody(ThemeData theme, String body) {
    return Text(
      body,
      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildBulletPoint(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5))),
        ],
      ),
    );
  }
}
