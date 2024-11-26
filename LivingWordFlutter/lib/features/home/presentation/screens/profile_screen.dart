import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../profile/data/models/user_details_model.dart';
import '../../../profile/providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user?.id;
      if (userId != null) {
        context.read<ProfileProvider>().loadUserDetails(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          _isEditing
              ? const SizedBox.shrink()
              : IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => setState(() => _isEditing = true),
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          if (profileProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final userDetails = profileProvider.userDetails;
          if (userDetails == null) {
            return const Center(child: Text('Could not load information'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ProfileImageSection(
                  userDetails: userDetails,
                  onImageUpdated: () => profileProvider.loadUserDetails(userDetails.id),
                ),
                const SizedBox(height: 24),
                _isEditing
                    ? ProfileEditForm(
                  userDetails: userDetails,
                  onSaved: () => setState(() => _isEditing = false),
                  onCanceled: () => setState(() => _isEditing = false),
                )
                    : ProfileDetails(userDetails: userDetails),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileImageSection extends StatelessWidget {
  final UserDetailsModel userDetails;
  final VoidCallback onImageUpdated;

  const ProfileImageSection({
    Key? key,
    required this.userDetails,
    required this.onImageUpdated,
  }) : super(key: key);

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final provider = context.read<ProfileProvider>();
      final success = await provider.updateProfileImage(File(image.path));
      if (success) {
        onImageUpdated();
      }
    }
  }

  Future<void> _deleteImage(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile Picture'),
        content: const Text('Are you sure you want to delete your profile picture?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = context.read<ProfileProvider>();
      final success = await provider.deleteProfileImage();
      if (success) {
        onImageUpdated();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileImageUrl = userDetails.photoUrl != null
        ? ApiConstants.profileImageUrl(userDetails.photoUrl!)
        : null;

    return Column(
      children: [
        Hero(
          tag: 'profile_image_${userDetails.id}',
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            child: ClipOval(
              child: profileImageUrl != null
                  ? Image.network(
                profileImageUrl,
                fit: BoxFit.cover,
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultImage(),
                loadingBuilder: _buildLoadingImage,
              )
                  : _buildDefaultImage(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_camera),
              label: const Text('Change Photo'),
              onPressed: () => _pickImage(context),
            ),
            if (profileImageUrl != null) ...[
              const SizedBox(width: 8),
              TextButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Remove'),
                onPressed: () => _deleteImage(context),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultImage() {
    return Image.asset(
      'assets/images/default_profile.png',
      fit: BoxFit.cover,
      width: 100,
      height: 100,
    );
  }

  Widget _buildLoadingImage(
      BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
            loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  }
}

class ProfileDetails extends StatelessWidget {
  final UserDetailsModel userDetails;

  const ProfileDetails({Key? key, required this.userDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem(
              theme,
              'Name',
              '${userDetails.name} ${userDetails.lastname}',
            ),
            _buildDetailItem(theme, 'Email', userDetails.email),
            _buildDetailItem(
              theme,
              'Phone',
              userDetails.phone ?? 'Not specified',
            ),
            _buildDetailItem(
              theme,
              'Address',
              userDetails.address ?? 'Not specified',
            ),
            _buildDetailItem(
              theme,
              'Gender',
              userDetails.gender ?? 'Not specified',
            ),
            _buildDetailItem(
              theme,
              'Marital Status',
              userDetails.maritalStatus ?? 'Not specified',
            ),
            if (userDetails.ministry != null)
              _buildDetailItem(theme, 'Ministry', userDetails.ministry!),
            _buildDetailItem(theme, 'Role', userDetails.role),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyLarge,
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class ProfileEditForm extends StatefulWidget {
  final UserDetailsModel userDetails;
  final VoidCallback onSaved;
  final VoidCallback onCanceled;

  const ProfileEditForm({
    Key? key,
    required this.userDetails,
    required this.onSaved,
    required this.onCanceled,
  }) : super(key: key);

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _lastnameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  String? _selectedGender;
  String? _selectedMaritalStatus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userDetails.name);
    _lastnameController = TextEditingController(text: widget.userDetails.lastname);
    _phoneController = TextEditingController(text: widget.userDetails.phone);
    _addressController = TextEditingController(text: widget.userDetails.address);
    _selectedGender = widget.userDetails.gender;
    _selectedMaritalStatus = widget.userDetails.maritalStatus;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedDetails = UserDetailsModel(
        id: widget.userDetails.id,
        name: _nameController.text,
        lastname: _lastnameController.text,
        email: widget.userDetails.email,
        phone: _phoneController.text,
        address: _addressController.text,
        gender: _selectedGender ?? widget.userDetails.gender,
        maritalStatus: _selectedMaritalStatus ?? widget.userDetails.maritalStatus,
        role: widget.userDetails.role,
        ministry: widget.userDetails.ministry,
        photoUrl: widget.userDetails.photoUrl,
      );
      final profileProvider = context.read<ProfileProvider>();
      final authProvider = context.read<AuthProvider>();

      final success = await context
          .read<ProfileProvider>()
          .updateUserDetails(updatedDetails);

      if (success && mounted) {
        await authProvider.refreshUserDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        widget.onSaved();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
          children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'First Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
            value?.isEmpty ?? true ? 'Required field' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lastnameController,
            decoration: const InputDecoration(
              labelText: 'Last Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
            value?.isEmpty ?? true ? 'Required field' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(),
            ),
            items: ['Male', 'Female', 'Other']
                .map((gender) => DropdownMenuItem(
              value: gender,
              child: Text(gender),
            ))
                .toList(),
            onChanged: (value) => setState(() => _selectedGender = value),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedMaritalStatus,
            decoration: const InputDecoration(
              labelText: 'Marital Status',
              border: OutlineInputBorder(),
            ),
            items: ['Single', 'Married', 'Divorced', 'Widowed']
                .map((status) => DropdownMenuItem(
              value: status,
              child: Text(status),
            ))
                .toList(),
            onChanged: (value) =>
                setState(() => _selectedMaritalStatus = value),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCanceled,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}