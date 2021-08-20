import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';


/// Function used to transform the 'blueAccent' color to a 'material color'.
Map<int, Color> color ={
  50:const Color.fromRGBO(68,138,255, .1),
  100:const Color.fromRGBO(68,138,255, .2),
  200:const Color.fromRGBO(68,138,255, .3),
  300:const Color.fromRGBO(68,138,255, .4),
  400:const Color.fromRGBO(68,138,255, .5),
  500:const Color.fromRGBO(68,138,255, .6),
  600:const Color.fromRGBO(68,138,255, .7),
  700:const Color.fromRGBO(68,138,255, .8),
  800:const Color.fromRGBO(68,138,255, .9),
  900:const Color.fromRGBO(68,138,255, 1),};


/// Function that create for every article a new page when the user click on it.
///
/// It does create a top bar and the text in the body of the app.
class TextPage extends StatelessWidget {

  const TextPage({Key? key, required this.title, required this.paragraph})
      : super(key: key);
  final String title;
  final String paragraph;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xff448aff, color),
        fontFamily: 'LinLiber',
        textTheme: const TextTheme(
          bodyText2: TextStyle(fontSize: 18,),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                    Icons.arrow_back, size: 25, color: Colors.white),
              ),
              Expanded(
                child: Text(title),
              ),
            ],
          ),
        ),
        body: Container(
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              child: Html(
                data: paragraph,
                  onLinkTap: (String? urlLink, RenderContext context, Map<String, String> attributes, dom.Element? element) {
                    if(urlLink!.isNotEmpty){
                      _launchURL(urlLink);
                    }
                  }
              ),


            )
        ),
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }}

}