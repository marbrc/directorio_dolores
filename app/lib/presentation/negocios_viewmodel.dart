import 'package:flutter/foundation.dart';

import '../datos/negocios_api.dart';
import '../dominio/negocio.dart';

// Los 5 estados por los que pasa la pantalla
enum Estado { inicial, cargando, listo, vacio, error }

// Aquí vive la lógica de la pantalla, la pantalla solo dibuja lo que diga el ViewModel
class NegociosViewModel extends ChangeNotifier {
  final NegociosApi api;
  Estado estado = Estado.inicial;
  List<Negocio> negocios = [];
  String? mensajeError;

  NegociosViewModel(this.api);

  // Pide la lista a la API y avisa cada vez que cambia el estado
  Future<void> cargar({String busqueda = ''}) async {
    estado = Estado.cargando;
    mensajeError = null;
    notifyListeners();
    try {
      negocios = await api.listar(busqueda: busqueda);
      estado = negocios.isEmpty ? Estado.vacio : Estado.listo;
    } catch (e) {
      mensajeError = e.toString();
      estado = Estado.error;
    }
    notifyListeners();
  }

  // Crea un negocio y vuelve a cargar la lista
  Future<void> agregar(Negocio n) async {
    try {
      await api.crear(n);
      await cargar();
    } catch (e) {
      mensajeError = e.toString();
      estado = Estado.error;
      notifyListeners();
    }
  }

  // Borra un negocio en la API y luego lo quita de la lista local
  Future<void> eliminar(Negocio n) async {
    try {
      await api.eliminar(n.id!);
      negocios = negocios.where((x) => x.id != n.id).toList();
      estado = negocios.isEmpty ? Estado.vacio : Estado.listo;
    } catch (e) {
      mensajeError = e.toString();
      estado = Estado.error;
    }
    notifyListeners();
  }

  // Marca o desmarca el favorito y usa la respuesta del servidor
  Future<void> alternarFavorito(Negocio n) async {
    try {
      final nuevo = await api.actualizar(n.copiarCon(favorito: !n.favorito));
      negocios = [for (final x in negocios) x.id == nuevo.id ? nuevo : x];
    } catch (e) {
      mensajeError = e.toString();
    }
    notifyListeners();
  }
}
