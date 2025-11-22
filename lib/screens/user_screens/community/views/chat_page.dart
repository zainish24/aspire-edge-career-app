// screens/user_screens/community/chat_page.dart
import 'dart:ui' hide Codec;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' hide Codec;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aspire_edge/config_example.dart';
import 'package:aspire_edge/models/community_model.dart';
import 'package:aspire_edge/services/community_service.dart';
import 'package:aspire_edge/theme/app_theme.dart';
import 'components/community_components.dart';

// Cloudinary credentials
  final String cloudinaryCloudName = CloudinaryConfig.cloudName;
  final String cloudinaryUploadPreset = CloudinaryConfig.uploadPreset;

// Helper function to upload files to Cloudinary
Future<String?> uploadToCloudinary(XFile file, String fileType) async {
  final cloudinaryResourceType = fileType == 'audio' ? 'raw' : fileType;
  final url = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/$cloudinaryResourceType/upload',
  );
  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = cloudinaryUploadPreset;

  try {
    final bytes = await file.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: file.name),
    );

    final response = await request.send();
    final responseData = await response.stream.toBytes();
    final jsonResponse = jsonDecode(String.fromCharCodes(responseData));

    if (response.statusCode == 200) {
      return jsonResponse['secure_url'];
    } else {
      debugPrint('Cloudinary upload failed: ${jsonResponse['error']['message']}');
      return null;
    }
  } catch (e) {
    debugPrint('Error uploading to Cloudinary: $e');
    return null;
  }
}

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String? receiverAvatar;

  const ChatPage({
    super.key,
    required this.receiverId,
    required this.receiverName,
    this.receiverAvatar,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final CommunityService _communityService = CommunityService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  late final String chatId;
  final ScrollController _scrollController = ScrollController();

  // Voice recording variables
  FlutterSoundRecorder? _soundRecorder;
  String? _audioPath;
  bool _isUploading = false;
  bool _isRecordingActive = false;

  // For message editing
  String? _editingMessageId;

  @override
  void initState() {
    super.initState();
    chatId = _communityService.getChatId(_currentUser!.uid, widget.receiverId);
    _markMessagesAsRead();
    if (!kIsWeb) {
      _initRecorder();
    }

    _messageController.addListener(() {
      setState(() {});
    });

    // Scroll to bottom after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    if (!kIsWeb) {
      _soundRecorder?.closeRecorder();
    }
    super.dispose();
  }

  Future<void> _initRecorder() async {
    _soundRecorder = FlutterSoundRecorder();
    await _soundRecorder?.openRecorder();
  }

  void _showSnackbar(String message, {Color color = AppColors.primary}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorders.radiusMd),
          ),
        ),
      );
    }
  }

  Future<void> _markMessagesAsRead() async {
    try {
      await _communityService.markMessagesAsRead(chatId, _currentUser!.uid);
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  Future<void> _pickMedia(ImageSource source, String type) async {
    final ImagePicker picker = ImagePicker();
    XFile? file;
    try {
      if (type == 'image') {
        file = await picker.pickImage(source: source, imageQuality: 75);
      } else if (type == 'video') {
        file = await picker.pickVideo(source: source);
      }

      if (file != null) {
        await _sendMediaMessage(file, type);
      }
    } catch (e) {
      _showSnackbar('Failed to pick media: $e', color: AppColors.error);
    }
  }

  Future<void> _startVoiceRecording() async {
    if (kIsWeb) {
      _showSnackbar('Voice recording is not supported on the web.', color: AppColors.error);
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      _audioPath = '${directory.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _soundRecorder?.startRecorder(
        toFile: _audioPath,
        codec: Codec.aacADTS,
      );
      setState(() {
        _isRecordingActive = true;
      });
    } catch (e) {
      _showSnackbar('Failed to start recording: $e', color: AppColors.error);
    }
  }

  Future<void> _sendVoiceRecording() async {
    if (!_isRecordingActive || _audioPath == null) {
      return;
    }

    try {
      final stopPath = await _soundRecorder?.stopRecorder();
      if (stopPath != null) {
        final audioFile = XFile(stopPath);
        await _sendMediaMessage(audioFile, 'audio');
      }
    } catch (e) {
      _showSnackbar('Failed to send recording: $e', color: AppColors.error);
    } finally {
      setState(() {
        _isRecordingActive = false;
      });
    }
  }

  Future<void> _cancelVoiceRecording() async {
    if (!_isRecordingActive) {
      return;
    }
    try {
      await _soundRecorder?.stopRecorder();
    } catch (e) {
      debugPrint('Error canceling recording: $e');
    } finally {
      setState(() {
        _isRecordingActive = false;
      });
    }
  }

  Future<void> _sendMediaMessage(XFile file, String mediaType) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final mediaUrl = await uploadToCloudinary(file, mediaType);

      if (mediaUrl == null) {
        _showSnackbar('Upload failed.', color: AppColors.error);
        return;
      }

      final message = ChatMessage(
        messageId: '',
        senderId: _currentUser!.uid,
        receiverId: widget.receiverId,
        message: mediaType == 'audio' ? '' : _messageController.text.trim(),
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        timestamp: DateTime.now(),
        isRead: false,
        delivered: true,
      );

      await _communityService.sendMessage(message, widget.receiverId);
      _messageController.clear();
      _showSnackbar('$mediaType sent!');
      _scrollToBottom();
    } catch (e) {
      _showSnackbar('Failed to send message: $e', color: AppColors.error);
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _editingMessageId == null) {
      return;
    }

    if (_currentUser == null) {
      _showSnackbar('User not logged in.', color: AppColors.error);
      return;
    }

    try {
      if (_editingMessageId != null) {
        // Update existing message
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(_editingMessageId)
            .update({
              'message': _messageController.text.trim(),
              'timestamp': FieldValue.serverTimestamp(),
            });
        _showSnackbar('Message updated!');
        _cancelEdit();
      } else {
        // Send new text message
        final message = ChatMessage(
          messageId: '',
          senderId: _currentUser.uid,
          receiverId: widget.receiverId,
          message: _messageController.text.trim(),
          timestamp: DateTime.now(),
          isRead: false,
          delivered: true,
        );

        await _communityService.sendMessage(message, widget.receiverId);
        _messageController.clear();
        _scrollToBottom();
        _showSnackbar('Message sent!');
      }
    } catch (e) {
      _showSnackbar('Failed to send message: $e', color: AppColors.error);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _startEdit(String messageId, String currentMessage) {
    setState(() {
      _editingMessageId = messageId;
      _messageController.text = currentMessage;
    });
    _scrollToBottom();
  }

  void _cancelEdit() {
    setState(() {
      _editingMessageId = null;
      _messageController.clear();
    });
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
      _showSnackbar('Message deleted!');
    } catch (e) {
      _showSnackbar('Failed to delete message: $e', color: AppColors.error);
    }
  }

  void _showCareerContext() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorders.radiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Career Connection',
                style: TextStyle(
                  fontSize: AppText.headlineSmall,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Continue career discussion with ${widget.receiverName}',
                style: TextStyle(
                  fontSize: AppText.bodyMedium,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  PrimaryButton(
                    text: 'Career Chat',
                    onPressed: () {
                      Navigator.pop(context);
                      _messageController.text = "Hi! I'd like to discuss career opportunities...";
                      setState(() {});
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessage({
    required String messageId,
    required String message,
    required Timestamp? timestamp,
    required bool isMe,
    required bool isRead,
    required bool delivered,
    String? mediaUrl,
    String? mediaType,
  }) {
    final String timeText = timestamp != null
        ? DateFormat('h:mm a').format(timestamp.toDate())
        : '...';

    return GestureDetector(
      onLongPress: isMe
          ? () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.95),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.edit, color: AppColors.primary),
                          title: Text(
                            'Edit',
                            style: TextStyle(color: AppColors.black),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _startEdit(messageId, message);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.delete, color: AppColors.error),
                          title: Text(
                            'Delete',
                            style: TextStyle(color: AppColors.error),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _deleteMessage(messageId);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          : null,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: EdgeInsets.only(
            top: 4,
            bottom: 4,
            left: isMe ? 60 : 12,
            right: isMe ? 12 : 60,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primary : AppColors.lightGrey,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(5),
              bottomRight: isMe ? const Radius.circular(5) : const Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (mediaUrl != null && mediaType == 'image')
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppBorders.radiusMd),
                  child: CachedNetworkImage(
                    imageUrl: mediaUrl,
                    width: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => SizedBox(
                      width: 200,
                      height: 150,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 200,
                      height: 150,
                      color: AppColors.lightGrey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, color: AppColors.grey),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: AppColors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (mediaUrl != null && mediaType == 'video')
                VideoPlayerWidget(videoUrl: mediaUrl),
              if (mediaUrl != null && mediaType == 'audio')
                AudioPlayerWidget(audioUrl: mediaUrl),
              if (message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    message, 
                    style: TextStyle(
                      color: isMe ? AppColors.white : AppColors.black,
                      fontSize: AppText.bodyMedium,
                    )
                  ),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeText,
                    style: TextStyle(
                      color: isMe ? AppColors.white.withOpacity(0.7) : AppColors.grey,
                      fontSize: AppText.labelSmall,
                    ),
                  ),
                  if (isMe)
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(
                        isRead ? Icons.done_all : Icons.done,
                        size: 15,
                        color: isRead ? AppColors.white : AppColors.white.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Row(
          children: [
            CommunityAvatar(
              photoUrl: widget.receiverAvatar,
              userName: widget.receiverName,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                      fontSize: AppText.bodyLarge,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  StreamBuilder<List<ChatMessage>>(
                    stream: _communityService.getChatMessages(_currentUser!.uid, widget.receiverId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final lastMessage = snapshot.data!.first;
                        final isOnline = lastMessage.timestamp.isAfter(
                          DateTime.now().subtract(const Duration(minutes: 5))
                        );
                        return Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: isOnline ? AppColors.success : AppColors.grey,
                            fontSize: AppText.labelSmall,
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: AppColors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.work_outline, color: AppColors.primary),
            onPressed: _showCareerContext,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _communityService.getChatMessages(_currentUser.uid, widget.receiverId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                
                if (snapshot.hasError) {
                  debugPrint('Chat error: ${snapshot.error}');
                  return ErrorRetryWidget(
                    message: 'Failed to load messages',
                    onRetry: () => setState(() {}),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return EmptyStateWidget(
                    title: 'Start a conversation!',
                    message: 'Send a message to get started with ${widget.receiverName}',
                    buttonText: 'Say Hello 👋',
                    onButtonPressed: () {
                      _messageController.text = 'Hello!';
                      setState(() {});
                    },
                    icon: Icons.chat_outlined,
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final bool isMe = message.senderId == _currentUser.uid;

                    return _buildMessage(
                      messageId: message.messageId,
                      message: message.message,
                      timestamp: Timestamp.fromDate(message.timestamp),
                      isMe: isMe,
                      isRead: message.isRead,
                      delivered: message.delivered,
                      mediaUrl: message.mediaUrl,
                      mediaType: message.mediaType,
                    );
                  },
                );
              },
            ),
          ),
          if (_isUploading)
            const LinearProgressIndicator(
              backgroundColor: AppColors.grey,
              color: AppColors.primary,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo, color: AppColors.primary),
                  onPressed: _isUploading || _isRecordingActive
                      ? null
                      : () => _pickMedia(ImageSource.gallery, 'image'),
                ),
                IconButton(
                  icon: Icon(Icons.videocam, color: AppColors.primary),
                  onPressed: _isUploading || _isRecordingActive
                      ? null
                      : () => _pickMedia(ImageSource.gallery, 'video'),
                ),
                if (!_isRecordingActive)
                  IconButton(
                    icon: Icon(Icons.mic, color: AppColors.primary),
                    onPressed: _isUploading || kIsWeb
                        ? null
                        : _startVoiceRecording,
                  ),
                if (_isRecordingActive)
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.error),
                    onPressed: _cancelVoiceRecording,
                  ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(AppBorders.radiusLg),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: AppColors.black),
                      decoration: InputDecoration(
                        hintText: _editingMessageId != null
                            ? 'Edit message...'
                            : 'Type a message...',
                        hintStyle: TextStyle(
                          color: AppColors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppBorders.radiusLg),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        suffixIcon:
                            (_messageController.text.isNotEmpty ||
                                _editingMessageId != null)
                                ? IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: AppColors.grey,
                                    ),
                                    onPressed: () {
                                      _messageController.clear();
                                      if (_editingMessageId != null) {
                                        _cancelEdit();
                                      }
                                    },
                                  )
                                : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isUploading
                      ? null
                      : (_isRecordingActive ? _sendVoiceRecording : _sendMessage),
                  backgroundColor: _isUploading
                      ? AppColors.grey
                      : AppColors.primary,
                  mini: true,
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Icon(
                          _editingMessageId != null
                              ? Icons.check
                              : Icons.send,
                          color: AppColors.white,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isBuffering = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() {
                _isBuffering = false;
              });
            }
          })
          .catchError((error) {
            debugPrint("Error initializing video: $error");
            if (mounted) {
              setState(() {
                _isBuffering = false;
              });
            }
          });

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
          _isBuffering = _controller.value.isBuffering;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller),
            if (!_isPlaying)
              Center(
                child: IconButton(
                  icon: Icon(
                    Icons.play_circle_filled,
                    color: AppColors.white,
                    size: 50,
                  ),
                  onPressed: () {
                    _controller.play();
                  },
                ),
              ),
            if (_isBuffering)
              Center(
                child: CircularProgressIndicator(color: AppColors.white),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: AppColors.primary,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 150,
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.white),
        ),
      );
    }
  }
}

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  const AudioPlayerWidget({super.key, required this.audioUrl});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();
  ap.PlayerState _playerState = ap.PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _playPauseAudio() async {
    try {
      if (_playerState == ap.PlayerState.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(ap.UrlSource(widget.audioUrl));
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(AppBorders.radiusLg),
        border: Border.all(color: AppColors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              _playerState == ap.PlayerState.playing
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill,
              color: AppColors.primary,
              size: 30,
            ),
            onPressed: _playPauseAudio,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6.0,
                    ),
                    overlayShape: SliderComponentShape.noOverlay,
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.white.withOpacity(0.3),
                    thumbColor: AppColors.white,
                  ),
                  child: Slider(
                    min: 0,
                    max: _duration.inSeconds.toDouble(),
                    value: _position.inSeconds.toDouble().clamp(
                      0.0,
                      _duration.inSeconds.toDouble(),
                    ),
                    onChanged: (value) async {
                      try {
                        final newPosition = Duration(seconds: value.toInt());
                        await _audioPlayer.seek(newPosition);
                        if (_playerState == ap.PlayerState.paused) {
                          await _audioPlayer.resume();
                        }
                      } catch (e) {
                        debugPrint('Error seeking audio: $e');
                      }
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.7),
                        fontSize: AppText.labelSmall,
                      ),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.7),
                        fontSize: AppText.labelSmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}