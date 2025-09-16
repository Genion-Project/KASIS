import 'package:flutter/material.dart';
import '../widgets/member_item_widget.dart';
import '../widgets/stat_header_widget.dart';

class MembersScreen extends StatelessWidget {
  final List<Map<String, dynamic>> members = [
    {'name': 'Nafil Habibi Mulyadi', 'status': 'Lunas', 'amount': 'Rp 50.000', 'avatar': 'N'},
    {'name': 'Boy Cahya Madinah', 'status': 'ngutang', 'amount': 'Rp 50.000', 'avatar': 'B'},
    {'name': 'Muhammad Yusuf', 'status': 'Lunas', 'amount': 'Rp 1.000.000', 'avatar': 'Y'},
    {'name': 'Jihan Nurana Tasah', 'status': 'ngutang', 'amount': 'Rp 50.000', 'avatar': 'J'},
    {'name': 'Firly Husnadiva', 'status': 'Belum Lunas', 'amount': 'Rp 0', 'avatar': 'E'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[600],
      appBar: AppBar(
        title: Text('Daftar Anggota', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, color: Colors.white),
            onPressed: () {
              // Handle add member
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Header
          StatHeaderWidget(),

          // Members List
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: ListView.builder(
                padding: EdgeInsets.all(20),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return MemberItemWidget(
                    name: member['name'],
                    status: member['status'],
                    amount: member['amount'],
                    avatar: member['avatar'],
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