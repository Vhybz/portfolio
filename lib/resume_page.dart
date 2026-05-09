import 'package:flutter/material.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFESSIONAL RESUME', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.8, -0.8),
            radius: 1.5,
            colors: isDark 
              ? [const Color(0xFF150202), const Color(0xFF050505)]
              : [const Color(0xFFFEF2F2), const Color(0xFFF9FAFB)],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(width * 0.08, 120, width * 0.08, 60),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              padding: const EdgeInsets.all(50),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Theme.of(context).dividerColor.withAlpha(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const Divider(height: 60),
                  _buildSection(context, 'SUMMARY', 'Visionary Founder and CEO of Tech Raven with over 5 years of experience in architecting high-performance digital ecosystems. Expert in Flutter and Full Stack development, dedicated to transforming complex ideas into industry-leading applications.'),
                  const SizedBox(height: 40),
                  _buildWorkExperience(context),
                  const SizedBox(height: 40),
                  _buildEducation(context),
                  const SizedBox(height: 40),
                  _buildSkills(context),
                  const SizedBox(height: 40),
                  _buildCertifications(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('KYEREMEH CLIFFORD', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1, height: 1)),
              const SizedBox(height: 10),
              const Text('Founder & CEO of Tech Raven | Full Stack Architect', style: TextStyle(fontSize: 18, color: Color(0xFFE50914), fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 20,
                runSpacing: 10,
                children: [
                  _contactInfo(Icons.email, 'techraven11@gmail.com'),
                  _contactInfo(Icons.phone, '+233 559 650 921'),
                  _contactInfo(Icons.location_on, 'Sunyani, Ghana'),
                  _contactInfo(Icons.language, 'www.techraven.com'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _contactInfo(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(fontSize: 14, color: Colors.grey)),
    ],
  );

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(title),
        const SizedBox(height: 15),
        Text(content, style: TextStyle(fontSize: 16, height: 1.6, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(200))),
      ],
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2, color: Color(0xFFE50914)),
  );

  Widget _buildWorkExperience(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('WORK EXPERIENCE'),
        const SizedBox(height: 25),
        _experienceItem(
          context,
          'Founder & CEO',
          'Tech Raven',
          '2022 - Present',
          'Leading the strategic vision and technical roadmap for a high-growth technology agency. Architecting enterprise-level mobile and web applications for global clients.',
        ),
        const SizedBox(height: 30),
        _experienceItem(
          context,
          'Senior Full Stack Developer',
          'Global Fintech Solutions',
          '2020 - 2022',
          'Developed secure, scalable payment systems using Flutter and Node.js. Optimized database performance by 40% and led a team of 5 developers.',
        ),
      ],
    );
  }

  Widget _experienceItem(BuildContext context, String role, String company, String date, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(role, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(date, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 5),
        Text(company, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFE50914))),
        const SizedBox(height: 10),
        Text(desc, style: TextStyle(fontSize: 15, height: 1.5, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(180))),
      ],
    );
  }

  Widget _buildEducation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('EDUCATION'),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('BSc in Information Technology', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('2016 - 2020', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        const Text('University of Energy and Natural Resources (UENR)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFE50914))),
      ],
    );
  }

  Widget _buildSkills(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('TECHNICAL SKILLS'),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _skillChip('Flutter'),
            _skillChip('Dart'),
            _skillChip('Supabase'),
            _skillChip('Firebase'),
            _skillChip('Node.js'),
            _skillChip('Clean Architecture'),
            _skillChip('UI/UX Design'),
            _skillChip('Cloud Infrastructure'),
          ],
        ),
      ],
    );
  }

  Widget _skillChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFE50914).withAlpha(15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE50914).withAlpha(30)),
    ),
    child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE50914))),
  );

  Widget _buildCertifications(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('CERTIFICATIONS'),
        const SizedBox(height: 20),
        const Text('• Google Certified Associate Cloud Engineer', style: TextStyle(fontSize: 15, height: 1.8)),
        const Text('• Meta Full-Stack Engineer Specialization', style: TextStyle(fontSize: 15, height: 1.8)),
      ],
    );
  }
}
