import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:aspire_edge/constants.dart';
import 'package:aspire_edge/models/resource_model.dart';

class AdminAddEditResourceScreen extends StatefulWidget {
  final String careerId;
  final String careerTitle;
  final ResourceModel? resource;

  const AdminAddEditResourceScreen({
    super.key,
    required this.careerId,
    required this.careerTitle,
    this.resource,
  });

  @override
  State<AdminAddEditResourceScreen> createState() =>
      _AdminAddEditResourceScreenState();
}

class _AdminAddEditResourceScreenState
    extends State<AdminAddEditResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _displayImageController = TextEditingController(); // ADD THIS

  final List<String> _tags = [];
  String? _selectedType;
  String _mediaType = 'image';
  String? _fileUrl;
  bool _uploading = false;
  bool _isEditing = false;

  // ADD THESE NEW VARIABLES
  String? _displayImageUrl;
  XFile? _selectedDisplayImage;
  bool _uploadingDisplayImage = false;

  XFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.resource != null;

    if (_isEditing && widget.resource != null) {
      _titleController.text = widget.resource!.title;
      _authorController.text = widget.resource!.author;
      _urlController.text = widget.resource!.url;
      _selectedType = widget.resource!.type;
      _mediaType = widget.resource!.mediaType;
      _fileUrl = widget.resource!.url;
      _tags.addAll(widget.resource!.tags);
      
      // ADD DISPLAY IMAGE INITIALIZATION
      _displayImageUrl = widget.resource!.displayImageUrl;
      _displayImageController.text = _displayImageUrl ?? '';
    }
  }

  // ADD DISPLAY IMAGE UPLOAD METHOD
  Future<void> _uploadDisplayImageToCloudinary() async {
    if (_selectedDisplayImage == null) return;

    setState(() => _uploadingDisplayImage = true);

    try {
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/dezave6hv/upload");
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'imageedge';

      final bytes = await _selectedDisplayImage!.readAsBytes();
      final filename = path.basename(_selectedDisplayImage!.path);

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonMap = jsonDecode(responseData);
        setState(() {
          _displayImageUrl = jsonMap['secure_url'];
          _displayImageController.text = _displayImageUrl!;
          _uploadingDisplayImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Display image uploaded successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _uploadingDisplayImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Display image upload failed. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _uploadingDisplayImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Display image upload error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ADD DISPLAY IMAGE PICKER METHOD
  Future<void> _pickDisplayImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        setState(() {
          _selectedDisplayImage = pickedImage;
        });
        await _uploadDisplayImageToCloudinary();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error picking display image: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // KEEP EXISTING FILE PICKER METHOD
  Future<void> _pickFile(ImageSource source) async {
    try {
      final picker = ImagePicker();
      XFile? pickedFile;

      if (_mediaType == 'video') {
        pickedFile = await picker.pickVideo(source: source);
      } else {
        pickedFile = await picker.pickImage(source: source);
      }

      if (pickedFile != null) {
        setState(() {
          _selectedFile = pickedFile;
        });
        await _uploadToCloudinary();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error picking file: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // KEEP EXISTING UPLOAD METHOD
  Future<void> _uploadToCloudinary() async {
    if (_selectedFile == null) return;

    setState(() => _uploading = true);

    try {
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/dezave6hv/upload");
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'imageedge';

      final bytes = await _selectedFile!.readAsBytes();
      final filename = path.basename(_selectedFile!.path);

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonMap = jsonDecode(responseData);
        setState(() {
          _fileUrl = jsonMap['secure_url'];
          _urlController.text = _fileUrl!;
          _uploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("File uploaded successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Upload failed. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag)) {
      setState(() => _tags.add(trimmedTag));
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  // UPDATE SUBMIT FORM METHOD
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // If a new file was selected, upload it first
      if (_selectedFile != null) {
        await _uploadToCloudinary();
      }

      // Upload display image if selected
      if (_selectedDisplayImage != null) {
        await _uploadDisplayImageToCloudinary();
      }

      if (_fileUrl == null && _urlController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please upload a file or provide a URL"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final resourceUrl = _fileUrl ?? _urlController.text;

      try {
        final resourceData = {
          'resourceId':
              _isEditing ? widget.resource!.resourceId : randomAlphaNumeric(12),
          'careerId': widget.careerId,
          'title': _titleController.text.trim(),
          'author': _authorController.text.trim(),
          'type': _selectedType!,
          'url': resourceUrl,
          'mediaType': _mediaType,
          'tags': _tags,
          'displayImageUrl': _displayImageUrl, // ADD THIS FIELD
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (_isEditing) {
          await FirebaseFirestore.instance
              .collection('resources')
              .doc(widget.resource!.resourceId)
              .update(resourceData);
        } else {
          await FirebaseFirestore.instance
              .collection('resources')
              .doc(resourceData['resourceId'] as String?)
              .set({
            ...resourceData,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? "Resource updated successfully"
                : "Resource added successfully"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving resource: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ADD DISPLAY IMAGE SECTION WIDGET
  Widget _buildDisplayImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            "Display Image (Optional)",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
        Text(
          "This image will be shown in resource cards. Recommended: 400x300px",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        
        // Display Image Preview
        if (_displayImageUrl != null) ...[
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(_displayImageUrl!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _displayImageController,
                  decoration: InputDecoration(
                    hintText: "Display image URL",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _displayImageUrl = value.isNotEmpty ? value : null;
                    });
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _displayImageUrl = null;
                    _displayImageController.clear();
                    _selectedDisplayImage = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        
        // Upload Display Image Button
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: _uploadingDisplayImage ? null : _pickDisplayImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_uploadingDisplayImage)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(primaryColor),
                      ),
                    )
                  else
                    Icon(
                      Icons.add_photo_alternate,
                      color: primaryColor,
                      size: 22,
                    ),
                  const SizedBox(width: 12),
                  Text(
                    _uploadingDisplayImage
                        ? "Uploading Display Image..."
                        : "Upload Display Image",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Or enter URL directly
        const SizedBox(height: 12),
        TextFormField(
          controller: _displayImageController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            hintText: "Or enter display image URL directly",
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.link, size: 20, color: Colors.grey[600]),
          ),
          keyboardType: TextInputType.url,
          onChanged: (value) {
            setState(() {
              _displayImageUrl = value.isNotEmpty ? value : null;
            });
          },
        ),
      ],
    );
  }

  // Helper method to determine if author field should be shown
  bool get _showAuthorField {
    return _selectedType == 'ebook' || _selectedType == 'blog';
  }

  // Helper method to determine media type options based on resource type
  List<String> get _availableMediaTypes {
    switch (_selectedType) {
      case 'blog':
        return ['image']; // Blogs typically use images
      case 'video':
        return ['video']; // Videos use video media type
      case 'ebook':
        return ['image', 'pdf']; // E-books can have cover images or PDFs
      default:
        return ['image', 'video']; // Default options
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _isEditing ? "Edit Resource" : "Add Resource",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black54),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Resource"),
                    content: const Text(
                        "Are you sure you want to delete this resource?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("Delete",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await FirebaseFirestore.instance
                      .collection('resources')
                      .doc(widget.resource!.resourceId)
                      .delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Resource deleted successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );

                  Navigator.of(context).pop(true);
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Career Title
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.work_outline, color: AppColors.primaryDark, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "For: ${widget.careerTitle}",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Resource Type
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  "Resource Type *",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  style: const TextStyle(fontSize: 15),
                  value: _selectedType,
                  items: const [
                    DropdownMenuItem(value: 'blog', child: Text('Blog Article')),
                    DropdownMenuItem(value: 'video', child: Text('Video')),
                    DropdownMenuItem(value: 'ebook', child: Text('E-Book')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                      // Reset media type when resource type changes
                      if (value == 'video') {
                        _mediaType = 'video';
                      } else {
                        _mediaType = 'image';
                      }
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a type' : null,
                  icon: const Icon(Icons.arrow_drop_down, size: 24),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  "Title *",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    hintText: "Enter resource title",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Title is required' : null,
                ),
              ),

              const SizedBox(height: 20),

              // Author (conditionally shown)
              if (_showAuthorField) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    "Author *",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _authorController,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      hintText: "Enter author name",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                    validator: (value) {
                      if (_showAuthorField && (value?.isEmpty ?? true)) {
                        return 'Author is required for ${_selectedType == 'ebook' ? 'E-Books' : 'Blogs'}';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ADD DISPLAY IMAGE SECTION HERE
              _buildDisplayImageSection(),

              const SizedBox(height: 20),

              // Media Type Selection
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  "Media Type *",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      if (_availableMediaTypes.contains('image'))
                        Expanded(
                          child: _MediaTypeOption(
                            title: "Image",
                            icon: Icons.image_outlined,
                            value: 'image',
                            groupValue: _mediaType,
                            onChanged: (value) {
                              if (value != null) setState(() => _mediaType = value);
                            },
                          ),
                        ),
                      if (_availableMediaTypes.contains('video'))
                        Expanded(
                          child: _MediaTypeOption(
                            title: "Video",
                            icon: Icons.videocam_outlined,
                            value: 'video',
                            groupValue: _mediaType,
                            onChanged: (value) {
                              if (value != null) setState(() => _mediaType = value);
                            },
                          ),
                        ),
                      if (_availableMediaTypes.contains('pdf'))
                        Expanded(
                          child: _MediaTypeOption(
                            title: "PDF",
                            icon: Icons.picture_as_pdf,
                            value: 'pdf',
                            groupValue: _mediaType,
                            onChanged: (value) {
                              if (value != null) setState(() => _mediaType = value);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // File Upload Section
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  "Resource File *",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),

              // Upload Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: _uploading ? null : () => _pickFile(ImageSource.gallery),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: _uploading 
                          ? null 
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [primaryColor, primaryColor.withOpacity(0.8)],
                            ),
                      color: _uploading ? Colors.grey[300] : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_uploading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        else
                          Icon(
                            _mediaType == 'video' 
                                ? Icons.video_library_outlined 
                                : _mediaType == 'pdf'
                                  ? Icons.picture_as_pdf
                                  : Icons.image_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        const SizedBox(width: 12),
                        Text(
                          _uploading
                              ? "Uploading..."
                              : "Upload ${_mediaType == 'video' ? 'Video' : _mediaType == 'pdf' ? 'PDF' : 'Image'}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (_fileUrl != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[100]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green[600], size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "File uploaded successfully",
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            color: Colors.green[800], size: 20),
                        onPressed: () {
                          setState(() {
                            _fileUrl = null;
                            _selectedFile = null;
                            _urlController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // URL Input (as alternative)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  "Or Enter URL",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _urlController,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    hintText: "Enter resource URL",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.link, size: 20, color: Colors.grey[600]),
                  ),
                  keyboardType: TextInputType.url,
                ),
              ),

              const SizedBox(height: 20),

              // Tags
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  "Tags",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags
                          .map((tag) => Chip(
                                label: Text(
                                  tag,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () => _removeTag(tag),
                                backgroundColor: AppColors.primaryExtraLight,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _tagController,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Add tag and press Enter",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add_circle_outline, color: primaryColor),
                          onPressed: () {
                            if (_tagController.text.isNotEmpty) {
                              _addTag(_tagController.text);
                            }
                          },
                        ),
                      ),
                      onSubmitted: (value) {
                        _addTag(value.replaceAll(",", "").trim());
                      },
                      onChanged: (value) {
                        if (value.contains(",")) {
                          _addTag(value.replaceAll(",", "").trim());
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _isEditing ? "Update Resource" : "Add Resource",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

// Custom widget for media type option
class _MediaTypeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _MediaTypeOption({
    required this.title,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? primaryColor : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}