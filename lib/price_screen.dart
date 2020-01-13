import 'dart:convert';

import 'package:flutter/material.dart';
import 'coin_data.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  //Establecemos la variable que almacenará la moneda que seleccione el usuario.
  String monedaSeleccionada = 'AUD';

  //Creamos las variables para los tipos de monedas virtuales.
  String valorMonedaBTC = '0';

  String valorMonedaETH = '0';

  String valorMonedaLTC = '0';

  //Creamos un método que actualiza los datos de la UI a través del set state (Utilizando los datos obtenidos por la api)
  void actualizarUI(dynamic datos, String seleccionada) {
    setState(() {
      monedaSeleccionada = seleccionada;
      valorMonedaBTC = datos[0]['last'].toString();
      valorMonedaETH = datos[1]['last'].toString();
      valorMonedaLTC = datos[2]['last'].toString();
      print(datos);
    });
  }

  //Creamos un método que genera el widget de lista (dropdown) para los dispositivos android.
  DropdownButton<String> androidDropdown() {
    //Lista que almacenará widget de 'DropdownMenuItem'.
    List<DropdownMenuItem<String>> items = [];

    //Por cada string que haya en nuestra lista de currencies (La cual está ubicada en 'coin_data')...
    for (String moneda in currenciesList) {
      //Creamos un DropdownMenuItem con los valores de ese string (moneda)
      var item = DropdownMenuItem(
        child: Text(moneda),
        value: moneda,
      );
      //Al final, lo añadimos a la lista.
      items.add(item);
    }

    //Regresamos un DropdownButton, cuyo valor será el de la moneda seleccionada.
    return DropdownButton<String>(
      value: monedaSeleccionada,
      items: items,
      //Al verse modficado, ejecutaremos la sig función async:
      onChanged: (value) async {
        //Obtenemos los datos de las monedas virtuales, con el nuevo valor seleccionado (value)
        //Esto lo hacemos a través del método 'ayudanteNetwork' que utiliza a la nueva moneda seleccionada (value) como argumento.
        var datos = await ayudanteNetwork(value);
        //Ejecutamos el método que actualiza la UI, con los datos obtenidos de la app, y el nombre de la nueva moneda seleccionada.
        actualizarUI(datos, value);
      },
    );
  }

  //Método que genera una lista pero para IOS
  CupertinoPicker iosPicker() {
    List<Text> monedas = [];

    for (String moneda in currenciesList) {
      monedas.add(Text(moneda));
    }

    CupertinoPicker(
      children: monedas,
      itemExtent: monedas.length.toDouble(),
      onSelectedItemChanged: (value) async {
        var datos = await ayudanteNetwork(currenciesList[value]);
        actualizarUI(datos, currenciesList[value]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TarjetaBitcoin(
              valorMoneda: valorMonedaBTC,
              monedaSeleccionada: monedaSeleccionada,
              tipoCoin: 'BTC'),
          TarjetaBitcoin(
              valorMoneda: valorMonedaETH,
              monedaSeleccionada: monedaSeleccionada,
              tipoCoin: 'ETH'),
          TarjetaBitcoin(
              valorMoneda: valorMonedaLTC,
              monedaSeleccionada: monedaSeleccionada,
              tipoCoin: 'LTC'),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: Platform.isIOS ? iosPicker() : androidDropdown(),
          ),
        ],
      ),
    );
  }
}

//Método que conecta con la api para recabar información
Future ayudanteNetwork(String codigoMoneda) async {
  //Almacenamos las URLS para cada una de las monedas.
  String urlBTC =
      'https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC$codigoMoneda';

  String urlETH =
      'https://apiv2.bitcoinaverage.com/indices/global/ticker/ETH$codigoMoneda';

  String urlLTC =
      'https://apiv2.bitcoinaverage.com/indices/global/ticker/LTC$codigoMoneda';

  //Creamos una lista de objetos que almacenará cada una de las respuestas de los links.
  List<Object> respuestas = [];

  //Conectamos con cada uno de los links
  var respuestaBTC = await http.get(urlBTC);
  var respuestaETH = await http.get(urlETH);
  var respuestaLTC = await http.get(urlLTC);

  //Si el codigo de estatus de la respuesta es de 200, entonces...
  if (respuestaBTC.statusCode == 200 &&
      respuestaETH.statusCode == 200 &&
      respuestaLTC.statusCode == 200) {
    //Almacenamos en una variable el cuerpo de la respuesta (La info)
    String cuerpoBTC = respuestaBTC.body;
    String cuerpoETH = respuestaETH.body;
    String cuerpoLTC = respuestaLTC.body;

    //Añadimos a la lista las respuestas.
    respuestas.add(jsonDecode(cuerpoBTC));
    respuestas.add(jsonDecode(cuerpoETH));
    respuestas.add(jsonDecode(cuerpoLTC));

    //Regresamos la lista para su uso.
    return respuestas;
  }
  //De cualquier otra forma, significa que el request no fue aduecado.
  else {
    print(respuestaBTC.hashCode);
    print(respuestaETH.hashCode);
    print(respuestaLTC.hashCode);
  }
}

//Clase que genera widget 'TarjetaBitcoin¿
class TarjetaBitcoin extends StatelessWidget {
  //Su creación toma como argumentos el valor de la moneda, la moneda selec, y el tipo de moneda.
  TarjetaBitcoin({this.valorMoneda, this.monedaSeleccionada, this.tipoCoin});

  final String valorMoneda;
  final String monedaSeleccionada;
  final String tipoCoin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
      child: Card(
        color: Colors.lightBlueAccent,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
          child: Text(
            '1 $tipoCoin = $valorMoneda $monedaSeleccionada',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
