import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/pages/base.dart';
import 'package:flutter_application_1/pages/knowledge_implementation.dart';

class ChatbotRedo extends StatefulWidget {
  final String initialCategory;
  final String? initialImagePath;
  final List<String> initialDetections;
  final Map<String, Map<String, String>> initialComponentImages;
  final List<int> initialBatch;

  const ChatbotRedo({
    super.key,
    required this.initialCategory,
    this.initialImagePath,
    required this.initialDetections,
    required this.initialComponentImages,
    required this.initialBatch,
  });

  @override
  State<ChatbotRedo> createState() => _ChatbotRedoState();
}

class _ChatbotRedoState extends State<ChatbotRedo> {
  bool _isSummaryExpanded = false; // Collapsed by default as requested
  RuleBase? _ruleBase; // Store the loaded rule base
  Node? _currentNode; // Current instruction node
  bool _isLoading = true; // Track if the rule base is still loading
  
  // New variables for component tracking
  String? _currentComponent; // Currently selected component
  Map<String, dynamic>? _componentMapping; // Map of issue types to components
  List<String>? _componentOrder; // Order of components from JSON
  Map<String, String>? _componentStartNodes; // Start nodes for each component
  
  // Store all component image paths for quick access
  Map<String, String> _componentImagePaths = {};
  Map<String, String>? _componentLabelMapping; // Component label mapping

  @override
  void initState() {
    super.initState();
    _loadRuleBase();
    _initializeComponentImagePaths();
  }

  // Initialize the component image paths map for quick access
  void _initializeComponentImagePaths() {
    // Create a flattened map of component name -> image path
    for (var entry in widget.initialComponentImages.entries) {
      for (var component in entry.value.entries) {
        // Extract base component name (remove any suffixes)
        final baseComponentName = component.key.split('_')[0].toLowerCase();
        _componentImagePaths[baseComponentName] = component.value;
      }
    }
    
    print("Component image paths: $_componentImagePaths");
  }

  Future<void> _loadRuleBase() async {
    try {
      print("Loading rule base for category: ${widget.initialCategory}");
      
      final ruleBase = await KnowledgeImplementation.loadRuleBase(widget.initialCategory);
      
      // Parse additional JSON structure (component mapping, order, etc.)
      _parseAdditionalRuleBaseStructure(ruleBase);
      
      print("Rule base loaded: ${ruleBase.nodes.length} nodes");
      if (ruleBase.startNode != null) {
        print("Start node found: ${ruleBase.startNode!.id}");
      } else {
        print("ERROR: Start node not found!");
      }
      
      setState(() {
        _ruleBase = ruleBase;
        _currentNode = ruleBase.startNode;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading rule base: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Parse additional structure from the rule base JSON
  void _parseAdditionalRuleBaseStructure(RuleBase ruleBase) {
    // Access the raw JSON data to get additional structures
    final rawData = KnowledgeImplementation.getRawJsonData(widget.initialCategory);
    if (rawData != null) {
      _componentMapping = rawData['component_mapping'];
      
      // Parse component order
      if (rawData.containsKey('component_order')) {
        _componentOrder = List<String>.from(rawData['component_order']);
      }
      
      // Parse component start nodes
      if (rawData.containsKey('component_start_nodes')) {
        _componentStartNodes = Map<String, String>.from(rawData['component_start_nodes']);
      }
      
      // Parse component label mapping
      if (rawData.containsKey('component_labels')) {
        _componentLabelMapping = Map<String, String>.from(rawData['component_labels']);
      }
      
      print("Component mapping: $_componentMapping");
      print("Component order: $_componentOrder");
      print("Component start nodes: $_componentStartNodes");
      print("Component label mapping: $_componentLabelMapping");
    }
  }
  
  // Updated to properly handle next_component field
  void _navigateToNode(String nodeIdOrComponent) {
    if (_ruleBase == null) return;
    
    // If this is a next_component (just component name), find the proper node ID
    String nodeId = nodeIdOrComponent;
    if (_componentStartNodes != null && _componentStartNodes!.containsKey(nodeIdOrComponent)) {
      // Look up the actual node ID for this component from component_start_nodes
      nodeId = _componentStartNodes![nodeIdOrComponent]!;
      print("Translating component '$nodeIdOrComponent' to node ID: '$nodeId'");
    }
    
    final node = _ruleBase!.findNodeById(nodeId);
    if (node != null) {
      // Check if we're navigating to a component-specific node
      _updateCurrentComponentFromNodeId(nodeId);
      
      setState(() {
        _currentNode = node;
      });
    } else {
      print("ERROR: Could not find node with ID: $nodeId");
    }
  }
  
  // Update the _updateCurrentComponentFromNodeId method:

  void _updateCurrentComponentFromNodeId(String nodeId) {
    // Check if we're navigating to a component extraction node
    if (nodeId.startsWith('extract_')) {
      final componentName = nodeId.substring('extract_'.length);
      setState(() {
        _currentComponent = componentName;
      });
      print("Now working on component: $_currentComponent");
    } 
    // Check if we're navigating to a component issue node
    else if (_componentMapping != null) {
      _componentMapping!.forEach((issue, components) {
        if (nodeId == issue) {
          if (components is String) {
            setState(() {
              _currentComponent = components;
            });
            print("Selected component issue: $_currentComponent");
          } 
          // If multiple components are possible for this issue, don't set current component yet
        }
      });
    }
    
    // IMPORTANT: Reset component when navigating to selection screens
    // Add these conditions to clear the current component
    if (nodeId == 'end' || 
        nodeId == 'start' || 
        nodeId == 'component_extraction' || 
        nodeId == 'issue') {
      setState(() {
        _currentComponent = null;
      });
      print("Reset current component - now at selection screen");
    }
  }
  
  // Get component image for the current component
  String? _getCurrentComponentImagePath() {
    if (_currentComponent == null) return null;
    return _componentImagePaths[_currentComponent];
  }

  void _showImageOverlay(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  color: Colors.black87,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                      ),
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Image.file(
                          File(imagePath),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Base(
      title: 'Extraction Assistant',
      child: Column(
        children: [
          // Collapsible Device Category and Components Section
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: const Color(0xFF34A853),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with Title and Toggle button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Device Category',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isSummaryExpanded 
                            ? Icons.keyboard_arrow_up 
                            : Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSummaryExpanded = !_isSummaryExpanded;
                        });
                      },
                    ),
                  ],
                ),
                
                // Device category value
                Text(
                  widget.initialCategory,
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                // Component chips
                if (widget.initialDetections.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _getUniqueComponents().map((component) {
                        // Get component name without suffixes
                        final displayName = component.split('_')[0];
                        final baseComponent = displayName.toLowerCase();
                        
                        // Highlight the current component
                        final isCurrentComponent = _currentComponent != null && 
                            baseComponent == _currentComponent!.toLowerCase();
                        
                        // Create icon based on component type
                        IconData iconData = _getIconForComponent(baseComponent);
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isCurrentComponent 
                                ? Colors.white 
                                : Colors.white10,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isCurrentComponent 
                                  ? Colors.white 
                                  : Colors.white30
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                iconData,
                                color: isCurrentComponent 
                                    ? const Color(0xFF34A853) 
                                    : Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatComponentName(displayName),
                                style: GoogleFonts.montserrat(
                                  color: isCurrentComponent 
                                      ? const Color(0xFF34A853) 
                                      : Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                
                // Only show these sections when expanded
                if (_isSummaryExpanded && widget.initialComponentImages.isNotEmpty) ...[
                  // Input Images Section
                  const SizedBox(height: 16),
                  Text(
                    'Input Images',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (var imagePath in widget.initialComponentImages.keys)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => _showImageOverlay(context, imagePath),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white30),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(imagePath),
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Detected Components Section
                  const SizedBox(height: 16),
                  Text(
                    'Detected Components',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Horizontal scrolling list of detected component images
                  SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (var entry in widget.initialComponentImages.entries)
                          for (var componentEntry in entry.value.entries)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => _showImageOverlay(context, componentEntry.value),
                                child: Container(
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: _isCurrentComponentImage(componentEntry.key) 
                                        ? Colors.white 
                                        : Colors.white10,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(8),
                                          ),
                                          child: Image.file(
                                            File(componentEntry.value),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 4,
                                        ),
                                        child: Text(
                                          _formatComponentName(componentEntry.key.split('_')[0]),
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            color: _isCurrentComponentImage(componentEntry.key)
                                                ? const Color(0xFF34A853)
                                                : Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Instructions Section
          Expanded(
            child: Container(
              color: Colors.white,
              child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF34A853)))
                : _buildInstructionsContent(),
            ),
          ),
        ],
      ),
    );
  }
  
  // Check if this image corresponds to the current component
  bool _isCurrentComponentImage(String componentKey) {
    if (_currentComponent == null) return false;
    return componentKey.toLowerCase().startsWith(_currentComponent!.toLowerCase());
  }
  
  // Get icon for a component type
  IconData _getIconForComponent(String component) {
    switch (component.toLowerCase()) {
      case 'ram':
        return Icons.memory;
      case 'battery':
      case 'cmos':
        return Icons.battery_full;
      case 'fan':
      case 'cooler':
        return Icons.air;
      case 'wifi':
      case 'card':
        return Icons.wifi;
      case 'drive':
      case 'hdd':
      case 'ssd':
      case 'disk':
        return Icons.storage;
      case 'cpu':
        return Icons.developer_board;
      case 'gpu':
        return Icons.videogame_asset;
      case 'psu':
        return Icons.power;
      case 'mboard':
        return Icons.dashboard;
      case 'case':
        return Icons.computer;
      default:
        return Icons.memory;
    }
  }

  // Build the instructions content based on the current node
  Widget _buildInstructionsContent() {
    if (_currentNode == null) {
      return const Center(
        child: Text('No instructions available for this device.'),
      );
    }
    
    final componentImagePath = _getCurrentComponentImagePath();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Component name at top
          if (_currentComponent != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _formatComponentName(_currentComponent!),
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          
          // Instructions label row
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: const Color(0xFF34A853),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Instructions',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF34A853),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Component image if available
          if (componentImagePath != null) ...[
            GestureDetector(
              onTap: () => _showImageOverlay(context, componentImagePath),
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(componentImagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Node text (question or instruction)
          if (_currentNode!.text != null)
            Text(
              _currentNode!.text!,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                color: Colors.grey[800],
              ),
            ),
          
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // IMPORTANT: Show steps FIRST
                  if (_currentNode!.isStepNode) ...[
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _currentNode!.steps.length,
                      itemBuilder: (context, index) {
                        final step = _currentNode!.steps[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF34A853),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  step.action,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // THEN show options after steps (if we have any)
                  if (_currentNode!.isQuestionNode) ...[
                    if (!_currentNode!.isStepNode) // Only show this label if there are no steps
                      Text(
                        'Select an option:',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    if (!_currentNode!.isStepNode)  
                      const SizedBox(height: 16),
                    
                    // Options below steps
                    ..._getFilteredOptions().map((option) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _navigateToNode(option.next),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF34A853),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              option.label,
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
          
          // Next button for step nodes (keep at bottom)
          if (_currentNode!.isStepNode && _currentNode!.next != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateToNode(_currentNode!.next!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF34A853),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to format component names
  String _formatComponentName(String name) {
    return name[0].toUpperCase() + name.substring(1);
  }

  // Helper method to get unique component names
  List<String> _getUniqueComponents() {
    return widget.initialDetections.toSet().toList();
  }

  // Add this method to filter options based on detected components
  List<Option> _getFilteredOptions() {
    if (_currentNode == null || !_currentNode!.isQuestionNode) {
      return [];
    }
    
    // For the component extraction screen, only show detected components
    if (_currentNode!.id == "component_extraction") {
      return _currentNode!.options.where((option) {
        // Always include navigation options like "Back" or "End"
        if (["Back", "End"].contains(option.label)) {
          return true;
        }
        
        // Convert option label to component name for comparison
        String componentName = _getComponentNameFromLabel(option.label).toLowerCase();
        
        // Check if this component was detected
        return widget.initialDetections.any((detection) {
          return detection.toLowerCase().startsWith(componentName);
        });
      }).toList();
    }
    
    // For other screens, show all options
    return _currentNode!.options;
  }

  // Helper method to extract component name from option label
  String _getComponentNameFromLabel(String label) {
    // If we have a mapping from the JSON, use it
    if (_componentLabelMapping != null) {
      // Try exact match first
      if (_componentLabelMapping!.containsKey(label)) {
        return _componentLabelMapping![label]!;
      }
      
      // Then try partial matches
      for (var entry in _componentLabelMapping!.entries) {
        if (label.toLowerCase().contains(entry.key.toLowerCase())) {
          return entry.value;
        }
      }
    }
    
    // Default: extract the first word and convert to lowercase
    return label.split(' ')[0].toLowerCase();
  }
}