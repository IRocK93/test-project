const fs = require('fs');

const translations = {
  // Stool types
  stoolTypeWatery: {ar:'مائي (إسهال)',de:'Wässrig (Durchfall)',es:'Acuosa (Diarrea)',fr:'Aqueuse (Diarrhée)',he:'מימי (שלשול)',it:'Acquosa (Diarrea)',pt:'Aguada (Diarreia)',zh:'水样（腹泻）'},
  stoolTypeLoose: {ar:'رخو',de:'Locker',es:'Suelta',fr:'Molle',he:'רך',it:'Molle',pt:'Mole',zh:'松散'},
  stoolTypeMushy: {ar:'طري',de:'Breiig',es:'Pastosa',fr:'Pâteuse',he:'דייסתי',it:'Pastosa',pt:'Pastosa',zh:'糊状'},
  stoolTypeSoftFormed: {ar:'لين ومتشكل',de:'Weich geformt',es:'Blanda formada',fr:'Molle formée',he:'רך ומעוצב',it:'Morbida formata',pt:'Macia formada',zh:'软成形'},
  stoolTypeNormal: {ar:'طبيعي',de:'Normal',es:'Normal',fr:'Normale',he:'תקין',it:'Normale',pt:'Normal',zh:'正常'},
  stoolTypeFirm: {ar:'صلب',de:'Fest',es:'Firme',fr:'Ferme',he:'מוצק',it:'Solida',pt:'Firme',zh:'坚实'},
  stoolTypeHardPellets: {ar:'كريات صلبة',de:'Harte Kügelchen',es:'Bolitas duras',fr:'Billes dures',he:'גלולות קשות',it:'Palline dure',pt:'Pelotas duras',zh:'硬颗粒'},
  stoolTypeConstipated: {ar:'إمساك',de:'Verstopfung',es:'Estreñimiento',fr:'Constipation',he:'עצירות',it:'Stitichezza',pt:'Constipação',zh:'便秘'},

  // Vaccine names
  vaccineOther: {ar:'أخرى',de:'Andere',es:'Otra',fr:'Autre',he:'אחר',it:'Altro',pt:'Outra',zh:'其他'},
  vaccineHepB: {ar:'التهاب الكبد ب',de:'Hepatitis B',es:'Hepatitis B',fr:'Hépatite B',he:'הפטיטיס B',it:'Epatite B',pt:'Hepatite B',zh:'乙肝'},
  vaccineRotavirus: {ar:'فيروس الروتا',de:'Rotavirus',es:'Rotavirus',fr:'Rotavirus',he:'רוטה-וירוס',it:'Rotavirus',pt:'Rotavírus',zh:'轮状病毒'},
  vaccineDTaP: {ar:'DTaP',de:'DTaP',es:'DTaP',fr:'DTaP',he:'DTaP',it:'DTaP',pt:'DTaP',zh:'百白破'},
  vaccineHib: {ar:'Hib',de:'Hib',es:'Hib',fr:'Hib',he:'Hib',it:'Hib',pt:'Hib',zh:'Hib'},
  vaccinePCV13: {ar:'PCV13',de:'PCV13',es:'PCV13',fr:'PCV13',he:'PCV13',it:'PCV13',pt:'PCV13',zh:'肺炎13价'},
  vaccineIPV: {ar:'IPV',de:'IPV',es:'IPV',fr:'IPV',he:'IPV',it:'IPV',pt:'IPV',zh:'脊灰灭活'},
  vaccineFlu: {ar:'الإنفلونزا',de:'Grippe',es:'Gripe',fr:'Grippe',he:'שפעת',it:'Influenza',pt:'Gripe',zh:'流感'},
  vaccineMMR: {ar:'MMR',de:'MMR',es:'MMR',fr:'ROR',he:'MMR',it:'MMR',pt:'Tríplice viral',zh:'麻腮风'},
  vaccineVaricella: {ar:'جدري الماء',de:'Windpocken',es:'Varicela',fr:'Varicelle',he:'אבעבועות רוח',it:'Varicella',pt:'Varicela',zh:'水痘'},
  vaccineHepA: {ar:'التهاب الكبد أ',de:'Hepatitis A',es:'Hepatitis A',fr:'Hépatite A',he:'הפטיטיס A',it:'Epatite A',pt:'Hepatite A',zh:'甲肝'},
  vaccineMenACWY: {ar:'المكورات السحائية',de:'Meningokokken',es:'Meningococo',fr:'Méningocoque',he:'מנינגוקוק',it:'Meningococco',pt:'Meningocócica',zh:'流脑'},
  vaccineCOVID: {ar:'كوفيد-19',de:'COVID-19',es:'COVID-19',fr:'COVID-19',he:'קורונה',it:'COVID-19',pt:'COVID-19',zh:'新冠'},
  vaccineHPV: {ar:'HPV',de:'HPV',es:'VPH',fr:'VPH',he:'HPV',it:'HPV',pt:'HPV',zh:'HPV'},
  vaccineTdap: {ar:'Tdap',de:'Tdap',es:'Tdap',fr:'Tdap',he:'Tdap',it:'Tdap',pt:'Tdap',zh:'百白破加强'},
  vaccineRSV: {ar:'RSV',de:'RSV',es:'VRS',fr:'VRS',he:'RSV',it:'RSV',pt:'VSR',zh:'RSV'},

  // Allergy names
  allergyOtherOption: {ar:'أخرى',de:'Andere',es:'Otra',fr:'Autre',he:'אחר',it:'Altro',pt:'Outra',zh:'其他'},
  allergyPeanutsOption: {ar:'فول سوداني',de:'Erdnüsse',es:'Cacahuetes',fr:'Cacahuètes',he:'בוטנים',it:'Arachidi',pt:'Amendoim',zh:'花生'},
  allergyTreeNutsOption: {ar:'مكسرات',de:'Baumnüsse',es:'Frutos secos',fr:'Noix',he:'אגוזי עץ',it:'Frutta a guscio',pt:'Nozes',zh:'坚果'},
  allergyMilkDairyOption: {ar:'حليب (ألبان)',de:'Milch (Milchprodukte)',es:'Leche (Lácteos)',fr:'Lait (Produits laitiers)',he:'חלב (מוצרי חלב)',it:'Latte (Latticini)',pt:'Leite (Laticínios)',zh:'牛奶（乳制品）'},
  allergyEggsOption: {ar:'بيض',de:'Eier',es:'Huevos',fr:'Œufs',he:'ביצים',it:'Uova',pt:'Ovos',zh:'鸡蛋'},
  allergySoyOption: {ar:'صويا',de:'Soja',es:'Soja',fr:'Soja',he:'סויה',it:'Soia',pt:'Soja',zh:'大豆'},
  allergyWheatOption: {ar:'قمح',de:'Weizen',es:'Trigo',fr:'Blé',he:'חיטה',it:'Grano',pt:'Trigo',zh:'小麦'},
  allergyFishOption: {ar:'سمك',de:'Fisch',es:'Pescado',fr:'Poisson',he:'דגים',it:'Pesce',pt:'Peixe',zh:'鱼'},
  allergyShellfishOption: {ar:'محار',de:'Schalentiere',es:'Mariscos',fr:'Crustacés',he:'רכיכות',it:'Crostacei',pt:'Frutos do mar',zh:'贝类'},
  allergySesameOption: {ar:'سمسم',de:'Sesam',es:'Sésamo',fr:'Sésame',he:'שומשום',it:'Sesamo',pt:'Gergelim',zh:'芝麻'},
  allergyMustardOption: {ar:'خردل',de:'Senf',es:'Mostaza',fr:'Moutarde',he:'חרדל',it:'Senape',pt:'Mostarda',zh:'芥末'},
  allergySulfaDrugsOption: {ar:'أدوية السلفا',de:'Sulfonamide',es:'Sulfamidas',fr:'Sulfamides',he:'תרופות סולפה',it:'Sulfamidici',pt:'Sulfas',zh:'磺胺类药物'},
  allergyPenicillinOption: {ar:'بنسلين',de:'Penicillin',es:'Penicilina',fr:'Pénicilline',he:'פניצילין',it:'Penicillina',pt:'Penicilina',zh:'青霉素'},
  allergyLatexOption: {ar:'لاتكس',de:'Latex',es:'Látex',fr:'Latex',he:'לטקס',it:'Lattice',pt:'Látex',zh:'乳胶'},
  allergyInsectStingsOption: {ar:'لسعات الحشرات',de:'Insektenstiche',es:'Picaduras',fr:'Piqûres',he:'עקיצות חרקים',it:'Punture',pt:'Picadas',zh:'虫咬'},
  allergyMoldOption: {ar:'عفن',de:'Schimmel',es:'Moho',fr:'Moisissure',he:'עובש',it:'Muffa',pt:'Mofo',zh:'霉菌'},
  allergyPetDanderOption: {ar:'وبر الحيوانات',de:'Tierhaare',es:'Caspa animal',fr:'Squames',he:'קשקשי חיות',it:'Forfora animale',pt:'Pelos de animais',zh:'宠物皮屑'},
  allergyPollenOption: {ar:'حبوب اللقاح',de:'Pollen',es:'Polen',fr:'Pollen',he:'אבקה',it:'Polline',pt:'Pólen',zh:'花粉'},
  allergyDustMitesOption: {ar:'عث الغبار',de:'Hausstaubmilben',es:'Ácaros',fr:'Acariens',he:'קרדית האבק',it:'Acari',pt:'Ácaros',zh:'尘螨'},

  // Allergy severity
  allergySeverityMild: {ar:'خفيف',de:'Leicht',es:'Leve',fr:'Légère',he:'קל',it:'Lieve',pt:'Leve',zh:'轻度'},
  allergySeverityModerate: {ar:'متوسط',de:'Mittel',es:'Moderada',fr:'Modérée',he:'בינוני',it:'Moderata',pt:'Moderada',zh:'中度'},
  allergySeveritySevere: {ar:'شديد',de:'Schwer',es:'Grave',fr:'Sévère',he:'חמור',it:'Grave',pt:'Grave',zh:'重度'},

  // Feeding
  feedingAmountLabel: {ar:'الكمية',de:'Menge',es:'Cantidad',fr:'Quantité',he:'כמות',it:'Quantità',pt:'Quantidade',zh:'用量'},
  amountLabelG: {ar:'الكمية (غ)',de:'Menge (g)',es:'Cantidad (g)',fr:'Quantité (g)',he:'כמות (גרם)',it:'Quantità (g)',pt:'Quantidade (g)',zh:'用量（克）'},
  amountLabelUnit: {ar:'الكمية ({unit})',de:'Menge ({unit})',es:'Cantidad ({unit})',fr:'Quantité ({unit})',he:'כמות ({unit})',it:'Quantità ({unit})',pt:'Quantidade ({unit})',zh:'用量（{unit}）'},

  // Drawer
  logoutTitle: {ar:'تسجيل الخروج',de:'Abmelden',es:'Cerrar sesión',fr:'Déconnexion',he:'התנתקות',it:'Disconnetti',pt:'Sair',zh:'登出'},

  // Subscription
  premiumPlan: {ar:'بريميوم',de:'Premium',es:'Premium',fr:'Premium',he:'פרימיום',it:'Premium',pt:'Premium',zh:'高级版'},
  currentPlanLabel: {ar:'الخطة الحالية',de:'Aktueller Tarif',es:'Plan actual',fr:'Forfait actuel',he:'תוכנית נוכחית',it:'Piano attuale',pt:'Plano atual',zh:'当前方案'},
  recommendedBadge: {ar:'موصى به',de:'EMPFOHLEN',es:'RECOMENDADO',fr:'RECOMMANDÉ',he:'מומלץ',it:'CONSIGLIATO',pt:'RECOMENDADO',zh:'推荐'},

  // Partners
  parentRole: {ar:'والد/ة',de:'Elternteil',es:'Padre/Madre',fr:'Parent',he:'הורה',it:'Genitore',pt:'Pai/Mãe',zh:'父母'},
  sendInviteLabel: {ar:'إرسال الدعوة',de:'Einladung senden',es:'Enviar invitación',fr:'Envoyer invitation',he:'שלח הזמנה',it:'Invia invito',pt:'Enviar convite',zh:'发送邀请'},
};

const locales = ['ar','de','es','fr','he','it','pt','zh'];
for (const loc of locales) {
  const path = 'app_' + loc + '.arb';
  const data = JSON.parse(fs.readFileSync(path, 'utf8'));
  let changed = 0;
  for (const [key, trans] of Object.entries(translations)) {
    if (data[key] && trans[loc] && data[key] !== trans[loc]) {
      data[key] = trans[loc];
      changed++;
    }
  }
  if (changed > 0) {
    fs.writeFileSync(path, JSON.stringify(data, null, 2) + '\n');
    console.log(loc + ': ' + changed + ' keys updated');
  } else {
    console.log(loc + ': no changes');
  }
}
