import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Languages
  String get chooseLanguage {
    switch (locale.languageCode) {
      case 'uk':
        return 'Оберіть мову';
      case 'en':
        return 'Choose language';
      case 'es':
        return 'Elige idioma';
      case 'hi':
        return 'भाषा चुनें';
      case 'zh':
        return '选择语言';
      default:
        return 'Оберіть мову';
    }
  }

  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'uk':
        return locale.languageCode == 'uk'
            ? 'Українська'
            : locale.languageCode == 'en'
            ? 'Ukrainian'
            : locale.languageCode == 'es'
            ? 'Ucraniano'
            : locale.languageCode == 'hi'
            ? 'यूक्रेनियाई'
            : '乌克兰语';
      case 'en':
        return locale.languageCode == 'uk'
            ? 'Англійська'
            : locale.languageCode == 'en'
            ? 'English'
            : locale.languageCode == 'es'
            ? 'Inglés'
            : locale.languageCode == 'hi'
            ? 'अंग्रेजी'
            : '英语';
      case 'es':
        return locale.languageCode == 'uk'
            ? 'Іспанська'
            : locale.languageCode == 'en'
            ? 'Spanish'
            : locale.languageCode == 'es'
            ? 'Español'
            : locale.languageCode == 'hi'
            ? 'स्पेनिश'
            : '西班牙语';
      case 'hi':
        return locale.languageCode == 'uk'
            ? 'Індійська хінді'
            : locale.languageCode == 'en'
            ? 'Hindi'
            : locale.languageCode == 'es'
            ? 'Hindi'
            : locale.languageCode == 'hi'
            ? 'हिंदी'
            : '印地语';
      case 'zh':
        return locale.languageCode == 'uk'
            ? 'Китайська'
            : locale.languageCode == 'en'
            ? 'Chinese'
            : locale.languageCode == 'es'
            ? 'Chino'
            : locale.languageCode == 'hi'
            ? 'चीनी'
            : '中文';
      default:
        return 'Українська';
    }
  }

  // Headers
  String get appTitle {
    switch (locale.languageCode) {
      case 'uk':
        return 'AI Психолог';
      case 'en':
        return 'AI Psychologist';
      case 'es':
        return 'Psicólogo IA';
      case 'hi':
        return 'AI मनोवैज्ञानिक';
      case 'zh':
        return 'AI 心理学家';
      default:
        return 'AI Психолог';
    }
  }

  String get welcomeTitle {
    switch (locale.languageCode) {
      case 'uk':
        return 'Привіт!';
      case 'en':
        return 'Hello!';
      case 'es':
        return '¡Hola!';
      case 'hi':
        return 'नमस्ते!';
      case 'zh':
        return '你好！';
      default:
        return 'Привіт!';
    }
  }

  String get registrationTitle {
    switch (locale.languageCode) {
      case 'uk':
        return 'Реєстрація';
      case 'en':
        return 'Registration';
      case 'es':
        return 'Registro';
      case 'hi':
        return 'पंजीकरण';
      case 'zh':
        return '注册';
      default:
        return 'Реєстрація';
    }
  }

  String get testTitle {
    switch (locale.languageCode) {
      case 'uk':
        return 'Психологічний тест';
      case 'en':
        return 'Psychological test';
      case 'es':
        return 'Test psicológico';
      case 'hi':
        return 'मनोवैज्ञानिक परीक्षण';
      case 'zh':
        return '心理测试';
      default:
        return 'Психологічний тест';
    }
  }

  // Buttons
  String get tryTogether {
    switch (locale.languageCode) {
      case 'uk':
        return 'Спробуємо разом';
      case 'en':
        return 'Let\'s try together';
      case 'es':
        return 'Intentemos juntos';
      case 'hi':
        return 'चलो एक साथ कोशिश करते हैं';
      case 'zh':
        return '让我们一起试试';
      default:
        return 'Спробуємо разом';
    }
  }

  String get authorize {
    switch (locale.languageCode) {
      case 'uk':
        return 'Авторизуватися';
      case 'en':
        return 'Authorize';
      case 'es':
        return 'Autorizar';
      case 'hi':
        return 'अधिकृत करें';
      case 'zh':
        return '授权';
      default:
        return 'Авторизуватися';
    }
  }

  String get register {
    switch (locale.languageCode) {
      case 'uk':
        return 'Зареєструватися';
      case 'en':
        return 'Register';
      case 'es':
        return 'Registrarse';
      case 'hi':
        return 'पंजीकरण करें';
      case 'zh':
        return '注册';
      default:
        return 'Зареєструватися';
    }
  }

  String get login {
    switch (locale.languageCode) {
      case 'uk':
        return 'Увійти';
      case 'en':
        return 'Login';
      case 'es':
        return 'Iniciar sesión';
      case 'hi':
        return 'लॉग इन करें';
      case 'zh':
        return '登录';
      default:
        return 'Увійти';
    }
  }

  String get continueText {
    switch (locale.languageCode) {
      case 'uk':
        return 'Продовжити';
      case 'en':
        return 'Continue';
      case 'es':
        return 'Continuar';
      case 'hi':
        return 'जारी रखें';
      case 'zh':
        return '继续';
      default:
        return 'Продовжити';
    }
  }

  String get startTest {
    switch (locale.languageCode) {
      case 'uk':
        return 'Пройти тест';
      case 'en':
        return 'Take test';
      case 'es':
        return 'Hacer test';
      case 'hi':
        return 'परीक्षण लें';
      case 'zh':
        return '参加测试';
      default:
        return 'Пройти тест';
    }
  }

  String get next {
    switch (locale.languageCode) {
      case 'uk':
        return 'Далі';
      case 'en':
        return 'Next';
      case 'es':
        return 'Siguiente';
      case 'hi':
        return 'अगला';
      case 'zh':
        return '下一步';
      default:
        return 'Далі';
    }
  }

  String get share {
    switch (locale.languageCode) {
      case 'uk':
        return 'Поділитися';
      case 'en':
        return 'Share';
      case 'es':
        return 'Compartir';
      case 'hi':
        return 'साझा करें';
      case 'zh':
        return '分享';
      default:
        return 'Поділитися';
    }
  }

  String get save {
    switch (locale.languageCode) {
      case 'uk':
        return 'Зберегти';
      case 'en':
        return 'Save';
      case 'es':
        return 'Guardar';
      case 'hi':
        return 'सहेजें';
      case 'zh':
        return '保存';
      default:
        return 'Зберегти';
    }
  }

  String get wantDeeper {
    switch (locale.languageCode) {
      case 'uk':
        return 'Хочу глибше';
      case 'en':
        return 'I want deeper';
      case 'es':
        return 'Quiero más profundo';
      case 'hi':
        return 'मैं गहरा चाहता हूं';
      case 'zh':
        return '我想要更深入';
      default:
        return 'Хочу глибше';
    }
  }

  String get goBack {
    switch (locale.languageCode) {
      case 'uk':
        return 'Повернутись';
      case 'en':
        return 'Go back';
      case 'es':
        return 'Volver';
      case 'hi':
        return 'वापस जाएं';
      case 'zh':
        return '返回';
      default:
        return 'Повернутись';
    }
  }

  String get tryAgain {
    switch (locale.languageCode) {
      case 'uk':
        return 'Спробувати ще';
      case 'en':
        return 'Try again';
      case 'es':
        return 'Intentar de nuevo';
      case 'hi':
        return 'फिर से कोशिश करें';
      case 'zh':
        return '再试一次';
      default:
        return 'Спробувати ще';
    }
  }

  String get endSession {
    switch (locale.languageCode) {
      case 'uk':
        return 'Завершити сесію';
      case 'en':
        return 'End session';
      case 'es':
        return 'Finalizar sesión';
      case 'hi':
        return 'सत्र समाप्त करें';
      case 'zh':
        return '结束会话';
      default:
        return 'Завершити сесію';
    }
  }

  String get showReport {
    switch (locale.languageCode) {
      case 'uk':
        return 'Показати звіт';
      case 'en':
        return 'Show report';
      case 'es':
        return 'Mostrar informe';
      case 'hi':
        return 'रिपोर्ट दिखाएं';
      case 'zh':
        return '显示报告';
      default:
        return 'Показати звіт';
    }
  }

  String get toMainPage {
    switch (locale.languageCode) {
      case 'uk':
        return 'На головну сторінку';
      case 'en':
        return 'To main page';
      case 'es':
        return 'A página principal';
      case 'hi':
        return 'मुख्य पृष्ठ पर';
      case 'zh':
        return '返回主页';
      default:
        return 'На головну сторінку';
    }
  }

  String get startConversation {
    switch (locale.languageCode) {
      case 'uk':
        return 'Почати розмову';
      case 'en':
        return 'Start conversation';
      case 'es':
        return 'Iniciar conversación';
      case 'hi':
        return 'बातचीत शुरू करें';
      case 'zh':
        return '开始对话';
      default:
        return 'Почати розмову';
    }
  }

  String get start {
    switch (locale.languageCode) {
      case 'uk':
        return 'Почати';
      case 'en':
        return 'Start';
      case 'es':
        return 'Comenzar';
      case 'hi':
        return 'शुरू करें';
      case 'zh':
        return '开始';
      default:
        return 'Почати';
    }
  }

  String get goToReport {
    switch (locale.languageCode) {
      case 'uk':
        return 'Перейти до звіту';
      case 'en':
        return 'Go to report';
      case 'es':
        return 'Ir al informe';
      case 'hi':
        return 'रिपोर्ट पर जाएं';
      case 'zh':
        return '转到报告';
      default:
        return 'Перейти до звіту';
    }
  }

  String get premiumTitle {
    switch (locale.languageCode) {
      case 'uk':
        return 'Розблокуй повний доступ';
      case 'en':
        return 'Unlock full access';
      case 'es':
        return 'Desbloquear acceso completo';
      case 'hi':
        return 'पूर्ण पहुंच अनलॉक करें';
      case 'zh':
        return '解锁完整访问';
      default:
        return 'Розблокуй повний доступ';
    }
  }

  String get activateFree {
    switch (locale.languageCode) {
      case 'uk':
        return 'Активувати безкоштовно';
      case 'en':
        return 'Activate for free';
      case 'es':
        return 'Activar gratis';
      case 'hi':
        return 'मुफ्त में सक्रिय करें';
      case 'zh':
        return '免费激活';
      default:
        return 'Активувати безкоштовно';
    }
  }

  // Test questions
  String get testIntroTitle {
    switch (locale.languageCode) {
      case 'uk':
        return 'Запропоновано пройти «Тест на самопізнання»';
      case 'en':
        return 'Suggested to take "Self-discovery test"';
      case 'es':
        return 'Se sugiere realizar "Test de autoconocimiento"';
      case 'hi':
        return '"आत्म-खोज परीक्षण" लेने का सुझाव दिया गया';
      case 'zh':
        return '建议参加"自我发现测试"';
      default:
        return 'Запропоновано пройти «Тест на самопізнання»';
    }
  }

  String get testIntroDescription {
    switch (locale.languageCode) {
      case 'uk':
        return 'Цей тест допоможе вам краще зрозуміти себе та свій психологічний тип. Відповідайте чесно на кожне питання.';
      case 'en':
        return 'This test will help you better understand yourself and your psychological type. Answer honestly to each question.';
      case 'es':
        return 'Este test te ayudará a entenderte mejor a ti mismo y tu tipo psicológico. Responde honestamente a cada pregunta.';
      case 'hi':
        return 'यह परीक्षण आपको खुद को और अपने मनोवैज्ञानिक प्रकार को बेहतर ढंग से समझने में मदद करेगा। प्रत्येक प्रश्न का ईमानदारी से उत्तर दें।';
      case 'zh':
        return '这个测试将帮助您更好地了解自己和您的心理类型。请诚实地回答每个问题。';
      default:
        return 'Цей тест допоможе вам краще зрозуміти себе та свій психологічний тип. Відповідайте чесно на кожне питання.';
    }
  }

  List<String> get testQuestions {
    switch (locale.languageCode) {
      case 'uk':
        return [
          'Мені легко тримати \nхолодний розум \nу складних ситуаціях',
          'Я часто керуюсь логікою, \nа не емоціями',
          'Я глибоко переживаю \nемоції — як свої, \nтак і чужі',
          'Я легко починаю \nспілкування з \nнезнайомими людьми',
          'Мені потрібно багато часу \nна самостійні роздуми',
          'Я люблю аналізувати, \nчому люди поводяться \nпевним чином',
          'Я добре приймаю \nраціональні рішення \nнавіть під тиском',
          'Я можу заплакати або \nрозчулитись від фільму \nчи розмови',
          'Я відчуваю дискомфорт \nвід спілкування \nв компанії',
          'Я часто замислююсь про \nсенс життя, глибокі речі',
        ];
      case 'en':
        return [
          'I easily keep \na cool head \nin difficult situations',
          'I often act based on \nlogic, not emotions',
          'I deeply experience \nemotions — both my own \nand others\'',
          'I easily start \nconversations with \nstrangers',
          'I need a lot of time \nfor independent \nreflection',
          'I like to analyze \nwhy people behave \nin a certain way',
          'I make good \nrational decisions \neven under pressure',
          'I can cry or be \nmoved by a movie \nor conversation',
          'I feel discomfort \nfrom communication \nin a group',
          'I often think about \nthe meaning of life, \ndeep things',
        ];
      case 'es':
        return [
          'Mantengo fácilmente \nla calma \nen situaciones difíciles',
          'A menudo actúo basándome \nen la lógica, no en emociones',
          'Experimentó profundamente \nlas emociones — tanto las mías \ncomo las de otros',
          'Inicio fácilmente \nconversaciones con \ndesconocidos',
          'Necesito mucho tiempo \npara la reflexión \nindependiente',
          'Me gusta analizar \npor qué las personas se comportan \nde cierta manera',
          'Tomo buenas \ndecisiones racionales \nincluso bajo presión',
          'Puedo llorar o \nconmoverme por una película \no conversación',
          'Siento incomodidad \npor la comunicación \nen grupo',
          'A menudo pienso en \nel significado de la vida, \ncosas profundas',
        ];
      case 'hi':
        return [
          'मुझे मुश्किल स्थितियों में \nआसानी से \nशांत रहना आता है',
          'मैं अक्सर तर्क पर \nकाम करता हूं, \nभावनाओं पर नहीं',
          'मैं गहराई से भावनाओं को \nअनुभव करता हूं — \nअपनी और दूसरों की',
          'मैं आसानी से \nअजनबियों के साथ \nबातचीत शुरू करता हूं',
          'मुझे स्वतंत्र चिंतन के लिए \nबहुत समय \nचाहिए',
          'मुझे विश्लेषण करना पसंद है \nकि लोग क्यों \nएक निश्चित तरीके से व्यवहार करते हैं',
          'मैं दबाव में भी \nअच्छे तर्कसंगत \nनिर्णय लेता हूं',
          'मैं एक फिल्म या \nबातचीत से \nरो सकता हूं या भावुक हो सकता हूं',
          'मुझे समूह में \nसंचार से \nअसुविधा महसूस होती है',
          'मैं अक्सर जीवन के अर्थ, \nगहरी बातों के बारे में \nसोचता हूं',
        ];
      case 'zh':
        return [
          '在困难的情况下 \n我很容易保持 \n冷静',
          '我经常基于 \n逻辑而不是情感 \n行事',
          '我深刻体验 \n情感——无论是 \n自己的还是他人的',
          '我很容易 \n与陌生人 \n开始对话',
          '我需要大量时间 \n进行独立 \n思考',
          '我喜欢分析 \n人们为什么 \n以某种方式行事',
          '即使在压力下 \n我也能做出 \n良好的理性决定',
          '我可能会因为 \n电影或对话 \n而哭泣或感动',
          '我在群体中 \n交流时感到 \n不适',
          '我经常思考 \n生活的意义， \n深刻的事情',
        ];
      default:
        return [
          'Мені легко тримати \nхолодний розум \nу складних ситуаціях',
          'Я часто керуюсь логікою, \nа не емоціями',
          'Я глибоко переживаю \nемоції — як свої, \nтак і чужі',
          'Я легко починаю \nспілкування з \nнезнайомими людьми',
          'Мені потрібно багато часу \nна самостійні роздуми',
          'Я люблю аналізувати, \nчому люди поводяться \nпевним чином',
          'Я добре приймаю \nраціональні рішення \nнавіть під тиском',
          'Я можу заплакати або \nрозчулитись від фільму \nчи розмови',
          'Я відчуваю дискомфорт \nвід спілкування \nв компанії',
          'Я часто замислююсь про \nсенс життя, глибокі речі',
        ];
    }
  }

  List<String> get emojiLabels {
    switch (locale.languageCode) {
      case 'uk':
        return ['Зовсім ні', 'Частково', 'Часто', 'Дуже часто'];
      case 'en':
        return ['Not at all', 'Partially', 'Often', 'Very often'];
      case 'es':
        return ['Para nada', 'Parcialmente', 'A menudo', 'Muy a menudo'];
      case 'hi':
        return ['बिल्कुल नहीं', 'आंशिक रूप से', 'अक्सर', 'बहुत अक्सर'];
      case 'zh':
        return ['完全没有', '部分', '经常', '非常经常'];
      default:
        return ['Зовсім ні', 'Частково', 'Часто', 'Дуже часто'];
    }
  }

  // Chat
  String get chatPlaceholder {
    switch (locale.languageCode) {
      case 'uk':
        return 'Напишіть повідомлення...';
      case 'en':
        return 'Write a message...';
      case 'es':
        return 'Escribe un mensaje...';
      case 'hi':
        return 'एक संदेश लिखें...';
      case 'zh':
        return '写一条消息...';
      default:
        return 'Напишіть повідомлення...';
    }
  }

  String get sessionCompleted {
    switch (locale.languageCode) {
      case 'uk':
        return 'Сеанс завершено. Дякуємо за довіру. Пам\'ятай - ти не один.';
      case 'en':
        return 'Session completed. Thank you for your trust. Remember - you are not alone.';
      case 'es':
        return 'Sesión completada. Gracias por tu confianza. Recuerda - no estás solo.';
      case 'hi':
        return 'सत्र पूरा हो गया। आपके विश्वास के लिए धन्यवाद। याद रखें - आप अकेले नहीं हैं।';
      case 'zh':
        return '会话已完成。感谢您的信任。记住 - 你并不孤单。';
      default:
        return 'Сеанс завершено. Дякуємо за довіру. Пам\'ятай - ти не один.';
    }
  }

  String get historyEmpty {
    switch (locale.languageCode) {
      case 'uk':
        return 'Історія порожня';
      case 'en':
        return 'History is empty';
      case 'es':
        return 'El historial está vacío';
      case 'hi':
        return 'इतिहास खाली है';
      case 'zh':
        return '历史记录为空';
      default:
        return 'Історія порожня';
    }
  }

  String get error {
    switch (locale.languageCode) {
      case 'uk':
        return 'Помилка';
      case 'en':
        return 'Error';
      case 'es':
        return 'Error';
      case 'hi':
        return 'त्रुटि';
      case 'zh':
        return '错误';
      default:
        return 'Помилка';
    }
  }

  String get alreadyTakenTest {
    switch (locale.languageCode) {
      case 'uk':
        return 'Ви вже пройшли тест?';
      case 'en':
        return 'Have you already taken the test?';
      case 'es':
        return '¿Ya has realizado el test?';
      case 'hi':
        return 'क्या आपने पहले से ही परीक्षण लिया है?';
      case 'zh':
        return '您已经参加测试了吗？';
      default:
        return 'Ви вже пройшли тест?';
    }
  }

  String get analyzing {
    switch (locale.languageCode) {
      case 'uk':
        return 'Аналіз...';
      case 'en':
        return 'Analyzing...';
      case 'es':
        return 'Analizando...';
      case 'hi':
        return 'विश्लेषण कर रहे हैं...';
      case 'zh':
        return '分析中...';
      default:
        return 'Аналіз...';
    }
  }

  String get waitAnalyzing {
    switch (locale.languageCode) {
      case 'uk':
        return 'Зачекайте, аналізуємо ваші відповіді...';
      case 'en':
        return 'Please wait, analyzing your answers...';
      case 'es':
        return 'Por favor espera, analizando tus respuestas...';
      case 'hi':
        return 'कृपया प्रतीक्षा करें, आपके उत्तरों का विश्लेषण कर रहे हैं...';
      case 'zh':
        return '请稍候，正在分析您的答案...';
      default:
        return 'Зачекайте, аналізуємо ваші відповіді...';
    }
  }

  String get analysisError {
    switch (locale.languageCode) {
      case 'uk':
        return 'Помилка аналізу';
      case 'en':
        return 'Analysis error';
      case 'es':
        return 'Error de análisis';
      case 'hi':
        return 'विश्लेषण त्रुटि';
      case 'zh':
        return '分析错误';
      default:
        return 'Помилка аналізу';
    }
  }

  String get analysisErrorDescription {
    switch (locale.languageCode) {
      case 'uk':
        return 'На жаль, не вдалося проаналізувати результати. Спробуйте ще раз.';
      case 'en':
        return 'Unfortunately, we couldn\'t analyze the results. Please try again.';
      case 'es':
        return 'Desafortunadamente, no pudimos analizar los resultados. Por favor intenta de nuevo.';
      case 'hi':
        return 'दुर्भाग्य से, हम परिणामों का विश्लेषण नहीं कर सके। कृपया फिर से कोशिश करें।';
      case 'zh':
        return '很抱歉，我们无法分析结果。请再试一次。';
      default:
        return 'На жаль, не вдалося проаналізувати результати. Спробуйте ще раз.';
    }
  }

  String get undefinedType {
    switch (locale.languageCode) {
      case 'uk':
        return 'Невизначений тип';
      case 'en':
        return 'Undefined type';
      case 'es':
        return 'Tipo indefinido';
      case 'hi':
        return 'अपरिभाषित प्रकार';
      case 'zh':
        return '未定义类型';
      default:
        return 'Невизначений тип';
    }
  }

  String get failedToGetDescription {
    switch (locale.languageCode) {
      case 'uk':
        return 'Не вдалося отримати опис';
      case 'en':
        return 'Failed to get description';
      case 'es':
        return 'No se pudo obtener la descripción';
      case 'hi':
        return 'विवरण प्राप्त करने में विफल';
      case 'zh':
        return '无法获取描述';
      default:
        return 'Не вдалося отримати опис';
    }
  }

  String get yourPsychotype {
    switch (locale.languageCode) {
      case 'uk':
        return 'Твій психотип';
      case 'en':
        return 'Your psychotype';
      case 'es':
        return 'Tu psicotipo';
      case 'hi':
        return 'आपका मनोवैज्ञानिक प्रकार';
      case 'zh':
        return '您的心理类型';
      default:
        return 'Твій психотип';
    }
  }

  String get tips {
    switch (locale.languageCode) {
      case 'uk':
        return 'Поради';
      case 'en':
        return 'Tips';
      case 'es':
        return 'Consejos';
      case 'hi':
        return 'सुझाव';
      case 'zh':
        return '建议';
      default:
        return 'Поради';
    }
  }

  String get goToChat {
    switch (locale.languageCode) {
      case 'uk':
        return 'Перейти до чату';
      case 'en':
        return 'Go to chat';
      case 'es':
        return 'Ir al chat';
      case 'hi':
        return 'चैट पर जाएं';
      case 'zh':
        return '前往聊天';
      default:
        return 'Перейти до чату';
    }
  }

  String get shareResult {
    switch (locale.languageCode) {
      case 'uk':
        return 'Поділитись результатом';
      case 'en':
        return 'Share result';
      case 'es':
        return 'Compartir resultado';
      case 'hi':
        return 'परिणाम साझा करें';
      case 'zh':
        return '分享结果';
      default:
        return 'Поділитись результатом';
    }
  }

  String get myPsychotype {
    switch (locale.languageCode) {
      case 'uk':
        return 'Мій психотип';
      case 'en':
        return 'My psychotype';
      case 'es':
        return 'Mi psicotipo';
      case 'hi':
        return 'मेरा मनोवैज्ञानिक प्रकार';
      case 'zh':
        return '我的心理类型';
      default:
        return 'Мій психотип';
    }
  }

  String get shareResultIn {
    switch (locale.languageCode) {
      case 'uk':
        return 'Поділитись результатом в:';
      case 'en':
        return 'Share result in:';
      case 'es':
        return 'Compartir resultado en:';
      case 'hi':
        return 'में परिणाम साझा करें:';
      case 'zh':
        return '在以下平台分享结果：';
      default:
        return 'Поділитись результатом в:';
    }
  }

  String get subscriptionMainText {
    switch (locale.languageCode) {
      case 'uk':
        return 'У реальному житті багато психологів орієнтовані на гроші - більше сесій, більше записів, більше оплат. Я - штучний. У мене немає емоцій, інтересу, здібності.\nЯ не веду тебе на кількість сесій. Я веду тебе до результату.';
      case 'en':
        return 'In real life, many psychologists are focused on money - more sessions, more appointments, more payments. I am artificial. I have no emotions, interest, ability.\nI don\'t lead you to a number of sessions. I lead you to a result.';
      case 'es':
        return 'En la vida real, muchos psicólogos están orientados al dinero: más sesiones, más citas, más pagos. Yo soy artificial. No tengo emociones, interés, habilidad.\nNo te llevo a un número de sesiones. Te llevo a un resultado.';
      case 'hi':
        return 'वास्तविक जीवन में, कई मनोवैज्ञानिक पैसे पर केंद्रित हैं - अधिक सत्र, अधिक नियुक्तियां, अधिक भुगतान। मैं कृत्रिम हूं। मेरे पास भावनाएं, रुचि, क्षमता नहीं है।\nमैं आपको सत्रों की संख्या तक नहीं ले जाता। मैं आपको परिणाम तक ले जाता हूं।';
      case 'zh':
        return '在现实生活中，许多心理学家专注于金钱——更多的疗程、更多的预约、更多的付款。我是人工的。我没有情感、兴趣、能力。\n我不会引导你进行多次疗程。我会引导你获得结果。';
      default:
        return 'У реальному житті багато психологів орієнтовані на гроші - більше сесій, більше записів, більше оплат. Я - штучний. У мене немає емоцій, інтересу, здібності.\nЯ не веду тебе на кількість сесій. Я веду тебе до результату.';
    }
  }

  String get whySubscription {
    switch (locale.languageCode) {
      case 'uk':
        return 'Навіщо підписка?';
      case 'en':
        return 'Why subscription?';
      case 'es':
        return '¿Por qué suscripción?';
      case 'hi':
        return 'सदस्यता क्यों?';
      case 'zh':
        return '为什么需要订阅？';
      default:
        return 'Навіщо підписка?';
    }
  }

  String get subscriptionExplanation {
    switch (locale.languageCode) {
      case 'uk':
        return 'Це не просто "взяти з тебе гроші". Це — підтримка розвитку цього додатку, щоб зробити його ще сильнішим і доступнішим для інших. У відповідь ти отримуєш:';
      case 'en':
        return 'This is not just "taking money from you". This is support for the development of this application, to make it even stronger and more accessible to others. In return, you get:';
      case 'es':
        return 'Esto no es solo "tomar dinero de ti". Esto es apoyo para el desarrollo de esta aplicación, para hacerla aún más fuerte y accesible para otros. A cambio, obtienes:';
      case 'hi':
        return 'यह सिर्फ "आपसे पैसे लेना" नहीं है। यह इस एप्लिकेशन के विकास के लिए समर्थन है, इसे और भी मजबूत और दूसरों के लिए सुलभ बनाने के लिए। बदले में, आपको मिलता है:';
      case 'zh':
        return '这不仅仅是"从你那里拿钱"。这是对应用程序开发的支持，使其更强大、更容易为他人所用。作为回报，您将获得：';
      default:
        return 'Це не просто "взяти з тебе гроші". Це — підтримка розвитку цього додатку, щоб зробити його ще сильнішим і доступнішим для інших. У відповідь ти отримуєш:';
    }
  }

  String get benefitWorkingPractices {
    switch (locale.languageCode) {
      case 'uk':
        return 'Практики, що працюють;';
      case 'en':
        return 'Working practices;';
      case 'es':
        return 'Prácticas que funcionan;';
      case 'hi':
        return 'काम करने वाली प्रथाएं;';
      case 'zh':
        return '有效的实践；';
      default:
        return 'Практики, що працюють;';
    }
  }

  String get benefitPocketPsychologist {
    switch (locale.languageCode) {
      case 'uk':
        return 'Кишенькового психолога 24/7;';
      case 'en':
        return 'Pocket psychologist 24/7;';
      case 'es':
        return 'Psicólogo de bolsillo 24/7;';
      case 'hi':
        return 'पॉकेट मनोवैज्ञानिक 24/7;';
      case 'zh':
        return '24/7 口袋心理学家；';
      default:
        return 'Кишенькового психолога 24/7;';
    }
  }

  String get benefitSupport {
    switch (locale.languageCode) {
      case 'uk':
        return 'Підтримку в моменти тривоги, сорому, емоційного болю.';
      case 'en':
        return 'Support in moments of anxiety, shame, emotional pain.';
      case 'es':
        return 'Apoyo en momentos de ansiedad, vergüenza, dolor emocional.';
      case 'hi':
        return 'चिंता, शर्म, भावनात्मक दर्द के क्षणों में सहायता।';
      case 'zh':
        return '在焦虑、羞耻、情感痛苦的时刻提供支持。';
      default:
        return 'Підтримку в моменти тривоги, сорому, емоційного болю.';
    }
  }

  String get continueButton {
    switch (locale.languageCode) {
      case 'uk':
        return 'Продовжити';
      case 'en':
        return 'Continue';
      case 'es':
        return 'Continuar';
      case 'hi':
        return 'जारी रखें';
      case 'zh':
        return '继续';
      default:
        return 'Продовжити';
    }
  }

  String get shareTestText {
    switch (locale.languageCode) {
      case 'uk':
        return 'Пройшов тест на самопізнання в AI Psychology Balance! 🧠✨';
      case 'en':
        return 'I took a self-discovery test in AI Psychology Balance! 🧠✨';
      case 'es':
        return '¡Hice un test de autoconocimiento en AI Psychology Balance! 🧠✨';
      case 'hi':
        return 'मैंने AI Psychology Balance में आत्म-खोज परीक्षण लिया! 🧠✨';
      case 'zh':
        return '我在AI Psychology Balance中进行了自我发现测试！🧠✨';
      default:
        return 'Пройшов тест на самопізнання в AI Psychology Balance! 🧠✨';
    }
  }

  // Welcome screen
  String get welcomeHello {
    switch (locale.languageCode) {
      case 'uk':
        return 'Привіт!\nЯ — Штучний Психолог';
      case 'en':
        return 'Hello!\nI am an AI Psychologist';
      case 'es':
        return '¡Hola!\nSoy un Psicólogo IA';
      case 'hi':
        return 'नमस्ते!\nमैं एक AI मनोवैज्ञानिक हूं';
      case 'zh':
        return '你好！\n我是AI心理学家';
      default:
        return 'Привіт!\nЯ — Штучний Психолог';
    }
  }

  String get welcomeDescription1 {
    switch (locale.languageCode) {
      case 'uk':
        return 'Цей додаток був створений людиною, яка пройшла через внутрішні кризи, вивчала психологію, і зрозуміла одну просту річ:';
      case 'en':
        return 'This app was created by a person who went through internal crises, studied psychology, and understood one simple thing:';
      case 'es':
        return 'Esta aplicación fue creada por una persona que pasó por crisis internas, estudió psicología y entendió una cosa simple:';
      case 'hi':
        return 'यह ऐप एक व्यक्ति द्वारा बनाया गया था जो आंतरिक संकटों से गुजरा, मनोविज्ञान का अध्ययन किया, और एक साधारण बात समझी:';
      case 'zh':
        return '这个应用程序是由一个经历过内心危机、学习过心理学并理解了一个简单道理的人创建的：';
      default:
        return 'Цей додаток був створений людиною, яка пройшла через внутрішні кризи, вивчала психологію, і зрозуміла одну просту річ:';
    }
  }

  String get welcomeDescription2 {
    switch (locale.languageCode) {
      case 'uk':
        return 'психолог має бути доступний кожному, незалежно від того, скільки ти заробляєш.';
      case 'en':
        return 'a psychologist should be available to everyone, regardless of how much you earn.';
      case 'es':
        return 'un psicólogo debe estar disponible para todos, independientemente de cuánto ganes.';
      case 'hi':
        return 'एक मनोवैज्ञानिक सभी के लिए उपलब्ध होना चाहिए, चाहे आप कितना भी कमाएं।';
      case 'zh':
        return '心理学家应该对每个人开放，无论你赚多少钱。';
      default:
        return 'психолог має бути доступний кожному, незалежно від того, скільки ти заробляєш.';
    }
  }

  // Main interface
  String get takeTest {
    switch (locale.languageCode) {
      case 'uk':
        return 'Пройти тест';
      case 'en':
        return 'Take test';
      case 'es':
        return 'Hacer test';
      case 'hi':
        return 'परीक्षण लें';
      case 'zh':
        return '参加测试';
      default:
        return 'Пройти тест';
    }
  }

  String get learnYourPsychotype {
    switch (locale.languageCode) {
      case 'uk':
        return 'Дізнайтеся свій психотип';
      case 'en':
        return 'Learn your psychotype';
      case 'es':
        return 'Descubre tu psicotipo';
      case 'hi':
        return 'अपना मनोवैज्ञानिक प्रकार जानें';
      case 'zh':
        return '了解您的心理类型';
      default:
        return 'Дізнайтеся свій психотип';
    }
  }

  String get talkToAI {
    switch (locale.languageCode) {
      case 'uk':
        return 'Поговорити з AI';
      case 'en':
        return 'Talk to AI';
      case 'es':
        return 'Hablar con IA';
      case 'hi':
        return 'AI से बात करें';
      case 'zh':
        return '与AI对话';
      default:
        return 'Поговорити з AI';
    }
  }

  String get personalPsychologist {
    switch (locale.languageCode) {
      case 'uk':
        return 'Песональний психолог 24/7';
      case 'en':
        return 'Personal psychologist 24/7';
      case 'es':
        return 'Psicólogo personal 24/7';
      case 'hi':
        return 'व्यक्तिगत मनोवैज्ञानिक 24/7';
      case 'zh':
        return '个人心理学家 24/7';
      default:
        return 'Песональний психолог 24/7';
    }
  }

  String get aiPsychologyNewGeneration {
    switch (locale.languageCode) {
      case 'uk':
        return 'AI-психологія нового покоління.\n';
      case 'en':
        return 'AI psychology of the new generation.\n';
      case 'es':
        return 'Psicología IA de la nueva generación.\n';
      case 'hi':
        return 'नई पीढ़ी की AI मनोविज्ञान।\n';
      case 'zh':
        return '新一代AI心理学。\n';
      default:
        return 'AI-психологія нового покоління.\n';
    }
  }

  String get createdInUkraine {
    switch (locale.languageCode) {
      case 'uk':
        return 'Створено в Україні під час війни — для тих, хто тримає світло всередині.';
      case 'en':
        return 'Created in Ukraine during the war — for those who keep the light inside.';
      case 'es':
        return 'Creado en Ucrania durante la guerra — para aquellos que mantienen la luz dentro.';
      case 'hi':
        return 'युद्ध के दौरान यूक्रेन में बनाया गया — उनके लिए जो अंदर प्रकाश रखते हैं।';
      case 'zh':
        return '在战争期间在乌克兰创建——为那些内心保持光明的人。';
      default:
        return 'Створено в Україні під час війни — для тих, хто тримає світло всередині.';
    }
  }

  // Chat
  String get chatWelcomeMessage {
    switch (locale.languageCode) {
      case 'uk':
        return 'Привіт! Я - AI психолог. Розкажи, що тебе турбує, і я постараюся допомогти.';
      case 'en':
        return 'Hello! I am an AI psychologist. Tell me what worries you, and I will try to help.';
      case 'es':
        return '¡Hola! Soy un psicólogo IA. Cuéntame qué te preocupa y trataré de ayudarte.';
      case 'hi':
        return 'नमस्ते! मैं एक AI मनोवैज्ञानिक हूं। मुझे बताएं कि आपको क्या परेशान करता है, और मैं मदद करने की कोशिश करूंगा।';
      case 'zh':
        return '你好！我是AI心理学家。告诉我什么困扰着你，我会尽力帮助你。';
      default:
        return 'Привіт! Я - AI психолог. Розкажи, що тебе турбує, і я постараюся допомогти.';
    }
  }

  String get startOver {
    switch (locale.languageCode) {
      case 'uk':
        return 'Почати заново';
      case 'en':
        return 'Start over';
      case 'es':
        return 'Empezar de nuevo';
      case 'hi':
        return 'फिर से शुरू करें';
      case 'zh':
        return '重新开始';
      default:
        return 'Почати заново';
    }
  }

  // Test intro
  String get testIntroInvite {
    switch (locale.languageCode) {
      case 'uk':
        return 'Запрошуємо пройти\n';
      case 'en':
        return 'We invite you to take\n';
      case 'es':
        return 'Te invitamos a realizar\n';
      case 'hi':
        return 'हम आपको लेने के लिए आमंत्रित करते हैं\n';
      case 'zh':
        return '我们邀请您参加\n';
      default:
        return 'Запрошуємо пройти\n';
    }
  }

  String get psychotypeTest {
    switch (locale.languageCode) {
      case 'uk':
        return '«Тест на психотип»';
      case 'en':
        return '"Psychotype Test"';
      case 'es':
        return '"Test de Psicotipo"';
      case 'hi':
        return '"मनोवैज्ञानिक प्रकार परीक्षण"';
      case 'zh':
        return '"心理类型测试"';
      default:
        return '«Тест на психотип»';
    }
  }

  String get chooseEmoji {
    switch (locale.languageCode) {
      case 'uk':
        return 'Обери смайлик, що найбільше відповідає твоїм відчуттям:';
      case 'en':
        return 'Choose the emoji that best matches your feelings:';
      case 'es':
        return 'Elige el emoji que mejor coincida con tus sentimientos:';
      case 'hi':
        return 'वह इमोजी चुनें जो आपकी भावनाओं से सबसे अधिक मेल खाता है:';
      case 'zh':
        return '选择最符合您感受的表情符号：';
      default:
        return 'Обери смайлик, що найбільше відповідає твоїм відчуттям:';
    }
  }

  String get notAboutMe {
    switch (locale.languageCode) {
      case 'uk':
        return '=   зовсім не про мене';
      case 'en':
        return '=   not about me at all';
      case 'es':
        return '=   nada sobre mí';
      case 'hi':
        return '=   मेरे बारे में बिल्कुल नहीं';
      case 'zh':
        return '=   完全不是我';
      default:
        return '=   зовсім не про мене';
    }
  }

  String get ratherNot {
    switch (locale.languageCode) {
      case 'uk':
        return '=   скоріше ні';
      case 'en':
        return '=   rather not';
      case 'es':
        return '=   más bien no';
      case 'hi':
        return '=   बल्कि नहीं';
      case 'zh':
        return '=   不太是';
      default:
        return '=   скоріше ні';
    }
  }

  String get partially {
    switch (locale.languageCode) {
      case 'uk':
        return '=   частково';
      case 'en':
        return '=   partially';
      case 'es':
        return '=   parcialmente';
      case 'hi':
        return '=   आंशिक रूप से';
      case 'zh':
        return '=   部分';
      default:
        return '=   частково';
    }
  }

  String get fullyAboutMe {
    switch (locale.languageCode) {
      case 'uk':
        return '=   повністю про мене';
      case 'en':
        return '=   fully about me';
      case 'es':
        return '=   completamente sobre mí';
      case 'hi':
        return '=   पूरी तरह से मेरे बारे में';
      case 'zh':
        return '=   完全是我';
      default:
        return '=   повністю про мене';
    }
  }

  // Auth and registration
  String get email {
    switch (locale.languageCode) {
      case 'uk':
        return 'Email';
      case 'en':
        return 'Email';
      case 'es':
        return 'Correo electrónico';
      case 'hi':
        return 'ईमेल';
      case 'zh':
        return '电子邮件';
      default:
        return 'Email';
    }
  }

  String get password {
    switch (locale.languageCode) {
      case 'uk':
        return 'Пароль';
      case 'en':
        return 'Password';
      case 'es':
        return 'Contraseña';
      case 'hi':
        return 'पासवर्ड';
      case 'zh':
        return '密码';
      default:
        return 'Пароль';
    }
  }

  String get enterEmail {
    switch (locale.languageCode) {
      case 'uk':
        return 'Введіть вашу електронну адресу';
      case 'en':
        return 'Enter your email address';
      case 'es':
        return 'Ingresa tu dirección de correo electrónico';
      case 'hi':
        return 'अपना ईमेल पता दर्ज करें';
      case 'zh':
        return '输入您的电子邮件地址';
      default:
        return 'Введіть вашу електронну адресу';
    }
  }

  String get enterPassword {
    switch (locale.languageCode) {
      case 'uk':
        return 'Введіть пароль';
      case 'en':
        return 'Enter password';
      case 'es':
        return 'Ingresa la contraseña';
      case 'hi':
        return 'पासवर्ड दर्ज करें';
      case 'zh':
        return '输入密码';
      default:
        return 'Введіть пароль';
    }
  }

  String get fillAllFields {
    switch (locale.languageCode) {
      case 'uk':
        return 'Будь ласка, заповніть всі поля';
      case 'en':
        return 'Please fill in all fields';
      case 'es':
        return 'Por favor completa todos los campos';
      case 'hi':
        return 'कृपया सभी फ़ील्ड भरें';
      case 'zh':
        return '请填写所有字段';
      default:
        return 'Будь ласка, заповніть всі поля';
    }
  }

  String get forgotPassword {
    switch (locale.languageCode) {
      case 'uk':
        return 'Забули пароль?';
      case 'en':
        return 'Forgot password?';
      case 'es':
        return '¿Olvidaste tu contraseña?';
      case 'hi':
        return 'पासवर्ड भूल गए?';
      case 'zh':
        return '忘记密码？';
      default:
        return 'Забули пароль?';
    }
  }

  String get passwordRecovery {
    switch (locale.languageCode) {
      case 'uk':
        return 'Відновлення пароля';
      case 'en':
        return 'Password recovery';
      case 'es':
        return 'Recuperación de contraseña';
      case 'hi':
        return 'पासवर्ड पुनर्प्राप्ति';
      case 'zh':
        return '密码恢复';
      default:
        return 'Відновлення пароля';
    }
  }

  String get passwordRecoveryDescription {
    switch (locale.languageCode) {
      case 'uk':
        return 'Введіть вашу електронну адресу, і ми надішлемо вам посилання для відновлення пароля на вашу електронну пошту';
      case 'en':
        return 'Enter your email address and we will send you a password recovery link to your email';
      case 'es':
        return 'Ingresa tu dirección de correo electrónico y te enviaremos un enlace de recuperación de contraseña a tu correo';
      case 'hi':
        return 'अपना ईमेल पता दर्ज करें और हम आपको आपके ईमेल पर पासवर्ड पुनर्प्राप्ति लिंक भेजेंगे';
      case 'zh':
        return '输入您的电子邮件地址，我们将向您的电子邮件发送密码恢复链接';
      default:
        return 'Введіть вашу електронну адресу, і ми надішлемо вам посилання для відновлення пароля на вашу електронну пошту';
    }
  }

  String get rememberPassword {
    switch (locale.languageCode) {
      case 'uk':
        return 'Згадали пароль?';
      case 'en':
        return 'Remembered password?';
      case 'es':
        return '¿Recordaste tu contraseña?';
      case 'hi':
        return 'पासवर्ड याद आया?';
      case 'zh':
        return '想起密码了？';
      default:
        return 'Згадали пароль?';
    }
  }

  String get passwordRecoveryLinkSent {
    switch (locale.languageCode) {
      case 'uk':
        return 'Посилання для відновлення пароля надіслано на вашу електронну адресу. Перевірте пошту та перейдіть за посиланням.';
      case 'en':
        return 'Password recovery link has been sent to your email address. Check your email and follow the link.';
      case 'es':
        return 'Se ha enviado un enlace de recuperación de contraseña a tu dirección de correo electrónico. Revisa tu correo y sigue el enlace.';
      case 'hi':
        return 'पासवर्ड पुनर्प्राप्ति लिंक आपके ईमेल पते पर भेजा गया है। अपना ईमेल जांचें और लिंक का पालन करें।';
      case 'zh':
        return '密码恢复链接已发送到您的电子邮件地址。检查您的电子邮件并点击链接。';
      default:
        return 'Посилання для відновлення пароля надіслано на вашу електронну адресу. Перевірте пошту та перейдіть за посиланням.';
    }
  }

  String get noAccount {
    switch (locale.languageCode) {
      case 'uk':
        return 'Немає аккаунту?';
      case 'en':
        return 'No account?';
      case 'es':
        return '¿No tienes cuenta?';
      case 'hi':
        return 'खाता नहीं है?';
      case 'zh':
        return '没有账户？';
      default:
        return 'Немає аккаунту?';
    }
  }

  String get alreadyHaveAccount {
    switch (locale.languageCode) {
      case 'uk':
        return 'Вже є акаунт?';
      case 'en':
        return 'Already have an account?';
      case 'es':
        return '¿Ya tienes una cuenta?';
      case 'hi':
        return 'पहले से खाता है?';
      case 'zh':
        return '已有账户？';
      default:
        return 'Вже є акаунт?';
    }
  }

  String get or {
    switch (locale.languageCode) {
      case 'uk':
        return 'або';
      case 'en':
        return 'or';
      case 'es':
        return 'o';
      case 'hi':
        return 'या';
      case 'zh':
        return '或';
      default:
        return 'або';
    }
  }

  // Profile
  String get testsPassed {
    switch (locale.languageCode) {
      case 'uk':
        return 'Пройдено тестів';
      case 'en':
        return 'Tests passed';
      case 'es':
        return 'Pruebas completadas';
      case 'hi':
        return 'परीक्षण पास किए';
      case 'zh':
        return '已通过测试';
      default:
        return 'Пройдено тестів';
    }
  }

  String get savedSessions {
    switch (locale.languageCode) {
      case 'uk':
        return 'Збережених сесій';
      case 'en':
        return 'Saved sessions';
      case 'es':
        return 'Sesiones guardadas';
      case 'hi':
        return 'सहेजे गए सत्र';
      case 'zh':
        return '已保存的会话';
      default:
        return 'Збережених сесій';
    }
  }

  String get daysOfUsage {
    switch (locale.languageCode) {
      case 'uk':
        return 'Днів використання';
      case 'en':
        return 'Days of usage';
      case 'es':
        return 'Días de uso';
      case 'hi':
        return 'उपयोग के दिन';
      case 'zh':
        return '使用天数';
      default:
        return 'Днів використання';
    }
  }

  String get subscription {
    switch (locale.languageCode) {
      case 'uk':
        return 'Підписка';
      case 'en':
        return 'Subscription';
      case 'es':
        return 'Suscripción';
      case 'hi':
        return 'सदस्यता';
      case 'zh':
        return '订阅';
      default:
        return 'Підписка';
    }
  }

  String get socialMedia {
    switch (locale.languageCode) {
      case 'uk':
        return 'Ми в соціальних мережах';
      case 'en':
        return 'We on social networks';
      case 'es':
        return 'Nosotros en las redes sociales';
      case 'hi':
        return 'सोशल नेटवर्क पर हम';
      case 'zh':
        return '我们在社交媒体上';
      default:
        return 'Ми в соціальних мережах';
    }
  }

  String get socialMediaDescription {
    switch (locale.languageCode) {
      case 'uk':
        return 'Ми в соцмережах — слідкуйте за нами, щоб бути в курсі всього найцікавішого';
      case 'en':
        return 'We are on social networks — follow us to stay updated on all the most interesting things';
      case 'es':
        return 'Estamos en las redes sociales — síguenos para estar al día de todo lo más interesante';
      case 'hi':
        return 'हम सोशल नेटवर्क पर हैं — सभी सबसे दिलचस्प चीजों के बारे में अपडेट रहने के लिए हमें फॉलो करें';
      case 'zh':
        return '我们在社交媒体上 — 关注我们以了解所有最有趣的事情';
      default:
        return 'Ми в соцмережах — слідкуйте за нами, щоб бути в курсі всього найцікавішого';
    }
  }

  String get language {
    switch (locale.languageCode) {
      case 'uk':
        return 'Мова';
      case 'en':
        return 'Language';
      case 'es':
        return 'Idioma';
      case 'hi':
        return 'भाषा';
      case 'zh':
        return '语言';
      default:
        return 'Мова';
    }
  }

  String get privacyPolicy {
    switch (locale.languageCode) {
      case 'uk':
        return 'Політика конфіденційності';
      case 'en':
        return 'Privacy policy';
      case 'es':
        return 'Política de privacidad';
      case 'hi':
        return 'गोपनीयता नीति';
      case 'zh':
        return '隐私政策';
      default:
        return 'Політика конфіденційності';
    }
  }

  String get agreeToPrivacyPolicy {
    switch (locale.languageCode) {
      case 'uk':
        return 'Продовжуючи, ви погоджуєтесь з нашою';
      case 'en':
        return 'By continuing, you agree to our';
      case 'es':
        return 'Al continuar, aceptas nuestra';
      case 'hi':
        return 'जारी रखकर, आप हमारी सहमति देते हैं';
      case 'zh':
        return '继续即表示您同意我们的';
      default:
        return 'Продовжуючи, ви погоджуєтесь з нашою';
    }
  }

  String get support {
    switch (locale.languageCode) {
      case 'uk':
        return 'Підтримка';
      case 'en':
        return 'Support';
      case 'es':
        return 'Soporte';
      case 'hi':
        return 'सहायता';
      case 'zh':
        return '支持';
      default:
        return 'Підтримка';
    }
  }

  String get logout {
    switch (locale.languageCode) {
      case 'uk':
        return 'Вийти';
      case 'en':
        return 'Logout';
      case 'es':
        return 'Cerrar sesión';
      case 'hi':
        return 'लॉग आउट';
      case 'zh':
        return '退出';
      default:
        return 'Вийти';
    }
  }

  String get logoutTitle {
    switch (locale.languageCode) {
      case 'uk':
        return 'Вийти з акаунту';
      case 'en':
        return 'Logout from account';
      case 'es':
        return 'Cerrar sesión de la cuenta';
      case 'hi':
        return 'खाते से लॉग आउट करें';
      case 'zh':
        return '退出账户';
      default:
        return 'Вийти з акаунту';
    }
  }

  String get logoutConfirm {
    switch (locale.languageCode) {
      case 'uk':
        return 'Ви впевнені, що хочете вийти з акаунту?';
      case 'en':
        return 'Are you sure you want to logout from your account?';
      case 'es':
        return '¿Estás seguro de que quieres cerrar sesión de tu cuenta?';
      case 'hi':
        return 'क्या आप वाकई अपने खाते से लॉग आउट करना चाहते हैं?';
      case 'zh':
        return '您确定要退出账户吗？';
      default:
        return 'Ви впевнені, що хочете вийти з акаунту?';
    }
  }

  String get cancel {
    switch (locale.languageCode) {
      case 'uk':
        return 'Скасувати';
      case 'en':
        return 'Cancel';
      case 'es':
        return 'Cancelar';
      case 'hi':
        return 'रद्द करें';
      case 'zh':
        return '取消';
      default:
        return 'Скасувати';
    }
  }

  String get errorSelectingPhoto {
    switch (locale.languageCode) {
      case 'uk':
        return 'Помилка при виборі фото';
      case 'en':
        return 'Error selecting photo';
      case 'es':
        return 'Error al seleccionar foto';
      case 'hi':
        return 'फोटो चुनने में त्रुटि';
      case 'zh':
        return '选择照片时出错';
      default:
        return 'Помилка при виборі фото';
    }
  }

  String get failedToOpenLink {
    switch (locale.languageCode) {
      case 'uk':
        return 'Не вдалося відкрити посилання';
      case 'en':
        return 'Failed to open link';
      case 'es':
        return 'No se pudo abrir el enlace';
      case 'hi':
        return 'लिंक खोलने में विफल';
      case 'zh':
        return '无法打开链接';
      default:
        return 'Не вдалося відкрити посилання';
    }
  }

  String get failedToOpenEmail {
    switch (locale.languageCode) {
      case 'uk':
        return 'Не вдалося відкрити поштовий клієнт';
      case 'en':
        return 'Failed to open email client';
      case 'es':
        return 'No se pudo abrir el cliente de correo';
      case 'hi':
        return 'ईमेल क्लाइंट खोलने में विफल';
      case 'zh':
        return '无法打开邮件客户端';
      default:
        return 'Не вдалося відкрити поштовий клієнт';
    }
  }

  // Paywall translations
  String get paywallMonthlyTitle {
    switch (locale.languageCode) {
      case 'uk':
        return 'Місячна';
      case 'en':
        return 'Monthly';
      case 'es':
        return 'Mensual';
      case 'hi':
        return 'मासिक';
      case 'zh':
        return '月度';
      default:
        return 'Місячна';
    }
  }

  String get paywallSixMonthTitle {
    switch (locale.languageCode) {
      case 'uk':
        return 'Піврічна';
      case 'en':
        return '6 Months';
      case 'es':
        return '6 Meses';
      case 'hi':
        return '6 महीने';
      case 'zh':
        return '6个月';
      default:
        return 'Піврічна';
    }
  }

  String get paywallYearlyTitle {
    switch (locale.languageCode) {
      case 'uk':
        return 'Річна';
      case 'en':
        return 'Yearly';
      case 'es':
        return 'Anual';
      case 'hi':
        return 'वार्षिक';
      case 'zh':
        return '年度';
      default:
        return 'Річна';
    }
  }

  String get paywallMonthlyPeriod {
    switch (locale.languageCode) {
      case 'uk':
        return '1 міс.';
      case 'en':
        return '1 mo.';
      case 'es':
        return '1 mes';
      case 'hi':
        return '1 महीना';
      case 'zh':
        return '1个月';
      default:
        return '1 міс.';
    }
  }

  String get paywallSixMonthPeriod {
    switch (locale.languageCode) {
      case 'uk':
        return '6 міс.';
      case 'en':
        return '6 mo.';
      case 'es':
        return '6 meses';
      case 'hi':
        return '6 महीने';
      case 'zh':
        return '6个月';
      default:
        return '6 міс.';
    }
  }

  String get paywallYearlyPeriod {
    switch (locale.languageCode) {
      case 'uk':
        return '1 рік';
      case 'en':
        return '1 year';
      case 'es':
        return '1 año';
      case 'hi':
        return '1 वर्ष';
      case 'zh':
        return '1年';
      default:
        return '1 рік';
    }
  }

  String get paywallMonthlyDescription {
    switch (locale.languageCode) {
      case 'uk':
        return 'Щомісячна підписка, без ліміту';
      case 'en':
        return 'Monthly subscription, unlimited';
      case 'es':
        return 'Suscripción mensual, ilimitada';
      case 'hi':
        return 'मासिक सदस्यता, असीमित';
      case 'zh':
        return '月度订阅，无限制';
      default:
        return 'Щомісячна підписка, без ліміту';
    }
  }

  String get paywallSixMonthDescription {
    switch (locale.languageCode) {
      case 'uk':
        return 'Піврічна підписка, без ліміту';
      case 'en':
        return '6-month subscription, unlimited';
      case 'es':
        return 'Suscripción de 6 meses, ilimitada';
      case 'hi':
        return '6 महीने की सदस्यता, असीमित';
      case 'zh':
        return '6个月订阅，无限制';
      default:
        return 'Піврічна підписка, без ліміту';
    }
  }

  String get paywallYearlyDescription {
    switch (locale.languageCode) {
      case 'uk':
        return 'Річна підписка, без ліміту';
      case 'en':
        return 'Yearly subscription, unlimited';
      case 'es':
        return 'Suscripción anual, ilimitada';
      case 'hi':
        return 'वार्षिक सदस्यता, असीमित';
      case 'zh':
        return '年度订阅，无限制';
      default:
        return 'Річна підписка, без ліміту';
    }
  }

  String get paywallBuyButton {
    switch (locale.languageCode) {
      case 'uk':
        return 'Придбати';
      case 'en':
        return 'Buy';
      case 'es':
        return 'Comprar';
      case 'hi':
        return 'खरीदें';
      case 'zh':
        return '购买';
      default:
        return 'Придбати';
    }
  }

  String get restorePurchases {
    switch (locale.languageCode) {
      case 'uk':
        return 'Відновити покупки';
      case 'en':
        return 'Restore purchases';
      case 'es':
        return 'Restaurar compras';
      case 'hi':
        return 'खरीदारी पुनर्स्थापित करें';
      case 'zh':
        return '恢复购买';
      default:
        return 'Відновити покупки';
    }
  }

  String get restoreSuccess {
    switch (locale.languageCode) {
      case 'uk':
        return 'Підписку успішно відновлено!';
      case 'en':
        return 'Subscription successfully restored!';
      case 'es':
        return '¡Suscripción restaurada con éxito!';
      case 'hi':
        return 'सदस्यता सफलतापूर्वक पुनर्स्थापित की गई!';
      case 'zh':
        return '订阅已成功恢复！';
      default:
        return 'Підписку успішно відновлено!';
    }
  }

  String get restoreNoSubscription {
    switch (locale.languageCode) {
      case 'uk':
        return 'Активних підписок не знайдено';
      case 'en':
        return 'No active subscriptions found';
      case 'es':
        return 'No se encontraron suscripciones activas';
      case 'hi':
        return 'कोई सक्रिय सदस्यता नहीं मिली';
      case 'zh':
        return '未找到有效订阅';
      default:
        return 'Активних підписок не знайдено';
    }
  }

  String get image {
    switch (locale.languageCode) {
      case 'uk':
        return 'Зображення';
      case 'en':
        return 'Image';
      case 'es':
        return 'Imagen';
      case 'hi':
        return 'छवि';
      case 'zh':
        return '图片';
      default:
        return 'Зображення';
    }
  }

  String get file {
    switch (locale.languageCode) {
      case 'uk':
        return 'Файл';
      case 'en':
        return 'File';
      case 'es':
        return 'Archivo';
      case 'hi':
        return 'फ़ाइल';
      case 'zh':
        return '文件';
      default:
        return 'Файл';
    }
  }

  String get imageLabel {
    switch (locale.languageCode) {
      case 'uk':
        return '[Зображення]';
      case 'en':
        return '[Image]';
      case 'es':
        return '[Imagen]';
      case 'hi':
        return '[छवि]';
      case 'zh':
        return '[图片]';
      default:
        return '[Зображення]';
    }
  }

  String get microphonePermissionDenied {
    switch (locale.languageCode) {
      case 'uk':
        return 'Дозвіл на використання мікрофона відхилено. Відкрийте налаштування додатку для надання доступу.';
      case 'en':
        return 'Microphone permission denied. Open app settings to grant access.';
      case 'es':
        return 'Permiso de micrófono denegado. Abra la configuración de la aplicación para otorgar acceso.';
      case 'hi':
        return 'माइक्रोफ़ोन अनुमति अस्वीकृत। पहुंच प्रदान करने के लिए ऐप सेटिंग्स खोलें।';
      case 'zh':
        return '麦克风权限被拒绝。打开应用设置以授予访问权限。';
      default:
        return 'Дозвіл на використання мікрофона відхилено. Відкрийте налаштування додатку для надання доступу.';
    }
  }

  String get settings {
    switch (locale.languageCode) {
      case 'uk':
        return 'Налаштування';
      case 'en':
        return 'Settings';
      case 'es':
        return 'Configuración';
      case 'hi':
        return 'सेटिंग्स';
      case 'zh':
        return '设置';
      default:
        return 'Налаштування';
    }
  }

  String get microphonePermissionRequired {
    switch (locale.languageCode) {
      case 'uk':
        return 'Необхідний дозвіл на використання мікрофона';
      case 'en':
        return 'Microphone permission required';
      case 'es':
        return 'Se requiere permiso de micrófono';
      case 'hi':
        return 'माइक्रोफ़ोन अनुमति आवश्यक';
      case 'zh':
        return '需要麦克风权限';
      default:
        return 'Необхідний дозвіл на використання мікрофона';
    }
  }

  String get chat {
    switch (locale.languageCode) {
      case 'uk':
        return 'Чат';
      case 'en':
        return 'Chat';
      case 'es':
        return 'Chat';
      case 'hi':
        return 'चैट';
      case 'zh':
        return '聊天';
      default:
        return 'Чат';
    }
  }

  String get saved {
    switch (locale.languageCode) {
      case 'uk':
        return 'Збережено';
      case 'en':
        return 'Saved';
      case 'es':
        return 'Guardado';
      case 'hi':
        return 'सहेजा गया';
      case 'zh':
        return '已保存';
      default:
        return 'Збережено';
    }
  }

  String get voiceMessage {
    switch (locale.languageCode) {
      case 'uk':
        return 'Голосове повідомлення';
      case 'en':
        return 'Voice message';
      case 'es':
        return 'Mensaje de voz';
      case 'hi':
        return 'वॉइस मैसेज';
      case 'zh':
        return '语音消息';
      default:
        return 'Голосове повідомлення';
    }
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['uk', 'en', 'es', 'hi', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final supported = ['uk', 'en', 'es', 'hi', 'zh'];
    final effectiveLocale = supported.contains(locale.languageCode)
        ? locale
        : const Locale('en');
    return AppLocalizations(effectiveLocale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
