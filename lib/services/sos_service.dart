import 'package:sms_advanced/sms_advanced.dart';

class SOSService {
  static Future<void> sendSOSMessages(List<String> numbers, String message) async {
    SmsSender sender = SmsSender();
    for (String number in numbers) {
      sender.sendSms(SmsMessage(number, message));
    }
  }
}
