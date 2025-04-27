import 'package:flutter/material.dart'; 
import 'dart:io'; 
import 'package:image_picker/image_picker.dart'; 
import 'package:flutter_application_1/pages/detection.dart'; 
import 'package:flutter_application_1/pages/base.dart'; // Import Base widget

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
  Future<void> _pickImageFromCamera() async { // This is a asynchronous, allowing you to perform tasks that take time withouth blocking the main thread.
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

  @override 
  Widget build(BuildContext context) {
    return Base( // Using Base.dart with the common UI designs
      title: widget.category, // Pass category as the title
      child: SafeArea(
         // Ensures UI avoids notches, status bar, etc.
        child: Column( // Arranges child widgets vertically
          children: [ // List of widgets inside the column
            // Main content section
            Expanded( // Takes up remaining vertical space
              child: Padding( // Adds padding around the child widget
                padding: const EdgeInsets.all(16.0), // Sets 16 pixels of padding on all sides
                child: Column( // Arranges widgets vertically
                  children: [ // List of widgets inside the column

                    const Text( // Displays instructional text
                      'Upload pictures of your e-waste or use your camera.', // The text content
                      textAlign: TextAlign.center, // Centers the text
                      style: TextStyle( // Sets the text style
                        color: Colors.white, // White color
                        fontSize: 18, // Font size 18
                      ),
                    ),

                    const SizedBox(height: 24), // Adds vertical space of 24 pixels

                    if (_selectedImages.isNotEmpty) // If there are images selected
                      Expanded( // Widget takes all available vertical space
                        child: GridView.builder( // Creates a scrollable grid layout
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( // Defines grid layout properties
                            crossAxisCount: 2, // Number of columns
                            crossAxisSpacing: 8, // Space between columns
                            mainAxisSpacing: 8, // Space between rows
                          ),
                          itemCount: _selectedImages.length, // Number of items in grid
                          itemBuilder: (context, index) { // Builds each grid item
                            return Stack( // Places widgets on top of each other
                              alignment: Alignment.topRight, // Aligns child to top right
                              children: [ // List of widgets in the stack
                                Container( // A container for styling the image
                                  decoration: BoxDecoration( // Adds border decoration
                                    border: Border.all(color: Colors.white54), // White border with opacity
                                  ),
                                  child: Image.file( // Displays the image from file
                                    _selectedImages[index], // Gets image from list
                                    height: 150, // Image height
                                    width: double.infinity, // Fills available width
                                    fit: BoxFit.cover, // Scales image to cover the box
                                  ),
                                ),
                                
                                GestureDetector( // Detects tap on the close button
                                  onTap: () => _removeImage(index), // Calls method to remove image
                                  child: Container( // A circular red close button
                                    margin: const EdgeInsets.all(4), // Margin around the button
                                    padding: const EdgeInsets.all(4), // Padding inside the button
                                    decoration: const BoxDecoration( // Circle background
                                      shape: BoxShape.circle, // Makes the shape circular
                                      color: Colors.redAccent, // Sets red color
                                    ),
                                    child: const Icon( // Close (X) icon
                                      Icons.close, // The X icon
                                      color: Colors.white, // White icon color
                                      size: 18, // Icon size
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                    if (_selectedImages.isEmpty) // If no images are selected
                      const Expanded( // Takes up vertical space
                        child: Center( // Centers the text
                          child: Text( // Displays message
                            'No images selected yet', // Text content
                            style: TextStyle( // Text style
                              color: Colors.white54, // White with opacity
                              fontSize: 16, // Font size
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 16), // Adds spacing before buttons

                    // Button to upload multiple images from gallery
                    SizedBox( // Creates a fixed-width box
                      width: double.infinity, // Takes full width
                      child: ElevatedButton.icon( // A button with an icon and label
                        onPressed: _pickMultipleImages, // Calls method to pick multiple images
                        icon: const Icon(Icons.upload_file), // Upload icon
                        label: const Text('Upload Image'), // Button label
                        style: ElevatedButton.styleFrom( // Button style
                          backgroundColor: const Color(0xFF4CAF50), // Green background
                          foregroundColor: Colors.white, // White text and icon
                          padding: const EdgeInsets.symmetric(vertical: 16), // Vertical padding
                          shape: RoundedRectangleBorder( // Rounded corners
                            borderRadius: BorderRadius.circular(8), // Corner radius
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16), // Adds vertical space

                    // Button to use camera
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _pickImageFromCamera, // Calls method to pick image from camera
                        icon: const Icon(Icons.camera_alt), // Camera icon
                        label: const Text('Use Camera'), // Label text
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    if (_selectedImages.isNotEmpty) // If any images are selected
                      Padding( // Adds padding around the button
                        padding: const EdgeInsets.only(top: 16), // Only top padding
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton( // Continue button
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

                            // For the continue Button
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Continue'), // Button text
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
    );
  }
}
