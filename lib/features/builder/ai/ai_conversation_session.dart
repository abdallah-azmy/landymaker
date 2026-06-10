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

  void addMessage(String role, String content) {
    messages.add(AIConversationMessage(
      role: role,
      content: content,
      timestamp: DateTime.now(),
    ));
    
    // Maintain last 10 messages
    if (messages.length > 10) {
      messages.removeAt(0);
    }
  }

  void updateProfileFromAI(Map<String, dynamic> profileJson) {
    businessProfile = BusinessProfile.fromJson(profileJson);
  }

  void updateSummary(String newSummary) {
    memorySummary = newSummary;
  }

  Map<String, dynamic> getContextForAI(Map<String, dynamic> currentDesign) {
    // LAYER 3: Builder Snapshot (Compressed)
    final List<String> sectionTypes = (currentDesign['blocks'] as List? ?? [])
        .map((block) => (block['type'] as String? ?? 'unknown'))
        .toList();
    
    final Map<String, dynamic> snapshot = {
      'sections': sectionTypes,
      'theme': {
        'primary': currentDesign['global_theme']?['primary'],
        'background': currentDesign['global_theme']?['background'],
      }
    };

    return {
      'memory_summary': memorySummary,
      'business_profile': businessProfile.toJson(),
      'builder_snapshot': snapshot,
      'recent_messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}
