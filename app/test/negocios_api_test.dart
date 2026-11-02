import 'dart:convert';
import 'dart:io';

import '../lib/datos/negocios_api.dart';
import '../lib/dominio/excepciones.dart';
import '../lib/dominio/negocio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// Crea la API con un cliente falso (MockClient) para no usar la red de verdad
NegociosApi apiCon(MockClient c) => NegociosApi(c, 'http://prueba');

void main() {
  // Ronda 3, ciclo 3.1: listar tiene que convertir el JSON en objetos Negocio
  test('listar convierte el JSON en objetos Negocio', () async {
    final api = apiCon(MockClient((req) async {
      // Aquí también revisamos que la app pida el método y la ruta correctos
      expect(req.method, 'GET');
      expect(req.url.path, '/negocios');
      return http.Response(
          jsonEncode([
            {'id': 1, 'nombre': 'A', 'categoria': 'X'},
            {'id': 2, 'nombre': 'B', 'categoria': 'Y'},
          ]),
          200);
    }));
    final lista = await api.listar();
    expect(lista.length, 2);
    expect(lista.first.nombre, 'A');
  });

  // Ronda 3, ciclo 3.2: los casos de falla

  // Un 500 del servidor tiene que convertirse en ErrorServidorException
  test('status 500 lanza ErrorServidorException con el codigo', () async {
    final api = apiCon(MockClient((_) async => http.Response('boom', 500)));
    expect(
        api.listar(),
        throwsA(isA<ErrorServidorException>()
            .having((e) => e.codigo, 'codigo', 500)));
  });

  // Si se cae la red, tiene que ser SinConexionException
  test('sin red lanza SinConexionException', () {
    final api =
        apiCon(MockClient((_) async => throw const SocketException('x')));
    expect(api.listar(), throwsA(isA<SinConexionException>()));
  });

  // Si el servidor tarda mucho, también cuenta como sin conexión
  test('timeout se trata como sin conexion', () {
    final api = NegociosApi(
      MockClient((_) async {
        await Future.delayed(const Duration(milliseconds: 200));
        return http.Response('[]', 200);
      }),
      'http://prueba',
      espera: const Duration(milliseconds: 20), // en la prueba esperamos solo 20 ms
    );
    expect(api.listar(), throwsA(isA<SinConexionException>()));
  });

  // Si llega HTML en vez de JSON, la respuesta es inválida
  test('JSON roto lanza RespuestaInvalidaException', () {
    final api = apiCon(MockClient((_) async => http.Response('<html>', 200)));
    expect(api.listar(), throwsA(isA<RespuestaInvalidaException>()));
  });

  // Ronda 3, ciclo 3.3: crear, buscar y eliminar

  // La búsqueda tiene que mandar el parámetro q bien codificado
  test('listar con busqueda manda el parametro q codificado', () async {
    final api = apiCon(MockClient((req) async {
      expect(req.url.queryParameters['q'], 'nieve limón');
      return http.Response('[]', 200);
    }));
    await api.listar(busqueda: 'nieve limón');
  });

  // Crear tiene que mandar un POST con JSON y el Content-Type correcto
  test('crear envia JSON con Content-Type correcto', () async {
    final api = apiCon(MockClient((req) async {
      expect(req.method, 'POST');
      expect(req.headers['Content-Type'], contains('application/json'));
      final cuerpo = jsonDecode(req.body) as Map<String, dynamic>;
      expect(cuerpo['nombre'], 'Nuevo');
      return http.Response(jsonEncode({...cuerpo, 'id': 9}), 201);
    }));
    final creado =
        await api.crear(const Negocio(nombre: 'Nuevo', categoria: 'Z'));
    expect(creado.id, 9);
  });

  // Eliminar tiene que usar DELETE con el id correcto
  test('eliminar usa DELETE al id correcto', () async {
    final api = apiCon(MockClient((req) async {
      expect(req.method, 'DELETE');
      expect(req.url.path, '/negocios/4');
      return http.Response('', 204);
    }));
    await api.eliminar(4);
  });


    // Reto 1: actualizar tiene que usar PUT al id correcto y mandar el favorito
  test('actualizar usa PUT al id correcto y manda el favorito', () async {
    final api = apiCon(MockClient((req) async {
      expect(req.method, 'PUT');
      expect(req.url.path, '/negocios/3');
      final cuerpo = jsonDecode(req.body) as Map<String, dynamic>;
      expect(cuerpo['favorito'], true);
      return http.Response(jsonEncode({...cuerpo, 'id': 3}), 200);
    }));
    final actualizado = await api.actualizar(
        const Negocio(id: 3, nombre: 'X', categoria: 'Y', favorito: true));
    expect(actualizado.favorito, true);
  });
}
