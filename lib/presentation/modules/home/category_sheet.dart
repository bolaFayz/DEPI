// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import 'home_controller.dart';
//
// class CategorySheet extends GetView<HomeController> {
//   const CategorySheet({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final categories = [
//       {'name': 'عام', 'value': 'general'},
//       {'name': 'العالم', 'value': 'world'},
//       {'name': 'أعمال', 'value': 'business'},
//       {'name': 'تكنولوجيا', 'value': 'technology'},
//       {'name': 'ترفيه', 'value': 'entertainment'},
//       {'name': 'رياضة', 'value': 'sports'},
//       {'name': 'علوم', 'value': 'science'},
//       {'name': 'صحة', 'value': 'health'},
//     ];
//
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'اختر فئة',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: const Icon(Icons.close),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//
//           // Categories Grid
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               mainAxisSpacing: 12,
//               crossAxisSpacing: 12,
//               childAspectRatio: 2,
//             ),
//             itemCount: categories.length,
//             itemBuilder: (context, index) {
//               final category = categories[index];
//               return Obx(() {
//                 final isSelected = controller.selectedCategory.value == category['value'];
//                 return GestureDetector(
//                   onTap: () {
//                     controller.filterByCategory(category['value'] as String);
//                     Navigator.pop(context);
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? Theme.of(context).primaryColor
//                           : Colors.grey[200],
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: isSelected
//                             ? Theme.of(context).primaryColor
//                             : Colors.transparent,
//                         width: 2,
//                       ),
//                     ),
//                     child: Center(
//                       child: Text(
//                         category['name'] as String,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: isSelected ? Colors.white : Colors.black,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }