import 'package:flutter/material.dart';

class AppText {
  // Font styles
  static const TextStyle headingStyle = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.bold, // Bold for headers
    fontSize: 24,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.normal, // Normal for text
    fontSize: 16,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w500, // Medium for buttons
    fontSize: 16,
  );

  // Adaptive styles for different screen sizes
  static TextStyle getHeadingStyle(double fontSize) => headingStyle.copyWith(fontSize: fontSize);
  static TextStyle getBodyStyle(double fontSize) => bodyStyle.copyWith(fontSize: fontSize);
  static TextStyle getButtonStyle(double fontSize) => buttonStyle.copyWith(fontSize: fontSize);
  // Headers
  static const String appTitle = 'AI Психолог';
  static const String welcomeTitle = 'Привіт!';
  static const String registrationTitle = 'Реєстрація';
  static const String testTitle = 'Психологічний тест';

  // Buttons
  static const String tryTogether = 'Спробуємо разом';
  static const String authorize = 'Авторизуватися';
  static const String register = 'Зареєструватися';
  static const String login = 'Увійти';
  static const String continueText = 'Продовжити';
  static const String startTest = 'Пройти тест';
  static const String next = 'Далі';
  static const String share = 'Поділитися';
  static const String save = 'Зберегти';
  static const String wantDeeper = 'Хочу глибше';
  static const String goBack = 'Повернутись';
  static const String tryAgain = 'Спробувати ще';
  static const String endSession = 'Завершити сесію';
  static const String showReport = 'Показати звіт';
  static const String toMainPage = 'На головну сторінку';
  static const String startConversation = 'Почати розмову';
  static const String start = 'Почати';
  static const String goToReport = 'Перейти до звіту';
  static const String premiumTitle = 'Розблокуй повний доступ';
  static const String activateFree = 'Активувати безкоштовно';

  // Test questions
  static const String testIntroTitle = 'Запропоновано пройти «Тест на самопізнання»';
  static const String testIntroDescription =
      'Цей тест допоможе вам краще зрозуміти себе та свій психологічний тип. Відповідайте чесно на кожне питання.';

  static const List<String> testQuestions = [
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

  // Emoji scale
  static const List<String> emojiScale = ['😞', '😐', '😊', '😄'];
  static const List<String> emojiLabels = ['Зовсім ні', 'Частково', 'Часто', 'Дуже часто'];

  // Test results
  static const Map<String, String> psychotypeResults = {
    'analyst': 'Аналітик',
    'balance': 'Баланс',
    'social': 'Соціальний',
    'introvert_analyst': 'Інтроверт-Аналітик',
  };

  // Chat
  static const String chatPlaceholder = 'Напишіть повідомлення...';
  static const String sessionCompleted = 'Сесію завершено. Дякую за довіру! Приходь ще!';
  static const String alreadyTakenTest = 'Ви вже пройшли тест?';

  // Premium features
  static const List<String> premiumFeatures = [
    'Отримаєш предсказання...',
    'Персональний психолог 24/7',
    'Щоденні вправи',
    'Доступ до всіх тестів',
    'Можна скасувати будь-коли',
  ];
}
