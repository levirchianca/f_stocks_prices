import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

const stockPriceApiBaseUrl = "https://api.hgbrasil.com/finance/stock_price";
const stockPriceApiKey = "143eb56d";

void main() {
  runApp(MaterialApp(title: "Ibovespa", home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController stockNameController = TextEditingController();

  void _clear() {
    stockNameController.clear();
    _formKey = new GlobalKey<FormState>();
  }

  void _getStockPrice(BuildContext context) async {
    var url = stockPriceApiBaseUrl +
        '?key=' +
        stockPriceApiKey +
        '&symbol=' +
        stockNameController.text;

    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      var stock = json.decode(response.body)['results']
          [stockNameController.text.toUpperCase()];

      if (stock['error'] != null && stock['error']) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text("Ops..."),
                  content: Text("Código da ação inválido"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Ok'))
                  ],
                ));
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(stock['company_name']),
                  content: Text("R\$ ${stock['price']}"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Ok'))
                  ],
                ));
      }
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Ops..."),
                content: Text("Não foi possível recuperar preço da ação"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Ok'))
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ibovespa"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _clear,
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            color: Colors.blueAccent,
            child: Column(
              children: <Widget>[
                Center(
                    child: Padding(
                  padding: EdgeInsets.only(top: 50, bottom: 50),
                  child: Text("Preço das Ações",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      )),
                )),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 40),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.grey),
                          hintText: "vale3, bidi4, petr4, ciel3",
                          labelText: "Código da ação",
                          labelStyle:
                              TextStyle(color: Colors.blueAccent, fontSize: 18),
                          border: OutlineInputBorder(),
                          enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.blueAccent, width: 1))),
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.black87, fontSize: 20),
                      controller: stockNameController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "O código da empresa é obrigatório";
                        } else if (value.length != 5) {
                          return "Formato de código inválido";
                        }
                      },
                    ),
                    Padding(padding: EdgeInsets.only(top: 50)),
                    FlatButton(
                      height: 50,
                      color: Colors.blueAccent,
                      onPressed: () {
                        var valid = _formKey.currentState.validate();

                        if (!valid) {
                          return;
                        }

                        _getStockPrice(context);
                      },
                      child: Text(
                        "Buscar",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
