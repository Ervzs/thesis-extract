import 'dart:convert';
import 'package:flutter/services.dart';

/// Class to load and handle rule-based knowledge from JSON files
class KnowledgeImplementation {
  // Maps to store loaded rule bases to avoid reloading the same file
  static final Map<String, RuleBase> _loadedRuleBases = {};
  
  // Store raw JSON data for access to additional structures
  static final Map<String, Map<String, dynamic>> _rawJsonData = {};

  /// Load the rule base for a specific device category
  static Future<RuleBase> loadRuleBase(String category) async {
    // Convert category to lowercase for consistent file naming
    final normalizedCategory = category.toLowerCase().replaceAll(' ', '_');
    
    print("Looking for rule base: assets/${normalizedCategory}_instructions.json");
    
    // Return cached rule base if already loaded
    if (_loadedRuleBases.containsKey(normalizedCategory)) {
      return _loadedRuleBases[normalizedCategory]!;
    }
    
    try {
      // Load rule base from JSON file
      final jsonString = await rootBundle.loadString(
        'assets/${normalizedCategory}_instructions.json'
      );
      
      print("JSON string loaded, length: ${jsonString.length}");
      
      // Parse JSON
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Store the raw JSON data for access to additional structures
      _rawJsonData[normalizedCategory] = jsonData;
      
      print("JSON decoded successfully");
      
      // Create rule base object
      final ruleBase = RuleBase.fromJson(jsonData);
      
      // Log successful parsing
      print("Rule base created with ${ruleBase.nodes.length} nodes");
      
      // Cache the loaded rule base
      _loadedRuleBases[normalizedCategory] = ruleBase;
      
      return ruleBase;
    } catch (e) {
      print('Error loading rule base for $category: $e');
      // Return empty rule base if there's an error
      return RuleBase(nodes: []);
    }
  }
  
  /// Get the raw JSON data for the currently loaded rule base
  static Map<String, dynamic>? getRawJsonData([String? category]) {
    if (_rawJsonData.isEmpty) return null;
    
    if (category != null) {
      final normalized = category.toLowerCase().replaceAll(' ', '_');
      return _rawJsonData[normalized];
    }
    
    return _rawJsonData.values.first;
  }
}

/// Represents the complete rule base loaded from a JSON file
class RuleBase {
  final List<Node> nodes;
  
  RuleBase({required this.nodes});
  
  /// Create a RuleBase from JSON data
  factory RuleBase.fromJson(Map<String, dynamic> json) {
    final List<dynamic> nodesList = json['nodes'] ?? [];
    final List<Node> nodes = nodesList.map((nodeJson) => Node.fromJson(nodeJson)).toList();
    
    return RuleBase(nodes: nodes);
  }
  
  /// Find a node by its ID
  Node? findNodeById(String id) {
    try {
      return nodes.firstWhere((node) => node.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Get the starting node (usually with ID 'start')
  Node? get startNode {
    return findNodeById('start');
  }
}

/// Represents a single node in the rule base
class Node {
  final String id;
  final String? text;
  final List<Option> options;
  final List<Step> steps;
  final String? next;
  
  Node({
    required this.id,
    this.text,
    this.options = const [],
    this.steps = const [],
    this.next,
  });
  
  /// Create a Node from JSON data
  factory Node.fromJson(Map<String, dynamic> json) {
    // Parse options if present
    final List<Option> options = [];
    if (json.containsKey('options')) {
      final List<dynamic> optionsList = json['options'];
      options.addAll(optionsList.map((option) => Option.fromJson(option)));
    }
    
    // Parse steps if present
    final List<Step> steps = [];
    if (json.containsKey('steps')) {
      final List<dynamic> stepsList = json['steps'];
      steps.addAll(stepsList.map((step) => Step.fromJson(step)));
      
      // Sort steps by order
      steps.sort((a, b) => a.order.compareTo(b.order));
    }
    
    return Node(
      id: json['id'],
      text: json['text'],
      options: options,
      steps: steps,
      next: json['next'],
    );
  }
  
  /// Determines if this node is a question node (has options)
  bool get isQuestionNode => options.isNotEmpty;
  
  /// Determines if this node is a step-by-step instruction node
  bool get isStepNode => steps.isNotEmpty;
}

/// Represents a choice option in a question node
class Option {
  final String label;
  final String next;
  
  Option({required this.label, required this.next});
  
  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      label: json['label'],
      next: json['next'],
    );
  }
}

/// Represents a single step in an instruction
class Step {
  final int order;
  final String action;
  
  Step({required this.order, required this.action});
  
  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      order: json['order'],
      action: json['action'],
    );
  }
}