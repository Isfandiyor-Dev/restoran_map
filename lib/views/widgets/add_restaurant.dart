import 'dart:io';
import 'package:restoran_map/views/admin/add_location.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restoran_map/cubit/restaurant_cubit.dart';
import 'package:restoran_map/models/restaurant.dart';
import 'package:restoran_map/views/widgets/my_text_field.dart';

class AddRestaurantDialog extends StatefulWidget {
  final Restaurant? restaurant;
  const AddRestaurantDialog({
    super.key,
    this.restaurant,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddRestaurantDialogState createState() => _AddRestaurantDialogState();
}

class _AddRestaurantDialogState extends State<AddRestaurantDialog> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? image;
  Point? location;

  late TextEditingController descriptionController;
  late TextEditingController titleController;

  @override
  void initState() {
    super.initState();
    location = widget.restaurant?.location;
    descriptionController =
        TextEditingController(text: widget.restaurant?.description ?? '');
    titleController =
        TextEditingController(text: widget.restaurant?.name ?? '');
  }

  Future<void> _pickImage(ImageSource source, int imageIndex) async {
    XFile? pickedFile = await _picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
      }
    });
  }

  void addProductBtn() {
    if (_formKey.currentState!.validate() && location != null) {
      showDialog(
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      if (widget.restaurant == null) {
        BlocProvider.of<RestaurantCubit>(context)
            .addRestaurant(
          Restaurant(
            id: UniqueKey().toString(),
            name: titleController.text,
            description: descriptionController.text,
            imageUrl: image,
            location: location,
          ),
        )
            .then((value) {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      } else {
        BlocProvider.of<RestaurantCubit>(context)
            .editRestaurant(
          widget.restaurant!.id,
          Restaurant(
            id: UniqueKey().toString(),
            name: titleController.text,
            description: descriptionController.text,
            imageUrl: image,
            location: location,
          ),
        )
            .then((value) {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Row(
        children: [
          Text("Add Restaurant"),
          SizedBox(
            width: 140,
          )
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Select Image",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  height: 2,
                ),
              ),
              _buildImagePicker(1, image),
              const Divider(),
              const SizedBox(height: 20),
              MyTextField(
                labelText: "Title",
                validation: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                textEditingController: titleController,
              ),
              const SizedBox(height: 20),
              MyTextField(
                labelText: "Description",
                validation: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                textEditingController: descriptionController,
              ),
              const SizedBox(
                height: 10,
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () async {
                  Point newlocation = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const AddRestaurantMap(),
                    ),
                  );
                  location = newlocation;
                  setState(() {});
                },
                child: const Text("Location"),
              ),
              const SizedBox(height: 10),
              location != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("lat ${location!.latitude}"),
                        Text("lon ${location!.longitude}"),
                      ],
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
          onPressed: addProductBtn,
          child: const Text('Add Product'),
        ),
      ],
    );
  }

  Widget _buildImagePicker(int index, File? imageFile) {
    return Row(
      children: [
        Container(
          margin: imageFile != null
              ? const EdgeInsets.all(15)
              : const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.hardEdge,
          child: imageFile != null
              ? Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                  height: 120,
                  width: 120,
                )
              : null,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextButton.icon(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.tertiary,
                ),
              ),
              onPressed: () => _pickImage(ImageSource.camera, index),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Camera"),
            ),
            TextButton.icon(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.tertiary,
                ),
              ),
              onPressed: () => _pickImage(ImageSource.gallery, index),
              icon: const Icon(Icons.photo),
              label: const Text("Camera"),
            ),
          ],
        ),
      ],
    );
  }
}
