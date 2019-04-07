import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:buscador_gifs/ui/gif_page.dart';

import 'package:share/share.dart';

import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _search;
  int _offSet = 0;


  @override
  void initState() {
    super.initState();

    _getGifs().then((map){
      print(map);
    });
  }

  Future<Map> _getGifs() async {
    http.Response response;

    if(_search == null){
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=Pfi9qIHSh2nCIdpameQiOKCBcDCpBlqQ&limit=20&rating=G");
    } else {
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=Pfi9qIHSh2nCIdpameQiOKCBcDCpBlqQ&q=${_search}&limit=19&offset=${_offSet}&rating=G&lang=en");
    }

    return json.decode(response.body);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
         Padding(
           padding: EdgeInsets.all(10.0),
           child:  TextField(
             decoration: InputDecoration(
                 labelText: "Pesquise Aqui",
                 labelStyle: TextStyle(
                     color: Colors.white
                 ),
                 border: OutlineInputBorder()
             ),
             style: TextStyle(
               color: Colors.white,
               fontSize: 18.0,
             ),
             textAlign: TextAlign.center,
             onSubmitted: (textoDoCampo){
               setState(() {
                 _search = textoDoCampo;
                 _offSet = 0;
               });
             },
           ),
         ),
          Expanded(child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    );
                  default:
                    if(snapshot.hasError) return Container();
                    else return _creatingGifTable(context, snapshot);

                }
              }
          ))
        ],
      ),
    );
  }

  int _getCount(List data){
    
    if(_search == null){
      return data.length;
    }
    
    return data.length + 1;
    
  }
  
  Widget _creatingGifTable(context, snapshot){
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,// quantos itens na horizontal
            crossAxisSpacing: 10.0, // espacamento entre os itens na horizontal
            mainAxisSpacing: 10.0 // espaçamento na vertical
        ),// mostra a organização dos itens na tel
        itemCount: _getCount(snapshot.data["data"]),// qtdGifs na tela
        itemBuilder: (context, index){ // para construir cada item

          if(
            _search == null ||
                /*se estiver pesquisando e este não for o ultimo item*/
              index < snapshot.data["data"].length
          ){
            return GestureDetector(// para pode clicar na imagem
              child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                  height: 300.0,
                  fit: BoxFit.cover,
              ),
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index]))
                );
              },
              onLongPress: (){
                Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
              },
            );
          }

          // se eu estiver pesquisando e for o ultimo item retorna o container
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.add, color: Colors.white, size: 70.0,),
                  Text(
                      "Carregar mais...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontStyle: FontStyle.normal,
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
              onTap: (){
                setState(() {
                  _offSet += 19; // vai carregar mais 19
                });
              },
            ),
          );

        }
    );
  }

}
