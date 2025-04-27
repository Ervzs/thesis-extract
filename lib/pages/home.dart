import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/category.dart';

// A widget called HomePage that doesn't change (stateless).
class HomePage extends StatelessWidget {
  // Constructor for HomePage, marked as constant for performance optimization. `super.key` passes the key to the parent class.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold provides the basic visual structure of the screen (app bar, body, floating buttons, etc.)
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),

      // SafeArea keeps content away from system UI like notches, status bars, and curved edges.
      body: SafeArea(
        // Padding adds space around the entire body content — 24 pixels on the sides, 40 on top and bottom.
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),

          // Column arranges child widgets vertically, from top to bottom.
          child: Column(
            // Space the top and bottom sections as far apart as possible.
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            // Children are all the widgets that appear inside this vertical Column.
            children: [
              // Another Column to group top content together vertically.
              Column(
                children: [
                  // Title text widget showing the app name "e-Xtract".
                  const Text(
                    'e-Xtract',
                    style: TextStyle(
                      fontSize: 40.0, 
                      fontWeight: FontWeight.bold, // Bold font
                      color: Color(0xFF4CD97B), 
                    ),
                  ),

                  // Adds space (16 pixels) below the title text.
                  const SizedBox(height: 16),

                  
                  const Text(
                    'Identify and extract valuable components in your e-waste instantly.',
                    textAlign: TextAlign.center, 
                    style: TextStyle(
                      fontSize: 16.0, 
                      color: Colors.white70, 
                      height: 1.5, // Line height between lines of text
                    ),
                  ),

                  // Adds space (60 pixels) below the description.
                  const SizedBox(height: 60.0),

                  // A circular container for the scan icon.
                  Container(
                    width: 80, 
                    height: 80, 
                    decoration: BoxDecoration(
                      color: Colors.grey[800], // Dark grey background
                      borderRadius: BorderRadius.circular(40), // Makes it circular (half of 80)
                    ),
                    // Icon inside the container, represents scanning.
                    child: const Icon(
                      Icons.document_scanner_outlined, // Scan icon
                      size: 40, // Size of the icon
                      color: Colors.white, // White icon color
                    ),
                  ),

                  // Adds space below the scan icon.
                  const SizedBox(height: 20.0),

                  // Text label "Scan" below the icon.
                  const Text(
                    'Scan',
                    style: TextStyle(
                      fontSize: 28.0, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white, 
                    ),
                  ),

                  // Adds space below the "Scan" label.
                  const SizedBox(height: 8.0),

                  
                  const Text(
                    'Analyze e-waste using your camera',
                    style: TextStyle(
                      fontSize: 14.0, 
                      color: Colors.white70, 
                    ),
                  ),
                ],
              ),

              // A button that the user can press to get started and proceed to category.dart page.
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Category()),
                  );
                },

                // Styling the button using a custom green background, full width, and rounded corners
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CD97B), // Green background color
                  minimumSize: const Size(double.infinity, 56), // Full width, fixed height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                ),

                // Text inside the button
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18.0, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white, 
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
