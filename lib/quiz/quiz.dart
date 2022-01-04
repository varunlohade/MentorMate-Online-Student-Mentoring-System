import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mentor_mate/globals.dart';
import 'package:mentor_mate/quiz/levels.dart';

class QuizRoute extends StatefulWidget {
  const QuizRoute({Key? key}) : super(key: key);

  @override
  _QuizRouteState createState() => _QuizRouteState();
}

class _QuizRouteState extends State<QuizRoute> {
  bool isLoading = false;
  List<DocumentSnapshot> subCards = [];
  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Quizzes').get();
    setState(() {
      subCards = querySnapshot.docs;
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              'Quiz',
              style: TextStyle(
                fontFamily: "MontserratB",
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.only(top: 60, left: 18),
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                        subCards.length,
                        (index) => Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LevelPage(
                                            name: subCards[index]['subject']
                                                .toString())),
                                  );
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Text(
                                    subCards[index]['subject'],
                                    //textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: "MontserratSB",
                                        fontSize: 26,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            )),
                  )));
  }
}
