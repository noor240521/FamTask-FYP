import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class ShoppingTab extends StatefulWidget {
  const ShoppingTab({super.key});

  @override
  State<ShoppingTab> createState() => _ShoppingTabState();
}

class _ShoppingTabState extends State<ShoppingTab> {
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  bool _isUrgent = false;

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _handleAddItem(AppState state) {
    final name = _nameController.text.trim();
    final qty = _qtyController.text.trim();
    if (name.isEmpty) return;

    state.addShoppingItem(name, qty.isEmpty ? '1' : qty, _isUrgent);
    
    _nameController.clear();
    _qtyController.clear();
    setState(() {
      _isUrgent = false;
    });

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item added to shopping list!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final pendingItems = state.shoppingList.where((item) => !item.isCompleted).toList();
    final completedItems = state.shoppingList.where((item) => item.isCompleted).toList();

    return Scaffold(
      backgroundColor: FamTheme.softBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Shopping List',
          style: GoogleFonts.outfit(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: FamTheme.darkPurple,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            // Quick Add Panel
            _buildQuickAddPanel(state),
            const SizedBox(height: 18),
            // Items List
            Expanded(
              child: state.shoppingList.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      children: [
                        if (pendingItems.isNotEmpty) ...[
                          _buildSectionHeader('Pending Items (${pendingItems.length})'),
                          const SizedBox(height: 8),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pendingItems.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) => _buildShoppingCard(pendingItems[index], state),
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (completedItems.isNotEmpty) ...[
                          _buildSectionHeader('Purchased Items'),
                          const SizedBox(height: 8),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: completedItems.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) => _buildShoppingCard(completedItems[index], state),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: FamTheme.darkPurple.withOpacity(0.5),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 60,
            color: FamTheme.darkPurple.withOpacity(0.2),
          ),
          const SizedBox(height: 14),
          Text(
            'Your shopping list is empty!',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: FamTheme.darkPurple.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddPanel(AppState state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: FamTheme.darkPurple.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Item Name (e.g. Milk)',
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _qtyController,
                  decoration: const InputDecoration(
                    hintText: 'Qty (e.g. 2)',
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _handleAddItem(state),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: FamTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: FamTheme.secondary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Mark as urgent',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: FamTheme.darkPurple.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              Switch(
                value: _isUrgent,
                activeColor: FamTheme.primary,
                onChanged: (val) {
                  setState(() {
                    _isUrgent = val;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingCard(ShoppingItem item, AppState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: FamTheme.darkPurple.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Completion Checkbox
          GestureDetector(
            onTap: () => state.toggleShoppingItem(item.id),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.isCompleted ? Colors.green : FamTheme.primary.withOpacity(0.5),
                  width: 2,
                ),
                color: item.isCompleted ? Colors.green : Colors.transparent,
              ),
              child: item.isCompleted
                  ? const Icon(Icons.done, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: FamTheme.darkPurple,
                    decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Quantity: ${item.quantity}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: FamTheme.darkPurple.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          // Badges and Deletion
          Row(
            children: [
              if (item.isUrgent && !item.isCompleted) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Urgent',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              GestureDetector(
                onTap: () {
                  state.deleteShoppingItem(item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item deleted!'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                },
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent.withOpacity(0.7),
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
