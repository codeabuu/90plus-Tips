// import 'package:flutter/material.dart';
// import '../models/prediction_model.dart';
// import '../theme/app_theme.dart';

// class FreeTipCard extends StatelessWidget {
//   final MatchPrediction prediction;
//   final VoidCallback? onTap;

//   const FreeTipCard({
//     super.key,
//     required this.prediction,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               blurRadius: 16,
//               offset: const Offset(0, 4),
//             ),
//           ],
//           border: Border(
//             left: BorderSide(
//               color: AppTheme.accentGreen,
//               width: 4,
//             ),
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppTheme.accentGreen.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Text(
//                       'FREE TIP #1',
//                       style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w700,
//                         color: AppTheme.accentGreen,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                   Icon(Icons.lock_open, size: 16, color: AppTheme.accentGreen),
//                 ],
//               ),

//               const SizedBox(height: 12),

//               // Match Info
//               Text(
//                 prediction.league,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 '${prediction.homeTeam} vs ${prediction.awayTeam}',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: AppTheme.primaryNavy,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   const Icon(Icons.schedule, size: 12, color: Colors.grey),
//                   const SizedBox(width: 4),
//                   Text(
//                     _formatTime(prediction.matchTime),
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   const Icon(Icons.location_on, size: 12, color: Colors.grey),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: Text(
//                       prediction.venue,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               // Prediction
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: AppTheme.neutralGray,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'PREDICTION',
//                       style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w700,
//                         color: AppTheme.primaryNavy.withOpacity(0.6),
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       prediction.prediction,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: AppTheme.primaryNavy,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Stats Row
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _buildStatItem(
//                     icon: Icons.attach_money,
//                     label: 'Odds',
//                     value: prediction.odds.toString(),
//                   ),
//                   _buildStatItem(
//                     icon: Icons.bar_chart,
//                     label: 'Confidence',
//                     value: '${(prediction.confidence * 100).toInt()}%',
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               // Confidence Bar
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Confidence',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                       Text(
//                         '${(prediction.confidence * 100).toInt()}%',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: _getConfidenceColor(prediction.confidence),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     height: 6,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(3),
//                     ),
//                     child: Stack(
//                       children: [
//                         Container(
//                           width: MediaQuery.of(context).size.width *
//                               prediction.confidence,
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 _getConfidenceColor(prediction.confidence),
//                                 _getConfidenceColor(prediction.confidence)
//                                     .withOpacity(0.8),
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(3),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               // View Analysis Button
//               Container(
//                 width: double.infinity,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: AppTheme.accentGreen),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'View Full Analysis',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: AppTheme.accentGreen,
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       Icon(Icons.arrow_forward, size: 16, color: AppTheme.accentGreen),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatItem({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(icon, size: 14, color: AppTheme.accentGreen),
//             const SizedBox(width: 4),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             color: AppTheme.primaryNavy,
//           ),
//         ),
//       ],
//     );
//   }

//   String _formatTime(DateTime time) {
//     return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
//   }

//   Color _getConfidenceColor(double confidence) {
//     if (confidence >= 0.75) return AppTheme.accentGreen;
//     if (confidence >= 0.6) return AppTheme.accentGold;
//     return AppTheme.mutedRed;
//   }
// }