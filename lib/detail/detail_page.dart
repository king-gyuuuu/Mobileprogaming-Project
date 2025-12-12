import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:kakao_flutter_sdk_template/kakao_flutter_sdk_template.dart';

class DetailPage extends StatefulWidget {
  final String question;
  final List<dynamic> selects; // 선택지 목록 (Firebase 리스트)
  final List<dynamic> answers; // 정답 목록 (Firebase 리스트)

  const DetailPage({
    super.key,
    required this.question,
    required this.selects,
    required this.answers,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // 사용자가 선택한 결과 텍스트를 저장할 변수 (처음엔 비어있음)
  String? resultText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('심리테스트')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: resultText == null
              ? _buildQuestionView() // 아직 선택 안 했으면 질문 화면 보여주기
              : _buildResultView(),  // 선택 했으면 결과 화면 보여주기
        ),
      ),
    );
  }

  // 1. 질문과 선택지 버튼을 보여주는 화면
  Widget _buildQuestionView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.question,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        // 선택지 리스트를 반복문으로 돌려서 버튼으로 만듦
        ...widget.selects.asMap().entries.map((entry) {
          int idx = entry.key;       // 0, 1, 2... 순서
          String text = entry.value; // 선택지 텍스트

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: double.infinity, // 버튼 너비 꽉 채우기
              child: ElevatedButton(
                onPressed: () {
                  // 버튼을 누르면 정답을 찾아서 화면 갱신
                  setState(() {
                    // 데이터베이스의 answers 리스트에서 같은 순서의 답을 가져옴
                    resultText = widget.answers[idx];
                  });
                },
                child: Text(text),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // Kakao Share method
  Future<void> _shareToKakao() async {
    // Construct the FeedTemplate
    final FeedTemplate template = FeedTemplate(
      content: Content(
        title: '내 심리테스트 결과는?',
        description: '${widget.question}\n결과: ${resultText ?? "결과를 알 수 없습니다." }',
        imageUrl: Uri.parse('https://via.placeholder.com/150'), // Placeholder image
        link: Link(
          webUrl: Uri.parse('https://developers.kakao.com/'), // Replace with your app's link
          mobileWebUrl: Uri.parse('https://developers.kakao.com/'), // Replace with your app's link
        ),
      ),
      buttons: [
        Button(
          title: '앱에서 확인하기',
          link: Link(
            webUrl: Uri.parse('https://developers.kakao.com/'), // Replace with your app's link
            mobileWebUrl: Uri.parse('https://developers.kakao.com/'), // Replace with your app's link
          ),
        ),
      ],
    );

    // Share
    try {
      Uri shareUrl = await ShareClient.instance.shareDefault(template: template);
      await ShareClient.instance.launchKakaoTalk(shareUrl);
      print('KakaoTalk Share success');
    } catch (error) {
      print('KakaoTalk Share failed: $error');
      // Show an error to the user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카카오톡 공유 실패: $error')),
        );
      }
    }
  }

  // 2. 결과를 보여주는 화면
  Widget _buildResultView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("당신의 결과는...", style: TextStyle(fontSize: 18)),
        const SizedBox(height: 20),
        Text(
          resultText ?? "",
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // 뒤로 가기
          },
          child: const Text('다른 테스트 하러 가기'),
        ),
        const SizedBox(height: 20), // Add spacing
        ElevatedButton(
          onPressed: _shareToKakao,
          child: const Text('카카오톡으로 결과 공유하기'),
        ),
      ],
    );
  }
}
