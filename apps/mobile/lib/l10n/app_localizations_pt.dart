// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'BabyMon';

  @override
  String get appTagline => 'Companheiro Parental Inteligente em Evolução';

  @override
  String get welcomeBack => 'Bem-vindo de Volta';

  @override
  String get createAccount => 'Criar Conta';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get nameLabel => 'Nome';

  @override
  String get loginButton => 'Entrar';

  @override
  String get registerButton => 'Cadastrar';

  @override
  String get forgotPassword => 'Esqueceu a senha?';

  @override
  String get resetPassword => 'Redefinir Senha';

  @override
  String get newPassword => 'Nova Senha';

  @override
  String get confirmPassword => 'Confirmar Senha';

  @override
  String get verifyEmail => 'Verifique seu E-mail';

  @override
  String get backToLogin => 'Voltar para Login';

  @override
  String get orContinueWith => 'ou continuar com';

  @override
  String get noAccount => 'Não tem uma conta?';

  @override
  String get hasAccount => 'Já tem uma conta? ';

  @override
  String get signUp => 'Cadastrar';

  @override
  String get logOut => 'Sair';

  @override
  String get settings => 'Configurações';

  @override
  String get dashboard => 'Painel';

  @override
  String get milestones => 'Marcos';

  @override
  String get feeding => 'Alimentação';

  @override
  String get sleep => 'Sono';

  @override
  String get health => 'Saúde';

  @override
  String get growth => 'Crescimento';

  @override
  String get journal => 'Diário';

  @override
  String get companion => 'Companheiro IA';

  @override
  String get profile => 'Perfil';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get confirm => 'Confirmar';

  @override
  String get loading => 'Carregando...';

  @override
  String get error => 'Erro';

  @override
  String get success => 'Sucesso';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get noData => 'Nenhum dado disponível';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get termsOfService => 'Termos de Serviço';

  @override
  String get ageConsent => 'Confirmo que tenho pelo menos 18 anos';

  @override
  String get tosConsent => 'Aceito os Termos de Serviço';

  @override
  String get privacyConsent => 'Aceito a Política de Privacidade';

  @override
  String get dataConsent => 'Concordo com o processamento de dados de saúde e desenvolvimento da criança';

  @override
  String get passwordStrength => 'Força da Senha';

  @override
  String get passwordRequirements => 'Pelo menos 8 caracteres com maiúsculas, minúsculas e números';

  @override
  String get biometricLogin => 'Entrar com biometria';

  @override
  String get medicalDisclaimer => 'O Companheiro IA não substitui o conselho médico profissional. Sempre consulte seu médico.';

  @override
  String get emergencyDisclaimer => 'Se for uma emergência médica, pare de usar este aplicativo e ligue imediatamente para o número de emergência local.';

  @override
  String get dailyBrief => 'Resumo Diário';

  @override
  String get routine => 'Rotina';

  @override
  String get adviceFeed => 'Conselhos';

  @override
  String get chat => 'Chat';

  @override
  String get askCompanion => 'Perguntar ao Companheiro';

  @override
  String get typeMessage => 'Digite uma mensagem...';

  @override
  String get modelDownload => 'Download do Modelo';

  @override
  String get downloadModel => 'Baixar Modelo';

  @override
  String get modelRequired => 'O Companheiro IA precisa baixar um modelo de linguagem para fornecer orientação personalizada no seu dispositivo.';

  @override
  String get downloading => 'Baixando...';

  @override
  String get verifying => 'Verificando...';

  @override
  String get complete => 'Concluído';

  @override
  String get errorDownloading => 'Erro ao baixar o modelo';

  @override
  String get retryDownload => 'Tentar novamente';

  @override
  String get medicalDisclaimerTitle => 'Aviso Médico';

  @override
  String get iUnderstand => 'Entendo';

  @override
  String get achieved => 'Conquistado!';

  @override
  String get milestoneAchieved => 'Marco alcançado!';

  @override
  String xpEarned(int xp) {
    return '+$xp XP';
  }

  @override
  String get noMilestones => 'Ainda não há marcos registrados';

  @override
  String get expectedMilestones => 'Marcos Esperados';

  @override
  String get achievedMilestones => 'Alcançados';

  @override
  String get allMilestones => 'Todos';

  @override
  String get activityPrompt => 'Sugestão de Atividade';

  @override
  String get needsEvaluation => 'Precisa de Avaliação';

  @override
  String get selectBabyMon => 'Selecionar BabyMon';

  @override
  String get addBabyMon => 'Adicionar BabyMon';

  @override
  String get deleteBabyMon => 'Excluir BabyMon';

  @override
  String get deleteBabyMonConfirm => 'Esta ação não pode ser desfeita. Todos os dados deste BabyMon serão permanentemente excluídos.';

  @override
  String get permanentDeletion => 'Exclusão Permanente';

  @override
  String get cancelSubscription => 'Cancelar Assinatura';

  @override
  String get subscriptionActive => 'Ativa';

  @override
  String get subscriptionCancelling => 'Cancelando';

  @override
  String trialDaysLeft(int days) {
    return '$days dias restantes no período de teste';
  }

  @override
  String get subscribeNow => 'Assinar Agora';

  @override
  String get manageSubscription => 'Gerenciar Assinatura';

  @override
  String get levelUp => 'Subiu de Nível!';

  @override
  String get phaseMilestone => 'Marco de Fase';

  @override
  String newLevel(int level, Object name) {
    return 'Nível $level: $name';
  }

  @override
  String get shareBabyMon => 'Compartilhar BabyMon';

  @override
  String get exportData => 'Exportar Dados';

  @override
  String get darkMode => 'Modo Escuro';

  @override
  String get visualStyle => 'Estilo Visual';

  @override
  String get glass => 'Vidro';

  @override
  String get clay => 'Argila';

  @override
  String get systemDefault => 'Padrão do Sistema';

  @override
  String get about => 'Sobre';

  @override
  String get version => 'Versão';

  @override
  String get deleteAccount => 'Excluir Conta';

  @override
  String get deleteAccountConfirm => 'Isso excluirá permanentemente sua conta e todos os dados associados.';

  @override
  String get changePassword => 'Alterar Senha';

  @override
  String get currentPassword => 'Senha Atual';

  @override
  String get updatePassword => 'Atualizar Senha';

  @override
  String get notifications => 'Notificações';

  @override
  String get pushNotifications => 'Notificações Push';

  @override
  String get emailNotifications => 'Notificações por E-mail';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglês';

  @override
  String get trackMilestone => 'Registrar Marco';

  @override
  String get addMilestone => 'Adicionar Marco';

  @override
  String get editMilestone => 'Editar Marco';

  @override
  String get milestoneTitle => 'Título do Marco';

  @override
  String get milestoneDate => 'Data de Conquista';

  @override
  String get milestoneNotes => 'Notas';

  @override
  String get milestoneDomain => 'Categoria';

  @override
  String get grossMotor => 'Motricidade Global';

  @override
  String get fineMotor => 'Motricidade Fina';

  @override
  String get languageComm => 'Linguagem e Comunicação';

  @override
  String get cognitive => 'Cognitivo';

  @override
  String get socialEmotional => 'Social e Emocional';

  @override
  String get logFeed => 'Registrar Alimentação';

  @override
  String get breastfeeding => 'Amamentação';

  @override
  String get formula => 'Fórmula';

  @override
  String get solidFood => 'Alimentação Sólida';

  @override
  String get feedAmount => 'Quantidade';

  @override
  String get feedDuration => 'Duração';

  @override
  String get feedUnit => 'Unidade';

  @override
  String get oz => 'oz';

  @override
  String get ml => 'ml';

  @override
  String get logSleep => 'Registrar Sono';

  @override
  String get sleepStart => 'Hora de Início';

  @override
  String get sleepEnd => 'Hora de Término';

  @override
  String get nap => 'Soneca';

  @override
  String get nightSleep => 'Sono Noturno';

  @override
  String get sleepQuality => 'Qualidade';

  @override
  String get logHealth => 'Registrar Registro de Saúde';

  @override
  String get healthCategory => 'Categoria';

  @override
  String get vaccination => 'Vacinação';

  @override
  String get doctorVisit => 'Consulta Médica';

  @override
  String get temperature => 'Temperatura';

  @override
  String get weight => 'Peso';

  @override
  String get height => 'Altura';

  @override
  String get headCircumference => 'Circunferência da Cabeça';

  @override
  String get logGrowth => 'Registrar Crescimento';

  @override
  String get growthType => 'Tipo de Medição';

  @override
  String get growthValue => 'Valor';

  @override
  String get growthUnit => 'Unidade';

  @override
  String get cm => 'cm';

  @override
  String get kg => 'kg';

  @override
  String get lb => 'lb';

  @override
  String get unitInches => 'pol';

  @override
  String get journalEntry => 'Entrada de Diário';

  @override
  String get allEntries => 'Todas as Entradas';

  @override
  String get filterByType => 'Filtrar por Tipo';

  @override
  String get pendingProposals => 'Propostas Pendentes';

  @override
  String get noEntries => 'Ainda não há entradas';

  @override
  String get photos => 'Fotos';

  @override
  String get uploadPhoto => 'Enviar Foto';

  @override
  String get takePhoto => 'Tirar Foto';

  @override
  String get chooseFromGallery => 'Escolher da Galeria';

  @override
  String get noPhotos => 'Ainda não há fotos';

  @override
  String get discover => 'Descobrir';

  @override
  String get babyMonProfile => 'Perfil do BabyMon';

  @override
  String get babyName => 'Nome do Bebê';

  @override
  String get birthDate => 'Data de Nascimento';

  @override
  String get conceptionDate => 'Data de Concepção';

  @override
  String get gender => 'Gênero';

  @override
  String get bloodType => 'Tipo Sanguíneo';

  @override
  String get allergies => 'Alergias';

  @override
  String get addAllergy => 'Adicionar Alergia';

  @override
  String get allergyName => 'Nome da Alergia';

  @override
  String get allergySeverity => 'Gravidade';

  @override
  String get allergyTriggers => 'Gatilhos';

  @override
  String get allergyTreatment => 'Tratamento';

  @override
  String get mild => 'Leve';

  @override
  String get moderate => 'Moderada';

  @override
  String get severe => 'Grave';

  @override
  String get medicalTeam => 'Equipe Médica';

  @override
  String get addMedicalContact => 'Adicionar Contato Médico';

  @override
  String get contactName => 'Nome';

  @override
  String get specialty => 'Especialidade';

  @override
  String get facility => 'Unidade de Saúde';

  @override
  String get partners => 'Co-Parents';

  @override
  String get invitePartner => 'Convidar Co-Parent';

  @override
  String get partnerEmail => 'E-mail do Co-Parent';

  @override
  String get sendInvite => 'Enviar Convite';

  @override
  String get pendingInvites => 'Convites Pendentes';

  @override
  String get accepted => 'Aceito';

  @override
  String get declined => 'Recusado';

  @override
  String get subscription => 'Assinatura';

  @override
  String get currentPlan => 'Plano Atual';

  @override
  String get freePlan => 'Gratuito';

  @override
  String get premiumPlan => 'Premium';

  @override
  String get upgradeToPremium => 'Fazer Upgrade para Premium';

  @override
  String get trialActive => 'Teste Ativo';

  @override
  String daysRemaining(Object days) {
    return '$days dias restantes';
  }

  @override
  String get renewalDate => 'Data de Renovação';

  @override
  String get createBabyMon => 'Criar BabyMon';

  @override
  String get stageType => 'Tipo de Etapa';

  @override
  String get idea => 'Apenas uma Ideia';

  @override
  String get conceived => 'Concebido';

  @override
  String get born => 'Nascido';

  @override
  String get createProfile => 'Criar Perfil';

  @override
  String get welcomeToBabymon => 'Bem-vindo ao BabyMon';

  @override
  String get getStarted => 'Começar';

  @override
  String get trackYourJourney => 'Acompanhe sua jornada como pai/mãe';

  @override
  String get skip => 'Pular';

  @override
  String get next => 'Próximo';

  @override
  String get finish => 'Finalizar';

  @override
  String get album => 'Álbum';

  @override
  String get share => 'Compartilhar';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get clearData => 'Limpar Dados';

  @override
  String get clearAllData => 'Limpar Todos os Dados';

  @override
  String get clearAllDataConfirm => 'Isso excluirá permanentemente todos os dados. Esta ação não pode ser desfeita.';

  @override
  String get dataCleared => 'Todos os dados foram limpos';

  @override
  String get exportStarted => 'Exportação iniciada';

  @override
  String get exportComplete => 'Exportação concluída';

  @override
  String get noInternet => 'Sem conexão com a internet';

  @override
  String get somethingWentWrong => 'Algo deu errado';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get close => 'Fechar';

  @override
  String get search => 'Pesquisar';

  @override
  String get filter => 'Filtrar';

  @override
  String get sortBy => 'Ordenar Por';

  @override
  String get newest => 'Mais Recente';

  @override
  String get oldest => 'Mais Antigo';

  @override
  String get selectDate => 'Selecionar Data';

  @override
  String get selectTime => 'Selecionar Hora';

  @override
  String get today => 'Hoje';

  @override
  String get yesterday => 'Ontem';

  @override
  String get thisWeek => 'Esta Semana';

  @override
  String get lastWeek => 'Semana Passada';

  @override
  String get thisMonth => 'Este Mês';

  @override
  String get older => 'Mais Antigo';

  @override
  String get growthChart => 'Gráfico de Crescimento';

  @override
  String percentile(int p) {
    return 'Percentil $p';
  }

  @override
  String get trendUp => 'Tendência de alta';

  @override
  String get trendDown => 'Tendência de baixa';

  @override
  String get trendStable => 'Estável';

  @override
  String get comparedToWho => 'Comparado aos padrões da OMS';

  @override
  String get sleepSummary => 'Resumo do Sono';

  @override
  String get avgSleep => 'Média de Sono';

  @override
  String get totalSleep => 'Sono Total';

  @override
  String get feedSummary => 'Resumo da Alimentação';

  @override
  String get totalFeeds => 'Total de Refeições';

  @override
  String get healthRecords => 'Registros de Saúde';

  @override
  String get upcomingVaccines => 'Próximas Vacinas';

  @override
  String get dueDate => 'Vencimento';

  @override
  String get completed => 'Concluído';

  @override
  String get pending => 'Pendente';

  @override
  String get verified => 'Verificado';

  @override
  String get unverified => 'Não Verificado';

  @override
  String get resendEmail => 'Reenviar E-mail de Verificação';

  @override
  String get checkInbox => 'Por favor, verifique sua caixa de entrada e clique no link de verificação';

  @override
  String get emailSent => 'E-mail de verificação enviado';

  @override
  String get biometricsPrompt => 'Autentique-se para continuar';

  @override
  String get biometricsNotAvailable => 'Biometria não disponível';

  @override
  String get socialLoginGoogle => 'Continuar com Google';

  @override
  String get socialLoginApple => 'Continuar com Apple';

  @override
  String get socialLoginFacebook => 'Continuar com Facebook';

  @override
  String get deleteConfirmation => 'Tem certeza de que deseja excluir isso?';

  @override
  String get deleteWarning => 'Esta ação não pode ser desfeita';

  @override
  String get noneRecorded => 'Nenhum registrado';

  @override
  String get traits => 'Traços';

  @override
  String get specialMove => 'Movimento Especial';

  @override
  String get bloodGroup => 'Grupo Sanguíneo';

  @override
  String get mother => 'Mãe';

  @override
  String get father => 'Pai';

  @override
  String get contact => 'Contato';

  @override
  String get shareText => 'Compartilhado via BabyMon';

  @override
  String get xpProgress => 'Progresso de XP';

  @override
  String get currentLevel => 'Nível Atual';

  @override
  String get nextLevel => 'Próximo Nível';

  @override
  String get badgesEarned => 'Emblemas Conquistados';

  @override
  String get noBadges => 'Ainda não há emblemas';

  @override
  String get viewAll => 'Ver Tudo';

  @override
  String get showMore => 'Mostrar Mais';

  @override
  String get showLess => 'Mostrar Menos';

  @override
  String get confirmDelete => 'Confirmar Exclusão';

  @override
  String get confirmLogout => 'Confirmar Saída';

  @override
  String get logoutMessage => 'Tem certeza de que deseja sair?';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get visualStyleGlass => 'Vidro';

  @override
  String get visualStyleClay => 'Argila';

  @override
  String get loginTitle => 'Bem-vindo de Volta!';

  @override
  String get loginSubtitle => 'Entre para continuar';

  @override
  String get emailRequired => 'Por favor, digite seu e-mail';

  @override
  String get passwordRequired => 'Por favor, digite sua senha';

  @override
  String get biometricPrompt => 'Autentique-se para entrar no BabyMon';

  @override
  String get biometricEnableTitle => 'Ativar Login Biométrico';

  @override
  String get biometricEnablePrompt => 'Gostaria de usar biometria para um login mais rápido da próxima vez?';

  @override
  String get notNow => 'Agora Não';

  @override
  String get enable => 'Ativar';

  @override
  String get orDivider => 'OU';

  @override
  String get signUpLink => 'Cadastre-se';

  @override
  String get loginLink => 'Entrar';

  @override
  String get resetPasswordTitle => 'Redefinir Senha';

  @override
  String get resetPasswordSubtitle => 'Digite seu endereço de e-mail e enviaremos um link de redefinição.';

  @override
  String get sendResetLink => 'Enviar Link';

  @override
  String get resetPasswordSuccess => 'Link de redefinição enviado para seu e-mail';

  @override
  String get createAccountTitle => 'Criar Conta';

  @override
  String get createAccountSubtitle => 'Junte-se ao BabyMon hoje';

  @override
  String get nameOptional => 'Nome (opcional)';

  @override
  String get passwordWeak => 'Fraca';

  @override
  String get passwordFair => 'Razoável';

  @override
  String get passwordGood => 'Boa';

  @override
  String get passwordStrong => 'Forte';

  @override
  String get dateOfBirth => 'Data de Nascimento';

  @override
  String get tapToSelect => 'Toque para selecionar';

  @override
  String get dateOfBirthHelp => 'Selecione sua data de nascimento';

  @override
  String get verifyEmailTitle => 'Verifique seu E-mail';

  @override
  String get verifyEmailSubtitle => 'Por favor, verifique sua caixa de entrada e clique no link de verificação para continuar.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get resendVerificationEmail => 'Reenviar E-mail de Verificação';

  @override
  String get emailSentSuccess => 'E-mail de verificação enviado! Verifique sua caixa de entrada.';

  @override
  String get emailSendFailed => 'Falha ao enviar e-mail de verificação. Por favor, tente novamente.';

  @override
  String get emailNotVerified => 'E-mail ainda não verificado. Por favor, verifique sua caixa de entrada.';

  @override
  String get checkVerificationFailed => 'Falha ao verificar o status de verificação.';

  @override
  String get newPasswordLabel => 'Nova Senha';

  @override
  String get passwordMinLength => 'A senha deve ter pelo menos 6 caracteres';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get passwordResetSuccess => 'Senha redefinida com sucesso. Por favor, faça login.';

  @override
  String get resetPasswordSemantic => 'Redefinir sua senha';

  @override
  String get acceptTermsPrefix => 'Aceito os ';

  @override
  String get termsOfServiceLink => 'Termos de Serviço';

  @override
  String get acceptPrivacyPrefix => 'Aceito a ';

  @override
  String get privacyPolicyLink => 'Política de Privacidade';

  @override
  String get iConsentToDataProcessing => 'Dou consentimento para o processamento de dados de saúde e desenvolvimento da criança';

  @override
  String get pleaseSelectDob => 'Por favor, selecione sua data de nascimento';

  @override
  String get mustAcceptTos => 'Você deve aceitar os Termos de Serviço';

  @override
  String get mustAcceptPrivacy => 'Você deve aceitar a Política de Privacidade';

  @override
  String get mustConsentData => 'Você deve consentir com o processamento de dados';

  @override
  String get togglePasswordVisibility => 'Alternar visibilidade da senha';

  @override
  String get editName => 'Editar Nome';

  @override
  String get nameUpdated => 'Nome atualizado!';

  @override
  String get noBabyMonToExport => 'Nenhum BabyMon para exportar';

  @override
  String get exportingData => 'Exportando seus dados...';

  @override
  String get deletePermanently => 'Excluir Permanentemente';

  @override
  String get babyMonDeleted => 'BabyMon excluído permanentemente';

  @override
  String get createBabyMonFirst => 'Crie um BabyMon primeiro';

  @override
  String get clearAllAllergies => 'Limpar todas as alergias';

  @override
  String get clearAllAllergiesDesc => 'Remove todos os perfis de alergia e eventos';

  @override
  String get clearAllEvents => 'Limpar todos os eventos de alergia';

  @override
  String get clearAllEventsDesc => 'Remove eventos mas mantém perfis de alergia';

  @override
  String get allergiesCleared => 'Alergias limpas';

  @override
  String get eventsCleared => 'Eventos limpos';

  @override
  String get couldNotClear => 'Não foi possível limpar. Por favor, tente novamente.';

  @override
  String get noBabyMonsToDelete => 'Nenhum BabyMon para excluir';

  @override
  String get noBabyMonSelected => 'Nenhum BabyMon selecionado';

  @override
  String get logOutTitle => 'Sair';

  @override
  String get logOutConfirm => 'Tem certeza de que deseja sair?';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get saveButton => 'Salvar';

  @override
  String get languageSetting => 'Idioma';

  @override
  String get selectLanguage => 'Selecionar Idioma';

  @override
  String get currentLanguage => 'Idioma Atual';

  @override
  String get localeUpdated => 'Idioma atualizado';

  @override
  String get localeUpdateFailed => 'Falha ao atualizar o idioma';

  @override
  String get preferences => 'Preferences';

  @override
  String get subscriptionAndPlan => 'Subscription & Plan';

  @override
  String get comparePlans => 'Compare plans & upgrade';

  @override
  String get notificationPreferences => 'Notification preferences';

  @override
  String get notificationPreferencesDesc => 'Push, milestone reminders, partner activity';

  @override
  String get biometricLoginSetting => 'Biometric login';

  @override
  String get biometricLoginDesc => 'Use fingerprint or face to sign in';

  @override
  String get measurementUnits => 'Measurement units';

  @override
  String get visualStyleDesc => 'Glass or Clay theme';

  @override
  String get themeMode => 'Theme mode';

  @override
  String get themeModeDesc => 'Light, dark, or follow system';

  @override
  String get babyMonData => 'BabyMon Data';

  @override
  String get activeBabyMon => 'Active BabyMon';

  @override
  String get switchBabyMonHint => 'Use the avatar in the top bar to switch';

  @override
  String get managePartners => 'Manage Partners';

  @override
  String get managePartnersDesc => 'Co-parents & guardians with access';

  @override
  String get backupPrivacy => 'Backup & Privacy';

  @override
  String get exportDataDesc => 'Download all records as JSON';

  @override
  String get syncStatus => 'Sync status';

  @override
  String get allChangesSaved => 'All changes saved';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get clearAllergiesEvents => 'Clear allergies & events';

  @override
  String get clearAllergiesEventsDesc => 'Remove allergy records for this BabyMon';

  @override
  String get deleteBabyMonDesc => 'Permanently remove all data';

  @override
  String get signOutDevice => 'Sign out of this device';

  @override
  String get clearButton => 'Clear';

  @override
  String get metric => 'Metric';

  @override
  String get imperial => 'Imperial';

  @override
  String featureComingSoon(Object feature) {
    return '$feature — coming soon';
  }

  @override
  String get errorInternal => 'Algo deu errado. Por favor, tente novamente.';

  @override
  String get errorDatabase => 'Ocorreu um erro no banco de dados. Por favor, tente novamente.';

  @override
  String get errorValidation => 'Solicitação inválida. Por favor, verifique seus dados.';

  @override
  String get errorNotFound => 'Não encontrado. O recurso pode não estar disponível ainda.';

  @override
  String get errorUnauthorized => 'Sessão expirada. Por favor, faça login novamente.';

  @override
  String get errorInvalidToken => 'Token inválido. Por favor, faça login novamente.';

  @override
  String get errorTokenExpired => 'Sua sessão expirou. Por favor, faça login novamente.';

  @override
  String get errorUserNotFound => 'Usuário não encontrado.';

  @override
  String get errorAccountDeleted => 'Esta conta foi excluída.';

  @override
  String get errorOAuthRequired => 'Por favor, use o login social para esta conta.';

  @override
  String get errorDuplicateEmail => 'Este e-mail já está registrado.';

  @override
  String get errorInvalidOperation => 'Operação inválida. Por favor, tente novamente.';

  @override
  String get errorRateLimited => 'Muitas solicitações. Por favor, aguarde um momento.';

  @override
  String get errorTrialExpired => 'Seu teste gratuito expirou. Por favor, faça o upgrade.';

  @override
  String get errorLimitReached => 'Você atingiu o limite para este recurso.';

  @override
  String get errorUpgradeRequired => 'Este recurso requer uma assinatura Premium.';

  @override
  String get errorEmailInUse => 'E-mail já em uso.';

  @override
  String get errorInvalidPassword => 'Senha inválida.';

  @override
  String get errorBadRequest => 'Solicitação inválida. Por favor, verifique seus dados.';

  @override
  String get errorForbidden => 'Você não tem permissão para fazer isso.';

  @override
  String get errorConflict => 'Isso já existe. Por favor, use um valor diferente.';

  @override
  String get errorServer => 'Erro do servidor. Por favor, tente novamente mais tarde.';

  @override
  String get errorConnectionTimeout => 'Tempo de conexão esgotado. Por favor, verifique sua internet.';

  @override
  String get errorConnectionFailed => 'Não foi possível conectar ao servidor.';

  @override
  String get errorNetwork => 'Erro de rede. Por favor, verifique sua conexão.';

  @override
  String get errorBabyMonNotFound => 'BabyMon não encontrado.';

  @override
  String get errorMilestoneNotFound => 'Marco não encontrado.';

  @override
  String get errorFeedLogNotFound => 'Registro de alimentação não encontrado.';

  @override
  String get errorHealthRecordNotFound => 'Registro de saúde não encontrado.';

  @override
  String get errorInvitationNotFound => 'Convite não encontrado.';

  @override
  String get errorCannotInviteSelf => 'Você não pode se convidar.';

  @override
  String get errorInvitationAlreadyProcessed => 'O convite já foi processado.';

  @override
  String get errorInvitationExpired => 'O convite expirou.';

  @override
  String get errorLinkNotFound => 'Link não encontrado.';

  @override
  String get errorPromoCodeInvalid => 'Código promocional inválido.';

  @override
  String get errorPromoCodeExpired => 'Este código promocional expirou.';

  @override
  String get errorPromoCodeLimitReached => 'Este código promocional atingiu seu limite de uso.';

  @override
  String get errorPromoCodeAlreadyUsed => 'Você já usou este código promocional.';

  @override
  String get errorAppleSignInUnavailable => 'O login com Apple não está disponível neste dispositivo.';

  @override
  String get errorAppleNoIdentityToken => 'Nenhum token de identidade recebido da Apple.';

  @override
  String get errorFacebookNoAccessToken => 'Nenhum token de acesso recebido do Facebook.';

  @override
  String get welcomeChooseLanguage => 'Escolha seu idioma';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get errorUnknown => 'Algo deu errado. Por favor, tente novamente.';
}
