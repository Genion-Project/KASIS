import 'package:flutter/material.dart';
import '../widgets/quick_action_widget.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/activity_item_widget.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[600],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.account_balance_wallet, color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Rp 2.350.000',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                      SizedBox(width: 15),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Colors.blue[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Quick Actions
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  QuickActionWidget(icon: Icons.add_circle_outline, label: 'Pemasukan', color: Colors.green),
                  QuickActionWidget(icon: Icons.remove_circle_outline, label: 'Pengeluaran', color: Colors.red),
                  QuickActionWidget(icon: Icons.history, label: 'Riwayat', color: Colors.purple),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Main Content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statistics Card
                      StatCardWidget(),

                      SizedBox(height: 20),

                      // Recent Activities
                      Text(
                        'Aktivitas Terbaru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 15),

                      ActivityItemWidget(
                        title: 'Iuran Bulanan - Ahmad',
                        amount: 'Rp 50.000',
                        color: Colors.green,
                        icon: Icons.arrow_downward,
                        time: '2 jam lalu',
                      ),
                      ActivityItemWidget(
                        title: 'Pembelian Perlengkapan',
                        amount: 'Rp 125.000',
                        color: Colors.red,
                        icon: Icons.arrow_upward,
                        time: '5 jam lalu',
                      ),
                      ActivityItemWidget(
                        title: 'Iuran Bulanan - Sari',
                        amount: 'Rp 50.000',
                        color: Colors.green,
                        icon: Icons.arrow_downward,
                        time: '1 hari lalu',
                      ),

                      SizedBox(height: 20),

                      

                      SizedBox(height: 100), // Bottom padding for FAB
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}