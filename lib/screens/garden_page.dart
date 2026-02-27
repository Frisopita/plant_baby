import 'package:flutter/material.dart';
import 'package:monitor_baby/models/plant.dart';
import 'package:monitor_baby/widgets/add_plant_dialog.dart';
import 'package:monitor_baby/widgets/plant_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PlantFilter {
  all,
  needsWater,
  upToDate,
}

class GardenPage extends StatefulWidget {
  const GardenPage({super.key});

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  static const _storageKey = 'plants';

  final List<Plant> _plants = <Plant>[];
  PlantFilter _currentFilter = PlantFilter.all;

  @override
  void initState() {
    super.initState();
    _loadPlantsFromStorage();
  }

  Future<void> _loadPlantsFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null || data.isEmpty) {
      return;
    }
    final loaded = Plant.decodeList(data);
    setState(() {
      _plants
        ..clear()
        ..addAll(loaded);
    });
  }

  Future<void> _savePlantsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, Plant.encodeList(_plants));
  }

  void _addPlant(Plant plant) {
    setState(() {
      _plants.add(plant);
    });
    _savePlantsToStorage();
  }

  void _deletePlant(String id) {
    setState(() {
      _plants.removeWhere((p) => p.id == id);
    });
    _savePlantsToStorage();
  }

  void _markPlantWatered(Plant plant) {
    final index = _plants.indexWhere((p) => p.id == plant.id);
    if (index == -1) {
      return;
    }
    setState(() {
      _plants[index] = plant.copyWith(lastWatered: DateTime.now());
    });
    _savePlantsToStorage();
  }

  int get _needsWaterCount =>
      _plants.where((plant) => plant.needsWater).length;

  int get _upToDateCount =>
      _plants.where((plant) => !plant.needsWater).length;

  List<Plant> get _filteredPlants {
    switch (_currentFilter) {
      case PlantFilter.needsWater:
        return _plants.where((p) => p.needsWater).toList();
      case PlantFilter.upToDate:
        return _plants.where((p) => !p.needsWater).toList();
      case PlantFilter.all:
      default:
        return _plants;
    }
  }

  Future<void> _openAddPlantDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AddPlantDialog(
        onSaved: _addPlant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _HeaderSection(needsWater: _needsWaterCount, upToDate: _upToDateCount),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _openAddPlantDialog,
                icon: const Icon(Icons.add),
                label: const Text('Agregar Planta'),
              ),
            ),
            const SizedBox(height: 16),
            _FilterTabs(
              currentFilter: _currentFilter,
              onChanged: (filter) {
                setState(() {
                  _currentFilter = filter;
                });
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _filteredPlants.isEmpty
                  ? Center(
                      child: Text(
                        'Aún no tienes plantas.\nToca \"Agregar Planta\" para comenzar.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _filteredPlants.length,
                      itemBuilder: (context, index) {
                        final plant = _filteredPlants[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PlantCard(
                            plant: plant,
                            onMarkWatered: () => _markPlantWatered(plant),
                            onDelete: () => _deletePlant(plant.id),
                            onConnectBle: () {
                              // Placeholder por ahora
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.needsWater,
    required this.upToDate,
  });

  final int needsWater;
  final int upToDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF16A34A),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Mi Jardín',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          const Text(
            'Cuida tus plantas con amor 🌱',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _SummaryCard(
                  color: const Color(0xFFFFF1F2),
                  iconColor: const Color(0xFFEF4444),
                  icon: Icons.local_fire_department,
                  value: needsWater,
                  label: 'Necesitan riego',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  color: const Color(0xFFECFDF3),
                  iconColor: const Color(0xFF16A34A),
                  icon: Icons.check_circle,
                  value: upToDate,
                  label: 'Al día',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final Color iconColor;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                value.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
    required this.currentFilter,
    required this.onChanged,
  });

  final PlantFilter currentFilter;
  final ValueChanged<PlantFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          _FilterChip(
            label: 'Todas',
            selected: currentFilter == PlantFilter.all,
            onTap: () => onChanged(PlantFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Regar',
            selected: currentFilter == PlantFilter.needsWater,
            onTap: () => onChanged(PlantFilter.needsWater),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Al día',
            selected: currentFilter == PlantFilter.upToDate,
            onTap: () => onChanged(PlantFilter.upToDate),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? Colors.black : const Color(0xFFD1D5DB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF4B5563),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

