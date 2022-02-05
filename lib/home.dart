import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mentor_mate/authentication/authenticate.dart';
import 'package:mentor_mate/chat/firebase.dart';
import 'package:mentor_mate/chat_screen.dart';
import 'package:mentor_mate/components/request.dart';
import 'package:mentor_mate/doubt_screen.dart';
import 'package:mentor_mate/doubts_list.dart';
import 'package:mentor_mate/forum.dart';
import 'package:mentor_mate/globals.dart';
import 'package:mentor_mate/models/models.dart';
import 'package:mentor_mate/quiz/quiz.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';

var currentName;
var currentYear;
final _advancedDrawerController = AdvancedDrawerController();

void _handleMenuButtonPressed() {
  _advancedDrawerController.showDrawer();
}

class StudentHomePage extends StatefulWidget {
  Map<String, dynamic> userMap;
  StudentHomePage({required this.userMap});

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  //this widget is the text style for subjects
  static TextStyle _textStyle() {
    return TextStyle(
        fontFamily: "MontserratSB", fontSize: 26, color: Colors.black);
  }

  //this widget is the subject card
  Widget _buildTile(Sub sub) {
    return InkWell(
      radius: 320,
      splashColor: Colors.black.withOpacity(0.2),
      onTap: () {},
      child: Container(
        child: Padding(
          padding: EdgeInsets.only(
              bottom: height! * 0.014, top: height! * 0.014), //12 12
          child: Text(
            sub.name!,
            style: _textStyle(),
          ),
        ),
      ),
    );
  }

  var collectionss;

  Future<void> setName() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(auth.currentUser!.uid)
        .get()
        .then((value) {
      print(value.data());
      print(value.data()!['name']);
      print(value.data()!['year']);
      setState(() {
        currentName = value.data()!['name'];
        currentYear = value.data()!['year'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((value) {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({"fcm": value});
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        print("Message Clicked");
      });
    });
    //setName();
    /*getUser();
    FirebaseFirestore.instance
        .collection("Users")
        .doc(auth.currentUser!.uid)
        .get()
        .then((value) {
      print(value.data());
      print(value.data()!['name']);
      currentUser = value.data()!['name'];
      setState(() {
        currentNameDisplay = value.data()!['name'];
      });
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _addSubs();
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(left: width! * 0.045, right: width! * 0.045), //18 18
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 30,
          ),
          Text(
            "Welcome,",
            style: TextStyle(
              fontFamily: "MontserratB",
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            widget.userMap['name'],
            style: TextStyle(
              fontFamily: "MontserratT",
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: height! * 0.141, //120
          ),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('Teachers').snapshots(),
            builder: (ctx, AsyncSnapshot<QuerySnapshot> usersnapshot) {
              if (usersnapshot.connectionState == ConnectionState.waiting) {
                return Container(
                    child: Center(child: CircularProgressIndicator()));
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: usersnapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document =
                          usersnapshot.data!.docs[index];

                      Map<String, dynamic> map = usersnapshot.data!.docs[index]
                          .data() as Map<String, dynamic>;
                      if (document.id == auth.currentUser?.uid) {
                        collectionss = document.data().toString();
                        return Container(height: 0);
                      }
                      return InkWell(
                        radius: 320,
                        splashColor: Colors.black.withOpacity(0.2),
                        onTap: () {
                          print(
                              'checkhere2--${FirebaseAuth.instance.currentUser!.uid} ${map['uid']}');
                          String roomId1 = chatRoomId(
                              FirebaseAuth.instance.currentUser!.uid,
                              map['uid']);
                          setState(() {
                            roomId = roomId1;
                            to = map['name'];
                          });
                          print('here--\n$roomId $to');

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                  chatRoomId: roomId1,
                                  userMap: map,
                                  name1: currentName,
                                  name2: map['name'])));
                        },
                        child: map['${widget.userMap['year']}'].toString() !=
                                'null'
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: Container(
                                    child: Text(
                                  map['${widget.userMap['year']}'].toString(),
                                  style: _textStyle(),
                                )),
                              )
                            : Container(
                                height: 0,
                              ),
                      );
                    },
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }
}

class StudentHome extends StatefulWidget {
  Map<String, dynamic> userMap;
  StudentHome({required this.userMap});
  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  List<Widget> _subTiles = [];

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? currentNameDisplay;

  PageController? _pageController = PageController();
  int? _currentPage = 0;

  void _addSubs() {
    List<Sub> sub = [
      Sub(name: "Applied Mathematics"),
      Sub(name: "Computer Networks"),
      Sub(name: "Object Oriented Programming"),
      Sub(name: "Data Structures"),
      Sub(name: "Theory of Computation"),
      Sub(name: "Microprocessors"),
    ];

    Future ft = Future(() {});
    /*sub.forEach((Sub sub) {
      ft = ft.then((data) {
        return Future.delayed(const Duration(milliseconds: 10), () {
          _subTiles.add(_buildTile(sub));
          _listKey.currentState!.insertItem(_subTiles.length - 1);
        });
      });
    });*/
  }

  //Map<String, dynamic>? userMap;
  var collectionss;

  void displayuserss() async {
    var documents = await _firestore.collection('Users').get();
    print("this is display useer");
    print(documents);
  }

  final _advancedDrawerController = AdvancedDrawerController();

//these two variables are related to animations
  Tween<Offset> _offset = Tween(begin: Offset(-1, 0), end: Offset(0, 0));
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }

  @override
  Widget build(BuildContext context) {
    displayuserss();
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return AdvancedDrawer(
      backdropColor: Colors.white,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: BoxDecoration(
        //border: Border.all(width: 2, color: Colors.black.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade900.withOpacity(0.05),
            blurRadius: 20.0,
            spreadRadius: 5.0,
            offset: Offset(-20.0, 0.0),
          ),
        ],
        borderRadius: BorderRadius.circular(30),
      ),
      drawer: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 120,
                ),
                Text(
                  "Logged is as",
                  style: TextStyle(
                    fontFamily: "MontserratB",
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.15),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  widget.userMap['name'],
                  style: TextStyle(
                    fontFamily: "MontserratB",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  FirebaseAuth.instance.currentUser!.email!,
                  style: TextStyle(
                    fontFamily: "MontserratT",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                InkWell(
                    onTap: () {
                      logOut(context);
                      setState(() {
                        role = '';
                      });
                    },
                    child: Container(
                      height: 40,
                      width: 120,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.black)),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              PhosphorIcons.sign_out,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(
                              'Logout',
                              style: TextStyle(
                                  fontFamily: 'MontserratSB',
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    )),
                SizedBox(
                  height: 100,
                ),
              ],
            ),
            AnimatedOpacity(
              opacity: 0.2,
              duration: Duration(),
              child: Container(
                height: 60,
                width: 60,
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            )
          ],
        ),
      )),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          brightness: Brightness.dark,
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            color: Colors.black,
            onPressed: _handleMenuButtonPressed,
            icon: ValueListenableBuilder<AdvancedDrawerValue>(
              valueListenable: _advancedDrawerController,
              builder: (_, value, __) {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  child: Icon(
                    value.visible ? Iconsax.close_square : Iconsax.menu,
                    key: ValueKey<bool>(value.visible),
                  ),
                );
              },
            ),
          ),
        ),
        body: PageView(
            controller: _pageController,
            onPageChanged: (value) {
              //_currentPage = value;
              setState(() {
                _currentPage = value;
              });
              /*_pageController!.animateTo(value.toDouble(),
                    duration: Duration(milliseconds: 300),
                    curve: Curves.bounceIn);*/
            },
            children: [
              StudentHomePage(userMap: widget.userMap),
              FormDart(teacherMap: widget.userMap),
              QuizRoute()
            ]),
        bottomNavigationBar: TitledBottomNavigationBar(
            indicatorColor: Colors.black,
            enableShadow: false,
            activeColor: Colors.black,
            currentIndex: _currentPage!,
            onTap: (index) {
              setState(() {
                _currentPage = index;
                _pageController!.animateToPage(index,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.bounceInOut);
              });
            },
            items: [
              TitledNavigationBarItem(
                  title: Text(
                    'Home',
                    style: TextStyle(
                      fontFamily: "MontserratT",
                      fontSize: width * 0.046, //30
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  icon: Icon(PhosphorIcons.house_bold)),
              TitledNavigationBarItem(
                  title: Text(
                    'Forums',
                    style: TextStyle(
                      fontFamily: "MontserratT",
                      fontSize: width * 0.046, //30
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  icon: Icon(PhosphorIcons.chats_bold)),
              TitledNavigationBarItem(
                title: Text(
                  'Quiz',
                  style: TextStyle(
                    fontFamily: "MontserratT",
                    fontSize: width * 0.046, //30
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                icon: Icon(PhosphorIcons.clipboard_text_bold),
              )
            ]),
      ),
    );
  }
}

class TeacherHomePage extends StatefulWidget {
  Map<String, dynamic> teacherMap;
  TeacherHomePage({required this.teacherMap});

  @override
  _TeacherHomePageState createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  bool? showTabs = true;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((value) {
      FirebaseFirestore.instance
          .collection("Teachers")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({"fcm": value});
      _controller = TabController(length: 4, vsync: this);
    });
       FirebaseMessaging.onMessageOpenedApp.listen((message) {
        print("Message Clicked");
      });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(120), //70
            child: AppBar(
              actions: [
                InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  FormDart(teacherMap: widget.teacherMap)));
                    },
                    child: Text("forum"))
              ],
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            color: Colors.black,
                            onPressed: _handleMenuButtonPressed,
                            icon: ValueListenableBuilder<AdvancedDrawerValue>(
                              valueListenable: _advancedDrawerController,
                              builder: (_, value, __) {
                                return AnimatedSwitcher(
                                  duration: Duration(milliseconds: 250),
                                  child: Icon(
                                    value.visible
                                        ? Iconsax.close_square
                                        : Iconsax.menu,
                                    key: ValueKey<bool>(value.visible),
                                  ),
                                );
                              },
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => RequestList(
                                            teacherMap: widget.teacherMap)));
                              },
                              icon: Icon(
                                Iconsax.notification_1,
                                size: 20,
                              ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height! * 0.018, //16
                    ),
                    TabBar(
                      indicatorColor: Colors.white,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black.withOpacity(0.3),
                      labelStyle: TextStyle(
                          fontFamily: "MontserratM",
                          fontSize: width! * 0.040, //16
                          color: Colors.black),
                      unselectedLabelStyle: TextStyle(
                          fontFamily: "MontserratM",
                          fontSize: width! * 0.040, //16
                          color: Colors.black.withOpacity(0.4)),
                      controller: _controller,
                      isScrollable: false,
                      tabs: [
                        Tab(
                          text: 'FY BTech',
                        ),
                        Tab(
                          text: 'SY BTech',
                        ),
                        Tab(
                          text: 'TY BTech',
                        ),
                        Tab(
                          text: 'BTech',
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _controller,
            children: [
              Expanded(
                  child: DoubtPage(
                      checkYear: "FY", teacherMap: widget.teacherMap)),
              Expanded(
                  child: DoubtPage(
                      checkYear: "SY", teacherMap: widget.teacherMap)),
              Expanded(
                  child: DoubtPage(
                      checkYear: "TY", teacherMap: widget.teacherMap)),
              Expanded(
                  child: DoubtPage(
                      checkYear: "BTech", teacherMap: widget.teacherMap)),
            ],
          )),
    );
  }
}

class TeacherHome extends StatefulWidget {
  Map<String, dynamic> teacherMap;
  TeacherHome({required this.teacherMap});
  @override
  _TeacherHomeState createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome>
    with SingleTickerProviderStateMixin {
  PageController? _pageControllerT = PageController();
  int? _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdropColor: Colors.white,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: BoxDecoration(
        //border: Border.all(width: 2, color: Colors.black.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade900.withOpacity(0.05),
            blurRadius: 20.0,
            spreadRadius: 5.0,
            offset: Offset(-20.0, 0.0),
          ),
        ],
        borderRadius: BorderRadius.circular(30),
      ),
      drawer: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 120,
                ),
                Text(
                  "Logged is as",
                  style: TextStyle(
                    fontFamily: "MontserratB",
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.15),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  widget.teacherMap['name'],
                  style: TextStyle(
                    fontFamily: "MontserratB",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  FirebaseAuth.instance.currentUser!.email!,
                  style: TextStyle(
                    fontFamily: "MontserratT",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                InkWell(
                    onTap: () {
                      logOut(context);
                      setState(() {
                        role = '';
                      });
                    },
                    child: Container(
                      height: 40,
                      width: 120,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.black)),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              PhosphorIcons.sign_out,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(
                              'Logout',
                              style: TextStyle(
                                  fontFamily: 'MontserratSB',
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    )),
                SizedBox(
                  height: 100,
                ),
              ],
            ),
            AnimatedOpacity(
              opacity: 0.2,
              duration: Duration(),
              child: Container(
                height: 60,
                width: 60,
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            )
          ],
        ),
      )),
      child: Scaffold(
        backgroundColor: Colors.white,

        body: PageView(
            controller: _pageControllerT,
            onPageChanged: (value) {
              setState(() {
                _currentIndex = value;
              });
              
            },
            children: [
              TeacherHomePage(teacherMap: widget.teacherMap),
              FormDart(teacherMap: widget.teacherMap)

              // Positioned(
              //     top: height! * 0.082, //70
              //     child: RequestList(teacherMap: widget.teacherMap))
            ]),
        bottomNavigationBar: TitledBottomNavigationBar(
            indicatorColor: Colors.black,
            enableShadow: false,
            activeColor: Colors.black,
            currentIndex: _currentIndex!,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                _pageControllerT!.animateToPage(index,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.bounceInOut);
              });
            },
            items: [
              TitledNavigationBarItem(
                  title: Text(
                    'Home',
                    style: TextStyle(
                      fontFamily: "MontserratT",
                      fontSize: width! * 0.046, //30
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  icon: Icon(PhosphorIcons.house_bold)),
              TitledNavigationBarItem(
                  title: Text(
                    'Forums',
                    style: TextStyle(
                      fontFamily: "MontserratT",
                      fontSize: width! * 0.046, //30
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  icon: Icon(PhosphorIcons.chats_bold)),
            ]),

        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.only(left: 26.0),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: [
        //       Center(
        //           child: FloatingActionButton(
        //         onPressed: () {
        //           Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                   builder: (_) => FormDart(
        //                         teacherMap: widget.teacherMap,
        //                       )));
        //         },
        //         shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(18),
        //             side: BorderSide(color: Colors.white)),
        //       )
        //       ),
        //     ],
        //   ),
        // )
      ),
    );
  }
}
