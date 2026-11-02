import 'dart:convert';

import '../lib/datos/negocios_api.dart';
import '../lib/presentation/negocios_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import '../lib/dominio/negocio.dart';

// Crea un ViewModel con una API falsa que contesta lo que le programemos
NegociosViewModel vmCon(Future<http.Response> Function(http.Request) h) =>
    NegociosViewModel(NegociosApi(MockClient(h), 'http://prueba'));

void main() {
  // Ronda 5: probamos el "viaje" de estados, no solo el destino
  test('cargar con datos termina en listo', () async {
    final vm = vmCon((_) async => http.Response(
        jsonEncode([
          {'id': 1, 'nombre': 'A', 'categoria': 'X'}
        ]),
        200));
    final estados = <Estado>[];
    vm.addListener(() => estados.add(vm.estado));
    await vm.cargar();
    expect(estados, [Estado.cargando, Estado.listo]);
    expect(vm.negocios.length, 1);
  });

  // Si llega una lista vacía, el estado es vacio
  test('cargar con lista vacia termina en vacio', () async {
    final vm = vmCon((_) async => http.Response('[]', 200));
    await vm.cargar();
    expect(vm.estado, Estado.vacio);
  });

  // Si el servidor falla, el estado es error y trae un mensaje
  test('cargar con error de servidor termina en error con mensaje', () async {
    final vm = vmCon((_) async => http.Response('', 500));
    await vm.cargar();
    expect(vm.estado, Estado.error);
    expect(vm.mensajeError, contains('500'));
  });

  // Eliminar quita el negocio de la lista local
  test('eliminar quita el negocio de la lista', () async {
    final vm = vmCon((req) async => req.method == 'DELETE'
        ? http.Response('', 204)
        : http.Response(
            jsonEncode([
              {'id': 1, 'nombre': 'A', 'categoria': 'X'},
              {'id': 2, 'nombre': 'B', 'categoria': 'Y'},
            ]),
            200));
    await vm.cargar();
    await vm.eliminar(vm.negocios.first);
    expect(vm.negocios.map((n) => n.id), [2]);
  });

  // Marcar favorito usa lo que responde el servidor
  test('alternarFavorito actualiza con la respuesta del servidor', () async {
    final vm = vmCon((req) async {
      if (req.method == 'PUT') {
        return http.Response(
            jsonEncode(
                {'id': 1, 'nombre': 'A', 'categoria': 'X', 'favorito': true}),
            200);
      }
      return http.Response(
          jsonEncode([
            {'id': 1, 'nombre': 'A', 'categoria': 'X'}
          ]),
          200);
    });
    await vm.cargar();
    await vm.alternarFavorito(vm.negocios.first);
    expect(vm.negocios.first.favorito, true);
  });

    // Reto 2: si el servidor rechaza los datos (400), el estado es error
  test('agregar con error 400 termina en error con mensaje', () async {
    final vm = vmCon((_) async => http.Response('', 400));
    await vm.agregar(const Negocio(nombre: 'X', categoria: 'Y'));
    expect(vm.estado, Estado.error);
    expect(vm.mensajeError, contains('400'));
  });

  
}
