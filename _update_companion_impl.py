import json, os
base = r'D:/Claude Workspace/Projects/00. Test Project/apps/mobile/lib/l10n'
keys = ['unlockAiCompanion','emergencyResponseFull','yourBabyLower','chatEmptySubtitle','safetyWarningPrefix']
for lang in ['en','ar','de','es','fr','he','pt']:
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
    print(f'Updated {lang}')
print('Done')
