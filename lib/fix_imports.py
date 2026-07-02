import os
import re

# Map of basenames to their new absolute paths
file_locations = {}

lib_dir = os.path.abspath('lib')

# Build the map of current file locations
for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            abs_path = os.path.join(root, file)
            basename = file
            file_locations[basename] = abs_path

import_pattern = re.compile(r"""import\s+['"](.*?)['"]\s*;""")

# Walk all files again to fix imports
for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            current_abs_path = os.path.join(root, file)
            current_dir = os.path.dirname(current_abs_path)
            
            with open(current_abs_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            new_content = content
            matches = import_pattern.finditer(content)
            
            changed = False
            for match in matches:
                imported_path = match.group(1)
                
                # Skip package imports
                if imported_path.startswith('package:'):
                    continue
                    
                # Resolve the imported path
                # imported_path is relative to current_dir
                resolved_abs_path = os.path.normpath(os.path.join(current_dir, imported_path))
                
                # Check if it exists
                if not os.path.exists(resolved_abs_path):
                    # It doesn't exist, it was probably moved!
                    basename = os.path.basename(resolved_abs_path)
                    
                    if basename in file_locations:
                        new_abs_path = file_locations[basename]
                        # Compute new relative path
                        new_rel_path = os.path.relpath(new_abs_path, current_dir)
                        
                        # Replace in content
                        old_import = match.group(0)
                        # Fix windows backslashes to forward slashes
                        new_rel_path = new_rel_path.replace('\\', '/')
                        
                        # If the relative path doesn't start with '.' or '..', we might need to prefix it with './' 
                        # but dart prefers just 'filename.dart' instead of './filename.dart' if it's in the same dir.
                        # Wait, os.path.relpath returns 'filename.dart' if in same dir, which is correct for dart.
                        
                        new_import = f"import '{new_rel_path}';"
                        new_content = new_content.replace(old_import, new_import)
                        changed = True

            if changed:
                with open(current_abs_path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f"Updated imports in {current_abs_path}")

print("Done fixing imports.")
