import 'package:hive_flutter/hive_flutter.dart';

import 'models/customer_model.dart';
import 'models/recording_model.dart';

class HiveBoxes {
  static const String customersBoxName = 'customers';
  static const String recordingsBoxName = 'recordings';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CustomerModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(RecordingModelAdapter());
    }
    await Hive.openBox<CustomerModel>(customersBoxName);
    await Hive.openBox<RecordingModel>(recordingsBoxName);
  }

  static Box<CustomerModel> customers() => Hive.box<CustomerModel>(customersBoxName);
  static Box<RecordingModel> recordings() => Hive.box<RecordingModel>(recordingsBoxName);
}

