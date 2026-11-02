import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../dominio/excepciones.dart';
import '../dominio/negocio.dart';

// El "mesero": lleva los pedidos a la API y regresa con los datos
class NegociosApi {
  final http.Client _cliente; // se pasa desde afuera para poder usar un MockClient en las pruebas
  final String baseUrl;
  final Duration espera; // cuánto esperamos antes de cortar la petición

  NegociosApi(this._cliente, this.baseUrl,
      {this.espera = const Duration(seconds: 5)});

  Uri _uri(String ruta) => Uri.parse('$baseUrl$ruta');
  static const _json = {'Content-Type': 'application/json'};

  // GET /negocios -> la lista de negocios (con búsqueda opcional)
  Future<List<Negocio>> listar({String busqueda = ''}) async {
    final r = await _ejecutar(() => _cliente.get(_uri(
        '/negocios${busqueda.isEmpty ? '' : '?q=${Uri.encodeQueryComponent(busqueda)}'}')));
    try {
      final lista = jsonDecode(r.body) as List;
      return lista
          .map((e) => Negocio.desdeJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw RespuestaInvalidaException();
    }
  }

  // POST /negocios -> crea un negocio nuevo
  Future<Negocio> crear(Negocio n) async {
    final r = await _ejecutar(() => _cliente.post(_uri('/negocios'),
        headers: _json, body: jsonEncode(n.aJson())));
    return _leerUno(r);
  }

  // PUT /negocios/ID -> actualiza un negocio
  Future<Negocio> actualizar(Negocio n) async {
    final r = await _ejecutar(() => _cliente.put(_uri('/negocios/${n.id}'),
        headers: _json, body: jsonEncode(n.aJson())));
    return _leerUno(r);
  }

  // DELETE /negocios/ID -> borra un negocio
  Future<void> eliminar(int id) async {
    await _ejecutar(() => _cliente.delete(_uri('/negocios/$id')));
  }

  // Convierte la respuesta en un solo Negocio
  Negocio _leerUno(http.Response r) {
    try {
      return Negocio.desdeJson(jsonDecode(r.body) as Map<String, dynamic>);
    } catch (_) {
      throw RespuestaInvalidaException();
    }
  }

  /// Un solo lugar donde se traducen los fallos técnicos a errores del negocio
  Future<http.Response> _ejecutar(
      Future<http.Response> Function() peticion) async {
    http.Response r;
    try {
      // Si el servidor no contesta a tiempo, cortamos
      r = await peticion().timeout(espera);
    } on SocketException {
      throw SinConexionException();
    } on TimeoutException {
      throw SinConexionException();
    } on http.ClientException {
      throw SinConexionException();
    }
    // Un 404 o 500 no lanza error solo, hay que revisar el código nosotros
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw ErrorServidorException(r.statusCode);
    }
    return r;
  }
}
