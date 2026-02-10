// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/predictions_provider.dart';
// import '../widgets/prediction_card.dart';
// import '../theme/app_theme.dart';

// class TodayScreen extends StatefulWidget {
//   const TodayScreen({super.key});

//   @override
//   State<TodayScreen> createState() => _TodayScreenState();
// }

// class _TodayScreenState extends State<TodayScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 5, vsync: this);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = context.read<PredictionsProvider>();
//       if (provider.todayTips.isEmpty) {
//         provider.fetchAllPredictions();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final predictionsProvider = context.watch<PredictionsProvider>();
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Today's Tips"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               predictionsProvider.fetchAllPredictions();
//             },
//           ),
//         ],
//         bottom: TabBar(
//           controller: _tabController,
//           isScrollable: true,
//           labelColor: AppTheme.accentGreen,
//           unselectedLabelColor: Colors.grey,
//           indicatorColor: AppTheme.accentGreen,
//           tabs: const [
//             Tab(text: 'All Tips'),
//             Tab(text: 'Tip of Day'),
//             Tab(text: 'BTTS'),
//             Tab(text: 'Accumulators'),
//             Tab(text: 'Leagues'),
//           ],
//         ),
//       ),
//       body: predictionsProvider.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildAllTips(predictionsProvider),
//                 _buildTipOfDay(predictionsProvider),
//                 _buildBTTS(predictionsProvider),
//                 _buildAccumulators(predictionsProvider),
//                 _buildLeagues(predictionsProvider),
//               ],
//             ),
//     );
//   }

//   Widget _buildAllTips(PredictionsProvider provider) {
//     final todayTips = provider.todayTips;
    
//     if (todayTips.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
//             const SizedBox(height: 16),
//             Text(
//               'No tips available for today',
//               style: Theme.of(context).textTheme.bodyLarge,
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: todayTips.length,
//       itemBuilder: (context, index) {
//         final tip = todayTips[index];
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 16),
//           child: PredictionCard(matchItem: tip),
//         );
//       },
//     );
//   }

//   Widget _buildTipOfDay(PredictionsProvider provider) {
//     final betOfDay = provider.betOfDayAccumulator;
    
//     if (betOfDay == null || betOfDay.matches.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.star, size: 64, color: Colors.grey),
//             const SizedBox(height: 16),
//             Text(
//               'No Tip of the Day available',
//               style: Theme.of(context).textTheme.bodyLarge,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 provider.fetchAllPredictions();
//               },
//               child: const Text('Refresh'),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         // Featured Header
//         Container(
//           margin: const EdgeInsets.only(bottom: 20),
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 AppTheme.accentGold.withOpacity(0.3),
//                 AppTheme.accentGold.withOpacity(0.1),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: AppTheme.accentGold.withOpacity(0.3),
//               width: 2,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: AppTheme.accentGold.withOpacity(0.2),
//                 blurRadius: 20,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.star, color: AppTheme.accentGold),
//                   const SizedBox(width: 8),
//                   Text(
//                     'TODAY\'S FEATURED TIP',
//                     style: Theme.of(context).textTheme.titleLarge!.copyWith(
//                           color: AppTheme.accentGold,
//                           fontWeight: FontWeight.w700,
//                         ),
//                   ),
//                   const SizedBox(width: 8),
//                   const Icon(Icons.star, color: AppTheme.accentGold),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 betOfDay.type,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Matches List
//         ...betOfDay.matches.map((match) {
//           return Container(
//             margin: const EdgeInsets.only(bottom: 16),
//             child: Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Match Header
//                     Text(
//                       match.matchTitle,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: AppTheme.primaryNavy,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       match.date,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
                    
//                     // Prediction Badge
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppTheme.accentGold.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: AppTheme.accentGold),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             match.prediction,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: AppTheme.accentGold,
//                             ),
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: AppTheme.accentGold,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               '⭐ Featured',
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Action Buttons
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton.icon(
//                             onPressed: () {
//                               // Save tip
//                             },
//                             icon: const Icon(Icons.bookmark_border),
//                             label: const Text('Save'),
//                             style: OutlinedButton.styleFrom(
//                               foregroundColor: AppTheme.primaryNavy,
//                               side: const BorderSide(color: AppTheme.primaryNavy),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: () {
//                               // Share tip
//                             },
//                             icon: const Icon(Icons.share),
//                             label: const Text('Share'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppTheme.accentGreen,
//                               foregroundColor: AppTheme.primaryNavy,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }

//   Widget _buildBTTS(PredictionsProvider provider) {
//     final bttsAccumulator = provider.bttsAccumulator;
    
//     if (bttsAccumulator == null || bttsAccumulator.matches.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.percent, size: 64, color: Colors.grey),
//             const SizedBox(height: 16),
//             Text(
//               'No BTTS predictions available',
//               style: Theme.of(context).textTheme.bodyLarge,
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         // BTTS Header
//         Container(
//           margin: const EdgeInsets.only(bottom: 20),
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.red[50],
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.red[100]!),
//           ),
//           child: Row(
//             children: [
//               const Icon(Icons.percent, color: Colors.red),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       bttsAccumulator.type,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.red,
//                       ),
//                     ),
//                     Text(
//                       '${bttsAccumulator.count} matches',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.red,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   'Total Odds: ${bttsAccumulator.totalOdds.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // BTTS Matches
//         ...bttsAccumulator.matches.map((match) {
//           return Container(
//             margin: const EdgeInsets.only(bottom: 16),
//             child: Card(
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       match.matchTitle,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       match.date,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.red.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(color: Colors.red),
//                       ),
//                       child: Text(
//                         match.prediction,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.red,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }

//   Widget _buildAccumulators(PredictionsProvider provider) {
//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         // BTTS & Win Accumulator
//         if (provider.bttsWinAccumulator != null && provider.bttsWinAccumulator!.matches.isNotEmpty)
//           _buildAccumulatorCard(
//             title: 'BTTS & Win',
//             accumulator: provider.bttsWinAccumulator!,
//             color: Colors.blue,
//             icon: Icons.attach_money,
//             onTap: () {
//               Navigator.pushNamed(context, '/btts-win');
//             },
//           ),

//         const SizedBox(height: 16),

//         // Over 2.5 Goals Accumulator
//         if (provider.over25GoalsAccumulator != null && provider.over25GoalsAccumulator!.matches.isNotEmpty)
//           _buildAccumulatorCard(
//             title: 'Over 2.5 Goals',
//             accumulator: provider.over25GoalsAccumulator!,
//             color: Colors.orange,
//             icon: Icons.trending_up,
//             onTap: () {
//               Navigator.pushNamed(context, '/over-25-goals');
//             },
//           ),

//         const SizedBox(height: 16),

//         // Daily Accumulator
//         if (provider.dailyAccumulator != null && provider.dailyAccumulator!.matches.isNotEmpty)
//           _buildAccumulatorCard(
//             title: 'Daily Accumulator',
//             accumulator: provider.dailyAccumulator!,
//             color: Colors.purple,
//             icon: Icons.calendar_today,
//             onTap: () {
//               Navigator.pushNamed(context, '/daily-accumulator');
//             },
//           ),
//       ],
//     );
//   }

//   Widget _buildAccumulatorCard({
//     required String title,
//     required dynamic accumulator,
//     required Color color,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//           border: Border.all(
//             color: color.withOpacity(0.3),
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(icon, color: color),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           accumulator.type ?? title,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             color: color,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           '${accumulator.count} matches',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: color.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Text(
//                       '${accumulator.totalOdds.toStringAsFixed(2)} odds',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: color,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               // Preview of first 2 matches
//               Column(
//                 children: accumulator.matches.take(2).map((match) {
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             match.matchTitle,
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.black87,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: color.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             match.prediction,
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: color,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ),
//               if (accumulator.matches.length > 2)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8),
//                   child: Text(
//                     '+ ${accumulator.matches.length - 2} more matches',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//               const SizedBox(height: 12),
//               // View Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 40,
//                 child: ElevatedButton(
//                   onPressed: onTap,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: color,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     'View Accumulator',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLeagues(PredictionsProvider provider) {
//     final leagues = provider.availableLeagues;
    
//     if (leagues.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
//             const SizedBox(height: 16),
//             Text(
//               'No league predictions available',
//               style: Theme.of(context).textTheme.bodyLarge,
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: leagues.length,
//       itemBuilder: (context, index) {
//         final league = leagues[index];
//         final predictions = provider.getMatchPredictionsByLeague(league);
//         final leagueData = provider.getLeagueData().firstWhere(
//           (data) => data['name'] == league,
//           orElse: () => {'flag': '🏴󠁧󠁢󠁥󠁮󠁧󠁿', 'country': ''},
//         );

//         return GestureDetector(
//           onTap: () {
//             // Navigate to league details or show matches
//           },
//           child: Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Text(
//                   leagueData['flag']!,
//                   style: const TextStyle(fontSize: 24),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         league,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: AppTheme.primaryNavy,
//                         ),
//                       ),
//                       Text(
//                         leagueData['country']!,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.blue[50],
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Text(
//                     '${predictions.length} matches',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.blue[700],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }