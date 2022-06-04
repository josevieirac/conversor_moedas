import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {

  //Executando Aplicação
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.orange,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
          focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
          hintStyle: TextStyle(color: Colors.orange),
        )
    ),
  ));
}

//HG Finance API
Future<Map> getData () async{

  //Colocando um delay no carregamento
  //await Future.delayed(Duration(seconds: 1));

  //Definindo URL
  var request = Uri.parse("https://api.hgbrasil.com/finance?key=c3865514");

  //Realizando requizição GET (o await é para ser assincrono)
  http.Response response = await http.get(request);

  //Convertendo para json e retornando
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  late double _dollar;
  late double _euro;

  final _reaisController = TextEditingController();
  final _dollarController = TextEditingController();
  final _euroController = TextEditingController();

  void clearTextField(){
    _reaisController.text = "";
    _euroController.text = "";
    _dollarController.text = "";
  }

  void _reaisChanged(String text){
      if(text == ""){
        _euroController.text = "";
        _dollarController.text = "";
      }else{
        double real = double.parse(text);
        _dollarController.text = (real/_dollar).toStringAsFixed(2);
        _euroController.text = (real/_euro).toStringAsFixed(2);
      }
  }

  void _dollarChanged(String text){
    if(text == ""){
      _reaisController.text = "";
      _euroController.text = "";
    }else{
      double dollar = double.parse(text);
      _reaisController.text = (dollar*_dollar).toStringAsFixed(2);
      _euroController.text = ((dollar*_dollar)/_euro).toStringAsFixed(2);
    }
  }

  void _euroChanged(String text){
    if(text == ""){
      _reaisController.text = "";
      _dollarController.text = "";
    }else{
      double euro = double.parse(text);
      _reaisController.text = (euro*_euro).toStringAsFixed(2);
      _dollarController.text = ((euro*_euro)/_dollar).toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          "\$ CONVERSOR MONETÁRIO \$",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: clearTextField, 
            icon: Icon(Icons.refresh),
            color: Colors.white,
          )
        ],
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.none ||
              snapshot.connectionState == ConnectionState.waiting){
            return Container(
              color: Colors.orange,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      width: 60,
                      height: 60,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Carregando Dados!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else{
            _dollar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
            _euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
            print("$_dollar | $_euro");
            return SingleChildScrollView(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Icon(
                    Icons.monetization_on_outlined,
                    color: Colors.orange,
                    size: 130,
                  ),
                  Divider(),
                  buildTextField("Reais", "R\$ ", _reaisController, _reaisChanged),
                  Divider(),
                  buildTextField("Dólares", "US\$ ", _dollarController, _dollarChanged),
                  Divider(),
                  buildTextField("Euro", "€ ", _euroController, _euroChanged),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController controller, Function function){
  return TextFormField(
    controller: controller,
    onChanged: (value) {
      function(value);
    },
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.orange,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      border: OutlineInputBorder(),
      prefixText: prefix,
      prefixStyle: TextStyle(
        color: Colors.orange,
        fontSize: 20,
      ),
    ),
    style: TextStyle(
      color: Colors.orange,
      fontSize: 20,
    ),
  );
}

