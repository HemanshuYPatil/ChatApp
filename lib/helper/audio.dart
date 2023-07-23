// import 'package:audioplayers/audioplayers.dart';

// class AudioService {
//   static final AudioPlayer _audioPlayer = AudioPlayer();

//   static Future<void> playSendingSound() async {
//     await _playSound('images/sending_tone.mp3');
//   }

//   static Future<void> playReceivingSound() async {
//     await _playSound('images/receving_tone.mp3');
//   }

//   static Future<void> _playSound(String soundPath) async {

//     try {
      
//       await _audioPlayer.play(Uri.parse(soundPath).toString() as Source,true);
//     } catch (e) {
//       print("Error playing sound: $e");
//     }
//   }
// }
