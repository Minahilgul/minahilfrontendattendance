import os
import re

formatter_import = "import 'package:attendence_verification/core/utils/date_formatter.dart';"

def add_import(content):
    if 'date_formatter.dart' not in content:
        lines = content.split('\n')
        for i, line in enumerate(lines):
            if line.startswith('import '):
                lines.insert(i, formatter_import)
                return '\n'.join(lines)
    return content

# 1. teacher_directory_screen.dart
path = '/Users/marsadakbar/colleges/minahilfrontendattendance/lib/screens/teacher_directory_screen.dart'
if os.path.exists(path):
    with open(path, 'r') as f: content = f.read()
    content = add_import(content)
    content = content.replace('Text(teacher.registeredInfo!', 'Text(DateFormatter.format(teacher.registeredInfo!)')
    content = content.replace("'LAST SEEN ${teacher.lastSeen}'", "'LAST SEEN ${DateFormatter.format(teacher.lastSeen)}'")
    with open(path, 'w') as f: f.write(content)
    print(f'Updated {path}')

# 2. student/student_dashboard_screen.dart
path = '/Users/marsadakbar/colleges/minahilfrontendattendance/lib/screens/student/student_dashboard_screen.dart'
if os.path.exists(path):
    with open(path, 'r') as f: content = f.read()
    content = add_import(content)
    content = content.replace('Text(n.createdAt,', 'Text(DateFormatter.format(n.createdAt),')
    with open(path, 'w') as f: f.write(content)
    print(f'Updated {path}')

# 3. teacher/session_report_screen.dart
path = '/Users/marsadakbar/colleges/minahilfrontendattendance/lib/screens/teacher/session_report_screen.dart'
if os.path.exists(path):
    with open(path, 'r') as f: content = f.read()
    content = add_import(content)
    content = content.replace("Text(log['time'] ?? '',", "Text(DateFormatter.format(log['time']),")
    content = content.replace("Text(s['date'] ?? '-',", "Text(DateFormatter.formatShort(s['date']),")
    with open(path, 'w') as f: f.write(content)
    print(f'Updated {path}')

# 4. attendance_report_screen.dart
path = '/Users/marsadakbar/colleges/minahilfrontendattendance/lib/screens/attendance_report_screen.dart'
if os.path.exists(path):
    with open(path, 'r') as f: content = f.read()
    content = add_import(content)
    content = content.replace("Text(s['date'] ?? '-',", "Text(DateFormatter.formatShort(s['date']),")
    with open(path, 'w') as f: f.write(content)
    print(f'Updated {path}')

# 5. admin/admin_report_screen.dart
path = '/Users/marsadakbar/colleges/minahilfrontendattendance/lib/screens/admin/admin_report_screen.dart'
if os.path.exists(path):
    with open(path, 'r') as f: content = f.read()
    content = add_import(content)
    content = content.replace("Text(s['date'] ?? '',", "Text(DateFormatter.formatShort(s['date']),")
    with open(path, 'w') as f: f.write(content)
    print(f'Updated {path}')
