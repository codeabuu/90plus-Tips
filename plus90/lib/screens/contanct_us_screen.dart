import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'dart:io';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedCategory = 'General';
  bool _isSubmitting = false;
  bool _isSuccess = false;
  
  // File attachment
  File? _selectedFile;
  String? _fileName;
  bool _isPickingFile = false;

  final List<String> _categories = [
    'General',
    'Predictions',
    'Technical',
    'Billing',
    'Feedback',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    final authProvider = AuthProvider.of(context);
    if (authProvider.currentUser != null) {
      _nameController.text = authProvider.currentUser!.name;
      _emailController.text = authProvider.currentUser!.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() {
      _isPickingFile = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File attached: $_fileName'),
            backgroundColor: AppTheme.accentGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isPickingFile = false;
      });
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isSuccess)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentGreen.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.accentGreen,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Message sent successfully! We\'ll respond within 12 hours.',
                        style: TextStyle(
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const Text(
              'We\'re here to help',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Contact us with any questions about predictions, '
              'technical issues, or account support.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Contact Methods
            _buildContactMethod(
              icon: Icons.email,
              title: 'Email Support',
              subtitle: 'support@premiumpredictions.com',
              action: 'Response time: Under 12 hours',
            ),
            const SizedBox(height: 24),

            _buildContactMethod(
              icon: Icons.message,
              title: 'In-App Support',
              subtitle: 'Send us a message directly',
              action: 'Direct to our support team',
            ),
            const SizedBox(height: 24),

            _buildContactMethod(
              icon: Icons.help,
              title: 'Help Center',
              subtitle: 'FAQs, guides, and tutorials',
              action: 'Visit Help Center',
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),


            // Contact Form
            if (!_isSuccess)
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Send Us a Message',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.category),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Message Field
                    TextFormField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your message';
                        }
                        if (value.length < 10) {
                          return 'Message is too short';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen,
                          foregroundColor: AppTheme.primaryNavy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Send Message',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required String action,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppTheme.primaryNavy),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  action,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.accentGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // TODO: Update your ApiService to handle file attachments
      // For now, just send the text message
      final success = await _apiService.submitContactMessage(
        name: _nameController.text,
        email: _emailController.text,
        category: _selectedCategory,
        message: _messageController.text,
        // file: _selectedFile, // Add this when ApiService is updated
      );

      setState(() {
        _isSubmitting = false;
        _isSuccess = success;
      });

      if (success) {
        _messageController.clear();
        _removeFile(); // Clear attached file
        // Auto-clear form after success
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _isSuccess = false;
            });
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}