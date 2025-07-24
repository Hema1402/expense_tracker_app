import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('expenses');
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Color(0xFFFFF9C4), // Light yellow
        fontFamily: 'Times New Roman',
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black, fontSize: 16),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      home: ExpenseHomePage(),
    );
  }
}

class ExpenseHomePage extends StatefulWidget {
  @override
  _ExpenseHomePageState createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final Box _expenseBox = Hive.box('expenses');

  List<Map<String, dynamic>> get _expenses =>
      _expenseBox.values.toList().cast<Map<String, dynamic>>();

  void _addExpense() {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text);
    if (title.isEmpty || amount == null) return;

    _expenseBox.add({'title': title, 'amount': amount});

    _titleController.clear();
    _amountController.clear();
    Navigator.of(context).pop();
    setState(() {});
  }

  void _deleteExpense(int index) {
    _expenseBox.deleteAt(index);
    setState(() {});
  }

  double _getTotalExpense() {
    return _expenses.fold(
        0.0, (sum, item) => sum + (item['amount'] as double));
  }

  void _showAddExpenseSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFFFFF9C4), // Light yellow
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Expense Title'),
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: _addExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: Text('Add Expense'),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenses = _expenses;
    return Scaffold(
      appBar: AppBar(
        title: Text("Expense Tracker"),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              "Total: ₹${_getTotalExpense().toStringAsFixed(2)}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: expenses.isEmpty
                ? Center(child: Text('No expenses yet, baby! 💸'))
                : ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (ctx, index) {
                      final expense = expenses[index];
                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          color: Colors.redAccent,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _deleteExpense(index);
                        },
                        child: Card(
                          color: Colors.white,
                          margin:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text(
                              expense['title'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Text(
                              "₹${expense['amount'].toStringAsFixed(2)}",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseSheet,
        child: Icon(Icons.add),
      ),
    );
  }
}

