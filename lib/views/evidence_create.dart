import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:app_monitor/providers/evidence_providers.dart'; // Ajusta la ruta de importación

class CreateEvidenceForm extends StatefulWidget {
  const CreateEvidenceForm({Key? key}) : super(key: key);

  @override
  _CreateEvidenceFormState createState() => _CreateEvidenceFormState();
}

class _CreateEvidenceFormState extends State<CreateEvidenceForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        // Se llama al método del provider y se obtiene el id de la evidencia creada.
        final int evidenceId = await Provider.of<EvidenceProvider>(
          context,
          listen: false,
        ).createEvidence(
          _nameController.text.trim(),
          _descriptionController.text.trim(),
        );

        // Navega a la vista de detalles utilizando el id obtenido.
        await GoRouter.of(context).push('/details/$evidenceId');
      } catch (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Crear Nueva Evidencia"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration(
                    "Nombre",
                    "Ingrese el nombre de la evidencia",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration: _buildInputDecoration(
                    "Descripción",
                    "Ingrese la descripción",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La descripción es obligatoria';
                    }
                    return null;
                  },
                  maxLines: 3,
                ),
                const SizedBox(height: 32.0),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              "Crear Evidencia",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
