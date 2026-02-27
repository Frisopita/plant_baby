import 'package:flutter/material.dart';
import 'package:monitor_baby/models/plant.dart';

class PlantCard extends StatelessWidget {
  const PlantCard({
    super.key,
    required this.plant,
    required this.onMarkWatered,
    required this.onDelete,
    required this.onConnectBle,
  });

  final Plant plant;
  final VoidCallback onMarkWatered;
  final VoidCallback onDelete;
  final VoidCallback onConnectBle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needsWater = plant.needsWater;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFD1FAE5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        plant.nickname,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        plant.scientificName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Eliminar planta',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Icon(
                  needsWater ? Icons.water_drop : Icons.check_circle,
                  color:
                      needsWater ? const Color(0xFF2563EB) : const Color(0xFF16A34A),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    needsWater
                        ? 'Necesita riego hoy'
                        : 'Próximo riego en ${plant.daysUntilNextWater} día(s)',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: onConnectBle,
                  icon: const Icon(Icons.bluetooth),
                  label: const Text('Conectar BLE'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onMarkWatered,
                  icon: const Icon(Icons.opacity),
                  label: const Text('Marcar riego'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
