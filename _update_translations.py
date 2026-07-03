import json, re, os

base = r'D:\Claude Workspace\Projects\00. Test Project\apps\mobile\lib\l10n'

translations = {
    'es': {
        'gentleReminder': 'Un Recordatorio Amable',
        'gentleReminderMessage': 'Nos encanta que confíe en BabyMon. Su pequeño merece lo mejor, y usted también. Por eso queremos ser completamente transparentes sobre cómo funciona nuestro Asistente IA.',
        'aiNotDoctorWarning': 'Nuestro Asistente IA funciona en su dispositivo... pero no es un médico. No tiene licencia médica, y nunca la tendrá. Es un compañero útil que puede responder preguntas y proporcionar orientación general sobre crianza.',
        'alwaysCheckPediatrician': 'Consulte siempre con su pediatra antes de tomar decisiones médicas.',
        'callDoctorRightAway': 'Llame a su médico de inmediato si nota algo preocupante en la salud de su bebé.',
        'useAsStartingPoint': 'Utilice nuestros consejos de crianza como punto de partida, no como sustituto de la atención profesional.',
        'callEmergencyImmediately': 'En una emergencia, llame al 112 inmediatamente. No espere. No lo dude.',
        'youAreDoingAmazing': 'Está haciendo un trabajo increíble.\nSolo queremos asegurarnos de que tenga la visión completa.',
        'becauseYourLittleOne': 'Porque su pequeño es lo que más importa',
        'callDoctor': 'Llamar al Médico',
        'remindMeLater': 'Recordármelo más tarde',
    },
    'fr': {
        'gentleReminder': 'Un Petit Rappel',
        'gentleReminderMessage': "Nous sommes ravis que vous fassiez confiance à BabyMon. Votre petit mérite ce qu'il y a de mieux — et vous aussi. C'est pourquoi nous voulons être totalement transparents sur le fonctionnement de notre Assistant IA.",
        'aiNotDoctorWarning': "Notre Assistant IA fonctionne sur votre appareil... mais ce n'est pas un médecin. Il n'a pas de licence médicale, et n'en aura jamais. C'est un compagnon utile qui peut répondre à vos questions et fournir des conseils parentaux généraux.",
        'alwaysCheckPediatrician': 'Consultez toujours votre pédiatre avant de prendre des décisions médicales.',
        'callDoctorRightAway': 'Appelez votre médecin immédiatement si vous remarquez quelque chose de préoccupant concernant la santé de votre bébé.',
        'useAsStartingPoint': "Utilisez nos conseils parentaux comme point de départ, pas comme un substitut aux soins professionnels.",
        'callEmergencyImmediately': "En cas d'urgence, appelez le 112 immédiatement. N'attendez pas. N'hésitez pas.",
        'youAreDoingAmazing': 'Vous faites un travail formidable.\nNous voulons simplement nous assurer que vous avez une vision complète.',
        'becauseYourLittleOne': 'Parce que votre petit est ce qui compte le plus',
        'callDoctor': 'Appeler le Médecin',
        'remindMeLater': 'Me le rappeler plus tard',
    },
    'de': {
        'gentleReminder': 'Eine Freundliche Erinnerung',
        'gentleReminderMessage': 'Wir freuen uns, dass Sie BabyMon vertrauen. Ihr Kleines verdient das Allerbeste — und Sie auch. Deshalb möchten wir völlig transparent sein, wie unser KI-Begleiter funktioniert.',
        'aiNotDoctorWarning': 'Unser KI-Begleiter läuft auf Ihrem Gerät... aber er ist kein Arzt. Er hat keine ärztliche Zulassung und wird sie auch nie haben. Er ist ein hilfreicher Begleiter, der Fragen beantworten und allgemeine Erziehungshinweise geben kann.',
        'alwaysCheckPediatrician': 'Konsultieren Sie immer Ihren Kinderarzt, bevor Sie medizinische Entscheidungen treffen.',
        'callDoctorRightAway': 'Rufen Sie sofort Ihren Arzt an, wenn Sie etwas Besorgniserregendes an der Gesundheit Ihres Babys bemerken.',
        'useAsStartingPoint': 'Nutzen Sie unsere Erziehungstipps als Ausgangspunkt — nicht als Ersatz für professionelle Betreuung.',
        'callEmergencyImmediately': 'Rufen Sie im Notfall sofort die 112 an. Warten Sie nicht. Zögern Sie nicht.',
        'youAreDoingAmazing': 'Sie machen einen großartigen Job.\nWir möchten nur sicherstellen, dass Sie das vollständige Bild haben.',
        'becauseYourLittleOne': 'Weil Ihr Kleines am wichtigsten ist',
        'callDoctor': 'Arzt Anrufen',
        'remindMeLater': 'Später erinnern',
    },
    'ar': {
        'gentleReminder': 'تذكير لطيف',
        'gentleReminderMessage': 'نحن سعداء بأنك تثق في BabyMon. طفلك الصغير يستحق الأفضل — وكذلك أنت. لهذا السبب نريد أن نكون شفافين تماماً حول كيفية عمل مساعد الذكاء الاصطناعي الخاص بنا.',
        'aiNotDoctorWarning': 'يعمل مساعد الذكاء الاصطناعي الخاص بنا على جهازك... لكنه ليس طبيباً. ليس لديه ترخيص طبي، ولن يحصل عليه أبداً. إنه رفيق مفيد يمكنه الإجابة على الأسئلة وتقديم إرشادات عامة حول التربية.',
        'alwaysCheckPediatrician': 'استشر طبيب الأطفال دائماً قبل اتخاذ القرارات الطبية.',
        'callDoctorRightAway': 'اتصل بطبيبك فوراً إذا لاحظت أي شيء مقلق بشأن صحة طفلك.',
        'useAsStartingPoint': 'استخدم نصائحنا التربوية كنقطة انطلاق — وليس كبديل للرعاية المهنية.',
        'callEmergencyImmediately': 'في حالة الطوارئ، اتصل برقم الطوارئ فوراً. لا تنتظر. لا تتردد.',
        'youAreDoingAmazing': 'أنت تقوم بعمل رائع.\nنريد فقط التأكد من أن لديك الصورة الكاملة.',
        'becauseYourLittleOne': 'لأن طفلك الصغير هو الأهم',
        'callDoctor': 'اتصل بالطبيب',
        'remindMeLater': 'ذكرني لاحقاً',
    },
    'he': {
        'gentleReminder': 'תזכורת עדינה',
        'gentleReminderMessage': 'אנחנו שמחים שאתה סומך על BabyMon. הקטן שלך ראוי לטוב ביותר — וכך גם אתה. לכן אנחנו רוצים להיות שקופים לחלוטין לגבי איך שהעוזר החכם שלנו עובד.',
        'aiNotDoctorWarning': 'העוזר החכם שלנו פועל על המכשיר שלך... אבל הוא לא רופא. אין לו רישיון רפואי, ולעולם לא יהיה לו. הוא חבר מועיל שיכול לענות על שאלות ולספק הדרכה כללית בנושאי הורות.',
        'alwaysCheckPediatrician': 'התייעץ תמיד עם רופא הילדים שלך לפני קבלת החלטות רפואיות.',
        'callDoctorRightAway': 'התקשר לרופא שלך מיד אם אתה מבחין במשהו מדאיג בבריאות התינוק שלך.',
        'useAsStartingPoint': 'השתמש בעצות ההורות שלנו כנקודת התחלה — לא כתחליף לטיפול מקצועי.',
        'callEmergencyImmediately': 'במקרה חירום, התקשר למוקד החירום מיד. אל תחכה. אל תהסס.',
        'youAreDoingAmazing': 'אתה עושה עבודה מדהימה.\nאנחנו רק רוצים לוודא שיש לך את התמונה המלאה.',
        'becauseYourLittleOne': 'כי הקטן שלך הוא החשוב ביותר',
        'callDoctor': 'התקשר לרופא',
        'remindMeLater': 'הזכר לי מאוחר יותר',
    },
}

def escape_dart(s):
    """Escape a string for use in a Dart single-quoted string."""
    return s.replace('\\', '\\\\').replace("'", "\\'")

for lang_code, trans in translations.items():
    arb_path = os.path.join(base, f'app_{lang_code}.arb')
    dart_path = os.path.join(base, f'app_localizations_{lang_code}.dart')
    
    # Update ARB
    with open(arb_path, 'r', encoding='utf-8') as f:
        arb = json.load(f)
    for k, v in trans.items():
        arb[k] = v
    with open(arb_path, 'w', encoding='utf-8') as f:
        json.dump(arb, f, ensure_ascii=False, indent=2)
        f.write('\n')
    
    # Update generated Dart file
    with open(dart_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    for k, v in trans.items():
        v_dart = escape_dart(v)
        # Pattern: String get key => 'old value';
        pattern = rf"(String get {k} => ')([^']*)(';)"
        content = re.sub(pattern, rf"\1{v_dart}\3", content)
    
    with open(dart_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f'Updated {lang_code}: ARB + generated')

print('All done!')
