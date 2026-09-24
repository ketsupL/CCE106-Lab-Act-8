import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class PickedImage {
  final File file;
  final String url;
  PickedImage({required this.file, required this.url});
}

class CrudService {
  final CollectionReference items = FirebaseFirestore.instance.collection('items');

  final CloudinaryPublic _cloudinary = CloudinaryPublic('jk6vbund', 'cce106', cache: false);

  final ImagePicker _picker = ImagePicker();

  Future<PickedImage?> pickImageForAddItem() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;
    final file = File(pickedFile.path);

    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        file.path,
        resourceType: CloudinaryResourceType.Image
      )
    );

    return PickedImage(file: file, url: response.secureUrl);
  }

  //Create
  Future <void> addItem(String name, int quantity) {
    return items.add({
      'name': name,
      'quantity': quantity,
      'createdAt': Timestamp.now(),  
    });
  }

  //Create
  Future <void> addItemWithImage(String name, int quantity, String? imageUrl) async {
    await items.add({
      'name': name,
      'quantity': quantity,
      'image_url': imageUrl,
      'createdAt': Timestamp.now(),  
    });
  }

  //Read
  Stream<QuerySnapshot> getItems() {
    return items.orderBy('createdAt', descending: true).snapshots();
  }


  //Update
  Future <void> updateItem(String id, String name, int quantity) {
    return items.doc(id).update({
      'name': name,
      'quantity': quantity,
    });
  }

  //Delete
  Future <void> deleteItem(String id) {
    return items.doc(id).delete();
  }
}