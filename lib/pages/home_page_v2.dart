import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gratitude_garden_app/widgets/user_header.dart';
import '../models/user_model.dart';
import '../models/plant_model.dart';
import '../theme/app_theme.dart';
import 'create_plant_page.dart';
import 'plant_detail_page.dart';
class HomePageV2 extends StatefulWidget {
  final UserModel user;
  final List<PlantModel> plants;

  const HomePageV2({super.key, required this.user, required this.plants});

  @override
  State<HomePageV2> createState() => _HomePageV2State();
}

class _HomePageV2State extends State<HomePageV2> {
  bool _isGridView = true;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8, initialPage: 0);
    _pageController.addListener(_handlePageScroll);
  }

  void _handlePageScroll() {
    if (_pageController.hasClients && _pageController.page != null) {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildWateringStatus(
    PlantModel plant, {
    required double fontSize,
    required double iconSize,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastWateredDay = DateTime(
      plant.lastWatered.year,
      plant.lastWatered.month,
      plant.lastWatered.day,
    );
    final daysDifference = today.difference(lastWateredDay).inDays;

    final String text;
    final Color color;
    final IconData icon;

    if (daysDifference == 0) {
      text = 'Watered today';
      color = AppColors.lightGreen;
      icon = Icons.water_drop;
    } else if (daysDifference == 1 || daysDifference == 2) {
      text = 'Needs water!';
      color = const Color(0xFFC06B6B);
      icon = Icons.warning_amber_rounded;
    } else {
      text = 'Water in 24h or plant will die!';
      color = const Color(0xFFC06B6B);
      icon = Icons.error_outline_rounded;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPlantCard(PlantModel plant) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailPage(
              userId: widget.user.userId,
              plantId: plant.plantId,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(
                0xFF373434,
              ).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Sprout Image with radial aura
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.seedGreen.withValues(
                            alpha: 0.15,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCoWkZpvg2y3XCY-IEILuXGTX3VgP4SAXOf-jkGfHXHiVN3IgK0b5Cp67J60MOtvGXW9FnlOJEB025a15t0LhYHAmtakLqy3WsXAZrxbBuAz8x1-T1gzF2X_5HNGElDU9vY2qJENr-a72bnddvnLp6XdMMT9lPkFDP_0f7-EZOp7ulxt5I4B1Fm9sobL3HR__XjrEbRfTv81IGsHRw9rrQxYfOY965XB0SNf_3Nfikx7nohBMcm1wKy9os_-6CTApkPMabAvTMI-Rs',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Text & Level info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      plant.plantName,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFAF4F4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    _buildWateringStatus(
                      plant,
                      fontSize: 12,
                      iconSize: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.glassBg.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSelectorButton(
            isActive: _isGridView,
            icon: Icons.grid_view_rounded,
            tooltip: 'Grid view',
            onTap: () {
              setState(() {
                _isGridView = true;
              });
            },
          ),
          const SizedBox(width: 4),
          _buildSelectorButton(
            isActive: !_isGridView,
            icon: Icons.view_carousel_rounded,
            tooltip: 'Card view',
            onTap: () {
              setState(() {
                _isGridView = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorButton({
    required bool isActive,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        color: AppColors.textDark,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.seedGreen.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive
                ? AppColors.lightGreen
                : AppColors.paleGreenGray.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildCardView() {
    // Prevent currentPage from overflowing if plants list changed
    if (_currentPage >= widget.plants.length) {
      _currentPage = widget.plants.length - 1;
      if (_currentPage < 0) _currentPage = 0;
    }

    return PageView.builder(
      controller: _pageController,
      physics: const ClampingScrollPhysics(),
      itemCount: widget.plants.length,
      itemBuilder: (context, index) {
        final plant = widget.plants[index];
        final isSelected = index == _currentPage;

        return Center(
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 24.0,
              top: 8.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 380,
              ),
              child: AspectRatio(
                aspectRatio: 0.72,
                child: AnimatedScale(
                  scale: isSelected ? 1.0 : 0.9,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    opacity: isSelected ? 1.0 : 0.6,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: _buildPlantCard(plant),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridViewItem(PlantModel plant) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailPage(
              userId: widget.user.userId,
              plantId: plant.plantId,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(
                0xFF373434,
              ).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Sprout Image with radial aura
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.seedGreen.withValues(
                            alpha: 0.15,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCoWkZpvg2y3XCY-IEILuXGTX3VgP4SAXOf-jkGfHXHiVN3IgK0b5Cp67J60MOtvGXW9FnlOJEB025a15t0LhYHAmtakLqy3WsXAZrxbBuAz8x1-T1gzF2X_5HNGElDU9vY2qJENr-a72bnddvnLp6XdMMT9lPkFDP_0f7-EZOp7ulxt5I4B1Fm9sobL3HR__XjrEbRfTv81IGsHRw9rrQxYfOY965XB0SNf_3Nfikx7nohBMcm1wKy9os_-6CTApkPMabAvTMI-Rs',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Text & Level info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      plant.plantName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFAF4F4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    _buildWateringStatus(
                      plant,
                      fontSize: 10,
                      iconSize: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.plants.length == 1) {
      final plant = widget.plants[0];
      return Scaffold(
        backgroundColor: AppColors.charcoal,
        body: ZenBackground(
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 32.0,
                      right: 32.0,
                      top: 70.0, // Avoid overlapping with header
                      bottom: 20.0,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 380,
                      ),
                      child: AspectRatio(
                        aspectRatio: 0.72,
                        child: _buildPlantCard(plant),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: UserHeader(user: widget.user),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreatePlantPage(user: widget.user),
              ),
            );
          },
          backgroundColor: AppColors.seedGreen,
          child: const Icon(Icons.add, color: AppColors.textDark),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.charcoal,
      body: ZenBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserHeader(user: widget.user),

              // Garden Grid or Empty State
              if (widget.plants.isEmpty)
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.seedGreen.withValues(alpha: 0.1),
                              border: Border.all(
                                color: AppColors.lightGreen.withValues(
                                  alpha: 0.2,
                                ),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.spa_outlined,
                              color: AppColors.lightGreen,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No plants yet',
                            style: GoogleFonts.lora(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFAF4F4),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              'Your garden is waiting to grow. Plant your first seed and nurture it with daily gratitude.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: AppColors.paleGreenGray.withValues(
                                  alpha: 0.7,
                                ),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: 220,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CreatePlantPage(user: widget.user),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.add,
                                color: Color(0xFFFAF4F4),
                                size: 20,
                              ),
                              label: Text(
                                'Plant a Seed',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFAF4F4),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.seedGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                elevation: 3,
                                shadowColor: AppColors.seedGreen.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                if (widget.plants.length > 1) _buildViewSelector(),
                Expanded(
                  child: _isGridView
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GridView.builder(
                            physics: const ClampingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.62,
                            ),
                            itemCount: widget.plants.length,
                            itemBuilder: (context, index) {
                              final plant = widget.plants[index];
                              return _buildGridViewItem(plant);
                            },
                          ),
                        )
                      : _buildCardView(),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: widget.plants.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatePlantPage(user: widget.user),
                  ),
                );
              },
              backgroundColor: AppColors.seedGreen,
              child: const Icon(Icons.add, color: AppColors.textDark),
            ),
    );
  }
}
