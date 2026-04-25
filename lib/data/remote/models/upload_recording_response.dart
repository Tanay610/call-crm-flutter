import '../../../domain/entities/upload_recording_result.dart';

class UploadRecordingResponse {
  const UploadRecordingResponse({required this.success, required this.recordingId});

  final bool success;
  final String recordingId;

  factory UploadRecordingResponse.fromJson(Map<String, dynamic> json) {
    return UploadRecordingResponse(
      success: json['success'] == true,
      recordingId: (json['recordingId'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'recordingId': recordingId};

  UploadRecordingResult toEntity() => UploadRecordingResult(success: success, recordingId: recordingId);
}
