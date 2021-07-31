import 'dart:developer';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
class TextPage extends StatelessWidget{

  const TextPage({Key? key, required this.title, required this.paragraph}) : super(key: key);
  final String title;
  final String paragraph;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            primarySwatch: MaterialColor(0xff448aff, color),
            textTheme: const TextTheme(
              bodyText2: TextStyle(fontSize: 18,),
            ),
        ),
        home: Scaffold(
            appBar: AppBar(
                title: Row(
                    children: [
                      TextButton(
                          onPressed: (){Navigator.pop(context);},
                          child: const Icon(Icons.arrow_back, size: 25,color: Colors.white),
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
                    child: Html(data: paragraph, ),


                )
            ),
        ),
        );
  }


//Text(formatText(paragraph), style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold
//))
/*
  RichText formatText(String p){
    List<TextSpan> _text = <TextSpan>[];
    List<String> splitted = p.split("<");

    bool bold = false;
    bool inList = false;


    for(var sentence in splitted){
      //log(sentence[0]);

      if(sentence[0] == "/") {
        int n = 0;
        if(sentence[1] == "s"){
          bold = false;
          log(sentence);
        }
        while(sentence[n] != ">"){n++;}

        _text.add(TextSpan(
          text: sentence.substring(n+1),
          style: const TextStyle(color: Colors.black),
        ));
      }else if(sentence[0] != "\n"){
        int n = 0;

        if(sentence[0] == "s"){
          bold = true;
        }

        while(sentence[n] != ">"){n++;}



        _text.add(TextSpan(
          text: sentence.substring(n+1),
          style: TextStyle(color: Colors.black, fontWeight: bold ? FontWeight.bold : FontWeight.normal, ),

        ));
      }
    }

    return RichText(text: TextSpan(children: _text));
  }*/
}
