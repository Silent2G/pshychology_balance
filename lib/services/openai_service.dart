import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'remote_config_service.dart';

class OpenAIService {
  final RemoteConfigService _remoteConfigService = RemoteConfigService();
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _whisperUrl = 'https://api.openai.com/v1/audio/transcriptions';

  String get _apiKey => _remoteConfigService.getOpenAIApiKey();

  // Test results analysis
  Future<Map<String, dynamic>> analyzeTestResults(List<int> answers, String languageCode) async {
    try {
      final prompt = _buildTestAnalysisPrompt(answers, languageCode);

      final systemPrompt = _buildTestSystemPrompt(languageCode);

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_apiKey'},
            body: jsonEncode({
              'model': 'gpt-4o-mini',
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.7,
              'max_tokens': 1500,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Таймаут запиту до OpenAI API');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];

        // Parse JSON from response with error handling
        try {
          // Extract JSON from markdown block if present
          String jsonContent = content.trim();

          // Remove markdown blocks
          if (jsonContent.startsWith('```json')) {
            jsonContent = jsonContent.substring(7);
          } else if (jsonContent.startsWith('```')) {
            jsonContent = jsonContent.substring(3);
          }

          if (jsonContent.endsWith('```')) {
            jsonContent = jsonContent.substring(0, jsonContent.length - 3);
          }

          jsonContent = jsonContent.trim();

          // If JSON is truncated, try to fix it
          if (!jsonContent.endsWith('}') && !jsonContent.endsWith(']')) {
            print('JSON обрезан, пытаемся починить...');
            // Find last opening bracket of recommendations array
            final lastBracketIndex = jsonContent.lastIndexOf('[');
            if (lastBracketIndex != -1) {
              // Find all complete recommendation strings
              final recommendationsStart = jsonContent.indexOf('"recommendations"');
              if (recommendationsStart != -1) {
                // Truncate to last complete recommendation
                final lastQuoteIndex = jsonContent.lastIndexOf('"', jsonContent.length - 1);
                if (lastQuoteIndex > lastBracketIndex) {
                  jsonContent = jsonContent.substring(0, lastQuoteIndex + 1);
                  jsonContent += '\n  ]\n}';
                }
              }
            }
          }

          print('Спроба парсингу JSON: $jsonContent');
          final result = jsonDecode(jsonContent);
          return result;
        } catch (jsonError) {
          print('Помилка парсингу JSON від OpenAI: $jsonError');
          print('Відповідь OpenAI: $content');

          // Return fallback result if JSON doesn't parse
          return {
            'psychotype': 'Аналітик',
            'description':
                'Ваші відповіді показують збалансований підхід до життя. Ви поєднуєте логічне мислення з емоційною чуттєвістю.',
            'recommendations': [
              'Продовжуйте розвивати свою інтуїцію',
              'Знаходьте час для самоаналізу',
              'Практикуйте активне слухання',
              'Розвивайте емоційний інтелект',
            ],
          };
        }
      } else {
        print('OpenAI API помилка: ${response.statusCode} - ${response.body}');
        throw Exception('OpenAI API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Помилка аналізу тесту: $e');
    }
  }

  String _buildTestSystemPrompt(String languageCode) {
    final basePrompt = _remoteConfigService.getTestSystemPrompt();

    // Determine response language
    String languageInstruction;
    switch (languageCode) {
      case 'en':
        languageInstruction =
            'IMPORTANT: Write your response in English. All text (psychotype name, description, recommendations) must be in English.';
        break;
      case 'es':
        languageInstruction =
            'IMPORTANTE: Escribe tu respuesta en español. Todo el texto (nombre del psicotipo, descripción, recomendaciones) debe estar en español.';
        break;
      case 'hi':
        languageInstruction =
            'महत्वपूर्ण: अपना उत्तर हिंदी में लिखें। सभी पाठ (मनोवैज्ञानिक प्रकार का नाम, विवरण, सुझाव) हिंदी में होना चाहिए।';
        break;
      case 'zh':
        languageInstruction = '重要：请用中文回复。所有文本（心理类型名称、描述、建议）必须使用中文。';
        break;
      default:
        languageInstruction =
            'ВАЖЛИВО: Пиши українською мовою. Весь текст (назва психотипу, опис, поради) має бути українською.';
    }

    // Remove old language instruction and add new one
    String prompt = basePrompt.replaceAll(RegExp(r'- Пиши українською мовою'), languageInstruction);
    if (!prompt.contains(languageInstruction)) {
      // Try to find and replace in "Important:" block
      prompt = prompt.replaceAll(RegExp(r'Важливо:\s*- Пиши українською мовою'), 'Важливо:\n$languageInstruction');
      if (!prompt.contains(languageInstruction)) {
        // If not found, add to end
        prompt = prompt.replaceAll(RegExp(r'Важливо:\s*$'), 'Важливо:\n$languageInstruction');
        if (!prompt.contains(languageInstruction)) {
          prompt += '\n\n$languageInstruction';
        }
      }
    }

    return prompt;
  }

  String _buildTestAnalysisPrompt(List<int> answers, String languageCode) {
    // Import localization for questions
    // Since we're in service, use hardcoded values with language check
    final questions = _getQuestionsForLanguage(languageCode);
    final emojiLabels = _getEmojiLabelsForLanguage(languageCode);
    final analyzeText = _getAnalyzeTextForLanguage(languageCode);
    final provideText = _getProvideTextForLanguage(languageCode);

    StringBuffer prompt = StringBuffer();
    prompt.writeln('$analyzeText\n');

    for (int i = 0; i < answers.length; i++) {
      prompt.writeln('${i + 1}. ${questions[i]}');
      prompt.writeln('   ${emojiLabels[answers[i]]}\n');
    }

    prompt.writeln('\n$provideText');

    return prompt.toString();
  }

  List<String> _getQuestionsForLanguage(String languageCode) {
    switch (languageCode) {
      case 'en':
        return [
          'I easily keep a cool head in difficult situations',
          'I often act based on logic, not emotions',
          'I deeply experience emotions — both my own and others\'',
          'I easily start conversations with strangers',
          'I need a lot of time for independent reflection',
          'I like to analyze why people behave in a certain way',
          'I make good rational decisions even under pressure',
          'I can cry or be moved by a movie or conversation',
          'I feel discomfort from communication in a group',
          'I often think about the meaning of life, deep things',
        ];
      case 'es':
        return [
          'Mantengo fácilmente la calma en situaciones difíciles',
          'A menudo actúo basándome en la lógica, no en emociones',
          'Experimentó profundamente las emociones — tanto las mías como las de otros',
          'Inicio fácilmente conversaciones con desconocidos',
          'Necesito mucho tiempo para la reflexión independiente',
          'Me gusta analizar por qué las personas se comportan de cierta manera',
          'Tomo buenas decisiones racionales incluso bajo presión',
          'Puedo llorar o conmoverme por una película o conversación',
          'Siento incomodidad por la comunicación en grupo',
          'A menudo pienso en el significado de la vida, cosas profundas',
        ];
      case 'hi':
        return [
          'मुझे मुश्किल स्थितियों में आसानी से शांत रहना आता है',
          'मैं अक्सर तर्क पर काम करता हूं, भावनाओं पर नहीं',
          'मैं गहराई से भावनाओं को अनुभव करता हूं — अपनी और दूसरों की',
          'मैं आसानी से अजनबियों के साथ बातचीत शुरू करता हूं',
          'मुझे स्वतंत्र चिंतन के लिए बहुत समय चाहिए',
          'मुझे विश्लेषण करना पसंद है कि लोग क्यों एक निश्चित तरीके से व्यवहार करते हैं',
          'मैं दबाव में भी अच्छे तर्कसंगत निर्णय लेता हूं',
          'मैं एक फिल्म या बातचीत से रो सकता हूं या भावुक हो सकता हूं',
          'मुझे समूह में संचार से असुविधा महसूस होती है',
          'मैं अक्सर जीवन के अर्थ, गहरी बातों के बारे में सोचता हूं',
        ];
      case 'zh':
        return [
          '在困难的情况下我很容易保持冷静',
          '我经常基于逻辑而不是情感行事',
          '我深刻体验情感——无论是自己的还是他人的',
          '我很容易与陌生人开始对话',
          '我需要大量时间进行独立思考',
          '我喜欢分析人们为什么以某种方式行事',
          '即使在压力下我也能做出良好的理性决定',
          '我可能会因为电影或对话而哭泣或感动',
          '我在群体中交流时感到不适',
          '我经常思考生活的意义，深刻的事情',
        ];
      default: // uk
        return [
          'Мені легко тримати холодний розум у складних ситуаціях',
          'Я часто керуюсь логікою, а не емоціями',
          'Я глибоко переживаю емоції — як свої, так і чужі',
          'Я легко починаю спілкування з незнайомими людьми',
          'Мені потрібно багато часу на самостійні роздуми',
          'Я люблю аналізувати, чому люди поводяться певним чином',
          'Я добре приймаю раціональні рішення навіть під тиском',
          'Я можу заплакати або розчулитись від фільму чи розмови',
          'Я відчуваю дискомфорт від спілкування в компанії',
          'Я часто замислююсь про сенс життя, глибокі речі',
        ];
    }
  }

  List<String> _getEmojiLabelsForLanguage(String languageCode) {
    switch (languageCode) {
      case 'en':
        return ['😞 Not at all', '😐 Partially', '😊 Often', '😄 Very often'];
      case 'es':
        return ['😞 Para nada', '😐 Parcialmente', '😊 A menudo', '😄 Muy a menudo'];
      case 'hi':
        return ['😞 बिल्कुल नहीं', '😐 आंशिक रूप से', '😊 अक्सर', '😄 बहुत अक्सर'];
      case 'zh':
        return ['😞 完全没有', '😐 部分', '😊 经常', '😄 非常经常'];
      default: // uk
        return ['😞 Зовсім ні', '😐 Частково', '😊 Часто', '😄 Дуже часто'];
    }
  }

  String _getAnalyzeTextForLanguage(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'Analyze the results of the user\'s psychological test:';
      case 'es':
        return 'Analiza los resultados del test psicológico del usuario:';
      case 'hi':
        return 'उपयोगकर्ता के मनोवैज्ञानिक परीक्षण के परिणामों का विश्लेषण करें:';
      case 'zh':
        return '分析用户的心理测试结果：';
      default: // uk
        return 'Проаналізуй результати психологічного тесту користувача:';
    }
  }

  String _getProvideTextForLanguage(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'Provide a detailed psychological analysis in JSON format.';
      case 'es':
        return 'Proporciona un análisis psicológico detallado en formato JSON.';
      case 'hi':
        return 'JSON प्रारूप में विस्तृत मनोवैज्ञानिक विश्लेषण प्रदान करें।';
      case 'zh':
        return '以JSON格式提供详细的心理分析。';
      default: // uk
        return 'Надай детальний психологічний аналіз у форматі JSON.';
    }
  }

  String _buildChatSystemPrompt(String languageCode) {
    final basePrompt = _remoteConfigService.getChatSystemPrompt();

    // Determine response language
    String languageInstruction;
    switch (languageCode) {
      case 'en':
        languageInstruction =
            '\n\n🌐 LANGUAGE RULE (CRITICAL):\nYou MUST communicate ONLY in English. All your responses, including refusal messages, must be written in English. Never switch to other languages.';
        break;
      case 'es':
        languageInstruction =
            '\n\n🌐 REGLA DE IDIOMA (CRÍTICA):\nDebes comunicarte SOLO en español. Todas tus respuestas, incluidos los mensajes de rechazo, deben estar escritos en español. Nunca cambies a otros idiomas.';
        break;
      case 'hi':
        languageInstruction =
            '\n\n🌐 भाषा नियम (महत्वपूर्ण):\nआपको केवल हिंदी में संवाद करना चाहिए। आपकी सभी प्रतिक्रियाएं, अस्वीकृति संदेश सहित, हिंदी में लिखे जाने चाहिए। कभी भी अन्य भाषाओं में न बदलें।';
        break;
      case 'zh':
        languageInstruction = '\n\n🌐 语言规则（关键）：\n你必须只用中文交流。你的所有回复，包括拒绝消息，都必须用中文书写。永远不要切换到其他语言。';
        break;
      default: // uk
        languageInstruction =
            '\n\n🌐 ПРАВИЛО МОВИ (КРИТИЧНО):\nТи ПОВИНЕН спілкуватися ЛИШЕ українською мовою. Всі твої відповіді, включно з повідомленнями про відмову, мають бути написані українською. Ніколи не переходи на інші мови.';
    }

    return basePrompt + languageInstruction;
  }

  // Send chat message with image support
  Future<String> sendChatMessage(
    String message,
    List<Map<String, dynamic>> chatHistory,
    String languageCode, {
    List<String>? imagePaths,
  }) async {
    try {
      final chatSystemPrompt = _buildChatSystemPrompt(languageCode);

      final messages = <Map<String, dynamic>>[
        {'role': 'system', 'content': chatSystemPrompt},
        ...chatHistory,
      ];

      String finalMessage = message;

      // If images present, create message with Vision API format content
      if (imagePaths != null && imagePaths.isNotEmpty) {
        final content = <Map<String, dynamic>>[
          {'type': 'text', 'text': finalMessage.isEmpty ? 'Опиши это изображение' : finalMessage},
        ];

        // Add images in base64
        for (final imagePath in imagePaths) {
          try {
            final imageFile = File(imagePath);
            if (await imageFile.exists()) {
              final imageBytes = await imageFile.readAsBytes();
              final base64Image = base64Encode(imageBytes);

              // Determine MIME type
              final extension = imagePath.split('.').last.toLowerCase();
              String mimeType;
              switch (extension) {
                case 'jpg':
                case 'jpeg':
                  mimeType = 'image/jpeg';
                  break;
                case 'png':
                  mimeType = 'image/png';
                  break;
                case 'gif':
                  mimeType = 'image/gif';
                  break;
                case 'webp':
                  mimeType = 'image/webp';
                  break;
                default:
                  mimeType = 'image/jpeg';
              }

              content.add({
                'type': 'image_url',
                'image_url': {'url': 'data:$mimeType;base64,$base64Image'},
              });
            }
          } catch (e) {
            print('Ошибка обработки изображения $imagePath: $e');
          }
        }

        messages.add({'role': 'user', 'content': content});
      } else {
        // Regular text message
        if (finalMessage.isNotEmpty) {
          messages.add({'role': 'user', 'content': finalMessage});
        } else {
          throw Exception('Пустое сообщение');
        }
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_apiKey'},
        body: jsonEncode({'model': 'gpt-4o-mini', 'messages': messages, 'temperature': 0.8, 'max_tokens': 500}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Помилка відправки повідомлення: $e');
    }
  }

  // Generate session title from messages
  Future<String> generateSessionTitle(List<Map<String, dynamic>> messages, String languageCode) async {
    try {
      // Take only first few messages for title generation
      final recentMessages = messages.length > 6 ? messages.sublist(0, 6) : messages;

      // Build prompt for title generation with language
      final prompt = _buildSessionTitlePrompt(recentMessages, languageCode);

      // Determine system prompt for title generation by language
      String systemPrompt;
      switch (languageCode) {
        case 'en':
          systemPrompt =
              'You help create a short title for a psychological session based on the dialogue. The title should be very short - 1-3 words that reflect the key topic or problem discussed in the dialogue. Respond only with the title, without additional explanations.';
          break;
        case 'es':
          systemPrompt =
              'Ayudas a crear un título corto para una sesión psicológica basado en el diálogo. El título debe ser muy corto - 1-3 palabras que reflejen el tema clave o problema discutido en el diálogo. Responde solo con el título, sin explicaciones adicionales.';
          break;
        case 'hi':
          systemPrompt =
              'आप संवाद के आधार पर एक मनोवैज्ञानिक सत्र के लिए एक छोटा शीर्षक बनाने में मदद करते हैं। शीर्षक बहुत छोटा होना चाहिए - 1-3 शब्द जो संवाद में चर्चा किए गए मुख्य विषय या समस्या को दर्शाते हैं। केवल शीर्षक के साथ उत्तर दें, बिना अतिरिक्त स्पष्टीकरण के।';
          break;
        case 'zh':
          systemPrompt = '你帮助根据对话创建一个心理会话的简短标题。标题应该非常短 - 1-3个词，反映对话中讨论的关键主题或问题。只回答标题，不要额外的解释。';
          break;
        default: // uk
          systemPrompt =
              'Ти допомагаєш створити коротку назву для психологічного сеансу на основі діалогу. Назва має бути дуже короткою - 1-3 слова, які відображають ключову тему або проблему, про яку йдеться в діалозі. Відповідай тільки назвою, без додаткових пояснень.';
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_apiKey'},
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 20, // Very short response
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final title = data['choices'][0]['message']['content'].trim();
        // Remove quotes if present
        return title.replaceAll('"', '').replaceAll("'", '');
      } else {
        throw Exception('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      print('Помилка генерації назви сеансу: $e');
        // Return fallback title by language
      switch (languageCode) {
        case 'en':
          return 'Chat';
        case 'es':
          return 'Chat';
        case 'hi':
          return 'चैट';
        case 'zh':
          return '聊天';
        default: // uk
          return 'Чат';
      }
    }
  }

  String _buildSessionTitlePrompt(List<Map<String, dynamic>> messages, String languageCode) {
    final buffer = StringBuffer();

    // Determine prompt text by language
    String introText;
    String userLabel;
    String psychologistLabel;
    String titleLabel;

    switch (languageCode) {
      case 'en':
        introText =
            'Based on the following dialogue, create a very short title (1-3 words) for this psychological session:\n';
        userLabel = 'User';
        psychologistLabel = 'Psychologist';
        titleLabel = '\nTitle (only 1-3 words):';
        break;
      case 'es':
        introText =
            'Basándote en el siguiente diálogo, crea un título muy corto (1-3 palabras) para esta sesión psicológica:\n';
        userLabel = 'Usuario';
        psychologistLabel = 'Psicólogo';
        titleLabel = '\nTítulo (solo 1-3 palabras):';
        break;
      case 'hi':
        introText = 'निम्नलिखित संवाद के आधार पर, इस मनोवैज्ञानिक सत्र के लिए एक बहुत छोटा शीर्षक (1-3 शब्द) बनाएं:\n';
        userLabel = 'उपयोगकर्ता';
        psychologistLabel = 'मनोवैज्ञानिक';
        titleLabel = '\nशीर्षक (केवल 1-3 शब्द):';
        break;
      case 'zh':
        introText = '根据以下对话，为这个心理会话创建一个非常简短的标题（1-3个词）：\n';
        userLabel = '用户';
        psychologistLabel = '心理学家';
        titleLabel = '\n标题（仅1-3个词）：';
        break;
      default: // uk
        introText =
            'На основі наступного діалогу створи дуже коротку назву (1-3 слова) для цього психологічного сеансу:\n';
        userLabel = 'Користувач';
        psychologistLabel = 'Психолог';
        titleLabel = '\nНазва (тільки 1-3 слова):';
    }

    buffer.writeln(introText);

    for (var msg in messages) {
      final role = msg['role'] == 'user' ? userLabel : psychologistLabel;
      dynamic content = msg['content'];
      String contentText = '';
      if (content is String) {
        contentText = content;
      } else if (content is List) {
        // For messages with images take text part
        for (var item in content) {
          if (item is Map && item['type'] == 'text') {
            contentText = item['text'] ?? '';
            break;
          }
        }
      }
      // Truncate long messages
      final shortContent = contentText.length > 100 ? '${contentText.substring(0, 100)}...' : contentText;
      buffer.writeln('$role: $shortContent');
    }

    buffer.writeln(titleLabel);
    return buffer.toString();
  }

  // Speech recognition via Whisper API
  Future<String> transcribeAudio(File audioFile, String languageCode) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_whisperUrl));
      request.headers['Authorization'] = 'Bearer $_apiKey';

      // Add file
      request.files.add(await http.MultipartFile.fromPath('file', audioFile.path));

      // Add parameters
      request.fields['model'] = 'whisper-1';
      // Specify language for better accuracy
      if (languageCode != 'uk') {
        request.fields['language'] = languageCode;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['text'] ?? '';
      } else {
        throw Exception('Whisper API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Помилка розпізнавання мови: $e');
    }
  }
}
