class MemoryNode {
  final String id;
  final String type;
  final String label;
  final Map<String, dynamic> attributes;
  final double confidence;
  final int referenceCount;
  final double? similarity;

  MemoryNode({
    required this.id,
    required this.type,
    required this.label,
    required this.attributes,
    required this.confidence,
    required this.referenceCount,
    this.similarity,
  });

  factory MemoryNode.fromJson(Map<String, dynamic> json) {
    return MemoryNode(
      id: json['id'] as String,
      type: json['type'] as String,
      label: json['label'] as String,
      attributes: Map<String, dynamic>.from(json['attributes'] ?? {}),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      referenceCount: json['reference_count'] ?? 0,
      similarity: json['similarity'] != null
          ? (json['similarity'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'label': label,
      'attributes': attributes,
      'confidence': confidence,
      'reference_count': referenceCount,
      if (similarity != null) 'similarity': similarity,
    };
  }

  MemoryNode copyWith({
    String? id,
    String? type,
    String? label,
    Map<String, dynamic>? attributes,
    double? confidence,
    int? referenceCount,
    double? similarity,
  }) {
    return MemoryNode(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      attributes: attributes ?? this.attributes,
      confidence: confidence ?? this.confidence,
      referenceCount: referenceCount ?? this.referenceCount,
      similarity: similarity ?? this.similarity,
    );
  }
}

// Node types enum for easy filtering
enum NodeType {
  all,
  person,
  place,
  preference,
  organization,
  event,
  concept;

  String get value => name == 'all' ? '' : name;

  String get displayName {
    switch (this) {
      case NodeType.all:
        return 'All';
      case NodeType.person:
        return 'Person';
      case NodeType.place:
        return 'Place';
      case NodeType.preference:
        return 'Preference';
      case NodeType.organization:
        return 'Organization';
      case NodeType.event:
        return 'Event';
      case NodeType.concept:
        return 'Concept';
    }
  }

  static NodeType fromString(String value) {
    return NodeType.values.firstWhere(
      (type) => type.value == value.toLowerCase(),
      orElse: () => NodeType.all,
    );
  }
}
