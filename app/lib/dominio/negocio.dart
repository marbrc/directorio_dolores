// Esta clase es cada negocio del directorio
class Negocio {
  final int? id; // puede ser null cuando el negocio todavía es nuevo
  final String nombre;
  final String categoria;
  final String telefono;
  final bool favorito;

  const Negocio({
    this.id,
    required this.nombre,
    required this.categoria,
    this.telefono = '', // si no lo mandan, queda vacío
    this.favorito = false, // si no lo mandan, no es favorito
  });

  // Convierte el JSON que manda la API en un objeto Negocio
  factory Negocio.desdeJson(Map<String, dynamic> json) => Negocio(
        id: json['id'] as int?,
        nombre: json['nombre'] as String,
        categoria: json['categoria'] as String,
        // el ?? pone un valor por omisión si el servidor no manda el campo
        telefono: (json['telefono'] as String?) ?? '',
        favorito: (json['favorito'] as bool?) ?? false,
      );

  // Convierte el objeto en JSON para mandarlo a la API
  Map<String, dynamic> aJson() => {
        if (id != null) 'id': id, // el id solo se manda si ya existe
        'nombre': nombre,
        'categoria': categoria,
        'telefono': telefono,
        'favorito': favorito,
      };

  // Hace una copia del negocio cambiando solo el favorito
  Negocio copiarCon({bool? favorito}) => Negocio(
        id: id,
        nombre: nombre,
        categoria: categoria,
        telefono: telefono,
        favorito: favorito ?? this.favorito,
      );
}
