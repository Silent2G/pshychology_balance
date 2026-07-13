import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_palette.dart';
import '../widgets/app_background.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import '../services/openai_service.dart';
import '../services/firestore_service.dart';
import '../providers/auth_provider.dart';
import '../models/chat_session.dart' as models;
import '../widgets/common_header.dart';
import '../widgets/ai_consent_dialog.dart';
import '../widgets/confirm_dialog.dart';
import '../l10n/app_localizations.dart';

class ChatScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onEndSession;
  final VoidCallback? onBack;
  final String? sessionId;

  const ChatScreen({super.key, this.onNext, this.onEndSession, this.onBack, this.sessionId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final OpenAIService _openAIService = OpenAIService();
  final FirestoreService _firestoreService = FirestoreService();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final Map<String, AudioPlayer> _audioPlayers = {}; // Players for each audio message
  final Map<String, bool> _audioPlayingStates = {}; // Playback states
  bool _isTyping = false;
  bool _isRecording = false;
  String? _audioPath;
  AnimationController? _typingAnimationController;

  final List<models.ChatMessage> _messages = [];
  final List<Map<String, dynamic>> _chatHistory = []; // History for display (current session)
  final List<Map<String, dynamic>> _allUserHistory = []; // Full user history for AI context
  final ImagePicker _imagePicker = ImagePicker();
  String? _currentSessionId;
  bool _isSessionCompleted = false;
  bool _titleGenerated = false; // Flag that title was already generated

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureAiConsent());
    _initializeChat();
  }

  /// Required by App Store Guideline 5.1.1(i)/5.1.2(i): the user must consent
  /// before any data is sent to the third-party AI service (OpenAI).
  Future<void> _ensureAiConsent() async {
    final agreed = await ensureAiConsent(context);
    if (!agreed && mounted) {
      Navigator.of(context).maybePop();
    }
  }

  void _initializeChat() async {
    // Check all sessions in Firestore
    await _firestoreService.debugPrintAllSessions();

    // Load full user history for AI context
    await _loadAllUserHistory();

    if (widget.sessionId != null) {
      await _loadExistingSession();
    } else {
      await _sendWelcomeMessage();
    }
  }

  Future<void> _loadAllUserHistory() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;

    if (userId == null) return;

    try {
      final allMessages = await _firestoreService.getAllUserMessages(userId);
      _allUserHistory.clear();

      // Convert all messages to OpenAI format
      for (var msg in allMessages) {
        if (msg.imagePath != null) {
          // For messages with images use special format
          _allUserHistory.add({'role': msg.isUser ? 'user' : 'assistant', 'content': msg.text});
        } else {
          _allUserHistory.add({'role': msg.isUser ? 'user' : 'assistant', 'content': msg.text});
        }
      }

      print('Loaded ${_allUserHistory.length} messages from all sessions for AI context');
    } catch (e) {
      print('Error loading all user history: $e');
    }
  }

  Future<void> _loadExistingSession() async {
    _currentSessionId = widget.sessionId;

    try {
      // Update shared history before loading session
      await _loadAllUserHistory();

      final session = await _firestoreService.getChatSession(_currentSessionId!);
      print('Loaded session: ${session?.id}, messages count: ${session?.messages.length}');

      if (session != null && mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(session.messages);
          _chatHistory.clear();
          for (var msg in session.messages) {
            _chatHistory.add({'role': msg.isUser ? 'user' : 'assistant', 'content': msg.text});
          }
          _isSessionCompleted = session.isCompleted;
          // If title is not default, it was already generated
          final localizations = AppLocalizations.of(context)!;
          final chatWord = localizations.chat;
          final isDefaultTitle = session.title == chatWord || session.title.startsWith('$chatWord ');
          _titleGenerated = !isDefaultTitle;
        });

        print('Messages loaded: ${_messages.length}');

        // Give time for widgets to build before scroll
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollToBottom();
        });
      } else {
        print('Session is null or widget not mounted');
      }
    } catch (e) {
      print('Error loading session: $e');
    }
  }

  Future<void> _sendWelcomeMessage() async {
    print('=== _sendWelcomeMessage called ===');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;
    print('User ID: $userId');

    if (userId != null) {
      // Create new session in Firestore
      print('Creating new chat session...');
      try {
        final localizations = AppLocalizations.of(context)!;
        final now = DateTime.now();
        final defaultTitle = '${localizations.chat} ${now.day}.${now.month}.${now.year}';
        final sessionId = await _firestoreService.createChatSession(userId, defaultTitle);
        print('Session created with ID: $sessionId');

        // Save session ID in state
        _currentSessionId = sessionId;
        _isSessionCompleted = false;
        _titleGenerated = false; // Reset flag for new session
        print('Session ID saved to state: $_currentSessionId');

        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        print('ERROR in _sendWelcomeMessage: $e');
      }
    } else {
      print('User ID is null, cannot create session');
    }

    final localizations = AppLocalizations.of(context);
    final welcomeMessage = models.ChatMessage(
      text:
          localizations?.chatWelcomeMessage ??
          "Привіт! Я - AI психолог. Розкажи, що тебе турбує, і я постараюся допомогти.",
      isUser: false,
      timestamp: DateTime.now(),
    );

    if (mounted) {
      setState(() {
        _messages.add(welcomeMessage);
      });
    }

    // Save welcome message
    if (_currentSessionId != null) {
      print('Saving welcome message to session: $_currentSessionId');
      try {
        await _firestoreService.addMessageToChat(_currentSessionId!, welcomeMessage);
        print('Welcome message saved successfully');
      } catch (e) {
        print('Failed to save welcome message: $e');
      }
    } else {
      print('No session ID to save welcome message');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController?.dispose();
    _audioRecorder.dispose();
    // Stop and dispose all audio players
    for (var player in _audioPlayers.values) {
      player.dispose();
    }
    _audioPlayers.clear();
    super.dispose();
  }

  Future<void> _toggleAudioPlayback(String audioPath) async {
    try {
      // Stop all other players
      for (var entry in _audioPlayers.entries) {
        if (entry.key != audioPath) {
          try {
            await entry.value.pause();
            await entry.value.seek(Duration.zero);
            if (mounted) {
              setState(() {
                _audioPlayingStates[entry.key] = false;
              });
            }
          } catch (e) {
            print('Ошибка остановки другого плеера: $e');
          }
        }
      }

      // If player already exists, use it
      AudioPlayer player;
      if (!_audioPlayers.containsKey(audioPath)) {
        player = AudioPlayer();
        await player.setFilePath(audioPath);
        _audioPlayers[audioPath] = player;
        _audioPlayingStates[audioPath] = false;

        // Listen to playback state changes
        player.playerStateStream.listen((state) {
          if (mounted) {
            setState(() {
              _audioPlayingStates[audioPath] = state.playing;
              if (state.processingState == ProcessingState.completed) {
                _audioPlayingStates[audioPath] = false;
              }
            });
          }
        });
      } else {
        player = _audioPlayers[audioPath]!;
      }

      final currentState = player.playerState;
      final isPlaying = currentState.playing;

      if (isPlaying) {
        await player.pause();
      } else {
        // If track ended, start from beginning
        if (currentState.processingState == ProcessingState.completed) {
          await player.seek(Duration.zero);
        }
        await player.play();
      }

      // Update state immediately for instant UI response
      if (mounted) {
        setState(() {
          _audioPlayingStates[audioPath] = !isPlaying;
        });
      }
    } catch (e) {
      print('Ошибка воспроизведения аудио: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка воспроизведения аудио: $e')));
        setState(() {
          _audioPlayingStates[audioPath] = false;
        });
      }
    }
  }

  void _sendMessage() async {
    print('=== _sendMessage called ===');
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    print('User message: $userMessage');
    print('Current session ID: $_currentSessionId');

    final userChatMessage = models.ChatMessage(text: userMessage, isUser: true, timestamp: DateTime.now());

    setState(() {
      _messages.add(userChatMessage);
      _isTyping = true;
    });

    // Save user message to Firestore
    if (_currentSessionId != null) {
      print('Saving user message to session: $_currentSessionId');
      try {
        await _firestoreService.addMessageToChat(_currentSessionId!, userChatMessage);
      } catch (e) {
        print('Failed to save user message: $e');
      }
    } else {
      print('No session ID - message not saved!');
    }

    // Add to current session history (for display)
    _chatHistory.add({'role': 'user', 'content': userMessage});

    _messageController.clear();
    _scrollToBottom();

    try {
      // Send request to OpenAI with full user history
      // sendChatMessage will add current message to end of history
      final localizations = AppLocalizations.of(context)!;
      final languageCode = localizations.locale.languageCode;
      // Convert history to required format (text messages only for history)
      final historyForApi = _allUserHistory
          .map(
            (msg) => {
              'role': msg['role'] as String,
              'content': msg['content'] is String
                  ? msg['content'] as String
                  : (msg['content'] as List).first['text'] ?? '',
            },
          )
          .toList();
      final response = await _openAIService.sendChatMessage(userMessage, historyForApi, languageCode);
      final aiChatMessage = models.ChatMessage(text: response, isUser: false, timestamp: DateTime.now());

      if (mounted) {
        setState(() {
          _messages.add(aiChatMessage);
          _isTyping = false;
          _typingAnimationController?.stop();
        });

        // Save AI response to Firestore
        if (_currentSessionId != null) {
          await _firestoreService.addMessageToChat(_currentSessionId!, aiChatMessage);
        }

        // Add AI response to current session history
        _chatHistory.add({'role': 'assistant', 'content': response});

        // Generate session title on first user message (after first AI response)
        if (!_titleGenerated && _chatHistory.length >= 2 && _currentSessionId != null) {
          await _generateSessionTitle();
        }

        // Update shared history from Firestore (both messages already saved there)
        await _loadAllUserHistory();

        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = models.ChatMessage(
          text: "Вибачте, виникла помилка. Спробуйте ще раз.",
          isUser: false,
          timestamp: DateTime.now(),
        );

        setState(() {
          _messages.add(errorMessage);
          _isTyping = false;
          _typingAnimationController?.stop();
        });

        if (_currentSessionId != null) {
          await _firestoreService.addMessageToChat(_currentSessionId!, errorMessage);
        }

        // Update shared history after saving
        await _loadAllUserHistory();

        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _generateSessionTitle() async {
    if (_currentSessionId == null || _chatHistory.isEmpty) return;

    try {
      // Generate title based on current chat history
      final localizations = AppLocalizations.of(context)!;
      final languageCode = localizations.locale.languageCode;
      final title = await _openAIService.generateSessionTitle(_chatHistory, languageCode);

      // Check default title for current language
      final chatWord = localizations.chat;
      final isDefaultTitle = title.trim() == chatWord || title.trim().startsWith('$chatWord ');

      if (title.isNotEmpty && !isDefaultTitle && _currentSessionId != null) {
        // Update title in Firestore
        await _firestoreService.updateChatSessionTitle(_currentSessionId!, title);
        _titleGenerated = true;
        print('✅ Название сеанса сгенерировано: $title');
      }
    } catch (e) {
      print('❌ Ошибка генерации названия сеансу: $e');
    }
  }

  /// Asks the user to confirm before clearing the conversation and starting over.
  Future<void> _confirmResetChat() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l.startOverConfirmTitle,
      message: l.startOverConfirmMessage,
      confirmLabel: l.startOver,
    );
    if (confirmed) _resetChat();
  }

  /// Asks the user to confirm before ending the current session.
  Future<void> _confirmEndSession() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l.endSessionConfirmTitle,
      message: l.endSessionConfirmMessage,
      confirmLabel: l.endSession,
      isDestructive: true,
    );
    if (confirmed) _endSession();
  }

  void _resetChat() {
    setState(() {
      _messages.clear();
      _chatHistory.clear();
      _isTyping = false;
      _currentSessionId = null;
      _isSessionCompleted = false;
      _titleGenerated = false;
    });
    _sendWelcomeMessage();
  }

  void _endSession() async {
    if (_currentSessionId != null) {
      await _firestoreService.completeChatSession(_currentSessionId!);
      setState(() {
        _isSessionCompleted = true;
      });
    }
    if (widget.onEndSession != null) {
      widget.onEndSession!();
    }
  }

  Future<void> _startRecording() async {
    try {
      // Check permission via permission_handler
      PermissionStatus status = await Permission.microphone.status;
      print('Microphone permission status: $status');

      // If permission not granted, request it
      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          // Permission denied permanently - need to open settings
          print('Microphone permission permanently denied');
          if (mounted) {
            final localizations = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.microphonePermissionDenied),
                action: SnackBarAction(label: localizations.settings, onPressed: () async => await openAppSettings()),
              ),
            );
          }
          return;
        }

        // Request permission - this should show system dialog on iOS
        print('Requesting microphone permission...');
        status = await Permission.microphone.request();
        print('Microphone permission request result: $status');

        // Check result after request
        if (!status.isGranted) {
          if (status.isPermanentlyDenied) {
            // User denied and chose "Don't ask again"
            print('Microphone permission permanently denied after request');
            if (mounted) {
              final localizations = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.microphonePermissionDenied),
                  action: SnackBarAction(label: localizations.settings, onPressed: () async => await openAppSettings()),
                ),
              );
            }
          } else {
            // User denied permission
            print('Microphone permission denied');
            if (mounted) {
              final localizations = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(localizations.microphonePermissionRequired)));
            }
          }
          return;
        }
      }

      // Check permission via record library (additional check)
      final hasRecordPermission = await _audioRecorder.hasPermission();
      print('AudioRecorder hasPermission: $hasRecordPermission');
      if (!hasRecordPermission) {
        // If record says no permission but permission_handler says yes,
        // try requesting via record directly
        print('AudioRecorder reports no permission, but permission_handler says granted');
        if (mounted) {
          final localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(localizations.microphonePermissionRequired)));
        }
        return;
      }

      // Get temp directory for saving audio
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _audioPath = '${directory.path}/audio_$timestamp.m4a';

      // Start recording
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
        path: _audioPath!,
      );

      if (mounted) {
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      print('Ошибка начала записи: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка записи: $e')));
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (!_isRecording || _audioPath == null) return;

      // Stop recording
      final path = await _audioRecorder.stop();

      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }

      if (path != null && path.isNotEmpty) {
        // Send audio for transcription
        await _processAudioRecording(path);
      } else {
        throw Exception('Путь к аудио файлу не найден');
      }
    } catch (e) {
      print('Ошибка остановки записи: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка обработки записи: $e')));
        setState(() {
          _isRecording = false;
        });
      }
    }
  }

  Future<void> _processAudioRecording(String audioPath) async {
    try {
      // First create and send message with audio to chat
      final audioMessage = models.ChatMessage(
        text: '', // Don't show transcribed text in message
        isUser: true,
        timestamp: DateTime.now(),
        audioPath: audioPath, // Save path to audio file
      );

      if (mounted) {
        setState(() {
          _messages.add(audioMessage);
          _isTyping = true;
        });
      }

      // Save user message to Firestore
      if (_currentSessionId != null) {
        try {
          await _firestoreService.addMessageToChat(_currentSessionId!, audioMessage);
        } catch (e) {
          print('Failed to save audio message: $e');
        }
      }

      _scrollToBottom();

      // Transcribe audio and send to OpenAI
      final localizations = AppLocalizations.of(context)!;
      final languageCode = localizations.locale.languageCode;
      final audioFile = File(audioPath);

      // Transcribe audio via Whisper
      String transcribedText = '';
      try {
        transcribedText = await _openAIService.transcribeAudio(audioFile, languageCode);
        print('Распознанный текст из аудио: $transcribedText');
      } catch (e) {
        print('Ошибка распознавания аудио: $e');
        if (mounted) {
          setState(() {
            _isTyping = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка распознавания речи: $e')));
        }
        return;
      }

      if (transcribedText.isEmpty) {
        if (mounted) {
          setState(() {
            _isTyping = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось распознать речь')));
        }
        return;
      }

      // Add transcribed text to history
      _chatHistory.add({'role': 'user', 'content': transcribedText});
      _allUserHistory.add({'role': 'user', 'content': transcribedText});

      // Send transcribed text to OpenAI for response
      try {
        final historyForApi = _allUserHistory
            .map(
              (msg) => <String, dynamic>{
                'role': msg['role'] as String,
                'content': msg['content'] is String
                    ? msg['content'] as String
                    : (msg['content'] as List).first['text'] ?? '',
              },
            )
            .toList();
        final response = await _openAIService.sendChatMessage(transcribedText, historyForApi, languageCode);
        final aiChatMessage = models.ChatMessage(text: response, isUser: false, timestamp: DateTime.now());

        if (mounted) {
          setState(() {
            _messages.add(aiChatMessage);
            _isTyping = false;
            _typingAnimationController?.stop();
          });
        }

        // Save AI response to Firestore
        if (_currentSessionId != null) {
          try {
            await _firestoreService.addMessageToChat(_currentSessionId!, aiChatMessage);
          } catch (e) {
            print('Failed to save AI response: $e');
          }
        }

        // Add response to history
        _chatHistory.add({'role': 'assistant', 'content': response});
        _allUserHistory.add({'role': 'assistant', 'content': response});

        _scrollToBottom();
      } catch (e) {
        print('Ошибка отправки аудио сообщения: $e');
        if (mounted) {
          setState(() {
            _isTyping = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка отправки сообщения: $e')));
        }
      }
    } catch (e) {
      print('Ошибка обработки аудио: $e');
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка распознавания речи: $e')));
      }
    }
  }

  // void _showAttachmentOptions() {
  //   final localizations = AppLocalizations.of(context)!;
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => Container(
  //       padding: const EdgeInsets.all(20),
  //       decoration: const BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //       ),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             leading: const Icon(Icons.image, color: Color(0xFFBC91DB)),
  //             title: Text(localizations.image),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _pickImage();
  //             },
  //           ),
  //           ListTile(
  //             leading: const Icon(Icons.insert_drive_file, color: Color(0xFFBC91DB)),
  //             title: Text(localizations.file),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _pickFile();
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (image != null) {
        await _sendMessageWithFile(image.path, [image.path]);
      }
    } catch (e) {
      print('Ошибка выбора изображения: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка выбора изображения: $e')));
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'mp3', 'mp4', 'mpeg', 'mpga', 'm4a', 'wav', 'webm'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final extension = filePath.split('.').last.toLowerCase();

        // Check file type
        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
          // Image
          await _sendMessageWithFile(filePath, [filePath]);
        } else if (['mp3', 'mp4', 'mpeg', 'mpga', 'm4a', 'wav', 'webm'].contains(extension)) {
          // Audio file - send for transcription via Whisper
          await _processAudioFile(filePath);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Неподдерживаемый формат файла'), duration: Duration(seconds: 2)),
            );
          }
        }
      }
    } catch (e) {
      print('Ошибка выбора файла: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка выбора файла: $e')));
      }
    }
  }

  Future<void> _sendMessageWithFile(String filePath, List<String> imagePaths) async {
    final userMessage = _messageController.text.trim();
    final localizations = AppLocalizations.of(context)!;

    // Create message with image for display
    final imageMessage = models.ChatMessage(
      text: userMessage.isEmpty ? localizations.imageLabel : userMessage,
      isUser: true,
      timestamp: DateTime.now(),
      imagePath: filePath,
    );

    setState(() {
      _messages.add(imageMessage);
      _isTyping = true;
    });

    // Save user message to Firestore
    if (_currentSessionId != null) {
      try {
        await _firestoreService.addMessageToChat(_currentSessionId!, imageMessage);
      } catch (e) {
        print('Failed to save user message: $e');
      }
    }

    // Add to history (Vision API needs special format)
    _chatHistory.add({
      'role': 'user',
      'content': [
        {'type': 'text', 'text': userMessage.isEmpty ? 'Опиши это изображение' : userMessage},
        ...imagePaths.map(
          (path) => {
            'type': 'image_url',
            'image_url': {'url': 'file://$path'},
          },
        ),
      ],
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final localizations = AppLocalizations.of(context)!;
      final languageCode = localizations.locale.languageCode;
      final response = await _openAIService.sendChatMessage(
        userMessage.isEmpty ? 'Опиши это изображение' : userMessage,
        _allUserHistory,
        languageCode,
        imagePaths: imagePaths,
      );

      final aiChatMessage = models.ChatMessage(text: response, isUser: false, timestamp: DateTime.now());

      if (mounted) {
        setState(() {
          _messages.add(aiChatMessage);
          _isTyping = false;
          _typingAnimationController?.stop();
        });

        // Save AI response to Firestore
        if (_currentSessionId != null) {
          await _firestoreService.addMessageToChat(_currentSessionId!, aiChatMessage);
        }

        // Add AI response to current session history
        _chatHistory.add({'role': 'assistant', 'content': response});

        // Generate session title on first user message
        if (!_titleGenerated && _chatHistory.length >= 2 && _currentSessionId != null) {
          await _generateSessionTitle();
        }

        // Update shared history from Firestore
        await _loadAllUserHistory();

        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _typingAnimationController?.stop();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка отправки: $e')));
      }
    }
  }

  Future<void> _processAudioFile(String filePath) async {
    try {
      if (mounted) {
        setState(() {
          _isTyping = true;
        });
      }

      final localizations = AppLocalizations.of(context)!;
      final languageCode = localizations.locale.languageCode;

      // Send audio for transcription via Whisper API
      final audioFile = File(filePath);
      final transcribedText = await _openAIService.transcribeAudio(audioFile, languageCode);

      if (mounted && transcribedText.isNotEmpty) {
        // Insert transcribed text into input field
        _messageController.text = transcribedText;
        setState(() {
          _isTyping = false;
        });

        // Auto-send transcribed message
        print('Отправляем распознанное сообщение из файла: $transcribedText');
        _sendMessage();
      } else if (mounted) {
        setState(() {
          _isTyping = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось распознать речь')));
      }
    } catch (e) {
      print('Ошибка обработки аудио файла: $e');
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка распознавания речи: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return GestureDetector(
      onTap: () {
        // Close keyboard when tapping outside text field
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: context.palette.scaffold,
        body: AppBackground(
          lightImage: 'assets/background_chat.png',
          child: SafeArea(
            child: Column(
              children: [
                // Common header with back button, logo and session controls
                CommonHeader(
                  onBack: widget.onBack,
                  showBackButton: true,
                  actions: _isSessionCompleted
                      ? const []
                      : [
                          CircleHeaderButton(
                            icon: Icons.refresh_rounded,
                            tooltip: localizations.startOver,
                            onTap: _confirmResetChat,
                          ),
                          CircleHeaderButton(
                            icon: Icons.check_rounded,
                            tooltip: localizations.endSession,
                            onTap: _confirmEndSession,
                          ),
                        ],
                ),
                SizedBox(height: screenHeight * 0.018), // ~15px on 812px
                // Message list
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.043), // 16px on 375px
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
                ),

                // Control panel
                Container(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      // Message input field
                      Container(
                        decoration: const BoxDecoration(color: Color(0xFFBC91DB)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.043,
                            vertical: screenHeight * 0.022,
                          ), // 16px, 17.5px
                          child: Row(
                            children: [
                              // Attachment button - hidden
                              // GestureDetector(
                              //   onTap: _showAttachmentOptions,
                              //   child: Container(
                              //     width: screenWidth * 0.096, // 36px on 375px
                              //     height: screenWidth * 0.096,
                              //     decoration: const BoxDecoration(color: Color(0xFFF9FBFF), shape: BoxShape.circle),
                              //     child: Center(
                              //       child: SvgPicture.asset(
                              //         'assets/ic_attachment.svg',
                              //         width: screenWidth * 0.048, // 18px on 375px
                              //         height: screenWidth * 0.048,
                              //         colorFilter: const ColorFilter.mode(Color(0xFFBC91DB), BlendMode.srcIn),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(width: screenWidth * 0.027), // 10px
                              // Input field
                              Expanded(
                                child: Container(
                                  height: screenWidth * 0.096, // 36px on 375px - same height as icons
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.027, // 10px
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.palette.surface,
                                    borderRadius: BorderRadius.circular(31),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _messageController,
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            height: 1.25,
                                            color: context.palette.textPrimary,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: localizations.chatPlaceholder,
                                            hintStyle: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              height: 1.25,
                                              color: Color(0xFFA2A2A2),
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                            isDense: true,
                                          ),
                                          textAlignVertical: TextAlignVertical.center,
                                          maxLines: 1,
                                          textInputAction: TextInputAction.send,
                                          onSubmitted: (_) => _sendMessage(),
                                        ),
                                      ),
                                      // Microphone button
                                      GestureDetector(
                                        onTap: _isRecording ? _stopRecording : _startRecording,
                                        onLongPress: _isRecording ? null : _startRecording,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: SvgPicture.asset(
                                            'assets/ic_microphone.svg',
                                            width: screenWidth * 0.04, // 15px on 375px
                                            height: screenWidth * 0.061, // 23px on 375px
                                            colorFilter: ColorFilter.mode(
                                              _isRecording ? Colors.red : const Color(0xFFBC91DB),
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.027), // 10px
                              // Send button
                              GestureDetector(
                                onTap: _sendMessage,
                                child: Container(
                                  width: screenWidth * 0.096, // 36px on 375px
                                  height: screenWidth * 0.096,
                                  decoration: BoxDecoration(color: context.palette.surface, shape: BoxShape.circle),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/ic_send.svg',
                                      width: screenWidth * 0.045, // 17px on 375px
                                      height: screenWidth * 0.045,
                                      colorFilter: const ColorFilter.mode(Color(0xFFBC91DB), BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioPlayer(String audioPath, bool isUser, AppLocalizations localizations) {
    // Initialize player if not yet created (for progress display)
    if (!_audioPlayers.containsKey(audioPath)) {
      // Create player in advance for progress display
      final player = AudioPlayer();
      player
          .setFilePath(audioPath)
          .then((_) {
            if (mounted) {
              setState(() {
                _audioPlayers[audioPath] = player;
                _audioPlayingStates[audioPath] = false;
              });

              // Listen to state changes
              player.playerStateStream.listen((state) {
                if (mounted) {
                  setState(() {
                    _audioPlayingStates[audioPath] = state.playing;
                    if (state.processingState == ProcessingState.completed) {
                      _audioPlayingStates[audioPath] = false;
                    }
                  });
                }
              });
            }
          })
          .catchError((e) {
            print('Ошибка инициализации плеера: $e');
          });
    }

    final player = _audioPlayers[audioPath];
    final isPlaying = _audioPlayingStates[audioPath] ?? false;

    return GestureDetector(
      onTap: () => _toggleAudioPlayback(audioPath),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFBC91DB) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: isUser ? Colors.white : context.palette.textPrimary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${localizations.voiceMessage}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: isUser ? Colors.white : context.palette.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            // Playback progress bar
            if (player != null)
              StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (context, positionSnapshot) {
                  return StreamBuilder<Duration?>(
                    stream: player.durationStream,
                    builder: (context, durationSnapshot) {
                      final position = positionSnapshot.data ?? Duration.zero;
                      final duration = durationSnapshot.data ?? Duration.zero;

                      if (duration == Duration.zero) {
                        return const SizedBox.shrink();
                      }

                      final progress = position.inMilliseconds / duration.inMilliseconds;

                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          children: [
                            LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              backgroundColor: isUser ? Colors.white.withOpacity(0.3) : context.palette.textMuted,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isUser ? Colors.white : const Color(0xFFBC91DB),
                              ),
                              minHeight: 3,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 10,
                                    color: isUser ? Colors.white70 : context.palette.textSecondary,
                                  ),
                                ),
                                Text(
                                  _formatDuration(duration),
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 10,
                                    color: isUser ? Colors.white70 : context.palette.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildMessageBubble(models.ChatMessage message) {
    final screenWidth = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!message.isUser) ...[const SizedBox(width: 0)],
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth * 0.6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isUser ? const Color(0xFFBC91DB) : context.palette.surface,
                    borderRadius: message.isUser
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          )
                        : const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image if present
                      if (message.imagePath != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(message.imagePath!),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(height: 100, color: Colors.grey[300], child: const Icon(Icons.error));
                            },
                          ),
                        ),
                        if (message.text.isNotEmpty) const SizedBox(height: 8),
                      ],
                      // Audio if present
                      if (message.audioPath != null) ...[
                        _buildAudioPlayer(message.audioPath!, message.isUser, localizations),
                        if (message.text.isNotEmpty) const SizedBox(height: 8),
                      ],
                      // Message text
                      if (message.text.isNotEmpty)
                        Text(
                          message.text,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            height: 1.25,
                            color: Color(0xFFFFFFFF),
                          ).copyWith(color: message.isUser ? const Color(0xFFFFFFFF) : context.palette.textPrimary),
                        ),
                    ],
                  ),
                ),
              ),
              if (message.isUser) ...[const SizedBox(width: 0)],
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: message.isUser ? 0 : 0, right: message.isUser ? 0 : 0),
            child: Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                height: 1.25,
                color: Color(0xFFB7B7B7),
              ),
              textAlign: message.isUser ? TextAlign.right : TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    // Start animation if not yet started
    if (_typingAnimationController != null && !_typingAnimationController!.isAnimating) {
      _typingAnimationController!.repeat();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AI Psychologist is typing…',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.25,
                    color: context.palette.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                _buildTypingDots(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDots() {
    if (_typingAnimationController == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _typingAnimationController!,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_typingAnimationController!.value - delay).clamp(0.0, 1.0);
            final opacity = (sin(animationValue * 2 * 3.14159) + 1) / 2;

            return Container(
              margin: const EdgeInsets.only(left: 2),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(color: context.palette.textSecondary, shape: BoxShape.circle),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
