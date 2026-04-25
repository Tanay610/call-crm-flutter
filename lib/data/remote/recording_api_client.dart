import 'dart:io';

import 'package:retrofit/retrofit.dart';

import 'models/upload_recording_response.dart';

@RestApi(baseUrl: 'https://mock.api/crm')
abstract class RecordingApiClientContract {
  @MultiPart()
  @POST('/recordings/upload')
  Future<UploadRecordingResponse> uploadRecording(
    @Part(name: 'file') File file,
  );
}
