import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/message_model.dart';
import '../services/db_service.dart';
import '../theme/app_theme.dart';

class PlantHistoryPage extends StatefulWidget {
  final String userId;
  final String plantId;
  final String plantName;

  const PlantHistoryPage({
    super.key,
    required this.userId,
    required this.plantId,
    required this.plantName,
  });

  @override
  State<PlantHistoryPage> createState() => _PlantHistoryPageState();
}

class _PlantHistoryPageState extends State<PlantHistoryPage> {
  final _dbService = DatabaseService();
  late Stream<List<MessageModel>> _messagesStream;

  @override
  void initState() {
    super.initState();
    _messagesStream = _dbService.messagesStream(widget.userId, widget.plantId);
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ZenBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.paleGreenGray,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'All Reflections',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // Empty placeholder button for balancing alignment
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Plant Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  widget.plantName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.lightGreen,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Reflections list
              Expanded(
                child: StreamBuilder<List<MessageModel>>(
                  stream: _messagesStream,
                  builder: (context, msgSnapshot) {
                    if (msgSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.seedGreen,
                        ),
                      );
                    }

                    final messages = msgSnapshot.data ?? [];
                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          'No history available',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            color: AppColors.paleGreenGray.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 8.0,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.glassBg.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.spa_outlined,
                                          color: AppColors.lightGreen,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Reflection #${messages.length - index}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: AppColors.lightGreen,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _formatDate(msg.dateWritten),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: AppColors.paleGreenGray
                                            .withValues(alpha: 0.5),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  msg.messageText,
                                  style: GoogleFonts.notoSerif(
                                    fontSize: 14.5,
                                    height: 1.6,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
