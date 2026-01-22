import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'rekap/input_pelanggaran_dialog.dart';
import '../services/local_storage.dart';

class OfflineModeScreen extends StatefulWidget {
  final VoidCallback? onRetry;

  const OfflineModeScreen({super.key, this.onRetry});

  @override
  State<OfflineModeScreen> createState() => _OfflineModeScreenState();
}

class _OfflineModeScreenState extends State<OfflineModeScreen> {
  bool _showInputForm = false;
  List<Map<String, dynamic>> _offlineData = [];

  @override
  void initState() {
    super.initState();
    _loadUnsyncedData();
  }

  Future<void> _loadUnsyncedData() async {
    final data = await LocalStorage.instance.getUnsyncedPelanggaran();
    if (mounted) {
      setState(() {
        _offlineData = data;
      });
    }
  }

  void _hideInputForm() {
    if (mounted) {
      setState(() {
        _showInputForm = false;
      });
      // Reload data after form closes to show new entry
      _loadUnsyncedData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Offline UI
        Scaffold(
          backgroundColor: const Color(0xFF0F172A), // Slate 900
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   // ... (Icon, Text, Buttons remain same) ...
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        PhosphorIconsRegular.wifiSlash,
                        size: 64,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Anda sedang Offline",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Koneksi internet tidak tersedia.\nBeberapa fitur mungkin tidak dapat diakses.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (widget.onRetry != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: widget.onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB), // Primary Blue
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Coba Hubungkan Ulang",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showInputForm = true;
                          });
                        },
                        icon: const Icon(Icons.note_add_rounded),
                        label: const Text(
                          "Input Pelanggaran (Offline)",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // OFFLINE DATA LIST SECTION
                  if (_offlineData.isNotEmpty) ...[
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Icon(PhosphorIconsRegular.clockCounterClockwise, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Riwayat Offline (${_offlineData.length})",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _offlineData.length,
                      itemBuilder: (context, index) {
                        final item = _offlineData[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(PhosphorIconsRegular.warning, color: Colors.orange, size: 16),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['nama'] ?? 'Tanpa Nama',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${item['jenis_pelanggaran']} • ${item['kelas']}",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "Belum Sync",
                                  style: TextStyle(color: Colors.orange, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Data akan otomatis di-upload saat online.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),


        // Input Form Overlay with dedicated Navigator
        if (_showInputForm)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: Navigator(
                // Using a local Navigator ensures 'Navigator.pop(context)' inside the dialog works!
                observers: [_DialogObserver(onClose: _hideInputForm)],
                onGenerateRoute: (settings) => MaterialPageRoute(
                  builder: (context) => Scaffold(
                    backgroundColor: Colors.transparent, 
                    body: Center(
                      child: InputPelanggaranDialog(
                        onSaved: () {
                           print("OFFLINE_DEBUG: Dialog Saved Callback Triggered");
                           // Force reload here in case pop detection missed it
                           _loadUnsyncedData();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Helper Observer to detect when the Dialog pops
class _DialogObserver extends NavigatorObserver {
  final VoidCallback onClose;
  _DialogObserver({required this.onClose});

  @override
  void didPop(Route route, Route? previousRoute) {
    // Only close if we are popping the root route (the Dialog Page).
    // Dropdown menus push a route on top; popping them should NOT close the overlay.
    // If previousRoute is null, it means we popped the last remaining route.
    if (previousRoute == null) {
      Future.microtask(onClose);
    }
    super.didPop(route, previousRoute);
  }
}
