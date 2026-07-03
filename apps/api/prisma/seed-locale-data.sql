-- Sample locale-aware seed data for Hebrew (he) and Arabic (ar)
-- Run after migration 0002_add_locale_to_content is applied

-- ── ExpertAdviceCard samples ──

INSERT INTO "ExpertAdviceCard" (id, stageKey, category, title, summary, content, "expertVoice", priority, "ageRangeMinDays", "ageRangeMaxDays", tags, "isRedFlag", locale)
VALUES
  -- Hebrew
  (gen_random_uuid(), 'born_week_0', 'NUTRITION_FEEDING', 'הנקה בתדירות גבוהה', 'תינוקות בגיל שבוע ניזונים בתדירות גבוהה — כל 2-3 שעות.', 'בשבוע הראשון, התינוק עדיין לומד להניק. הנקה לפי דרישה היא הדרך הטובה ביותר להבטיח קבלת חלב אם מספיקה. שימי לב לסימני רעב כמו מציצת שפתיים ותנועות ידיים לכיוון הפה.', 'MARIA_CHEN', 10, 0, 7, ARRAY['הנקה', 'תזונה'], false, 'he'),
  (gen_random_uuid(), 'born_week_0', 'SLEEP', 'שינת תינוקות בגיל שבוע', 'תינוקות ישנים 16-18 שעות ביממה, אך בקטעים קצרים.', 'בשבוע הראשון, מחזור השינה של התינוק עדיין מתפתח. צפי לקטעי שינה באורך 2-4 שעות בין ההאכלות. שינה בטוחה חשובה: הניחי את התינוק לישון על הגב במיטה ריקה.', 'DR_VASQUEZ', 8, 0, 7, ARRAY['שינה', 'בטיחות'], false, 'he'),
  -- Arabic
  (gen_random_uuid(), 'born_week_0', 'NUTRITION_FEEDING', 'الرضاعة المتكررة', 'الأطفال حديثو الولادة في أسبوعهم الأول يتغذون بشكل متكرر — كل 2-3 ساعات.', 'في الأسبوع الأول، لا يزال الطفل يتعلم الرضاعة. الرضاعة حسب الطلب هي أفضل طريقة لضمان حصوله على كمية كافية من حليب الأم. انتبهي لعلامات الجوع مثل مص الشفاه وتحريك اليدين نحو الفم.', 'MARIA_CHEN', 10, 0, 7, ARRAY['الرضاعة', 'التغذية'], false, 'ar'),
  (gen_random_uuid(), 'born_week_0', 'SLEEP', 'نوم الأطفال حديثي الولادة', 'ينام الأطفال حديثو الولادة 16-18 ساعة يومياً، لكن على فترات متقطعة.', 'في الأسبوع الأول، لا يزال إيقاع نوم الطفل يتطور. توقعي فترات نوم مدتها 2-4 ساعات بين الرضعات. النوم الآمن مهم: ضعي طفلك للنوم على ظهره في سرير خالي.', 'DR_VASQUEZ', 8, 0, 7, ARRAY['النوم', 'الأمان'], false, 'ar')
ON CONFLICT DO NOTHING;

-- ── RoutineTemplate samples ──

INSERT INTO "RoutineTemplate" (id, stageKey, title, description, "wakeWindowMins", "napCount", "totalNapHours", "nightSleepHours", "feedFrequency", "sampleSchedule", "bedtimeRitual", flexible, locale)
VALUES
  -- Hebrew
  (gen_random_uuid(), 'born_week_0', 'שגרת שבוע ראשון', 'שגרה גמישה המתאימה לתינוק בגיל שבוע אחד.', 45, 4, 6.0, 10.0, 'כל 2-3 שעות',
   '{"06:00": "האכלה", "08:30": "תנומה", "10:00": "האכלה", "12:00": "תנומה", "14:00": "האכלה", "15:30": "תנומה", "17:00": "האכלה", "18:30": "תנומה קצרה", "20:00": "האכלה ושינת לילה"}'::jsonb,
   ARRAY['רחצה חמה', 'עיטוף נוח', 'שיר ערש'], true, 'he'),
  -- Arabic
  (gen_random_uuid(), 'born_week_0', 'روتين الأسبوع الأول', 'روتين مرن يناسب الطفل في أسبوعه الأول.', 45, 4, 6.0, 10.0, 'كل 2-3 ساعات',
   '{"06:00": "الإرضاع", "08:30": "قيلولة", "10:00": "الإرضاع", "12:00": "قيلولة", "14:00": "الإرضاع", "15:30": "قيلولة", "17:00": "الإرضاع", "18:30": "قيلولة قصيرة", "20:00": "الإرضاع والنوم الليلي"}'::jsonb,
   ARRAY['حمام دافئ', 'لف مريح', 'تهدئة بالغناء'], true, 'ar')
ON CONFLICT DO NOTHING;

-- ── MilestoneExpectation samples ──

INSERT INTO "MilestoneExpectation" (id, stageKey, domain, title, description, status, "ageRangeMinDays", "ageRangeMaxDays", "redFlagText", "activityPrompt", "xpReward", locale)
VALUES
  -- Hebrew
  (gen_random_uuid(), 'born_week_0', 'GROSS_MOTOR', 'הרמת ראש קצרה', 'התינוק מסוגל להרים את ראשו לכמה שניות כשהוא שוכב על הבטן.', 'EXPECTED', 0, 14, NULL, ' הניחי את התינוק על הבטן למשך 3-5 דקות פעמיים ביום.', 10, 'he'),
  (gen_random_uuid(), 'born_week_0', 'LANGUAGE_COMMUNICATION', 'תגובה לקול', 'התינוק מגיב לקולות בבכי או בהירגעות.', 'EXPECTED', 0, 14, NULL, 'דברי אל התינוק ברכות ושירי לו שיר ערש.', 10, 'he'),
  -- Arabic
  (gen_random_uuid(), 'born_week_0', 'GROSS_MOTOR', 'رفع الرأس لفترة قصيرة', 'الطفل قادر على رفع رأسه لبضع ثوانٍ عند وضعه على بطنه.', 'EXPECTED', 0, 14, NULL, 'ضعي طفلك على بطنه لمدة 3-5 دقائق مرتين في اليوم.', 10, 'ar'),
  (gen_random_uuid(), 'born_week_0', 'LANGUAGE_COMMUNICATION', 'الاستجابة للأصوات', 'الطفل يستجيب للأصوات بالبكاء أو الهدوء.', 'EXPECTED', 0, 14, NULL, 'تحدثي مع طفلك بهدوء وغنّي له أغنية.', 10, 'ar')
ON CONFLICT DO NOTHING;

-- ── StageContent samples ──

INSERT INTO "StageContent" (id, stageKey, "weekNumber", "monthNumber", "isPostBirth", "summaryText", "nurturingText", "encouragementText", "xpThreshold", locale)
VALUES
  -- Hebrew
  (gen_random_uuid(), 'born_week_0', 0, NULL, true,
   'ברוכה הבאה לשבוע הראשון! זהו זמן של התאקלמות עבורכם ועבור {name}. כל בכי הוא תקשורת, וכל חיוך — אפילו אם הוא רפלקס — קסם.',
   'תני לעצמך חסד. את לומדת את {name}, וגם {name} לומד אותך. שימי לב לאינסטינקטים שלך.',
   'את עושה עבודה נפלאה. כל האכלה וכל חיבוק חשובים.', 0, 'he'),
  -- Arabic
  (gen_random_uuid(), 'born_week_0', 0, NULL, true,
   'مرحباً بك في الأسبوع الأول! هذا وقت التأقلم لكِ ولـ{name}. كل بكاء هو تواصل، وكل ابتسامة — حتى لو كانت رد فعل — سحر.',
   'تسامحي مع نفسك. أنتِ تتعلمين {name}، و{name} يتعلمكِ أيضاً. ثقي بغريزتكِ.',
   'أنتِ تؤدين عملاً رائعاً. كل رضعة وكل حضن مهم.', 0, 'ar')
ON CONFLICT DO NOTHING;
