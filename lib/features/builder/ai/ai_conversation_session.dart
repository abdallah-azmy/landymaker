class AIConversationMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime timestamp;

  AIConversationMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  factory AIConversationMessage.fromJson(Map<String, dynamic> json) => AIConversationMessage(
    role: json['role'],
    content: json['content'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class BusinessProfile {
  String? businessName;
  String? industry;
  String? offer;
  String? targetAudience;
  String? brandTone;
  String? businessType;

  BusinessProfile({
    this.businessName,
    this.industry,
    this.offer,
    this.targetAudience,
    this.brandTone,
    this.businessType,
  });

  bool get isIncomplete => businessName == null || industry == null || offer == null;

  Map<String, dynamic> toJson() => {
    'business_name': businessName,
    'industry': industry,
    'offer': offer,
    'target_audience': targetAudience,
    'brand_tone': brandTone,
    'business_type': businessType,
  };

  factory BusinessProfile.fromJson(Map<String, dynamic> json) => BusinessProfile(
    businessName: json['business_name'],
    industry: json['industry'],
    offer: json['offer'],
    targetAudience: json['target_audience'],
    brandTone: json['brand_tone'],
    businessType: json['business_type'],
  );
}

class AIConversationSession {
  final String sessionId;
  final List<AIConversationMessage> messages = [];
  String memorySummary = "";
  BusinessProfile businessProfile = BusinessProfile();

  AIConversationSession({required this.sessionId});

  static const int maxMessages = 30;
  static const int fullMessageThreshold = 10;
  static const int maxContentLength = 200;

  void addMessage(String role, String content) {
    messages.add(AIConversationMessage(
      role: role,
      content: content,
      timestamp: DateTime.now(),
    ));
    
    // Maintain last 30 messages (up from 10)
    if (messages.length > maxMessages) {
      messages.removeAt(0);
    }
  }

  List<Map<String, dynamic>> getCompressedMessages() {
    final int count = messages.length;
    return messages.asMap().entries.map((entry) {
      final int i = entry.key;
      final msg = entry.value;
      final bool isRecent = i >= count - fullMessageThreshold;
      return {
        'role': msg.role,
        'content': isRecent ? msg.content : _compress(msg.content),
        'timestamp': msg.timestamp.toIso8601String(),
      };
    }).toList();
  }

  String _compress(String text) {
    if (text.length <= maxContentLength) return text;
    return '${text.substring(0, maxContentLength)}... (مضغوط)';
  }

  void rollbackLastMessage() {
    if (messages.isNotEmpty) {
      messages.removeLast();
    }
  }

  void updateProfileFromAI(Map<String, dynamic> profileJson) {
    businessProfile = BusinessProfile.fromJson(profileJson);
  }

  void updateSummary(String newSummary) {
    memorySummary = newSummary;
  }

  Map<String, dynamic> getContextForAI(Map<String, dynamic> currentDesign) {
    final blocks = currentDesign['blocks'] as List? ?? [];
    final List<String> sectionTypes = blocks
        .map((block) => (block['type'] as String? ?? 'unknown'))
        .toList();

    // Include per-block background & animation context for AI editing
    final List<Map<String, dynamic>> sectionDetails = [];
    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      sectionDetails.add({
        'type': block['type'],
        'index': i,
        'bg_image_url': block['bg_image_url'],
        'animation_type': block['animation']?['type'],
        'is_visible': block['is_visible'] ?? true,
      });
    }

    final theme = (currentDesign['global_theme'] ?? currentDesign['theme']) as Map<String, dynamic>?;
    final Map<String, dynamic> snapshot = {
      'sections': sectionTypes,
      'section_count': sectionTypes.length,
      'section_details': sectionDetails,
      'theme': theme != null ? {
        'primary': theme['primary'],
        'secondary': theme['secondary'],
        'background': theme['background'],
        'textPrimary': theme['textPrimary'],
        'textSecondary': theme['textSecondary'],
        'font_family': theme['font_family'],
        'button_text_color': theme['button_text_color'],
        'globalBgColorHex': theme['globalBgColorHex'],
        'globalBgImageUrl': theme['globalBgImageUrl'],
      } : {},
    };

    return {
      'memory_summary': memorySummary,
      'business_profile': businessProfile.toJson(),
      'builder_snapshot': snapshot,
      'recent_messages': getCompressedMessages(),
    };
  }
}
