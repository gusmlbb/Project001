import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'main.g.dart';

// MODELLER
@HiveType(typeId: 0)
class Flashcard extends HiveObject {
  @HiveField(0)
  String word;

  @HiveField(1)
  String translation;

  @HiveField(2)
  String note;

  Flashcard({required this.word, required this.translation, this.note = ''});
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  Hive.registerAdapter(FlashcardAdapter());
  await Hive.openBox<Flashcard>('flashcards');
  runApp(MyApp());
}

// UYGULAMA BAŞLANGICI
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocabulary App',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomeScreen(),
    );
  }
}

// ANA SAYFA
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final flashcardsBox = Hive.box<Flashcard>('flashcards');

    return Scaffold(
      appBar: AppBar(title: Text('Kelime Kartlarım')),
      body: ValueListenableBuilder(
        valueListenable: flashcardsBox.listenable(),
        builder: (context, Box<Flashcard> box, _) {
          if (box.isEmpty) {
            return Center(child: Text('Henüz kart yok.'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final card = box.getAt(index);
              return ListTile(
                title: Text(card?.word ?? ''),
                subtitle: Text(card?.translation ?? ''),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => card?.delete(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddFlashcardScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// KART EKLEME SAYFASI
class AddFlashcardScreen extends StatefulWidget {
  @override
  _AddFlashcardScreenState createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  final _wordController = TextEditingController();
  final _translationController = TextEditingController();
  final _noteController = TextEditingController();

  void _saveCard() {
    final word = _wordController.text.trim();
    final translation = _translationController.text.trim();
    final note = _noteController.text.trim();

    if (word.isNotEmpty && translation.isNotEmpty) {
      final card = Flashcard(word: word, translation: translation, note: note);
      Hive.box<Flashcard>('flashcards').add(card);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Yeni Kart Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _wordController, decoration: InputDecoration(labelText: 'İngilizce')),
            TextField(controller: _translationController, decoration: InputDecoration(labelText: 'Türkçe')),
            TextField(controller: _noteController, decoration: InputDecoration(labelText: 'Not (isteğe bağlı)')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _saveCard, child: Text('Kaydet')),
          ],
        ),
      ),
    );
  }
}
