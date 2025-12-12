import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../sub/question_page.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

class MainPageState extends State<MainPage> {
  late DatabaseReference _testRef;
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  String welcomeTitle = '';
  bool bannerUse = false;

  @override
  void initState() {
    super.initState();
    _testRef = FirebaseDatabase.instance.ref('test');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('심리 테스트 목록'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: StreamBuilder(
        stream: _testRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!.snapshot.value;
            if (data == null) {
              return const Center(
                child: Text('No Data'),
              );
            }
            final questions = (data as Map).values.toList();
            final questionKeys = (data as Map).keys.toList();

            return ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index] as Map<String, dynamic>;
                return Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    leading: const Icon(Icons.psychology, color: Colors.deepPurple),
                    title: Text(
                      question['title'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.deepPurple),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return QuestionPage(
                              question: question,
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text('No Data'),
            );
          }
        },
      ),
    );
  }
}
