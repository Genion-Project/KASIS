import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../pages/member_detail_page.dart';
import '../widgets/stat_header_widget.dart';
import '../widgets/member_item_widget.dart';
import 'package:bendahara_app/pages/AddMemberPage.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  late Future<List<Map<String, dynamic>>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = ApiService.getMembers();
  }

  // Method untuk reload data members
  void _reloadMembers() {
    if (!mounted) return;
    setState(() {
      _membersFuture = ApiService.getMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[600],
      appBar: AppBar(
        title: const Text(
          'Daftar Anggota',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddMemberPage()),
              ).then((result) {
                if (result == true && mounted) _reloadMembers();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header statistik
          StatHeaderWidget(),

          // List member dengan FutureBuilder
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _membersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.blue,
                    ));
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      'Gagal mengambil data: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada anggota'));
                  }

                  final members = snapshot.data!;

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: members.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final int totalPaid = member['amount'] ?? 0;
                      final status = totalPaid > 0 ? 'Sudah Bayar' : 'Belum Bayar';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MemberDetailPage(
                                memberId: member['id'],
                                memberName: member['name'],
                              ),
                            ),
                          ).then((_) => _reloadMembers());
                        },
                        child: MemberItemWidget(
                          name: member['name'] ?? 'Tidak Diketahui',
                          status: status,
                          amount: 'Rp $totalPaid',
                          avatar: (member['name'] != null &&
                                  member['name'].isNotEmpty)
                              ? member['name'][0].toUpperCase()
                              : '?',
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
