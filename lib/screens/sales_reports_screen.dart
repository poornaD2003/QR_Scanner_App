// lib/screens/admin/sales_reports_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class SalesReportsScreen extends StatefulWidget {
  const SalesReportsScreen({Key? key}) : super(key: key);

  @override
  _SalesReportsScreenState createState() => _SalesReportsScreenState();
}

// In sales_reports_screen.dart - Update the _loadReports method and calculations

class _SalesReportsScreenState extends State<SalesReportsScreen> {
  List<Map<String, dynamic>> _bills = [];
  bool _isLoading = true;
  String? _error;
  String _selectedPeriod = 'Today';
  final List<String> _periods = ['Today', 'This Week', 'This Month', 'All Time'];

  // Helper method to safely parse numbers
  double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      // Try to parse the string to double
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // Helper method to safely parse timestamp
  int _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now().millisecondsSinceEpoch;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? DateTime.now().millisecondsSinceEpoch;
    }
    return DateTime.now().millisecondsSinceEpoch;
  }

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await context.read<AuthProvider>().getToken();
      if (token == null) throw Exception('Not authenticated');

      final bills = await ApiService.getAllBills(token: token);
      
      // Process bills to ensure correct data types
      final processedBills = bills.map((bill) {
        return {
          ...bill,
          'totalAmount': _parseAmount(bill['totalAmount']),
          'timestamp': _parseTimestamp(bill['timestamp']),
        };
      }).toList();
      
      setState(() {
        _bills = processedBills;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredBills {
    final now = DateTime.now();
    
    return _bills.where((bill) {
      final timestamp = bill['timestamp'] as int;
      final billDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      
      switch (_selectedPeriod) {
        case 'Today':
          return billDate.year == now.year &&
                 billDate.month == now.month &&
                 billDate.day == now.day;
        case 'This Week':
          final weekAgo = now.subtract(const Duration(days: 7));
          return billDate.isAfter(weekAgo);
        case 'This Month':
          return billDate.year == now.year && billDate.month == now.month;
        case 'All Time':
        default:
          return true;
      }
    }).toList();
  }

  double get _totalSales {
    return _filteredBills.fold(0.0, (sum, bill) {
      return sum + (bill['totalAmount'] as double);
    });
  }

  int get _totalTransactions => _filteredBills.length;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'Rs ');
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: _selectedPeriod,
              decoration: InputDecoration(
                labelText: 'Select Period',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _periods.map((period) {
                return DropdownMenuItem(
                  value: period,
                  child: Text(period),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPeriod = value;
                  });
                }
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadReports,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Summary Cards
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Total Sales',
                              value: currencyFormat.format(_totalSales),
                              icon: Icons.attach_money,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Transactions',
                              value: '$_totalTransactions',
                              icon: Icons.receipt,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Bills List
                    Expanded(
                      child: _filteredBills.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No transactions found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredBills.length,
                              itemBuilder: (context, index) {
                                final bill = _filteredBills[index];
                                final timestamp = bill['timestamp'] as int;
                                final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
                                final totalAmount = bill['totalAmount'] as double;
                                
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ExpansionTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue.shade100,
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(color: Colors.blue.shade800),
                                      ),
                                    ),
                                    title: Text(
                                      'Bill #${bill['bill_id']?.toString().substring(0, 8) ?? 'Unknown'}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(dateFormat.format(date)),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Cart: ${bill['cart_id']}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        currencyFormat.format(totalAmount),
                                        style: TextStyle(
                                          color: Colors.green.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    children: [
                                      if (bill['items'] != null)
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            children: (bill['items'] as List).map((item) {
                                              final itemPrice = _parseAmount(item['price']);
                                              final itemQuantity = item['quantity'] as int? ?? 1;
                                              
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 4),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text('${item['name']} x$itemQuantity'),
                                                    Text(currencyFormat.format(itemPrice * itemQuantity)),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}