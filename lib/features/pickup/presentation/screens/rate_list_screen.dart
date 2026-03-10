import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/request_pickup_sheet.dart';

class RateListScreen extends StatelessWidget {
  const RateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> plasticRates = [
      {
        'type': 'PET Bottle',
        'rate': 15,
        'unit': 'kg',
        'icon': Icons.local_drink_rounded,
        'color': Colors.blue,
        'description': 'Transparent water & soda bottles',
      },
      {
        'type': 'HDPE Plastic',
        'rate': 25,
        'unit': 'kg',
        'icon': Icons.sanitizer_rounded,
        'color': Colors.orange,
        'description': 'Milk jugs, detergent bottles, shampoo',
      },
      {
        'type': 'PVC / Pipes',
        'rate': 10,
        'unit': 'kg',
        'icon': Icons.plumbing_rounded,
        'color': Colors.red,
        'description': 'Pipes, fittings, vinyl flooring',
      },
      {
        'type': 'LDPE Plastic',
        'rate': 12,
        'unit': 'kg',
        'icon': Icons.shopping_bag_rounded,
        'color': Colors.purple,
        'description': 'Grocery bags, shrink wrap',
      },
      {
        'type': 'PP Plastic',
        'rate': 18,
        'unit': 'kg',
        'icon': Icons.takeout_dining_rounded,
        'color': Colors.teal,
        'description': 'Yogurt containers, bottle caps',
      },
      {
        'type': 'PS / Styrofoam',
        'rate': 5,
        'unit': 'kg',
        'icon': Icons.fastfood_rounded,
        'color': Colors.brown,
        'description': 'Disposable plates, foam packaging',
      },
      {
        'type': 'Multi-layer (MLP)',
        'rate': 4,
        'unit': 'kg',
        'icon': Icons.layers_rounded,
        'color': Colors.amber,
        'description': 'Chip packets, biscuit wrappers',
      },
      {
        'type': 'Mixed Plastic',
        'rate': 8,
        'unit': 'kg',
        'icon': Icons.recycling_rounded,
        'color': Colors.green,
        'description': 'Sorted batch of various plastics',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Plastic Rate List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: plasticRates.length,
        itemBuilder: (context, index) {
          final item = plasticRates[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                // Pass the exact plastic type to the schedule sheet
                String type = item['type'] as String;

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) =>
                      RequestPickupSheet(initialPlasticType: type),
                );
              },
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: item['color'] as Color,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['type'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['description'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${item['rate']}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'per ${item['unit']}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textHint,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            '* Rates may vary based on market conditions and quality of plastic.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}
