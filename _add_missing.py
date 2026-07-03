import subprocess, re, os

# Get analyze output
result = subprocess.run(
    ['flutter', 'analyze', 'lib/'],
    cwd=r'D:/Claude Workspace/Projects/00. Test Project/apps/mobile',
    capture_output=True, text=True, timeout=60
)

# Extract missing key names
missing = set()
for line in result.stdout.split('\n'):
    m = re.search(r"AppLocalizations\.(\w+)'", line)
    if m:
        missing.add(m.group(1))
    m = re.search(r"AppLocalizations\.(\w+)\(", line)
    if m:
        missing.add(m.group(1))

print(f'Missing keys: {len(missing)}')
for k in sorted(missing):
    print(f'  {k}')

# Add to abstract class
base = r'D:/Claude Workspace/Projects/00. Test Project/apps/mobile/lib/l10n'
abs_path = os.path.join(base, 'app_localizations.dart')
with open(abs_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add before the closing } of the abstract class
marker = 'String get weightCategoryLabel;\n}'
getter_lines = [f'  String get {k};' for k in sorted(missing)]
content = content.replace(marker, 'String get weightCategoryLabel;\n' + '\n'.join(getter_lines) + '\n}')
with open(abs_path, 'w', encoding='utf-8') as f:
    f.write(content)
print('Added to abstract class')
