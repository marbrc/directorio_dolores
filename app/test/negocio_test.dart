import 'package:flutter_test/flutter_test.dart';
import '../lib/dominio/negocio.dart';

void main() {
  // Ronda 2: el modelo tiene que leer todos los campos del JSON
  test('desdeJson lee todos los campos', () {
    final n = Negocio.desdeJson({
      'id': 1, 'nombre': 'Nieves de la Plaza', 'categoria': 'Nevería',
      'telefono': '418-100-0001', 'favorito': true,
    });
    expect(n.id, 1);
    expect(n.nombre, 'Nieves de la Plaza');
    expect(n.favorito, true);
  });

  // Si el servidor no manda telefono ni favorito, usamos valores por omisión
  test('campos opcionales ausentes usan valores por omision', () {
    final n = Negocio.desdeJson({'id': 2, 'nombre': 'X', 'categoria': 'Y'});
    expect(n.telefono, '');
    expect(n.favorito, false);
  });

  // Un negocio nuevo no manda id, el servidor es quien lo asigna
  test('aJson no manda id cuando es nuevo', () {
    const n = Negocio(nombre: 'X', categoria: 'Y');
    expect(n.aJson().containsKey('id'), false);
  });

  // copiarCon cambia solo el favorito y deja lo demás igual
  test('copiarCon cambia solo el favorito', () {
    const n = Negocio(id: 3, nombre: 'X', categoria: 'Y');
    final f = n.copiarCon(favorito: true);
    expect(f.favorito, true);
    expect(f.nombre, 'X');
    expect(f.id, 3);
  });
}
