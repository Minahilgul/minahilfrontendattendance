import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Widget statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5)
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blue),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500)),

              const SizedBox(height: 4),

              Text(value,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget actionButton(IconData icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4)
            ],
          ),
          child: Icon(icon, color: Colors.blue),
        ),

        const SizedBox(height: 6),

        Text(text, style: const TextStyle(fontSize: 12))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f8),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [

                      Text("GOOD MORNING",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey)),

                      SizedBox(height: 4),

                      Text("Admin Portal",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold))
                    ],
                  ),

                  Row(
                    children: const [
                      Icon(Icons.search),
                      SizedBox(width: 12),
                      Icon(Icons.notifications),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 20),

              
              LayoutBuilder(
                builder: (context, constraints) {

                  int crossAxisCount = 2;

                  if (constraints.maxWidth > 900) {
                    crossAxisCount = 4;
                  } else if (constraints.maxWidth > 600) {
                    crossAxisCount = 3;
                  }

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [

                      statCard("TEACHERS", "124", Icons.school),
                      statCard("STUDENTS", "3,450", Icons.people),
                      statCard("CLASSES", "42", Icons.class_),
                      statCard("ATTENDANCE", "94%", Icons.bar_chart),

                    ],
                  );
                },
              ),

              const SizedBox(height: 25),

            
              const Text("Critical Alerts",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),

                child: const Row(
                  children: [

                    Icon(Icons.warning, color: Colors.red),

                    SizedBox(width: 10),

                    Expanded(
                      child: Text(
                          "Suspicious GPS Login\n2 sessions detected outside campus"),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              
              const Text("Quick Actions",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),

              const SizedBox(height: 10),

              LayoutBuilder(
                builder: (context, constraints) {

                  int crossAxisCount = 3;

                  if (constraints.maxWidth > 900) {
                    crossAxisCount = 6;
                  } else if (constraints.maxWidth > 600) {
                    crossAxisCount = 4;
                  }

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                    children: [

                      actionButton(Icons.person_add, "Add Staff"),
                      actionButton(Icons.insert_drive_file, "Reports"),
                      actionButton(Icons.map, "Campus Map"),
                      actionButton(Icons.settings, "Settings"),
                      actionButton(Icons.event, "Events"),
                      actionButton(Icons.people, "Students"),
                      actionButton(Icons.school, "Teachers"),
                      actionButton(Icons.analytics, "Analytics"),

                    ],
                  );
                },
              ),

              const SizedBox(height: 25),

              
              const Text("Recent Activity",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),

              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  children: const [

                    ListTile(
                      leading:
                          Icon(Icons.check_circle, color: Colors.green),
                      title: Text("Dr. Miller verified Physics 101"),
                      subtitle: Text("10:45 AM"),
                    ),

                    Divider(),

                    ListTile(
                      leading: Icon(Icons.download),
                      title: Text("Monthly Report Generated"),
                      subtitle: Text("09:15 AM"),
                    ),

                    Divider(),

                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text("15 students registered for CS204"),
                      subtitle: Text("08:30 AM"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [

          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: "Dash"),

          BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: "People"),

          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: "Stats"),

          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings"),
        ],
      ),
    );
  }
}