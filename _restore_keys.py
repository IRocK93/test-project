import json, os
base = r'D:/Claude Workspace/Projects/00. Test Project/apps/mobile/lib/l10n'
for lang in ['en','ar','de','es','fr','he','pt']:
    ipath = os.path.join(base, f'app_localizations_{lang}.dart')
    apath = os.path.join(base, f'app_{lang}.arb')
    with open(ipath, 'r', encoding='utf-8') as f:
        ic = f.read()
    with open(apath, 'r', encoding='utf-8') as f:
        ad = json.load(f)
    il = ic.rfind('}')
    for k in ['beginYourJourney', 'beginYourStory']:
        v = ad.get(k)
        if not v:
            continue
        esc = v.replace('\\', '\\\\').replace("'", "\\'")
        ic = ic[:il] + f'\n  @override\n  String get {k} => \'{esc}\';' + ic[il:]
    # Dedup
    lines = ic.split('\n')
    seen = set()
    new_lines = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.strip() == '@override' and i + 1 < len(lines):
            import re
            m = re.match(r'  String get (\w+) =>', lines[i + 1])
            if m and m.group(1) in seen:
                i += 2
                continue
            if m:
                seen.add(m.group(1))
        new_lines.append(line)
        i += 1
    with open(ipath, 'w', encoding='utf-8') as f:
        f.write('\n'.join(new_lines))
    print(f'Restored {lang}')
