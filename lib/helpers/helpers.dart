import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> showEvidenceFormDialog(
  BuildContext context, {
  required String title,
  String initialName = "",
  String initialDescription = "",
  required Future<void> Function(String name, String description) onSubmit,
}) async {
  final _formKey = GlobalKey<FormState>();
  String name = initialName;
  String description = initialDescription;

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: initialName,
                decoration: InputDecoration(labelText: "Nombre"),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Campo requerido"
                            : null,
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                initialValue: initialDescription,
                decoration: InputDecoration(labelText: "Descripción"),
                onSaved: (value) => description = value ?? "",
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text("Cancelar"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("Aceptar"),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                await onSubmit(name, description);

                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> showPhotoFormDialog(
  BuildContext context, {
  required String title,
  String initialDescription = "",
  bool isImageRequired = true,
  required Future<void> Function(String descripcion, XFile? imageFile) onSubmit,
}) async {
  final _formKey = GlobalKey<FormState>();
  String descripcion = initialDescription;
  XFile? imageFile;
  final ImagePicker _picker = ImagePicker();

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Selecciona una imagen ${isImageRequired ? '(requerida)' : '(opcional)'}",
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        child: Text("Galería"),
                        onPressed: () async {
                          final pickedFile = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedFile != null) {
                            setState(() {
                              imageFile = pickedFile;
                            });
                          }
                        },
                      ),
                      ElevatedButton(
                        child: Text("Cámara"),
                        onPressed: () async {
                          final pickedFile = await _picker.pickImage(
                            source: ImageSource.camera,
                          );
                          if (pickedFile != null) {
                            setState(() {
                              imageFile = pickedFile;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (imageFile != null)
                    Container(
                      width: 100,
                      height: 100,
                      child: Image.file(
                        File(imageFile!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(height: 10),
                  TextFormField(
                    initialValue: initialDescription,
                    decoration: InputDecoration(labelText: "Descripción"),
                    onSaved: (value) => descripcion = value ?? "",
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text("Cancelar"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text("Aceptar"),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (isImageRequired && imageFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Por favor, selecciona o toma una fotografía",
                          ),
                        ),
                      );
                      return;
                    }
                    // Mostrar diálogo de carga (indicador)
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return Center(child: CircularProgressIndicator());
                      },
                    );
                    try {
                      await onSubmit(descripcion, imageFile);
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                    // Cerrar el diálogo de carga
                    Navigator.of(context).pop();
                    // Cerrar el diálogo principal
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}
