import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

class ImageLarge extends StatefulWidget {
  final String? imageurl;

  ImageLarge({this.imageurl});
  @override
  _ImageLargeState createState() => _ImageLargeState();
}

class _ImageLargeState extends State<ImageLarge> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                              child: Icon(
                            PhosphorIcons.caret_left_bold,
                            color: Colors.black,
                          ))),
                    )),
                Text(
                  "Image",
                  style: TextStyle(
                      fontFamily: 'MontserratSB',
                      color: Colors.black,
                      fontSize: 18),
                ),
              ],
            ),
            InteractiveViewer(
              clipBehavior: Clip.none,
              panEnabled: false, // Set it to false
              boundaryMargin: EdgeInsets.all(00),
              minScale: 0.5,
              maxScale: 2,
              child: Container(
                height: MediaQuery.of(context).size.height - 140,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Hero(
                        tag: widget.imageurl!,
                        child: Image.network(
                          widget.imageurl!,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
