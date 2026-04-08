import 'package:flutter/material.dart';
import 'add_student_screen.dart';
import 'add_teacher_screen.dart'; 
import 'profile_screen.dart' as profile;
import 'view_attendance_screen.dart';


class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  // final List<ScrollController> scrollControllers = [
  //   ScrollController(),
  //   ScrollController(),
  //   ScrollController(),
  //   ScrollController(),
  // ];

  final List<Widget> screens = [
  const AdminDashboardScreen(),
  const AddTeacherScreen(),
  const ViewAttendanceScreen(),
  const profile.ProfileScreen(),
];



  Widget statCard(String title, String value, IconData icon,
      {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xff1f4e79) : Colors.white,
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
              color: isHighlight ? Colors.white24 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: isHighlight ? Colors.white : Colors.blue),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 12,
                      color: isHighlight ? Colors.white70 : Colors.grey,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isHighlight ? Colors.white : Colors.black)),
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

      body: IndexedStack(
        index: _currentIndex,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    CircleAvatar(
          radius: 22,
          backgroundImage: AssetImage('assets/profile.jpg'),
        ),
        const SizedBox(width: 10),
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
  statCard("ATTENDANCE", "94%", Icons.bar_chart, isHighlight: true),

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
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.orange),
  ),
  child: const Row(
    children: [
      Icon(Icons.warning_amber, color: Colors.orange),
      SizedBox(width: 10),
      Expanded(
        child: Text(
            "Unverified Attendance\n5 classes pending teacher verification"),
      ),
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
                      // actionButton(Icons.people, "Students"),
                      // actionButton(Icons.school, "Teachers"),
                      // actionButton(Icons.analytics, "Analytics"),

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
                      subtitle: Text("10:45 AM + ROOM 302"),
                    ),

                    Divider(),

                    ListTile(
                      leading: Icon(Icons.download),
                      title: Text("Monthly Report Generated"),
                      subtitle: Text("09:15 AM + Admin System"),
                    ),

                    Divider(),

                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text("15 students registered for CS204"),
                      subtitle: Text("08:30 AM + Web Portal"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
        
            ),
        ),
        ]
      ),
  
    

bottomNavigationBar: BottomNavigationBar(
  selectedItemColor: Colors.blue,
  unselectedItemColor: Colors.grey,
  type: BottomNavigationBarType.fixed,
    currentIndex: _currentIndex,
  onTap: (index) {
    setState(() {
      _currentIndex = index;
    });
  
  // currentIndex: _currentIndex,
  // onTap: (index) {
  //   setState(() {
  //     _currentIndex = index;
  //   });
    if (index == 0) {
      // Already Dashboard (do nothing)
    } 
    else if (index == 1) {
      // Teachers Screen
      // (
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => const AddTeacherScreen(),
      //   ),
      // );
    } 
    else if (index == 2) {
      //  Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => const ViewAttendanceScreen(),
      //   ),
      // );
      // Attendance Screen (agar hai)
    }
    else if (index == 3) {
      // Profile Screen (temporary)
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => const profile.ProfileScreen(),
      //   ),
      // );
    }
  },
  items: const [

    BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: "Dashboard"),

    BottomNavigationBarItem(
        icon: Icon(Icons.people),
        label: "Teachers"),

    BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart),
        label: "View Attendance"),

    BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: "Profile"),
  ],
),

floatingActionButton: FloatingActionButton(
  onPressed: () => navigateToAddStudent(context),
 
  backgroundColor: const Color(0xff1f4e79),
  child: const Icon(Icons.add, size: 30),
),
floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void navigateToAddStudent(BuildContext context){
    final route = MaterialPageRoute(
      builder: (context) => const AddStudentScreen());
    Navigator.push(context, route);
  }
}


  
