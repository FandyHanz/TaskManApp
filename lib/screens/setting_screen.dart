import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StorageService storageService = StorageService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: Maintenance
          const Text(
            "Maintenance",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
              title: const Text("Clear All Tasks"),
              subtitle: const Text("Menghapus semua data tugas secara permanen"),
              onTap: () => _showDeleteConfirmDialog(context, storageService),
            ),
          ),
          
          const SizedBox(height: 24),

          // Section: Info
          const Text(
            "Application",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.blueAccent),
                  title: Text("About"),
                  subtitle: Text("Tasker Local v1.0.0"),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code, color: Colors.orangeAccent),
                  title: const Text("Developer"),
                  subtitle: const Text("Fandy Wahyu Hanzura"),
                  onTap: () {
                    // Bisa ditambahin link ke portfolio atau GitHub ente
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dialog konfirmasi biar gak sengaja kehapus semua
  void _showDeleteConfirmDialog(BuildContext context, StorageService storage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: const Text("Yakin mau hapus semua data? Semua task di JSON bakal ilang total gan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await storage.clearAll(); // Hapus file JSON
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Cache berhasil dibersihkan!"), backgroundColor: Colors.green),
              );
            },
            child: const Text("Hapus Semua", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}