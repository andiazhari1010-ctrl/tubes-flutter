import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';
import '../models/app_state.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final gold = state.hero.gold;

        return Scaffold(
          backgroundColor: AppColors.c0,
          appBar: AppBar(
            title: const Text('QUEST SHOP'),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AppIcons.gold, size: 15, color: AppColors.gold),
                        const SizedBox(width: 4),
                        Text(
                          '$gold',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.shopItems.length,
            itemBuilder: (context, index) {
              final item = state.shopItems[index];
              return RevealOnce(
                child: _ShopItemTile(
                  item: item,
                  canAfford: gold >= item.price,
                  onBuy: () {
                    if (gold >= item.price && !item.owned) {
                      state.buyItem(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Berhasil membeli ${item.name}!'),
                          backgroundColor: AppColors.green,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ShopItemTile extends StatelessWidget {
  final ShopItem item;
  final bool canAfford;
  final VoidCallback onBuy;

  const _ShopItemTile({
    required this.item,
    required this.canAfford,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final rc = item.rarityColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.c2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.owned
              ? AppColors.accent.withValues(alpha: 0.4)
              : rc.withValues(alpha: 0.28),
          width: 1,
        ),
        // Item legendaris bercahaya halus.
        boxShadow: item.rarity == ItemRarity.legendary
            ? [BoxShadow(color: rc.withValues(alpha: 0.14), blurRadius: 16, spreadRadius: -2)]
            : null,
      ),
      child: Row(
        children: [
          // Item Icon — di-tint sesuai rarity.
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [rc.withValues(alpha: 0.22), AppColors.c3],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: rc.withValues(alpha: 0.4), width: 0.5),
            ),
            child: Center(
              child: Icon(AppIcons.itemCategory(item.category), size: 28, color: rc),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.t1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Badge rarity.
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: rc.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.rarity.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: rc,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(fontSize: 11, color: AppColors.t2),
                ),
                const SizedBox(height: 7),
                Text(
                  item.category.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.t3,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Buy Button
          item.owned
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'OWNED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent2,
                    ),
                  ),
                )
              : ElevatedButton(
                  onPressed: canAfford ? onBuy : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    disabledBackgroundColor: AppColors.c3,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIcons.gold, size: 13, color: canAfford ? Colors.white : AppColors.t3),
                      const SizedBox(width: 4),
                      Text(
                        '${item.price}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: canAfford ? Colors.white : AppColors.t3,
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}