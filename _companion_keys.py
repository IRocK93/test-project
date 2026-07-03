import json, os
base = r'D:/Claude Workspace/Projects/00. Test Project/apps/mobile/lib/l10n'

keys_en = {
    'unlockAiCompanion': 'Create your first BabyMon to unlock the AI Companion — personalised routines, milestones, and parenting guidance.',
    'emergencyResponseFull': '**MEDICAL EMERGENCY**\n\nBased on what you\'ve described, this may be a medical emergency.\n\n**Please stop using this app immediately and call 911 (or your local emergency number) right now.**\n\nIf you are outside the US, here are emergency numbers:\n• UK: 999\n• EU: 112\n• Australia: 000\n• India: 112\n• Japan: 119\n• UAE: 998\n\n**The AI Companion is NOT a substitute for emergency medical services. It cannot diagnose or treat medical emergencies.**',
    'yourBabyLower': 'your baby',
    'chatEmptySubtitle': 'I\'m powered by an on-device AI that runs entirely on your phone. Your questions and your child\'s data never leave your device.',
    'safetyWarningPrefix': '\n\n⚠️ ',
}

trans = {
    'pt': {
        'unlockAiCompanion': 'Crie o seu primeiro BabyMon para desbloquear o Assistente IA — rotinas personalizadas, marcos e orientação parental.',
        'emergencyResponseFull': '**EMERGÊNCIA MÉDICA**\n\nCom base no que descreveu, isto pode ser uma emergência médica.\n\n**Por favor, pare de usar esta aplicação imediatamente e ligue para o 112 (ou o seu número de emergência local) agora mesmo.**\n\nSe estiver fora da UE, aqui estão números de emergência:\n• Reino Unido: 999\n• EUA: 911\n• Austrália: 000\n• Índia: 112\n• Japão: 119\n• EAU: 998\n\n**O Assistente IA NÃO substitui os serviços médicos de emergência. Não pode diagnosticar ou tratar emergências médicas.**',
        'yourBabyLower': 'o seu bebé',
        'chatEmptySubtitle': 'Sou alimentado por uma IA no dispositivo que funciona inteiramente no seu telefone. As suas perguntas e os dados do seu filho nunca saem do seu dispositivo.',
        'safetyWarningPrefix': '\n\n⚠️ ',
    },
    'es': {
        'unlockAiCompanion': 'Crea tu primer BabyMon para desbloquear el Asistente IA — rutinas personalizadas, hitos y orientación parental.',
        'emergencyResponseFull': '**EMERGENCIA MÉDICA**\n\nSegún lo que has descrito, esto puede ser una emergencia médica.\n\n**Por favor, deja de usar esta aplicación inmediatamente y llama al 112 (o tu número de emergencia local) ahora mismo.**\n\nSi estás fuera de la UE, aquí tienes números de emergencia:\n• Reino Unido: 999\n• EE.UU.: 911\n• Australia: 000\n• India: 112\n• Japón: 119\n• EAU: 998\n\n**El Asistente IA NO sustituye a los servicios médicos de emergencia. No puede diagnosticar ni tratar emergencias médicas.**',
        'yourBabyLower': 'tu bebé',
        'chatEmptySubtitle': 'Funciono con una IA en el dispositivo que se ejecuta completamente en tu teléfono. Tus preguntas y los datos de tu hijo nunca salen de tu dispositivo.',
        'safetyWarningPrefix': '\n\n⚠️ ',
    },
    'fr': {
        'unlockAiCompanion': 'Créez votre premier BabyMon pour débloquer l\'Assistant IA — routines personnalisées, étapes et conseils parentaux.',
        'emergencyResponseFull': '**URGENCE MÉDICALE**\n\nD\'après ce que vous avez décrit, il pourrait s\'agir d\'une urgence médicale.\n\n**Veuillez cesser immédiatement d\'utiliser cette application et appeler le 112 (ou votre numéro d\'urgence local) maintenant.**\n\nSi vous êtes hors de l\'UE, voici les numéros d\'urgence :\n• Royaume-Uni : 999\n• États-Unis : 911\n• Australie : 000\n• Inde : 112\n• Japon : 119\n• EAU : 998\n\n**L\'Assistant IA NE remplace PAS les services médicaux d\'urgence. Il ne peut pas diagnostiquer ni traiter les urgences médicales.**',
        'yourBabyLower': 'votre bébé',
        'chatEmptySubtitle': 'Je suis alimenté par une IA sur l\'appareil qui fonctionne entièrement sur votre téléphone. Vos questions et les données de votre enfant ne quittent jamais votre appareil.',
        'safetyWarningPrefix': '\n\n⚠️ ',
    },
    'de': {
        'unlockAiCompanion': 'Erstellen Sie Ihr erstes BabyMon, um den KI-Begleiter freizuschalten — personalisierte Routinen, Meilensteine und Elternberatung.',
        'emergencyResponseFull': '**MEDIZINISCHER NOTFALL**\n\nBasierend auf Ihrer Beschreibung könnte dies ein medizinischer Notfall sein.\n\n**Bitte beenden Sie die Nutzung dieser App sofort und rufen Sie 112 (oder Ihre lokale Notrufnummer) an.**\n\nWenn Sie außerhalb der EU sind, hier Notrufnummern:\n• Großbritannien: 999\n• USA: 911\n• Australien: 000\n• Indien: 112\n• Japan: 119\n• VAE: 998\n\n**Der KI-Begleiter ist KEIN Ersatz für medizinische Notdienste. Er kann keine medizinischen Notfälle diagnostizieren oder behandeln.**',
        'yourBabyLower': 'Ihr Baby',
        'chatEmptySubtitle': 'Ich werde von einer On-Device-KI betrieben, die vollständig auf Ihrem Telefon läuft. Ihre Fragen und die Daten Ihres Kindes verlassen niemals Ihr Gerät.',
        'safetyWarningPrefix': '\n\n⚠️ ',
    },
    'ar': {
        'unlockAiCompanion': 'أنشئ أول BabyMon لفتح المساعد الذكي — روتينات مخصصة ومعالم وإرشادات للتربية.',
        'emergencyResponseFull': '**حالة طبية طارئة**\n\nبناءً على ما وصفتَه، قد تكون هذه حالة طبية طارئة.\n\n**يرجى التوقف عن استخدام هذا التطبيق فوراً والاتصال برقم الطوارئ المحلي (911 في الولايات المتحدة، 997 في الإمارات، 112 في أوروبا) الآن.**\n\nإذا كنت خارج الولايات المتحدة، إليك أرقام الطوارئ:\n• المملكة المتحدة: 999\n• الاتحاد الأوروبي: 112\n• أستراليا: 000\n• الهند: 112\n• اليابان: 119\n• الإمارات: 998\n\n**المساعد الذكي ليس بديلاً عن خدمات الطوارئ الطبية. لا يمكنه تشخيص أو علاج الحالات الطبية الطارئة.**',
        'yourBabyLower': 'طفلك',
        'chatEmptySubtitle': 'أنا مدعوم بذكاء اصطناعي على الجهاز يعمل بالكامل على هاتفك. أسئلتك وبيانات طفلك لا تغادر جهازك أبداً.',
        'safetyWarningPrefix': '\n\n⚠️ ',
    },
    'he': {
        'unlockAiCompanion': 'צור את ה-BabyMon הראשון שלך כדי לפתוח את המלווה החכם — שגרות מותאמות אישית, אבני דרך והדרכת הורים.',
        'emergencyResponseFull': '**מצב חירום רפואי**\n\nבהתבסס על מה שתיארת, זה עלול להיות מצב חירום רפואי.\n\n**אנא הפסק להשתמש באפליקציה זו מיד והתקשר ל-101 (או למספר החירום המקומי שלך) עכשיו.**\n\nאם אתה מחוץ לישראל, הנה מספרי חירום:\n• ארה"ב: 911\n• בריטניה: 999\n• האיחוד האירופי: 112\n• אוסטרליה: 000\n• יפן: 119\n\n**המלווה החכם אינו תחליף לשירותי חירום רפואיים. הוא אינו יכול לאבחן או לטפל במצבי חירום רפואיים.**',
        'yourBabyLower': 'התינוק שלך',
        'chatEmptySubtitle': 'אני מופעל על ידי בינה מלאכותית על המכשיר שפועלת במלואה בטלפון שלך. השאלות שלך ונתוני הילד שלך לעולם לא עוזבים את המכשיר שלך.',
        'safetyWarningPrefix': '\n\n⚠️ ',
    },
}

# Add to ARBs
for lang, entries in trans.items():
    path = os.path.join(base, f'app_{lang}.arb')
    with open(path, 'r', encoding='utf-8') as f: c = f.read()
    l = c.rfind('}')
    lines = [f'  "{k}": "{v}"' for k, v in entries.items()]
    c = c[:l] + ',\n' + ',\n'.join(lines) + '\n}'
    with open(path, 'w', encoding='utf-8') as f: f.write(c)

# Add to English ARB
with open(os.path.join(base, 'app_en.arb'), 'r', encoding='utf-8') as f: c = f.read()
l = c.rfind('}')
lines = [f'  "{k}": "{v}"' for k, v in keys_en.items()]
c = c[:l] + ',\n' + ',\n'.join(lines) + '\n}'
with open(os.path.join(base, 'app_en.arb'), 'w', encoding='utf-8') as f: f.write(c)

# Add abstract getters
abs_path = os.path.join(base, 'app_localizations.dart')
with open(abs_path, 'r', encoding='utf-8') as f: c = f.read()
marker = 'String get noTimeFallback;\n}'
getters = '\n'.join([f'  String get {k};' for k in keys_en])
c = c.replace(marker, 'String get noTimeFallback;\n' + getters + '\n}')
with open(abs_path, 'w', encoding='utf-8') as f: f.write(c)

# Update generated impl files
for lang_code in ['en'] + list(trans.keys()):
    ipath = os.path.join(base, f'app_localizations_{lang_code}.dart')
    apath = os.path.join(base, f'app_{lang_code}.arb')
    with open(ipath, 'r', encoding='utf-8') as f: ic = f.read()
    with open(apath, 'r', encoding='utf-8') as f: ad = json.load(f)
    il = ic.rfind('}')
    impl_lines = []
    for k in keys_en:
        v = ad.get(k)
        if not v: continue
        esc = v.replace('\\', '\\\\').replace("'", "\\'")
        impl_lines.append(f'  @override\n  String get {k} => \'{esc}\';')
    ic = ic[:il] + '\n' + '\n'.join(impl_lines) + '\n}'
    with open(ipath, 'w', encoding='utf-8') as f: f.write(ic)
print('All keys added')
