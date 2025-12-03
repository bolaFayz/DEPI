import 'package:get/get.dart';
import 'timeline_controller.dart';

class TimelineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TimelineController>(() => TimelineController());
  }
}