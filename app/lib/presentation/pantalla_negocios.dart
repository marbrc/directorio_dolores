import 'package:flutter/material.dart';

import '../dominio/negocio.dart';
import 'negocios_viewmodel.dart';

// La pantalla solo dibuja según el estado del ViewModel
class PantallaNegocios extends StatefulWidget {
  final NegociosViewModel vm;
  const PantallaNegocios({super.key, required this.vm});

  @override
  State<PantallaNegocios> createState() => _PantallaNegociosState();
}

class _PantallaNegociosState extends State<PantallaNegocios> {
  @override
  void initState() {
    super.initState();
    widget.vm.cargar(); // al abrir la pantalla pedimos los negocios
  }

  // Ventanita para agregar un negocio nuevo
  Future<void> _nuevo() async {
    final nombre = TextEditingController();
    final categoria = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuevo negocio'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: nombre,
              decoration: const InputDecoration(labelText: 'Nombre')),
          TextField(
              controller: categoria,
              decoration: const InputDecoration(labelText: 'Categoría')),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar')),
        ],
      ),
    );
    if (ok == true) {
      await widget.vm
          .agregar(Negocio(nombre: nombre.text, categoria: categoria.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    // AnimatedBuilder vuelve a dibujar la pantalla cada vez que el ViewModel avisa un cambio
    return AnimatedBuilder(
      animation: vm,
      builder: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Directorio · Dolores Hidalgo')),
        floatingActionButton:
            FloatingActionButton(onPressed: _nuevo, child: const Icon(Icons.add)),
        // Un caso por cada uno de los 5 estados
        body: switch (vm.estado) {
          Estado.inicial || Estado.cargando =>
            const Center(child: CircularProgressIndicator()),
          Estado.error => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.cloud_off, size: 64),
                  const SizedBox(height: 12),
                  Text(vm.mensajeError ?? 'Error', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                      onPressed: vm.cargar, child: const Text('Reintentar')),
                ]),
              ),
            ),
          Estado.vacio =>
            const Center(child: Text('Aún no hay negocios. ¡Agrega el primero!')),
          Estado.listo => RefreshIndicator(
              onRefresh: vm.cargar, // jalar hacia abajo para recargar
              child: ListView(children: [
                for (final n in vm.negocios)
                  Dismissible(
                    key: ValueKey(n.id),
                    background: Container(color: Colors.red),
                    onDismissed: (_) => vm.eliminar(n), // deslizar para borrar
                    child: ListTile(
                      title: Text(n.nombre),
                      subtitle: Text('${n.categoria} · ${n.telefono}'),
                      trailing: IconButton(
                        icon: Icon(n.favorito ? Icons.star : Icons.star_border),
                        onPressed: () => vm.alternarFavorito(n),
                      ),
                    ),
                  ),
              ]),
            ),
        },
      ),
    );
  }
}
