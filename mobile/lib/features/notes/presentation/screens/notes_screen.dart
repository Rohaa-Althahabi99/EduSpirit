import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/note_model.dart';
import '../../data/note_repository.dart';

class NotesScreen extends StatefulWidget {
  final NoteRepository repository;
  const NotesScreen({super.key, required this.repository});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _searchController = TextEditingController();
  List<NoteModel> _notes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load([String? query]) async {
    setState(() { _loading = true; _error = null; });
    try {
      _notes = await widget.repository.search(query);
    } catch (_) {
      _error = 'تعذّر تحميل الملاحظات.';
    }
    setState(() => _loading = false);
  }

  void _showCreateSheet() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.l, right: AppSpacing.l, top: AppSpacing.l,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('ملاحظة جديدة', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: AppSpacing.m),
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'العنوان')),
            const SizedBox(height: AppSpacing.m),
            TextField(controller: contentController, maxLines: 4, decoration: const InputDecoration(labelText: 'المحتوى')),
            const SizedBox(height: AppSpacing.m),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                await widget.repository.create(title: titleController.text.trim(), contentRichText: contentController.text.trim());
                if (sheetContext.mounted) Navigator.pop(sheetContext);
                _load();
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الملاحظات')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(hintText: 'ابحث في الملاحظات...', prefixIcon: Icon(Icons.search)),
              onSubmitted: (value) => _load(value),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _load(_searchController.text),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? ListView(children: [Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Center(child: Text(_error!)))])
                      : _notes.isEmpty
                          ? ListView(children: const [Padding(
                              padding: EdgeInsets.all(AppSpacing.xl),
                              child: Center(child: Text('لا توجد ملاحظات بعد.')),
                            )])
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                              itemCount: _notes.length,
                              itemBuilder: (context, index) {
                                final note = _notes[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: AppSpacing.m),
                                  child: ListTile(
                                    title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    subtitle: note.contentRichText != null
                                        ? Text(note.contentRichText!, maxLines: 2, overflow: TextOverflow.ellipsis)
                                        : null,
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20),
                                      onPressed: () async {
                                        await widget.repository.delete(note.id);
                                        _load(_searchController.text);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showCreateSheet, child: const Icon(Icons.add)),
    );
  }
}
