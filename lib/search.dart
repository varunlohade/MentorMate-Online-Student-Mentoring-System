import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mentor_mate/forum.dart';
import 'package:mentor_mate/globals.dart';

class Search extends StatefulWidget {
  String search;
  Map<String, dynamic> teacherMap;

  Search({required this.search, required this.teacherMap});
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String name = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Forum',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          leading: InkWell(
              customBorder: new CircleBorder(),
              splashColor: Colors.black.withOpacity(0.2),
              onTap: () {
                print("This is form dataaaaaaaaa");
                print("widget search =");
                // Navigator.pop(context);
              },
              child: Container(
                  height: height! * 0.035, //30
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: Center(child: SvgPicture.asset('assets/back.svg')))),
        ),

       
        body: Column(children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Forum')
                .where("title", isGreaterThanOrEqualTo: widget.search)
                .orderBy("servertime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              return (snapshot.connectionState == ConnectionState.waiting)
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot data = snapshot.data!.docs[index];
                          Map<String, dynamic> map = snapshot.data!.docs[index]
                              .data() as Map<String, dynamic>;

                          return ForumCard(
                              map: map, teacherMap: widget.teacherMap);
                        },
                      ),
                    );
            },
          ),
        ]));
  }
}
