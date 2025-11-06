// firestone_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoneService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Colecciones
  final String notesCollection = 'notes';
  final String categoriesCollection = 'categories'; // Nueva colección

//Crear Nota (MODIFICADO)
// Ahora acepta 'category' y usa FieldValue.serverTimestamp() para mejor manejo de fechas
Future<void> addnote(String text, String category) async {
await _db.collection(notesCollection).add({
'text': text,
'category': category, // Nuevo campo
'createdAt': FieldValue.serverTimestamp() // Mejor práctica para fechas
});
}

//Leer Nota (MODIFICADO)
// Usamos el Stream original, pero nos aseguramos de que el campo 'createdAt' se use para ordenar.
Stream<QuerySnapshot> getNotesStream(){
 return _db.collection(notesCollection).orderBy('createdAt', descending: true).snapshots();
}

//Update Nota (MODIFICADO)
// Ahora acepta 'newCategory'
Future<void> updateNote(String id, String newText, String newCategory) async {
await _db.collection(notesCollection).doc(id).update({
'text': newText,
'category': newCategory, // Campo actualizado
 // No actualizamos 'createdAt', ya que es la fecha de creación.
});
}

//Delete Nota
Future<void> deleteNote(String id) async {
await _db.collection(notesCollection).doc(id).delete();
}

// NUEVO MÉTODO: Obtener categorías
// Se asume que la colección 'categories' contiene documentos con un campo 'name'
Stream<List<String>> getCategoriesStream() {
    return _db.collection(categoriesCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Devuelve el valor del campo 'name' o 'Sin Categoría' por defecto.
        return doc['name'] as String? ?? 'Sin Categoría'; 
      }).toList();
    });
}
}