import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

Future<File> compressImage(String filePath) async {
  File file = File(filePath);
  Uint8List bytes = await file.readAsBytes();

  // Decodificar imagen
  img.Image? image = img.decodeImage(bytes);
  if (image == null) return file;

  // Redimensionar si la imagen es muy grande
  img.Image resized = img.copyResize(image, width: 1024); // Reduce el ancho

  // Comprimir la imagen
  Uint8List compressedBytes = Uint8List.fromList(
    img.encodeJpg(resized, quality: 80),
  );

  // Guardar la imagen comprimida en un nuevo archivo
  File compressedFile = File(
    "${file.parent.path}/compressed_${file.uri.pathSegments.last}",
  );
  await compressedFile.writeAsBytes(compressedBytes);

  return compressedFile;
}
