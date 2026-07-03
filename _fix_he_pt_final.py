import os, json
base = r'D:/Claude Workspace/Projects/00. Test Project/apps/mobile/lib/l10n'
for lang in ['he','pt']:
    path = os.path.join(base, f'app_{lang}.arb')
    with open(path, 'r', encoding='utf-8') as f: c = f.read()
    # Fix chatEmptySubtitle literal newlines
    marker = '"chatEmptySubtitle": "'
    idx = c.find(marker)
    if idx > 0:
        start = idx + len(marker)
        end = c.find('"', start + 1)
        while end > 0 and c[end-1] == '\\':
            end = c.find('"', end + 1)
        val = c[start:end]
        fixed_val = val.replace('\n', '\\n')
        c = c[:start] + fixed_val + c[end:]
    with open(path, 'w', encoding='utf-8') as f: f.write(c)
    print(f'Fixed {lang}')

keys = ['unlockAiCompanion','emergencyResponseFull','yourBabyLower','chatEmptySubtitle','safetyWarningPrefix']
for lang in ['he','pt']:
    ipath = os.path.join(base, f'app_localizations_{lang}.dart')
    apath = os.path.join(base, f'app_{lang}.arb')
    with open(ipath, 'r', encoding='utf-8') as f: ic = f.read()
    with open(apath, 'r', encoding='utf-8') as f: ad = json.load(f)
    il = ic.rfind('}')
    impl_lines = []
    for k in keys:
        v = ad.get(k)
        if not v: continue
        esc = v.replace('\\', '\\\\').replace("'", "\\'")
        impl_lines.append(f'  @override\n  String get {k} => \'{esc}\';')
    ic = ic[:il] + '\n' + '\n'.join(impl_lines) + '\n}'
    with open(ipath, 'w', encoding='utf-8') as f: f.write(ic)
    print(f'Generated {lang}')
print('Done')
