// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'BabyMon';

  @override
  String get appTagline => 'Compañero Inteligente para Padres en Evolución';

  @override
  String get welcomeBack => 'Bienvenido de Nuevo';

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get emailLabel => 'Correo Electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get loginButton => 'Iniciar Sesión';

  @override
  String get registerButton => 'Registrarse';

  @override
  String get forgotPassword => '¿Olvidaste tu Contraseña?';

  @override
  String get resetPassword => 'Restablecer Contraseña';

  @override
  String get newPassword => 'Nueva Contraseña';

  @override
  String get confirmPassword => 'Confirmar Contraseña';

  @override
  String get verifyEmail => 'Verifica tu Correo';

  @override
  String get backToLogin => 'Volver al Inicio de Sesión';

  @override
  String get orContinueWith => 'o continuar con';

  @override
  String get noAccount => '¿No tienes una cuenta?';

  @override
  String get hasAccount => '¿Ya tienes una cuenta? ';

  @override
  String get signUp => 'Registrarse';

  @override
  String get logOut => 'Cerrar Sesión';

  @override
  String get settings => 'Configuración';

  @override
  String get dashboard => 'Panel Principal';

  @override
  String get milestones => 'Hitos';

  @override
  String get feeding => 'Alimentación';

  @override
  String get sleep => 'Sueño';

  @override
  String get health => 'Salud';

  @override
  String get growth => 'Crecimiento';

  @override
  String get journal => 'Diario';

  @override
  String get companion => 'Compañero IA';

  @override
  String get profile => 'Perfil';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get retry => 'Reintentar';

  @override
  String get noData => 'No hay datos disponibles';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get termsOfService => 'Términos de Servicio';

  @override
  String get ageConsent => 'Confirmo que tengo al menos 18 años';

  @override
  String get tosConsent => 'Acepto los Términos de Servicio';

  @override
  String get privacyConsent => 'Acepto la Política de Privacidad';

  @override
  String get dataConsent => 'Doy mi consentimiento para el procesamiento de datos de salud y desarrollo del niño';

  @override
  String get passwordStrength => 'Fortaleza de la Contraseña';

  @override
  String get passwordRequirements => 'Al menos 8 caracteres con mayúsculas, minúsculas y números';

  @override
  String get biometricLogin => 'Iniciar sesión con biometría';

  @override
  String get medicalDisclaimer => 'El Compañero IA no sustituye el consejo médico profesional. Consulta siempre a tu proveedor de salud.';

  @override
  String get emergencyDisclaimer => 'Si se trata de una emergencia médica, deja de usar esta aplicación y llama al 911 o a tu número de emergencia local inmediatamente.';

  @override
  String get dailyBrief => 'Resumen Diario';

  @override
  String get routine => 'Rutina';

  @override
  String get adviceFeed => 'Consejos';

  @override
  String get chat => 'Chat';

  @override
  String get askCompanion => 'Preguntar al Compañero';

  @override
  String get typeMessage => 'Escribe un mensaje...';

  @override
  String get modelDownload => 'Descarga del Modelo';

  @override
  String get downloadModel => 'Descargar Modelo';

  @override
  String get modelRequired => 'El Compañero IA necesita descargar un modelo de lenguaje para ofrecer orientación personalizada en tu dispositivo.';

  @override
  String get downloading => 'Descargando...';

  @override
  String get verifying => 'Verificando...';

  @override
  String get complete => 'Completado';

  @override
  String get errorDownloading => 'Error al descargar el modelo';

  @override
  String get retryDownload => 'Reintentar';

  @override
  String get medicalDisclaimerTitle => 'Aviso Médico';

  @override
  String get iUnderstand => 'Entiendo';

  @override
  String get achieved => '¡Logrado!';

  @override
  String get milestoneAchieved => '¡Hito alcanzado!';

  @override
  String xpEarned(int xp) {
    return '+$xp PX';
  }

  @override
  String get noMilestones => 'Aún no hay hitos registrados';

  @override
  String get expectedMilestones => 'Hitos Esperados';

  @override
  String get achievedMilestones => 'Logrados';

  @override
  String get allMilestones => 'Todos';

  @override
  String get activityPrompt => 'Sugerencia de Actividad';

  @override
  String get needsEvaluation => 'Necesita Evaluación';

  @override
  String get selectBabyMon => 'Seleccionar BabyMon';

  @override
  String get addBabyMon => 'Añadir BabyMon';

  @override
  String get deleteBabyMon => 'Eliminar BabyMon';

  @override
  String get deleteBabyMonConfirm => 'Esta acción no se puede deshacer. Todos los datos de este BabyMon se eliminarán permanentemente.';

  @override
  String get permanentDeletion => 'Eliminación Permanente';

  @override
  String get cancelSubscription => 'Cancelar Suscripción';

  @override
  String get subscriptionActive => 'Activa';

  @override
  String get subscriptionCancelling => 'Cancelando';

  @override
  String trialDaysLeft(int days) {
    return '$days días restantes de prueba';
  }

  @override
  String get subscribeNow => 'Suscribirse Ahora';

  @override
  String get manageSubscription => 'Gestionar Suscripción';

  @override
  String get levelUp => '¡Subida de Nivel!';

  @override
  String get phaseMilestone => 'Hito de Fase';

  @override
  String newLevel(int level, Object name) {
    return 'Nivel $level: $name';
  }

  @override
  String get shareBabyMon => 'Compartir BabyMon';

  @override
  String get exportData => 'Exportar Datos';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get visualStyle => 'Estilo Visual';

  @override
  String get glass => 'Cristal';

  @override
  String get clay => 'Arcilla';

  @override
  String get systemDefault => 'Predeterminado del Sistema';

  @override
  String get about => 'Acerca de';

  @override
  String get version => 'Versión';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get deleteAccountConfirm => 'Esto eliminará permanentemente tu cuenta y todos los datos asociados.';

  @override
  String get changePassword => 'Cambiar Contraseña';

  @override
  String get currentPassword => 'Contraseña Actual';

  @override
  String get updatePassword => 'Actualizar Contraseña';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get pushNotifications => 'Notificaciones Push';

  @override
  String get emailNotifications => 'Notificaciones por Correo';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get trackMilestone => 'Registrar Hito';

  @override
  String get addMilestone => 'Añadir Hito';

  @override
  String get editMilestone => 'Editar Hito';

  @override
  String get milestoneTitle => 'Título del Hito';

  @override
  String get milestoneDate => 'Fecha de Logro';

  @override
  String get milestoneNotes => 'Notas';

  @override
  String get milestoneDomain => 'Categoría';

  @override
  String get grossMotor => 'Motricidad Gruesa';

  @override
  String get fineMotor => 'Motricidad Fina';

  @override
  String get languageComm => 'Lenguaje y Comunicación';

  @override
  String get cognitive => 'Cognitivo';

  @override
  String get socialEmotional => 'Social y Emocional';

  @override
  String get logFeed => 'Registrar Alimentación';

  @override
  String get breastfeeding => 'Lactancia Materna';

  @override
  String get formula => 'Fórmula';

  @override
  String get solidFood => 'Comida Sólida';

  @override
  String get feedAmount => 'Cantidad';

  @override
  String get feedDuration => 'Duración';

  @override
  String get feedUnit => 'Unidad';

  @override
  String get oz => 'oz';

  @override
  String get ml => 'ml';

  @override
  String get logSleep => 'Registrar Sueño';

  @override
  String get sleepStart => 'Hora de Inicio';

  @override
  String get sleepEnd => 'Hora de Fin';

  @override
  String get nap => 'Siesta';

  @override
  String get nightSleep => 'Sueño Nocturno';

  @override
  String get sleepQuality => 'Calidad';

  @override
  String get logHealth => 'Registrar Historial de Salud';

  @override
  String get healthCategory => 'Categoría';

  @override
  String get vaccination => 'Vacunación';

  @override
  String get doctorVisit => 'Visita al Médico';

  @override
  String get temperature => 'Temperatura';

  @override
  String get weight => 'Peso';

  @override
  String get height => 'Altura';

  @override
  String get headCircumference => 'Circunferencia de la Cabeza';

  @override
  String get logGrowth => 'Registrar Crecimiento';

  @override
  String get growthType => 'Tipo de Medición';

  @override
  String get growthValue => 'Valor';

  @override
  String get growthUnit => 'Unidad';

  @override
  String get cm => 'cm';

  @override
  String get kg => 'kg';

  @override
  String get lb => 'lb';

  @override
  String get unitInches => 'in';

  @override
  String get journalEntry => 'Entrada de Diario';

  @override
  String get allEntries => 'Todas las Entradas';

  @override
  String get filterByType => 'Filtrar por Tipo';

  @override
  String get pendingProposals => 'Propuestas Pendientes';

  @override
  String get noEntries => 'Aún no hay entradas';

  @override
  String get photos => 'Fotos';

  @override
  String get uploadPhoto => 'Subir Foto';

  @override
  String get takePhoto => 'Tomar Foto';

  @override
  String get chooseFromGallery => 'Elegir de la Galería';

  @override
  String get noPhotos => 'Aún no hay fotos';

  @override
  String get discover => 'Descubrir';

  @override
  String get babyMonProfile => 'Perfil de BabyMon';

  @override
  String get babyName => 'Nombre del Bebé';

  @override
  String get birthDate => 'Fecha de Nacimiento';

  @override
  String get conceptionDate => 'Fecha de Concepción';

  @override
  String get gender => 'Género';

  @override
  String get bloodType => 'Tipo de Sangre';

  @override
  String get allergies => 'Alergias';

  @override
  String get addAllergy => 'Añadir Alergia';

  @override
  String get allergyName => 'Nombre de la Alergia';

  @override
  String get allergySeverity => 'Gravedad';

  @override
  String get allergyTriggers => 'Desencadenantes';

  @override
  String get allergyTreatment => 'Tratamiento';

  @override
  String get mild => 'Leve';

  @override
  String get moderate => 'Moderada';

  @override
  String get severe => 'Grave';

  @override
  String get medicalTeam => 'Equipo Médico';

  @override
  String get addMedicalContact => 'Añadir Contacto Médico';

  @override
  String get contactName => 'Nombre';

  @override
  String get specialty => 'Especialidad';

  @override
  String get facility => 'Centro Médico';

  @override
  String get partners => 'Co-Parents';

  @override
  String get invitePartner => 'Invitar Co-Parent';

  @override
  String get partnerEmail => 'Correo del Co-Parent';

  @override
  String get sendInvite => 'Enviar Invitación';

  @override
  String get pendingInvites => 'Invitaciones Pendientes';

  @override
  String get accepted => 'Aceptada';

  @override
  String get declined => 'Rechazada';

  @override
  String get subscription => 'Suscripción';

  @override
  String get currentPlan => 'Plan Actual';

  @override
  String get freePlan => 'Gratis';

  @override
  String get premiumPlan => 'Premium';

  @override
  String get upgradeToPremium => 'Actualizar a Premium';

  @override
  String get trialActive => 'Prueba Activa';

  @override
  String daysRemaining(Object days) {
    return '$days días restantes';
  }

  @override
  String get renewalDate => 'Fecha de Renovación';

  @override
  String get createBabyMon => 'Crear BabyMon';

  @override
  String get stageType => 'Tipo de Etapa';

  @override
  String get idea => 'Solo una Idea';

  @override
  String get conceived => 'Concebido';

  @override
  String get born => 'Nacido';

  @override
  String get createProfile => 'Crear Perfil';

  @override
  String get welcomeToBabymon => 'Bienvenido a BabyMon';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get trackYourJourney => 'Registra tu viaje como padre';

  @override
  String get skip => 'Omitir';

  @override
  String get next => 'Siguiente';

  @override
  String get finish => 'Finalizar';

  @override
  String get album => 'Álbum';

  @override
  String get share => 'Compartir';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get clearData => 'Borrar Datos';

  @override
  String get clearAllData => 'Borrar Todos los Datos';

  @override
  String get clearAllDataConfirm => 'Esto eliminará permanentemente todos los datos. Esta acción no se puede deshacer.';

  @override
  String get dataCleared => 'Todos los datos han sido borrados';

  @override
  String get exportStarted => 'Exportación iniciada';

  @override
  String get exportComplete => 'Exportación completada';

  @override
  String get noInternet => 'Sin conexión a Internet';

  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String get tryAgain => 'Intentar de Nuevo';

  @override
  String get close => 'Cerrar';

  @override
  String get search => 'Buscar';

  @override
  String get filter => 'Filtrar';

  @override
  String get sortBy => 'Ordenar Por';

  @override
  String get newest => 'Más Reciente';

  @override
  String get oldest => 'Más Antiguo';

  @override
  String get selectDate => 'Seleccionar Fecha';

  @override
  String get selectTime => 'Seleccionar Hora';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get thisWeek => 'Esta Semana';

  @override
  String get lastWeek => 'Semana Pasada';

  @override
  String get thisMonth => 'Este Mes';

  @override
  String get older => 'Más Antiguo';

  @override
  String get growthChart => 'Gráfica de Crecimiento';

  @override
  String percentile(int p) {
    return 'Percentil $p';
  }

  @override
  String get trendUp => 'Tendencia al alza';

  @override
  String get trendDown => 'Tendencia a la baja';

  @override
  String get trendStable => 'Estable';

  @override
  String get comparedToWho => 'Comparado con los estándares de la OMS';

  @override
  String get sleepSummary => 'Resumen de Sueño';

  @override
  String get avgSleep => 'Sueño Promedio';

  @override
  String get totalSleep => 'Sueño Total';

  @override
  String get feedSummary => 'Resumen de Alimentación';

  @override
  String get totalFeeds => 'Total de Alimentaciones';

  @override
  String get healthRecords => 'Registros de Salud';

  @override
  String get upcomingVaccines => 'Próximas Vacunas';

  @override
  String get dueDate => 'Vence';

  @override
  String get completed => 'Completado';

  @override
  String get pending => 'Pendiente';

  @override
  String get verified => 'Verificado';

  @override
  String get unverified => 'No Verificado';

  @override
  String get resendEmail => 'Reenviar Correo de Verificación';

  @override
  String get checkInbox => 'Por favor revisa tu bandeja de entrada y haz clic en el enlace de verificación';

  @override
  String get emailSent => 'Correo de verificación enviado';

  @override
  String get biometricsPrompt => 'Autenticar para continuar';

  @override
  String get biometricsNotAvailable => 'Biometría no disponible';

  @override
  String get socialLoginGoogle => 'Continuar con Google';

  @override
  String get socialLoginApple => 'Continuar con Apple';

  @override
  String get socialLoginFacebook => 'Continuar con Facebook';

  @override
  String get deleteConfirmation => '¿Estás seguro de que deseas eliminar esto?';

  @override
  String get deleteWarning => 'Esta acción no se puede deshacer';

  @override
  String get noneRecorded => 'Ninguno registrado';

  @override
  String get traits => 'Rasgos';

  @override
  String get specialMove => 'Movimiento Especial';

  @override
  String get bloodGroup => 'Grupo Sanguíneo';

  @override
  String get mother => 'Madre';

  @override
  String get father => 'Padre';

  @override
  String get contact => 'Contacto';

  @override
  String get shareText => 'Compartido vía BabyMon';

  @override
  String get xpProgress => 'Progreso de PX';

  @override
  String get currentLevel => 'Nivel Actual';

  @override
  String get nextLevel => 'Siguiente Nivel';

  @override
  String get badgesEarned => 'Insignias Ganadas';

  @override
  String get noBadges => 'Aún no hay insignias';

  @override
  String get viewAll => 'Ver Todo';

  @override
  String get showMore => 'Mostrar Más';

  @override
  String get showLess => 'Mostrar Menos';

  @override
  String get confirmDelete => 'Confirmar Eliminación';

  @override
  String get confirmLogout => 'Confirmar Cierre de Sesión';

  @override
  String get logoutMessage => '¿Estás seguro de que deseas cerrar sesión?';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get visualStyleGlass => 'Cristal';

  @override
  String get visualStyleClay => 'Arcilla';

  @override
  String get loginTitle => '¡Bienvenido de Nuevo!';

  @override
  String get loginSubtitle => 'Inicia sesión para continuar';

  @override
  String get emailRequired => 'Por favor ingresa tu correo electrónico';

  @override
  String get passwordRequired => 'Por favor ingresa tu contraseña';

  @override
  String get biometricPrompt => 'Autentícate para iniciar sesión en BabyMon';

  @override
  String get biometricEnableTitle => 'Activar Inicio con Biometría';

  @override
  String get biometricEnablePrompt => '¿Te gustaría usar biometría para un inicio de sesión más rápido la próxima vez?';

  @override
  String get notNow => 'Ahora No';

  @override
  String get enable => 'Activar';

  @override
  String get orDivider => 'O';

  @override
  String get signUpLink => 'Regístrate';

  @override
  String get loginLink => 'Iniciar Sesión';

  @override
  String get resetPasswordTitle => 'Restablecer Contraseña';

  @override
  String get resetPasswordSubtitle => 'Ingresa tu dirección de correo y te enviaremos un enlace para restablecer tu contraseña.';

  @override
  String get sendResetLink => 'Enviar Enlace';

  @override
  String get resetPasswordSuccess => 'Enlace de restablecimiento enviado a tu correo';

  @override
  String get createAccountTitle => 'Crear Cuenta';

  @override
  String get createAccountSubtitle => 'Únete a BabyMon hoy';

  @override
  String get nameOptional => 'Nombre (opcional)';

  @override
  String get passwordWeak => 'Débil';

  @override
  String get passwordFair => 'Aceptable';

  @override
  String get passwordGood => 'Buena';

  @override
  String get passwordStrong => 'Fuerte';

  @override
  String get dateOfBirth => 'Fecha de Nacimiento';

  @override
  String get tapToSelect => 'Toca para seleccionar';

  @override
  String get dateOfBirthHelp => 'Selecciona tu fecha de nacimiento';

  @override
  String get verifyEmailTitle => 'Verifica tu Correo';

  @override
  String get verifyEmailSubtitle => 'Por favor revisa tu bandeja de entrada y haz clic en el enlace de verificación para continuar.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get resendVerificationEmail => 'Reenviar Correo de Verificación';

  @override
  String get emailSentSuccess => '¡Correo de verificación enviado! Revisa tu bandeja de entrada.';

  @override
  String get emailSendFailed => 'No se pudo enviar el correo de verificación. Por favor intenta de nuevo.';

  @override
  String get emailNotVerified => 'El correo aún no está verificado. Por favor revisa tu bandeja de entrada.';

  @override
  String get checkVerificationFailed => 'No se pudo verificar el estado de verificación.';

  @override
  String get newPasswordLabel => 'Nueva Contraseña';

  @override
  String get passwordMinLength => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get passwordResetSuccess => 'Contraseña restablecida exitosamente. Por favor inicia sesión.';

  @override
  String get resetPasswordSemantic => 'Restablecer tu contraseña';

  @override
  String get acceptTermsPrefix => 'Acepto los ';

  @override
  String get termsOfServiceLink => 'Términos de Servicio';

  @override
  String get acceptPrivacyPrefix => 'Acepto la ';

  @override
  String get privacyPolicyLink => 'Política de Privacidad';

  @override
  String get iConsentToDataProcessing => 'Doy mi consentimiento para el procesamiento de datos de salud y desarrollo infantil';

  @override
  String get pleaseSelectDob => 'Por favor selecciona tu fecha de nacimiento';

  @override
  String get mustAcceptTos => 'Debes aceptar los Términos de Servicio';

  @override
  String get mustAcceptPrivacy => 'Debes aceptar la Política de Privacidad';

  @override
  String get mustConsentData => 'Debes dar tu consentimiento para el procesamiento de datos';

  @override
  String get togglePasswordVisibility => 'Alternar visibilidad de contraseña';

  @override
  String get editName => 'Editar Nombre';

  @override
  String get nameUpdated => '¡Nombre actualizado!';

  @override
  String get noBabyMonToExport => 'No hay BabyMon para exportar';

  @override
  String get exportingData => 'Exportando tus datos...';

  @override
  String get deletePermanently => 'Eliminar Permanentemente';

  @override
  String get babyMonDeleted => 'BabyMon eliminado permanentemente';

  @override
  String get createBabyMonFirst => 'Crea un BabyMon primero';

  @override
  String get clearAllAllergies => 'Borrar todas las alergias';

  @override
  String get clearAllAllergiesDesc => 'Elimina todos los perfiles de alergia y eventos';

  @override
  String get clearAllEvents => 'Borrar todos los eventos de alergia';

  @override
  String get clearAllEventsDesc => 'Elimina los eventos pero conserva los perfiles de alergia';

  @override
  String get allergiesCleared => 'Alergias borradas';

  @override
  String get eventsCleared => 'Eventos borrados';

  @override
  String get couldNotClear => 'No se pudo borrar. Por favor intenta de nuevo.';

  @override
  String get noBabyMonsToDelete => 'No hay BabyMons para eliminar';

  @override
  String get noBabyMonSelected => 'No hay BabyMon seleccionado';

  @override
  String get logOutTitle => 'Cerrar sesión';

  @override
  String get logOutConfirm => '¿Estás seguro de que deseas cerrar sesión?';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get saveButton => 'Guardar';

  @override
  String get languageSetting => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get currentLanguage => 'Idioma Actual';

  @override
  String get localeUpdated => 'Idioma actualizado';

  @override
  String get localeUpdateFailed => 'No se pudo actualizar el idioma';

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
  String get errorInternal => 'Algo salió mal. Por favor intenta de nuevo.';

  @override
  String get errorDatabase => 'Ocurrió un error de base de datos. Por favor intenta de nuevo.';

  @override
  String get errorValidation => 'Solicitud inválida. Por favor verifica tus datos.';

  @override
  String get errorNotFound => 'No encontrado. La función puede no estar disponible aún.';

  @override
  String get errorUnauthorized => 'Sesión expirada. Por favor inicia sesión de nuevo.';

  @override
  String get errorInvalidToken => 'Token inválido. Por favor inicia sesión de nuevo.';

  @override
  String get errorTokenExpired => 'Tu sesión ha expirado. Por favor inicia sesión de nuevo.';

  @override
  String get errorUserNotFound => 'Usuario no encontrado.';

  @override
  String get errorAccountDeleted => 'Esta cuenta ha sido eliminada.';

  @override
  String get errorOAuthRequired => 'Por favor usa inicio de sesión social para esta cuenta.';

  @override
  String get errorDuplicateEmail => 'Este correo ya está registrado.';

  @override
  String get errorInvalidOperation => 'Operación inválida. Por favor intenta de nuevo.';

  @override
  String get errorRateLimited => 'Demasiadas solicitudes. Por favor espera un momento.';

  @override
  String get errorTrialExpired => 'Tu prueba gratuita ha expirado. Por favor actualiza tu plan.';

  @override
  String get errorLimitReached => 'Has alcanzado el límite para esta función.';

  @override
  String get errorUpgradeRequired => 'Esta función requiere una suscripción Premium.';

  @override
  String get errorEmailInUse => 'Correo ya en uso.';

  @override
  String get errorInvalidPassword => 'Contraseña inválida.';

  @override
  String get errorBadRequest => 'Solicitud inválida. Por favor verifica tus datos.';

  @override
  String get errorForbidden => 'No tienes permiso para hacer eso.';

  @override
  String get errorConflict => 'Esto ya existe. Por favor usa un valor diferente.';

  @override
  String get errorServer => 'Error del servidor. Por favor intenta más tarde.';

  @override
  String get errorConnectionTimeout => 'Tiempo de conexión agotado. Por favor verifica tu internet.';

  @override
  String get errorConnectionFailed => 'No se pudo conectar al servidor.';

  @override
  String get errorNetwork => 'Error de red. Por favor verifica tu conexión.';

  @override
  String get errorBabyMonNotFound => 'BabyMon no encontrado.';

  @override
  String get errorMilestoneNotFound => 'Hito no encontrado.';

  @override
  String get errorFeedLogNotFound => 'Registro de alimentación no encontrado.';

  @override
  String get errorHealthRecordNotFound => 'Registro de salud no encontrado.';

  @override
  String get errorInvitationNotFound => 'Invitación no encontrada.';

  @override
  String get errorCannotInviteSelf => 'No puedes invitarte a ti mismo.';

  @override
  String get errorInvitationAlreadyProcessed => 'La invitación ya fue procesada.';

  @override
  String get errorInvitationExpired => 'La invitación ha expirado.';

  @override
  String get errorLinkNotFound => 'Enlace no encontrado.';

  @override
  String get errorPromoCodeInvalid => 'Código promocional inválido.';

  @override
  String get errorPromoCodeExpired => 'Este código promocional ha expirado.';

  @override
  String get errorPromoCodeLimitReached => 'Este código promocional ha alcanzado su límite de uso.';

  @override
  String get errorPromoCodeAlreadyUsed => 'Ya has usado este código promocional.';

  @override
  String get errorAppleSignInUnavailable => 'Inicio de sesión con Apple no está disponible en este dispositivo.';

  @override
  String get errorAppleNoIdentityToken => 'No se recibió token de identidad de Apple.';

  @override
  String get errorFacebookNoAccessToken => 'No se recibió token de acceso de Facebook.';

  @override
  String get welcomeChooseLanguage => 'Elige tu idioma';

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
  String get errorUnknown => 'Algo salió mal. Por favor intenta de nuevo.';
}
