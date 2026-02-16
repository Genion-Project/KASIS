import 'dart:async';
import 'dart:io'; // Import dart:io
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../services/local_storage.dart';
import '../services/api_service.dart';
import '../screens/offline_mode_screen.dart';
import '../providers/transaction_provider.dart';
import '../providers/member_provider.dart';
import '../providers/violation_provider.dart';

class ConnectionWrapper extends StatefulWidget {
  final Widget child;

  const ConnectionWrapper({super.key, required this.child});

  @override
  State<ConnectionWrapper> createState() => _ConnectionWrapperState();
}

class _ConnectionWrapperState extends State<ConnectionWrapper> {
  // Assume online by default to avoid flash
  bool _isOfflineMode = false;
  bool _showDialog = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen(_updateStatus);
    
    // Fallback timer for desktop platforms where connectivity events might be unreliable
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
        final results = await Connectivity().checkConnectivity();
        _updateStatus(results);
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      _updateStatus(results);
    } catch (e) {
      // Ignored
    }
  }

  Future<void> _updateStatus(List<ConnectivityResult> results) async {
    if (!mounted) return;

    // 1. Initial Check based on connection type
    bool isOffline = results.contains(ConnectivityResult.none);

    // 2. Deep Check: If "connected" mainly via 'other' or 'ethernet' (common in Linux virtual adapters),
    // or simply always verify actual internet access to be sure.
    // 'other' often appears on Linux due to Docker/VirtualBridges.
    if (!isOffline) {
       final hasInternet = await _hasInternetConnection();
       if (!hasInternet) {
         isOffline = true;
       }
    }

    // 3. SYNC CHECK
    if (!isOffline) {
       _checkAndSyncData();
    }

    if (!mounted) return; // Check mounted again after await

    if (isOffline) {
      // If we are definitely offline
      if (!_isOfflineMode && !_showDialog) {
        // Trigger dialog prompt
        setState(() {
          _showDialog = true;
        });
      }
    } else {
      // We are back online
      if (_isOfflineMode || _showDialog) {
        // Trigger REFRESH in providers
        if (mounted) {
          try {
            // Refresh dashboard, members, and violations data
            context.read<TransactionProvider>().fetchDashboardData();
            context.read<MemberProvider>().fetchMembers();
            context.read<ViolationProvider>().fetchViolations();
          } catch (e) {
            debugPrint("Refresh failed: $e");
          }
        }

        setState(() {
          _isOfflineMode = false;
          _showDialog = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Koneksi Internet Kembali Pulih. Memperbarui data..."),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _checkAndSyncData() async {
    final unsynced = await LocalStorage.instance.getUnsyncedPelanggaran();
    
    if (unsynced.isEmpty) return;

    if (!mounted) return;
    
    // Start Sync - No Dialog to avoid Context/Navigator issues

    int successCount = 0;
    int duplicateCount = 0;

    try {
      final serverData = await ApiService.getPelanggaran(); 
      
      for (var local in unsynced) {
        
        bool isDuplicate = serverData.any((server) {
          // Robust Comparison
          try {
             // 1. Compare Name (Case Insensitive)
             final serverName = server['nama']?.toString().toLowerCase().trim() ?? '';
             final localName = local['nama']?.toString().toLowerCase().trim() ?? '';
             if (serverName != localName) return false;

             // 2. Compare Violation Type
             final serverType = server['jenis_pelanggaran']?.toString().toLowerCase().trim() ?? '';
             final localType = local['jenis_pelanggaran']?.toString().toLowerCase().trim() ?? '';
             if (serverType != localType) return false;

             // 3. Compare Date (Year, Month, Day only)
             final serverDateObj = DateTime.tryParse(server['tanggal'].toString());
             final localDateObj = DateTime.tryParse(local['tanggal'].toString());
             
             if (serverDateObj != null && localDateObj != null) {
               return serverDateObj.year == localDateObj.year && 
                      serverDateObj.month == localDateObj.month && 
                      serverDateObj.day == localDateObj.day;
             }
             
             // Fallback if parsing fails: String comparison of first 10 chars (YYYY-MM-DD)
             final sDate = server['tanggal'].toString();
             final lDate = local['tanggal'].toString();
             if (sDate.length >= 10 && lDate.length >= 10) {
                return sDate.substring(0, 10) == lDate.substring(0, 10);
             }
             
             return false;
          } catch (e) {
             return false;
          }
        });

        if (isDuplicate) {
           duplicateCount++;
           await LocalStorage.instance.markAsSynced(local['id']);
        } else {
           // Upload
           try {
             await ApiService.addPelanggaran({
               "nama": local['nama'],
               "kelas": local['kelas'],
               "jenis_pelanggaran": local['jenis_pelanggaran'],
               "keterangan": local['keterangan'],
               "poin": local['poin'],
               "tanggal": local['tanggal'],
             });
             await LocalStorage.instance.markAsSynced(local['id']);
             successCount++;
           } catch (e) {
             // Ignored
           }
        }
      }
    } catch (e) {
      // Ignored
    }

    if (context.mounted) {
      if (successCount > 0 || duplicateCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sync Selesai: $successCount tersimpan, $duplicateCount duplikat diabaikan."),
            backgroundColor: Colors.blue,
          )
        );
      }
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void _manualCheck() async {
    final results = await Connectivity().checkConnectivity();
    _updateStatus(results); // Reuse logic
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Content or Offline Screen
        if (_isOfflineMode)
          OfflineModeScreen(onRetry: _manualCheck)
        else
          widget.child,

        // Custom Overlay Dialog (Because Navigator/Context is tricky in wrapper)
        if (_showDialog && !_isOfflineMode)
          Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(PhosphorIconsRegular.wifiSlash, color: Colors.red[600], size: 32),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Koneksi Terputus",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Koneksi internet anda tidak stabil atau terputus.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() => _showDialog = false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(color: Colors.grey[300]!),
                              ),
                              child: Text("Abaikan", style: TextStyle(color: Colors.grey[700])),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showDialog = false;
                                  _isOfflineMode = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text("Mode Offline", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
