import 'dart:io';

import 'package:activity_8/auth_service.dart';
import 'package:activity_8/crud_service.dart';
import 'package:activity_8/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final CrudService service = CrudService();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text('Firebase Morales'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              AuthService().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage())
              );
            },
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => openAddDialog(context),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: service.getItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No items found', style: TextStyle(fontSize: 18),));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var item = docs[index];

              final data = item.data() as Map<String, dynamic>;
              final imageUrl = data['image_url'];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: imageUrl != null 
                    ? ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ) : null,
                  title: Text(
                    data['name'] ?? '',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Quantity ${data['quantity'] ?? 0}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => openEditDialog(context, item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.orange),
                        onPressed: () => _confirmDelete(context, item.id),
                      )
                    ],
                  ),

                )
              );
            }
          );
        },
      )
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Delete item'),
      content: const Text('Are you sure you want to delete the item?'),
      actions: [
        TextButton(
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
          onPressed: () {
            service.deleteItem(id);
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context)
        ),
      ]
    ));
  }

  void openAddDialog(BuildContext context) {
    nameCtrl.clear();
    qtyCtrl.clear();

    File? selectedImageFile;
    String? selectedImageUrl;

    showDialog(
      context: context, 
      builder: (_) => StatefulBuilder(builder: (context, setState) =>
      
      AlertDialog(
        title: const Text('Add item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),

              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: qtyCtrl,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            if(selectedImageFile != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                selectedImageFile!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              )
            ),
            SizedBox(height: 8,),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload image'),
              onPressed: () async {
                final pickedFile = await service.pickImageForAddItem();
                if (pickedFile != null) {
                  setState(() {
                    selectedImageFile = pickedFile.file;
                    selectedImageUrl = pickedFile.url;
                  });
                }
              },
            )
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Save'),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty && qtyCtrl.text.isNotEmpty) {
                await service.addItemWithImage(nameCtrl.text, int.parse(qtyCtrl.text), selectedImageUrl,);
                Navigator.pop(context);
              }
            }
          )
        ],
      )
      )
    );
  }

  void openEditDialog(BuildContext context, DocumentSnapshot item) {
    nameCtrl.text = item['name'];
    qtyCtrl.text = item['quantity'].toString();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 10,),

            TextField(
              controller: qtyCtrl,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            child: const Text('Update'),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && qtyCtrl.text.isNotEmpty) {
                service.updateItem(item.id, nameCtrl.text, int.parse(qtyCtrl.text));
                Navigator.pop(context);
              }
            }
          )
        ],
      )
      
    );
  }
}