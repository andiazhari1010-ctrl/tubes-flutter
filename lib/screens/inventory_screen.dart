import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../models/models.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int _activeCategoryIndex = 0; // 0: All, 1: Weapon, 2: Armor, 3: Potion

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final ownedItems = state.shopItems.where((i) => i.owned).toList();
        List<ShopItem> filteredItems;

        switch (_activeCategoryIndex) {
          case 1:
            filteredItems = ownedItems.where((i) => i.category == ItemCategory.weapon).toList();
            break;
          case 2:
            filteredItems = ownedItems.where((i) => i.category == ItemCategory.armor).toList();
            break;
          case 3:
            filteredItems = ownedItems.where((i) => i.category == ItemCategory.potion || i.category == ItemCategory.accessory).toList();
            break;
          default:
            filteredItems = ownedItems;
        }

        return Scaffold(
          backgroundColor: AppColors.c0,
          appBar: AppBar(
            title: const Text('INVENTORY'),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Text('🎒', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
          body: Column(
            children: [
              // Categories
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _categoryTab('All', 0),
                    _categoryTab('Weapons', 1),
                    _categoryTab('Armor', 2),
                    _categoryTab('Items', 3),
                  ],
                ),
              ),

              // Grid
              Expanded(
                child: filteredItems.isEmpty
                    ? _emptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return _InventoryItemCard(
                            item: item,
                            onTap: () => _showItemOptions(context, state, item),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _categoryTab(String label, int index) {
    final active = _activeCategoryIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _activeCategoryIndex = index),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.accent.withOpacity(0.2) : AppColors.c2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppColors.accent : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? AppColors.t1 : AppColors.t3,
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📭', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'Inventory is empty',
            style: TextStyle(fontSize: 16, color: AppColors.t1, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Gunakan gold-mu di shop untuk\nmencari gear hebat!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.t3),
          ),
        ],
      ),
    );
  }

  void _showItemOptions(BuildContext context, AppState state, ShopItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.c1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.c2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Center(
                child: Text(item.emoji, style: const TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.name,
              style: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.t1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.category.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent2,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (item.bonuses.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: item.bonuses.entries.map((e) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.c3,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${e.key.toUpperCase()} +${e.value}',
                        style: const TextStyle(fontSize: 10, color: AppColors.green, fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
              ),
            Text(
              item.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.t2, height: 1.5),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      state.sellItem(item);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.red, width: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('JUAL (50%)', style: TextStyle(color: AppColors.red, fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      state.equipItem(item);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      item.category == ItemCategory.potion ? 'GUNAKAN' : (item.isEquipped ? 'LEPAS' : 'PAKAI'),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  final ShopItem item;
  final VoidCallback onTap;

  const _InventoryItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.c2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: item.isEquipped ? AppColors.gold : item.rarityColor.withOpacity(0.4),
            width: item.isEquipped ? 2 : 1,
          ),
          boxShadow: item.isEquipped
              ? [BoxShadow(color: AppColors.gold.withOpacity(0.2), blurRadius: 10, spreadRadius: 1)]
              : [BoxShadow(color: item.rarityColor.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      item.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10, 
                        fontWeight: FontWeight.bold, 
                        color: item.rarityColor
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (item.isEquipped)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 10, color: Colors.black),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
