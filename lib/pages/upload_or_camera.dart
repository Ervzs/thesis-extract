import 'package:flutter/material.dart'; 
import 'dart:io'; 
import 'package:image_picker/image_picker.dart'; 
import 'package:flutter_application_1/pages/part_detection.dart'; 
import 'package:flutter_application_1/pages/base.dart'; 
import 'package:google_fonts/google_fonts.dart'; // Added Google Fonts for better typography

// This widget represents the UploadPage screen where users can upload/select images
// Since the UI needs to update dynamically based on the contents of _selectedImages, a StatefulWidget is required.
class UploadPage extends StatefulWidget {
  final String category; // Declares a final variable to store the category passed from previous screen (category.dart)

  const UploadPage({ // Constructor for UploadPage that requires a category
    Key? key, // Optional key to identify the widget uniquely. Key helps Flutter uniquely identify widgets during rebuilds(e.g., during hot reload ).
              // It allows Flutter to maintain state when the widget is moved or rebuilt.
    required this.category, // Requires a category to be passed when creating UploadPage
  }) : super(key: key); // Passes the key to the superclass constructor

  @override 
  _UploadPageState createState() => _UploadPageState(); // It links the UploadPage widget to its corresponding state class (_UploadPageState), 
                                                       //enabling the widget to rebuild dynamically when its state changes.
                                                       
}

// The mutable state class for UploadPage
class _UploadPageState extends State<UploadPage> {
  List<File> _selectedImages = []; // A list to store all selected image files
  final ImagePicker _picker = ImagePicker(); // Creates an instance of ImagePicker to select images

  // Asynchronous method to pick a single image from the camera
  Future<void> _pickImageFromCamera() async { // This is a asynchronous, allowing you to perform tasks that take time without blocking the main thread.
    try { 
      final XFile? pickedImage = await _picker.pickImage(source: ImageSource.camera); // Opens camera and waits for image
      if (pickedImage != null) { // Checks if an image was picked
        setState(() { // Updates/informs the UI to reflect changes
          _selectedImages.add(File(pickedImage.path)); 
        });
      }
    } catch (e) { 
      print("Error picking image from camera: $e"); 
    }
  }

  // Asynchronous method to pick multiple images from the gallery
  Future<void> _pickMultipleImages() async {
    try { 
      final List<XFile> pickedImages = await _picker.pickMultiImage(); // Opens gallery and allows multiple image selection
      if (pickedImages.isNotEmpty) { // Checks if any images were selected
        setState(() { // Updates the UI
          for (var image in pickedImages) { // Loops through each selected image
            _selectedImages.add(File(image.path)); // Adds each image to the list
          }
        });
      }
    } catch (e) {
      print("Error picking multiple images: $e");
    }
  }

  // Method to remove a selected image by its index in the list
  void _removeImage(int index) {
    setState(() { // Updates the UI
      _selectedImages.removeAt(index); // Removes the image at the given index
    });
  }

  // Helper method to build styled buttons with gradients and shadows
  Widget _buildUploadCameraButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap, // Calls the provided function when tapped
      child: Container(
        decoration: BoxDecoration( // Adds decorations to button
          gradient: const LinearGradient( // Creates a gradient background
            colors: [Color(0xFF34A853), Color(0xFF0F9D58)], // From lighter green to darker green
            begin: Alignment.topLeft, // Gradient starts from top left
            end: Alignment.bottomRight, // Gradient ends at bottom right
          ),
          borderRadius: BorderRadius.circular(20), // Rounded corners
          boxShadow: [ // Adds shadow for depth
            BoxShadow(
              color: Colors.black.withOpacity(0.3), // Semi-transparent black
              offset: const Offset(0, 4), // Shadow offset down by 4 pixels
              blurRadius: 10, // Shadow blur effect
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20), // Padding inside button
        child: Row( // Row to align icon and text horizontally
          mainAxisAlignment: MainAxisAlignment.center, // Center alignment
          children: [
            Icon(icon, color: Colors.white, size: 40), // Button icon
            const SizedBox(width: 10), // Spacing between icon and text
            Text( // Button text
              label,
              style: GoogleFonts.montserrat( // Using Google Fonts for better typography
                fontSize: 20, // Text size
                fontWeight: FontWeight.bold, // Bold text
                color: Colors.white, // Text color
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override 
  Widget build(BuildContext context) {
    return Base( // Using Base.dart with the common UI designs
      title: widget.category, // Pass category as the title
      child: SingleChildScrollView( // Allows scrolling if content exceeds screen
        padding: const EdgeInsets.all(16.0), // Sets 16 pixels of padding on all sides
        child: Column( // Arranges widgets vertically
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretches children horizontally
          children: [ // List of widgets inside the column
            const SizedBox(height: 50), // Adds vertical spacing from the top
            
            // Instructional text with improved styling
            Text(
              'Upload pictures of your e-waste or use your camera.', // The text content
              style: GoogleFonts.montserrat( // Using Google Fonts
                color: Colors.white70, // Slightly transparent white
                fontSize: 20, // Larger font size
                fontWeight: FontWeight.w600, // Medium-bold weight
              ),
              textAlign: TextAlign.center, // Centers the text
            ),
            
            const SizedBox(height: 20), // Adds vertical space

            // Horizontal scrolling image list instead of grid
            if (_selectedImages.isNotEmpty) // If there are images selected
              SizedBox(
                height: 300, // Fixed height for the image container
                child: ListView.separated( // Creates a scrollable horizontal list
                  scrollDirection: Axis.horizontal, // Horizontal scrolling
                  itemCount: _selectedImages.length, // Number of items in list
                  separatorBuilder: (_, __) => const SizedBox(width: 10), // Space between images
                  itemBuilder: (context, index) { // Builds each list item
                    return Stack( // Places widgets on top of each other
                      children: [
                        // Image container with border
                        Container(
                          width: 200, // Fixed width for each image
                          height: 300, // Fixed height for each image
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 4), // Thick black border
                          ),
                          child: ClipRRect( // Clips the image to the container
                            child: Image.file(
                              _selectedImages[index], // Gets image from list
                              fit: BoxFit.cover, // Scales image to cover the box
                            ),
                          ),
                        ),
                        
                        // Delete button positioned at top-right
                        Positioned(
                          top: 4, // Position from top
                          right: 4, // Position from right
                          child: GestureDetector( // Detects tap on the close button
                            onTap: () => _removeImage(index), // Calls method to remove image
                            child: Container( // A circular red close button
                              decoration: const BoxDecoration( // Circle background
                                color: Colors.redAccent, // Sets red color
                                shape: BoxShape.circle, // Makes the shape circular
                              ),
                              padding: const EdgeInsets.all(6), // Padding inside the button
                              child: const Icon( // Close (X) icon
                                Icons.close, // The X icon
                                color: Colors.white, // White icon color
                                size: 20, // Icon size
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            else // If no images are selected
              SizedBox( // Creates a fixed height box
                height: 200, // Box height
                child: Center( // Centers the child
                  child: Text( // Displays message
                    'No images selected yet', // Text content
                    style: GoogleFonts.montserrat( // Using Google Fonts
                      color: Colors.white54, // White with opacity
                      fontSize: 16, // Font size
                      fontWeight: FontWeight.w500, // Medium weight
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20), // Adds spacing before buttons
            
            // Button to upload multiple images from gallery - using our custom button builder
            _buildUploadCameraButton(
              label: 'Upload Image',
              icon: Icons.upload_file,
              onTap: _pickMultipleImages, // Calls method to pick multiple images
            ),
            
            const SizedBox(height: 10), // Adds vertical space
            
            // Button to use camera - using our custom button builder
            _buildUploadCameraButton(
              label: 'Use Camera',
              icon: Icons.camera_alt,
              onTap: _pickImageFromCamera, // Calls method to pick image from camera
            ),

            // Continue button - only shown if images are selected
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 20), // Space above continue button
              
              // Enhanced continue button with gradient and shadow
              ElevatedButton(
                onPressed: () { // On button press
                  Navigator.push( // Navigate to another screen
                    context,
                    MaterialPageRoute( // Creates a route to DetectionPage
                      builder: (context) => DetectionPage( // Passes required data
                        category: widget.category,
                        selectedImages: _selectedImages,
                      ),
                    ),
                  );
                },
                // Complex styling with transparent background and gradient ink
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.transparent, // Transparent background
                  shadowColor: Colors.transparent, // No shadow from ElevatedButton
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                  ),
                ).copyWith( // Extra styling properties
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  backgroundColor: MaterialStateProperty.all(
                    Colors.transparent,
                  ),
                ),
                child: Ink( // Uses Ink widget for gradient background
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF34A853), Color(0xFF0F9D58)], // Green gradient
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10), // Padding inside button
                    alignment: Alignment.center, // Centers text
                    child: Text(
                      'Continue', // Button text
                      style: GoogleFonts.montserrat(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
