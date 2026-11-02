// Errores con nombre propio, la pantalla decide qué mensaje mostrar

// Cuando no hay conexión con el servidor
class SinConexionException implements Exception {
  @override
  String toString() =>
      'No se pudo conectar con el servidor. ¿Está encendida la API y estás en la misma red?';
}

// Cuando el servidor sí contesta pero con un error (400, 404, 500...)
class ErrorServidorException implements Exception {
  final int codigo;
  ErrorServidorException(this.codigo);

  @override
  String toString() => codigo == 404
      ? 'No se encontró lo que buscabas (404).'
      : codigo == 400
          ? 'El servidor rechazó los datos enviados (400).'
          : 'El servidor respondió con error ($codigo).';
}

// Cuando el servidor contesta algo que no es JSON válido
class RespuestaInvalidaException implements Exception {
  @override
  String toString() => 'El servidor respondió algo que no entiendo.';
}
