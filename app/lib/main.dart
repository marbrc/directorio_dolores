import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'datos/config_api.dart';
import 'datos/negocios_api.dart';
import 'presentation/negocios_viewmodel.dart';
import 'presentation/pantalla_negocios.dart';

// Aquí se conecta todo: cliente HTTP real, API, ViewModel y pantalla
void main() {
  final api = NegociosApi(http.Client(), urlBaseApi());
  runApp(MaterialApp(
    title: 'Directorio Dolores',
    theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
    home: PantallaNegocios(vm: NegociosViewModel(api)),
  ));
}
