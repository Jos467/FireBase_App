// main.dart MODIFICADO

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Importa el nuevo archivo de login
import 'login.dart'; 
// Asumo que estos archivos existen en tu proyecto
import 'firebase_config.dart';
import 'firestone_service.dart';



void main() async {
WidgetsFlutterBinding.ensureInitialized();
// Usamos el objeto de configuración que definiste
await Firebase.initializeApp(options: firebaseConfig); 
runApp(const MyApp());

}

class MyApp extends StatelessWidget {
const MyApp({super.key});
@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'Notas con Firebase y Categorías',
theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
// CAMBIO: La página de inicio ahora es LoginPage
home: const LoginPage(), 
);
}
}

// *** NotesPage y su State (Todo lo demás se mantiene igual) ***

class NotesPage extends StatefulWidget {
const NotesPage({super.key});
@override
State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
final TextEditingController _controller = TextEditingController();
final FirestoneService _service = FirestoneService();
 
 // Variables para manejar la categoría de la nueva nota
 List<String> _categories = [];
 String? _selectedCategory; // Puede ser nulo hasta que se carguen

 @override
 void initState() {
 super.initState();
 // Suscribirse al stream de categorías
 _service.getCategoriesStream().listen((list) {
 if (mounted) {
 setState(() {
 _categories = list.isEmpty ? ['Personal','Trabajo','Universidad'] : list;
 // Inicializar la categoría seleccionada con la primera disponible
 if (_selectedCategory == null) {
 _selectedCategory = _categories.first;
 }
  });
 }
 });
 }

Future<void> _addNote() async {
final text = _controller.text.trim();
// Si no hay categorías cargadas o el texto está vacío, salir
if (text.isEmpty || _selectedCategory == null) return; 
await _service.addnote(text, _selectedCategory!); // Pasa la categoría
_controller.clear();
// Opcional: restablecer la categoría seleccionada al valor por defecto
setState(() {
_selectedCategory = _categories.first;
});
}

// MODIFICADO: Ahora el diálogo permite editar la categoría.
Future<void> _editNote(String id, String oldText, String oldCategory) async {
final ctrl = TextEditingController(text: oldText);
 String currentCategory = oldCategory;

final result = await showDialog<Map<String, String>>(
context: context,
builder: (dialogContext) {
 // Usamos StatefulBuilder para que el DropdownButton pueda actualizarse
 return StatefulBuilder(
 builder: (context, setStateSB) {
 return AlertDialog(
title: const Text('Editar nota'),
content: Column(
 mainAxisSize: MainAxisSize.min,
 children: [
  TextField(controller: ctrl),
  const SizedBox(height: 16), // DropdownButton para editar la categoría
  DropdownButtonFormField<String>(
   value: currentCategory,
   decoration: const InputDecoration(labelText: 'Categoría'),
   items: _categories.map((String category) {
   return DropdownMenuItem<String>(
  value: category,
  child: Text(category),
  );
  }).toList(),
  onChanged: (String? newValue) {
  setStateSB(() { // Usar setStateSB
  currentCategory = newValue!;
 });
  },
  ),
 ],
 ),
actions: [
 TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
 ElevatedButton(
 onPressed: () => Navigator.pop(context, {
 'text': ctrl.text.trim(),
  'category': currentCategory,
 }), 
 child: const Text('Guardar')
 ),
],
);
 }
 );
},
);
 
 // Procesa el resultado de la edición
if (result == null || result['text']!.isEmpty) return;
await _service.updateNote(id, result['text']!, result['category']!);
}

Future<void> _deleteNote(String id) async {
await _service.deleteNote(id);
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
    title: const Text('Notas con Firebase'),
    actions: [
      // Añade un botón de "Cerrar Sesión" simulado
      IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () {
          // ⚠️ En una app real, aquí se llamaría a FirebaseAuth.instance.signOut();
          // Simplemente volvemos a la página de login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        },
      ),
    ]
  ),
body: Column(
children: [
Padding(
padding: const EdgeInsets.all(12),
child: Row(
children: [
 // Dropdown para la categoría de la NUEVA nota
 if (_categories.isNotEmpty) 
 Expanded(
 flex: 1,
 child: DropdownButtonFormField<String>(
  value: _selectedCategory,
 decoration: const InputDecoration(
  labelText: 'Categoría',
  border: OutlineInputBorder(),
  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
  ),
  items: _categories.map((String category) {
  return DropdownMenuItem<String>(
 value: category,
 child: Text(category),
  );
  }).toList(),
  onChanged: (String? newValue) {
  setState(() { _selectedCategory = newValue;
  });
  },
 ),
 ),

const SizedBox(width: 8),

Expanded(
  flex: 2,
child: TextField(
controller: _controller,
decoration: const InputDecoration(
hintText: 'Escribe una nota...',
border: OutlineInputBorder(),
),
onSubmitted: (_) => _addNote(),
),

),
const SizedBox(width: 8),
ElevatedButton(onPressed: _addNote, child: const Text('Agregar')),
 ],),
),
Expanded(
child: StreamBuilder<QuerySnapshot>(
stream: _service.getNotesStream(),
builder: (context, snapshot) {
if (!snapshot.hasData) {
return const Center(child: CircularProgressIndicator());
}
final notes = snapshot.data!.docs;
if (notes.isEmpty) return const Center(child: Text('Sin notas aún'));

return ListView.builder(
itemCount: notes.length,
itemBuilder: (context, i) {
 final doc = notes[i];
 // 🚨 CORRECCIÓN: Usamos .data() y lo casteamos a Map<String, dynamic>
 final data = doc.data() as Map<String, dynamic>?; 
 
 // Asegurarse de que los datos no sean nulos
 if (data == null) return const SizedBox.shrink();

final text = data['text'] as String? ?? 'Contenido vacío';
 // Ahora accedemos a 'category' de forma más segura
 final category = data['category'] as String? ?? 'Sin asignar'; 
 final timestamp = data['createdAt'] as Timestamp?;
 
 // Formatear la fecha de creación
 String formattedDate = 'Fecha N/A';
 if (timestamp != null) {
 DateTime date = timestamp.toDate();
  
 }

return ListTile(
title: Text(text),
subtitle: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text('Categoría: $category', 
 style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
 const SizedBox(height: 2),
 Text('Creada: $formattedDate', 
 style: const TextStyle(fontSize: 11, color: Colors.grey)), 
 ],
 ),

onTap: () => _editNote(doc.id, text, category), 
trailing: IconButton(
icon: const Icon(Icons.delete, color: Colors.red),
 onPressed: () => _deleteNote(doc.id),
 ),
);
 },
);
},
),
),
],
),
);
}
}