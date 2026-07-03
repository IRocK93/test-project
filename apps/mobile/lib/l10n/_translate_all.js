const fs = require('fs');

// Comprehensive translations for ALL stale English keys
const trans = {
  // ─── Vaccine names ───
  vaccineSelected: {ar:'اللقاح: {value}',de:'Impfstoff: {value}',es:'Vacuna: {value}',fr:'Vaccin : {value}',he:'חיסון: {value}',it:'Vaccino: {value}',pt:'Vacina: {value}',zh:'疫苗：{value}'},
  vaccineFormat: {ar:'{vaccine} ({dose})',de:'{vaccine} ({dose})',es:'{vaccine} ({dose})',fr:'{vaccine} ({dose})',he:'{vaccine} ({dose})',it:'{vaccine} ({dose})',pt:'{vaccine} ({dose})',zh:'{vaccine}（{dose}）'},
  vaccinePrefix: {ar:'اللقاح:',de:'Impfstoff:',es:'Vacuna:',fr:'Vaccin :',he:'חיסון:',it:'Vaccino:',pt:'Vacina:',zh:'疫苗：'},
  vaccineDTaP: {ar:'DTaP',de:'DTaP',es:'DTaP',fr:'DTaP',he:'DTaP',it:'DTaP',pt:'DTaP'},
  vaccineHib: {ar:'Hib',de:'Hib',es:'Hib',fr:'Hib',he:'Hib',it:'Hib',pt:'Hib',zh:'Hib'},
  vaccineMMR: {ar:'MMR',de:'MMR',es:'MMR',he:'MMR',it:'MMR'},
  vaccineCOVID: {de:'COVID-19',es:'COVID-19',fr:'COVID-19',it:'COVID-19',pt:'COVID-19'},
  vaccineHPV: {ar:'HPV',de:'HPV',he:'HPV',it:'HPV',pt:'HPV',zh:'HPV'},
  vaccineTdap: {ar:'Tdap',de:'Tdap',es:'Tdap',fr:'Tdap',he:'Tdap',it:'Tdap',pt:'Tdap'},
  vaccineRSV: {ar:'RSV',de:'RSV',he:'RSV',it:'RSV',zh:'RSV'},

  // ─── Allergy explanations (sub-text) ───
  allergyExplanationPeanuts: {ar:'البقوليات — الفول السوداني هو الأكثر شيوعاً للحساسية المفرطة',de:'Hülsenfrüchte — Erdnüsse sind der häufigste Auslöser für Anaphylaxie',es:'Legumbres — el cacahuete es el desencadenante más común de anafilaxia',fr:'Légumineuses — l\'arachide est le déclencheur le plus courant d\'anaphylaxie',he:'קטניות — בוטנים הם הגורם הנפוץ ביותר לאנפילקסיס',it:'Legumi — le arachidi sono la causa più comune di anafilassi',pt:'Leguminosas — o amendoim é o gatilho mais comum de anafilaxia',zh:'豆科——花生是过敏性休克最常见的诱因'},
  allergyExplanationTreeNuts: {ar:'المكسرات — تشمل اللوز والجوز والكاجو',de:'Baumnüsse — einschließlich Mandeln, Walnüsse, Cashews',es:'Frutos secos — incluye almendras, nueces, anacardos',fr:'Noix — y compris amandes, noix, noix de cajou',he:'אגוזי עץ — כולל שקדים, אגוזי מלך, קשיו',it:'Frutta a guscio — incluse mandorle, noci, anacardi',pt:'Nozes — incluindo amêndoas, nozes, castanhas de caju',zh:'坚果——包括杏仁、核桃、腰果'},
  allergyExplanationMilkDairy: {ar:'منتجات الألبان — الحليب والجبن والزبدة',de:'Milchprodukte — Milch, Käse, Butter',es:'Lácteos — leche, queso, mantequilla',fr:'Produits laitiers — lait, fromage, beurre',he:'מוצרי חלב — חלב, גבינה, חמאה',it:'Latticini — latte, formaggio, burro',pt:'Laticínios — leite, queijo, manteiga',zh:'乳制品——牛奶、奶酪、黄油'},
  allergyExplanationEggs: {ar:'البيض — يوجد في المخبوزات والمايونيز',de:'Eier — in Backwaren und Mayonnaise enthalten',es:'Huevos — presentes en productos horneados y mayonesa',fr:'Œufs — présents dans les pâtisseries et la mayonnaise',he:'ביצים — נמצאות במוצרי מאפה ומיונז',it:'Uova — presenti nei prodotti da forno e nella maionese',pt:'Ovos — presentes em assados e maionese',zh:'鸡蛋——存在于烘焙食品和蛋黄酱中'},
  allergyExplanationSoy: {ar:'الصويا — شائعة في الأطعمة المصنعة',de:'Soja — häufig in verarbeiteten Lebensmitteln',es:'Soja — común en alimentos procesados',fr:'Soja — courant dans les aliments transformés',he:'סויה — נפוצה במזון מעובד',it:'Soia — comune negli alimenti trasformati',pt:'Soja — comum em alimentos processados',zh:'大豆——常见于加工食品中'},
  allergyExplanationWheat: {ar:'القمح — يوجد في الخبز والمعكرونة',de:'Weizen — in Brot und Nudeln enthalten',es:'Trigo — presente en pan y pasta',fr:'Blé — présent dans le pain et les pâtes',he:'חיטה — נמצאת בלחם ופסטה',it:'Grano — presente in pane e pasta',pt:'Trigo — presente em pão e massa',zh:'小麦——存在于面包和意大利面中'},
  allergyExplanationFish: {ar:'الأسماك — تختلف عن حساسية المحار',de:'Fisch — unterscheidet sich von Schalentierallergie',es:'Pescado — diferente de la alergia a mariscos',fr:'Poisson — différent de l\'allergie aux crustacés',he:'דגים — שונים מאלרגיה לרכיכות',it:'Pesce — diverso dall\'allergia ai crostacei',pt:'Peixe — diferente da alergia a frutos do mar',zh:'鱼类——与贝类过敏不同'},
  allergyExplanationShellfish: {ar:'المحار — يشمل الروبيان وسرطان البحر',de:'Schalentiere — einschließlich Garnelen und Krabben',es:'Mariscos — incluye camarones y cangrejo',fr:'Crustacés — y compris crevettes et crabe',he:'רכיכות — כולל שרימפס וסרטן',it:'Crostacei — inclusi gamberi e granchio',pt:'Frutos do mar — incluindo camarão e caranguejo',zh:'贝类——包括虾和螃蟹'},
  allergyExplanationSesame: {ar:'السمسم — يوجد في الحمص والطحينة',de:'Sesam — in Hummus und Tahini enthalten',es:'Sésamo — presente en hummus y tahini',fr:'Sésame — présent dans le houmous et le tahini',he:'שומשום — נמצא בחומוס וטחינה',it:'Sesamo — presente in hummus e tahini',pt:'Gergelim — presente em húmus e tahine',zh:'芝麻——存在于鹰嘴豆泥和芝麻酱中'},
  allergyExplanationPollen: {ar:'حبوب اللقاح — مسببات الحساسية الموسمية',de:'Pollen — saisonale Allergene',es:'Polen — alérgenos estacionales',fr:'Pollen — allergènes saisonniers',he:'אבקה — אלרגנים עונתיים',it:'Polline — allergeni stagionali',pt:'Pólen — alérgenos sazonais',zh:'花粉——季节性过敏原'},
  allergyExplanationDustMites: {ar:'عث الغبار — يوجد في الفراش والأثاث',de:'Hausstaubmilben — in Bettwäsche und Polstermöbeln',es:'Ácaros del polvo — presentes en ropa de cama y tapicería',fr:'Acariens — présents dans la literie et les tissus d\'ameublement',he:'קרדית האבק — נמצאת במצעים וריפוד',it:'Acari della polvere — presenti in biancheria da letto e tappezzeria',pt:'Ácaros — presentes em roupas de cama e estofados',zh:'尘螨——存在于床上用品和软垫家具中'},
  allergyExplanationMold: {ar:'العفن — يزدهر في المناطق الرطبة',de:'Schimmel — gedeiht in feuchten Bereichen',es:'Moho — prospera en zonas húmedas',fr:'Moisissure — se développe dans les zones humides',he:'עובש — משגשג באזורים לחים',it:'Muffa — prospera in aree umide',pt:'Mofo — prolifera em áreas úmidas',zh:'霉菌——在潮湿区域滋生'},
  allergyExplanationPetDander: {ar:'وبر الحيوانات — من القطط والكلاب',de:'Tierhaare — von Katzen und Hunden',es:'Caspa de mascotas — de gatos y perros',fr:'Squames d\'animaux — provenant des chats et des chiens',he:'קשקשי חיות מחמד — מחתולים וכלבים',it:'Forfora di animali — da gatti e cani',pt:'Pelos de animais — de gatos e cachorros',zh:'宠物皮屑——来自猫和狗'},
  allergyExplanationInsectStings: {ar:'لسعات الحشرات — النحل والدبابير',de:'Insektenstiche — Bienen und Wespen',es:'Picaduras de insectos — abejas y avispas',fr:'Piqûres d\'insectes — abeilles et guêpes',he:'עקיצות חרקים — דבורים וצרעות',it:'Punture di insetti — api e vespe',pt:'Picadas de insetos — abelhas e vespas',zh:'虫咬——蜜蜂和黄蜂'},
  allergyExplanationLatex: {ar:'اللاتكس — يوجد في القفازات والبالونات',de:'Latex — in Handschuhen und Luftballons enthalten',es:'Látex — presente en guantes y globos',fr:'Latex — présent dans les gants et les ballons',he:'לטקס — נמצא בכפפות ובלונים',it:'Lattice — presente in guanti e palloncini',pt:'Látex — presente em luvas e balões',zh:'乳胶——存在于手套和气球中'},
  allergyExplanationPenicillin: {ar:'البنسلين — مضاد حيوي شائع',de:'Penicillin — ein häufiges Antibiotikum',es:'Penicilina — un antibiótico común',fr:'Pénicilline — un antibiotique courant',he:'פניצילין — אנטיביוטיקה נפוצה',it:'Penicillina — un antibiotico comune',pt:'Penicilina — um antibiótico comum',zh:'青霉素——一种常见抗生素'},
  allergyExplanationNSAIDs: {ar:'مضادات الالتهاب — مثل الإيبوبروفين والأسبرين',de:'NSAIDs — wie Ibuprofen und Aspirin',es:'AINEs — como ibuprofeno y aspirina',fr:'AINS — comme l\'ibuprofène et l\'aspirine',he:'NSAIDs — כמו איבופרופן ואספירין',it:'FANS — come ibuprofene e aspirina',pt:'AINEs — como ibuprofeno e aspirina',zh:'非甾体抗炎药——如布洛芬和阿司匹林'},
  allergyExplanationSulfaDrugs: {ar:'أدوية السلفا — مضادات حيوية تحتوي على الكبريت',de:'Sulfonamide — schwefelhaltige Antibiotika',es:'Sulfamidas — antibióticos que contienen azufre',fr:'Sulfamides — antibiotiques contenant du soufre',he:'תרופות סולפה — אנטיביוטיקה המכילה גופרית',it:'Sulfamidici — antibiotici contenenti zolfo',pt:'Sulfas — antibióticos contendo enxofre',zh:'磺胺类药物——含硫抗生素'},

  // ─── Allergy severity ───
  allergySeverityLifeThreatening: {ar:'مهدد للحياة',de:'Lebensbedrohlich',es:'Potencialmente mortal',fr:'Mortelle',he:'מסכן חיים',it:'Pericolosa per la vita',pt:'Risco de vida',zh:'危及生命'},
  allergyNSAIDsOption: {ar:'مضادات الالتهاب',de:'NSAIDs',es:'AINEs',fr:'AINS',he:'NSAIDs',it:'FANS',pt:'AINEs',zh:'非甾体抗炎药'},

  // ─── Feeding ───
  amountLabel: {ar:'الكمية',de:'Menge',fr:'Quantité',it:'Quantità',pt:'Quantidade',zh:'用量'},
  amountWithUnit: {ar:'الكمية ({unit})',de:'Menge ({unit})',es:'Cantidad ({unit})',fr:'Quantité ({unit})',it:'Quantità ({unit})',pt:'Quantidade ({unit})',zh:'用量（{unit}）'},
  formula: {it:'Formula'},
  formulaShortLabel: {de:'Formula',it:'Formula'},
  breastLabel: {ar:'ثدي',de:'Brust',es:'Pecho',fr:'Sein',it:'Seno',pt:'Peito',zh:'母乳'},
  bottleLabel: {ar:'زجاجة',de:'Flasche',es:'Biberón',fr:'Biberon',it:'Biberon',pt:'Mamadeira',zh:'奶瓶'},
  solidLabel: {ar:'صلب',de:'Fest',fr:'Solide',it:'Solido',pt:'Sólido',zh:'固体'},
  feedLogSemantics: {ar:'{type}، {amount}، {date}',de:'{type}, {amount}, {date}',es:'{type}, {amount}, {date}',fr:'{type}, {amount}, {date}',he:'{type}, {amount}, {date}',pt:'{type}, {amount}, {date}'},
  feedingMethod: {ar:'طريقة التغذية',de:'Fütterungsmethode',es:'Método de alimentación',fr:'Méthode d\'alimentation',pt:'Método de alimentação'},
  feedingFilter: {ar:'تغذية',de:'Fütterung',fr:'Alimentation',it:'Alimentazione'},
  feedDayTotal: {es:'Total del día',fr:'Total du jour',pt:'Total do dia'},
  pumpedLabel: {ar:'مضخوخ',de:'Abgepumpt',es:'Extraído',fr:'Tiré',it:'Tirato',pt:'Bombeado',zh:'泵出'},
  feedLogSemantics: {ar:'{type}، {amount}، {date}',de:'{type}, {amount}, {date}',es:'{type}, {amount}, {date}',fr:'{type}, {amount}, {date}',he:'{type}, {amount}, {date}',pt:'{type}, {amount}, {date}'},

  // ─── Subscription ───
  freePlanLabel: {ar:'مجاني',de:'KOSTENLOS',es:'GRATIS',fr:'GRATUIT',it:'GRATIS',pt:'GRÁTIS',zh:'免费'},
  freePlanBanner: {ar:'خطة مجانية',de:'Kostenloser Tarif',es:'Plan gratuito',fr:'Forfait gratuit',it:'Piano gratuito',pt:'Plano gratuito',zh:'免费方案'},
  freeForever: {ar:'مجاني للأبد',de:'Für immer kostenlos',es:'Gratis para siempre',fr:'Gratuit pour toujours',it:'Gratis per sempre',pt:'Grátis para sempre',zh:'永久免费'},
  freePlanFeature1: {ar:'ملف طفل واحد',de:'1 BabyMon-Profil',es:'1 perfil de BabyMon',fr:'1 profil BabyMon',it:'1 profilo BabyMon',pt:'1 perfil BabyMon',zh:'1 个 BabyMon 档案'},
  freePlanFeature2: {ar:'تتبع المراحل الأساسية',de:'Basis-Meilenstein-Tracking',es:'Seguimiento básico de hitos',fr:'Suivi de base des étapes',it:'Monitoraggio base traguardi',pt:'Acompanhamento básico de marcos',zh:'基础里程碑跟踪'},
  freePlanFeature3: {ar:'سجل التغذية',de:'Fütterungsprotokoll',es:'Registro de alimentación',fr:'Journal d\'alimentation',it:'Registro alimentazione',pt:'Registro de alimentação',zh:'喂养记录'},
  freePlanFeature4: {ar:'تتبع النوم',de:'Schlaftracking',es:'Seguimiento de sueño',fr:'Suivi du sommeil',it:'Monitoraggio sonno',pt:'Acompanhamento de sono',zh:'睡眠跟踪'},
  freePlanFeature5: {ar:'سجلات الصحة',de:'Gesundheitsakten',es:'Registros de salud',fr:'Dossiers de santé',it:'Registri sanitari',pt:'Registros de saúde',zh:'健康记录'},
  freePlanFeature6: {ar:'مذكرات يومية',de:'Tagebuch',es:'Diario',fr:'Journal',it:'Diario',pt:'Diário',zh:'日记'},
  premiumPlan: {de:'Premium',es:'Premium',fr:'Premium',it:'Premium',pt:'Premium'},
  premiumPlanBanner: {ar:'خطة بريميوم',de:'Premium-Tarif',es:'Plan Premium',fr:'Forfait Premium',it:'Piano Premium',pt:'Plano Premium',zh:'高级方案'},
  premiumPlanLabel: {ar:'بريميوم',de:'PREMIUM',es:'PREMIUM',fr:'PREMIUM',it:'PREMIUM',pt:'PREMIUM',zh:'高级'},
  premiumFeature1: {ar:'ملفات أطفال غير محدودة',de:'Unbegrenzte BabyMon-Profile',es:'Perfiles BabyMon ilimitados',fr:'Profils BabyMon illimités',it:'Profili BabyMon illimitati',pt:'Perfis BabyMon ilimitados',zh:'无限 BabyMon 档案'},
  premiumFeature2: {ar:'مراحل متقدمة مع XP',de:'Erweiterte Meilensteine mit XP',es:'Hitos avanzados con XP',fr:'Étapes avancées avec XP',it:'Traguardi avanzati con XP',pt:'Marcos avançados com XP',zh:'高级里程碑及 XP'},
  premiumFeature3: {ar:'رفيق ذكاء اصطناعي',de:'KI-Begleiter',es:'Compañero de IA',fr:'Compagnon IA',it:'Compagno IA',pt:'Companheiro IA',zh:'AI 伴侣'},
  premiumFeature4: {ar:'بطاقات نصائح الخبراء',de:'Experten-Ratschläge',es:'Tarjetas de consejos expertos',fr:'Cartes de conseils d\'experts',it:'Schede di consigli esperti',pt:'Cartões de conselhos especializados',zh:'专家建议卡'},
  premiumFeature5: {ar:'تصدير البيانات',de:'Datenexport',es:'Exportación de datos',fr:'Exportation de données',it:'Esportazione dati',pt:'Exportação de dados',zh:'数据导出'},
  premiumFeature6: {ar:'دعم ذو أولوية',de:'Prioritäts-Support',es:'Soporte prioritario',fr:'Support prioritaire',it:'Supporto prioritario',pt:'Suporte prioritário',zh:'优先支持'},
  premiumFeature7: {ar:'وصول مبكر للميزات',de:'Frühzugang zu Funktionen',es:'Acceso anticipado a funciones',fr:'Accès anticipé aux fonctionnalités',it:'Accesso anticipato alle funzionalità',pt:'Acesso antecipado a recursos',zh:'功能抢先体验'},
  chooseFreePlan: {ar:'اختيار المجاني',de:'Kostenlos wählen',es:'Elegir Gratis',fr:'Choisir Gratuit',it:'Scegli Gratis',pt:'Escolher Grátis',zh:'选择免费'},
  chooseYourPlan: {ar:'اختر خطتك',de:'Wähle deinen Tarif',es:'Elige tu plan',fr:'Choisissez votre forfait',it:'Scegli il tuo piano',pt:'Escolha seu plano',zh:'选择您的方案'},
  chooseYourPlanTitle: {ar:'اختر خطتك',de:'Wähle deinen Tarif',es:'Elige tu plan',fr:'Choisissez votre forfait',it:'Scegli il tuo piano',pt:'Escolha seu plano',zh:'选择您的方案'},
  chooseFreeLabel: {ar:'اختيار مجاني',de:'Kostenlos wählen',es:'Elegir gratis',fr:'Choisir gratuit',it:'Scegli gratis',pt:'Escolher grátis',zh:'选择免费'},
  renewMonthly: {ar:'تجديد شهري',de:'Monatlich erneuerbar',es:'Renovable mensualmente',fr:'Renouvelable mensuellement',it:'Rinnovabile mensilmente',pt:'Renovável mensalmente',zh:'按月续订'},
  renewsMonthly: {ar:'يجدد شهرياً',de:'Verlängert sich monatlich',es:'Se renueva mensualmente',fr:'Se renouvelle mensuellement',it:'Si rinnova mensilmente',pt:'Renova mensalmente',zh:'每月续订'},
  restorePurchases: {ar:'استعادة المشتريات',de:'Käufe wiederherstellen',es:'Restaurar compras',fr:'Restaurer les achats',it:'Ripristina acquisti',pt:'Restaurar compras',zh:'恢复购买'},
  restorePurchasesLink: {ar:'استعادة المشتريات',de:'Käufe wiederherstellen',es:'Restaurar compras',fr:'Restaurer les achats',it:'Ripristina acquisti',pt:'Restaurar compras',zh:'恢复购买'},
  securedByStripe: {ar:'مؤمن بواسطة Stripe',de:'Gesichert durch Stripe',es:'Asegurado por Stripe',fr:'Sécurisé par Stripe',it:'Protetto da Stripe',pt:'Protegido por Stripe',zh:'由 Stripe 保障'},
  moneyBackGuarantee: {ar:'ضمان استرداد الأموال لمدة 30 يوماً',de:'30-Tage-Geld-zurück-Garantie',es:'Garantía de devolución de 30 días',fr:'Garantie de remboursement de 30 jours',it:'Garanzia di rimborso di 30 giorni',pt:'Garantia de reembolso de 30 dias',zh:'30 天退款保证'},
  planSubtitle: {ar:'ابدأ مجاناً. قم بالترقية في أي وقت.',de:'Starte kostenlos. Upgrade jederzeit.',es:'Empieza gratis. Actualiza cuando quieras.',fr:'Commencez gratuitement. Mettez à niveau à tout moment.',it:'Inizia gratis. Aggiorna quando vuoi.',pt:'Comece grátis. Atualize a qualquer momento.',zh:'免费开始。随时升级。'},
  plansTitle: {ar:'الخطط',de:'Tarife',es:'Planes',fr:'Forfaits',it:'Piani',pt:'Planos',zh:'方案'},
  compareFeatures: {ar:'مقارنة الميزات',de:'Funktionen vergleichen',es:'Comparar características',fr:'Comparer les fonctionnalités',it:'Confronta funzionalità',pt:'Comparar recursos',zh:'功能对比'},
  compareFeaturesTitle: {ar:'مقارنة الميزات',de:'Funktionen vergleichen',es:'Comparar características',fr:'Comparer les fonctionnalités',it:'Confronta funzionalità',pt:'Comparar recursos',zh:'功能对比'},
  planFreeTierName: {ar:'مجاني',de:'KOSTENLOS',es:'GRATIS',fr:'GRATUIT',it:'GRATIS',pt:'GRÁTIS',zh:'免费'},
  planPremiumTierName: {ar:'بريميوم',de:'PREMIUM',es:'PREMIUM',fr:'PREMIUM',it:'PREMIUM',pt:'PREMIUM',zh:'高级'},
  planPremium: {de:'Premium',es:'Premium',fr:'Premium',it:'Premium',pt:'Premium'},
  periodForever: {ar:'للأبد',de:'für immer',es:'para siempre',fr:'pour toujours',it:'per sempre',pt:'para sempre',zh:'永久'},
  periodMonth: {ar:'شهر',de:'Monat',es:'mes',fr:'mois',it:'mese',pt:'mês',zh:'月'},
  upgradeToPremiumLabel: {ar:'الترقية إلى بريميوم',de:'Upgrade auf Premium',es:'Actualizar a Premium',fr:'Passer à Premium',it:'Passa a Premium',pt:'Atualizar para Premium',zh:'升级到高级版'},
  havePromoCode: {ar:'هل لديك رمز ترويجي؟',de:'Hast du einen Aktionscode?',es:'¿Tienes un código promocional?',fr:'Vous avez un code promo ?',pt:'Tem um código promocional?'},

  // ─── Partners ───
  parentRole: {fr:'Parent'},
  sendInviteLabel: {ar:'إرسال الدعوة',de:'Einladung senden',es:'Enviar invitación',fr:'Envoyer l\'invitation',it:'Invia invito'},

  // ─── General ───
  appTitle: {ar:'BabyMon',de:'BabyMon',es:'BabyMon',fr:'BabyMon',he:'BabyMon',it:'BabyMon',pt:'BabyMon',zh:'BabyMon'},
  areYouSure: {ar:'هل أنت متأكد؟',de:'Bist du sicher?',es:'¿Estás seguro?',fr:'Êtes-vous sûr ?',it:'Sei sicuro?',pt:'Tem certeza?',zh:'确定吗？'},
  saveLabel: {ar:'حفظ',de:'Speichern',fr:'Enregistrer',it:'Salva',pt:'Salvar',zh:'保存'},
  addButton: {ar:'إضافة',de:'Hinzufügen',fr:'Ajouter',it:'Aggiungi',pt:'Adicionar',zh:'添加'},
  nextButton: {ar:'التالي',de:'Weiter',fr:'Suivant',it:'Avanti',pt:'Próximo',zh:'下一步'},
  cancelLabel: {ar:'إلغاء',de:'Abbrechen',fr:'Annuler',it:'Annulla',pt:'Cancelar',zh:'取消'},
  deleteLabel: {ar:'حذف',de:'Löschen',fr:'Supprimer',it:'Elimina',pt:'Excluir',zh:'删除'},
  closeMenu: {ar:'إغلاق القائمة',de:'Menü schließen',es:'Cerrar menú',fr:'Fermer le menu',he:'סגור תפריט',it:'Chiudi menu',pt:'Fechar menu',zh:'关闭菜单'},
  searchLabel: {ar:'بحث',de:'Suchen',fr:'Rechercher',it:'Cerca',pt:'Buscar',zh:'搜索'},
  filterLabel: {ar:'تصفية',de:'Filtern',fr:'Filtrer',it:'Filtra',pt:'Filtrar',zh:'筛选'},
  editLabel: {ar:'تعديل',de:'Bearbeiten',fr:'Modifier',it:'Modifica',pt:'Editar',zh:'编辑'},
  doneLabel: {ar:'تم',de:'Fertig',fr:'Terminé',it:'Fatto',pt:'Concluído',zh:'完成'},
};

const locales = ['ar','de','es','fr','he','it','pt','zh'];
let totalFixed = 0;
for (const loc of locales) {
  const path = 'app_' + loc + '.arb';
  const data = JSON.parse(fs.readFileSync(path, 'utf8'));
  let changed = 0;
  for (const [key, t] of Object.entries(trans)) {
    if (data[key] && t[loc] && data[key] !== t[loc]) {
      data[key] = t[loc];
      changed++;
    }
  }
  if (changed > 0) {
    fs.writeFileSync(path, JSON.stringify(data, null, 2) + '\n');
    console.log(loc + ': ' + changed + ' keys updated');
    totalFixed += changed;
  }
}
console.log('\nTotal: ' + totalFixed + ' keys fixed');
