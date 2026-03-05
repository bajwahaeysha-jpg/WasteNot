import 'package:flutter/material.dart';
import '../../donors/all_donors_screen.dart';
import '../../donations/all_donations_screen.dart';
import '../../alerts/alert_screen.dart';
import '../../../../widgets/dashboard_stat_card.dart';
import '../../../../widgets/pressable_scale.dart';
import '../../ngos/all_ngos_screen.dart';
import '../../meals/all_meals_screen.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    /// responsive padding
    final cardPadding = screenWidth * 0.04;
    final alertIconSize = screenWidth * 0.045;
    final textSize = screenWidth * 0.035;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// 🔔 ALERT CARD
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AlertScreen()),
            );
          },

          child: Container(
            padding: EdgeInsets.fromLTRB(
                cardPadding, cardPadding, cardPadding, cardPadding),
            margin: const EdgeInsets.only(top: 2, bottom: 6),

            decoration: BoxDecoration(
              color: const Color(0xFFFFF6D5),
              borderRadius: BorderRadius.circular(16),

              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],

              border: Border.all(
                color: const Color(0xFFF1E0A6),
              ),
            ),

            child: Column(
              children: [
                _AlertRow(
                  text: "2 urgent requests need approval",
                  iconSize: alertIconSize,
                  textSize: textSize,
                ),
                _AlertRow(
                  text: "Pickup scheduled in 30 minutes",
                  iconSize: alertIconSize,
                  textSize: textSize,
                ),
                _AlertRow(
                  text: "Weekly impact report is ready",
                  iconSize: alertIconSize,
                  textSize: textSize,
                ),
              ],
            ),
          ),
        ),

        /// 📊 STATS GRID
        LayoutBuilder(
          builder: (context, constraints) {

            /// tablet support
            int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              childAspectRatio: 1.18,
              crossAxisSpacing: screenWidth * 0.035,
              mainAxisSpacing: screenWidth * 0.035,

              children: [
                _buildCard(context, "donors"),
                _buildCard(context, "ngos"),
                _buildCard(context, "donations"),
                _buildCard(context, "meals"),
              ],
            );
          },
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCard(BuildContext context, String type) {

    switch (type) {

      case "donors":
        return _cardWrapper(
          context,
          const AllDonorsScreen(),
          const DashboardStatCard(
            title: "All donors",
            value: "2,531",
            change: "+2.5%",
            isUp: true,
            icon: Icons.group,
            iconColor: Colors.green,
          ),
        );

      case "ngos":
        return _cardWrapper(
          context,
          const AllNGOsScreen(),
          const DashboardStatCard(
            title: "All NGOs",
            value: "25,351",
            change: "-0.15%",
            isUp: false,
            icon: Icons.favorite,
            iconColor: Colors.red,
          ),
        );

      case "donations":
        return _cardWrapper(
          context,
          const AllDonationsScreen(),
          const DashboardStatCard(
            title: "All donations",
            value: "351.12k",
            change: "+24.5%",
            isUp: true,
            icon: Icons.monetization_on,
            iconColor: Colors.orange,
          ),
        );

      case "meals":
        return _cardWrapper(
          context,
          const AllMealsScreen(),
          const DashboardStatCard(
            title: "Meals Saved",
            value: "1,351",
            change: "-0.5%",
            isUp: false,
            icon: Icons.restaurant,
            iconColor: Colors.blue,
          ),
        );

      default:
        return const SizedBox();
    }
  }

  Widget _cardWrapper(BuildContext context, Widget screen, Widget card) {
    return PressableScale(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: card,
    );
  }
}

/// 🔸 ALERT ROW
class _AlertRow extends StatelessWidget {

  final String text;
  final double iconSize;
  final double textSize;

  const _AlertRow({
    required this.text,
    required this.iconSize,
    required this.textSize,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        children: [

          Icon(
            Icons.warning_amber_rounded,
            color: const Color(0xFFF39C12),
            size: iconSize,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: textSize,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}