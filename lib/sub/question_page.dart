import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../detail/detail_page.dart';

class QuestionPage extends StatefulWidget {
  final Map<String , dynamic> question;

  const QuestionPage({super.key, required this.question});

  @override
  State<StatefulWidget> createState() {
    return _QuestionPage();
  }
}

class _QuestionPage extends State<QuestionPage> {
  String title = '';
  int? selectedOption; // null safety 적용
  late List<dynamic> selects;
  late List<dynamic> answers;

  @override
  void initState() {
    super.initState();
    title = widget.question['title'] as String; // initState에서 title 설정

    // Firebase에서 가져온 데이터는 Map 형태이며, 순서가 보장되지 않을 수 있습니다.
    // 따라서 key를 기준으로 정렬하여 순서를 보장합니다.
    final selectsMap = widget.question['selects'] as Map;
    final sortedSelectKeys = selectsMap.keys.toList()..sort((a, b) => int.parse(a.toString()).compareTo(int.parse(b.toString())));
    selects = sortedSelectKeys.map((key) => selectsMap[key]).toList();

    final answersMap = widget.question['answer'] as Map;
    final sortedAnswerKeys = answersMap.keys.toList()..sort((a, b) => int.parse(a.toString()).compareTo(int.parse(b.toString())));
    answers = sortedAnswerKeys.map((key) => answersMap[key]).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question['question'] as String,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: selects.length,
                itemBuilder: (context, index) {
                  return RadioListTile<int>(
                    title: Text(selects[index] as String),
                    value: index,
                    groupValue: selectedOption,
                    onChanged: (int? value) {
                      setState(() {
                        selectedOption = value;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: selectedOption == null
                    ? null
                    : () async {
                  try {
                    await FirebaseAnalytics.instance.logEvent(
                      name: "personal_select",
                      parameters: {
                        "test_name": title,
                        "select": selectedOption ?? 0,
                      },
                    );
                    await Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          question: widget.question['question'] as String,
                          selects: selects,
                          answers: answers,
                        ),
                      ),
                    );
                  } catch (e) {
                    print('Failed to log event: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text('성격 보기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
