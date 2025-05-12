import 'package:flutter/material.dart';

class DiaryScreen extends StatelessWidget {
  final List<DiaryEntry> entries;
  final VoidCallback onAddEntry;

  const DiaryScreen({
    super.key,
    required this.entries,
    required this.onAddEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Diary')),
      body:
          entries.isEmpty
              ? Center(
                child: Text(
                  'No diary entries yet. Tap + to add your day!\n\nWrite about your activities, thoughts, and timings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              )
              : ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        entry.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(entry.content),
                      trailing: Text(
                        entry.time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddEntry,
        child: const Icon(Icons.add),
        tooltip: 'Add Diary Entry',
      ),
    );
  }
}

class DiaryEntry {
  final String title;
  final String content;
  final String time;

  DiaryEntry({required this.title, required this.content, required this.time});
}
