import 'package:flutter/material.dart';
import '../controllers/trip_controller.dart';
import '../widgets/form_fields.dart';
import '../widgets/primary_button.dart';

class ActivityFormScreen extends StatefulWidget {
  const ActivityFormScreen({super.key});

  @override
  State<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TripController _controller = TripController();

  String? _activityId;
  String? _tripId;
  int _totalHari = 1;
  int _selectedDay = 1;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _selectedCategory;
  bool _isLoading = false;
  bool _isInit = true;
  bool _isEdit = false;

  final List<String> _categories = ['Gunung', 'Pantai', 'Kota', 'Hutan', 'Kuliner', 'Transportasi'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        _isEdit = args['isEdit'] ?? false;
        _tripId = args['trip_id']?.toString();
        _totalHari = (args['total_hari'] as int?) ?? 1;
        _selectedDay = (args['hari_ke'] as int?) ?? 1;

        if (_isEdit) {
          _activityId = args['id']?.toString();
          _placeController.text = args['tempat'] ?? '';
          _costController.text = (args['biaya'] ?? '').toString().replaceAll('Rp ', '').replaceAll('.', '');
          _noteController.text = args['catatan'] ?? '';
          _selectedCategory = args['kategori'];

          if (args['startTime'] != null && args['startTime'] is TimeOfDay) {
            _startTime = args['startTime'];
          }
          if (args['endTime'] != null && args['endTime'] is TimeOfDay) {
            _endTime = args['endTime'];
          }
        }
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _placeController.dispose();
    _costController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatTime24(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? (_startTime ?? TimeOfDay.now()) : (_endTime ?? TimeOfDay.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveActivity() async {
    if (_formKey.currentState!.validate()) {
      if (_startTime == null || _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap pilih jam mulai dan jam selesai!')),
        );
        return;
      }
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih kategori aktivitas!')),
        );
        return;
      }
      if (_tripId == null || _tripId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID perjalanan tidak ditemukan!')),
        );
        return;
      }

      final parsedCost = int.tryParse(_costController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

      setState(() => _isLoading = true);
      try {
        if (_isEdit && _activityId != null) {
          await _controller.updateActivity(
            id: _activityId!,
            hariKe: _selectedDay,
            jamMulai: _formatTime24(_startTime!),
            jamSelesai: _formatTime24(_endTime!),
            tempat: _placeController.text,
            kategori: _selectedCategory!,
            biaya: parsedCost,
            catatan: _noteController.text,
          );
        } else {
          await _controller.createActivity(
            tripId: _tripId!,
            hariKe: _selectedDay,
            jamMulai: _formatTime24(_startTime!),
            jamSelesai: _formatTime24(_endTime!),
            tempat: _placeController.text,
            kategori: _selectedCategory!,
            biaya: parsedCost,
            catatan: _noteController.text,
          );
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan aktivitas: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final dayOptions = List.generate(_totalHari < 1 ? 1 : _totalHari, (i) => i + 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Aktivitas Harian' : 'Tambah Aktivitas Harian',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (dayOptions.length > 1) ...[
                        const Text('Jadwal Hari', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 20),
                          child: DropdownButtonFormField<int>(
                            initialValue: dayOptions.contains(_selectedDay) ? _selectedDay : 1,
                            decoration: buildAppInputDecoration(
                              hintText: 'Pilih Hari',
                              icon: Icons.today_rounded,
                              primaryColor: primaryColor,
                            ),
                            items: dayOptions.map((day) {
                              return DropdownMenuItem(value: day, child: Text('Hari ke-$day', style: const TextStyle(fontSize: 14)));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedDay = val);
                            },
                          ),
                        ),
                      ],

                      const Text('Nama Tempat / Aktivitas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 20),
                        child: TextFormField(
                          controller: _placeController,
                          decoration: buildAppInputDecoration(
                            hintText: 'Cth: Pantai Kuta / Makan Siang',
                            icon: Icons.place_rounded,
                            primaryColor: primaryColor,
                          ),
                          validator: (value) => (value == null || value.trim().isEmpty) ? 'Tidak boleh kosong' : null,
                        ),
                      ),

                      const Text('Kategori Aktivitas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 20),
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          hint: const Text('Pilih Kategori', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          decoration: buildAppInputDecoration(
                            hintText: 'Pilih Kategori',
                            icon: Icons.category_rounded,
                            primaryColor: primaryColor,
                          ),
                          items: _categories.map((cat) {
                            return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 14)));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedCategory = val),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: AppPickerField(
                                label: 'Jam Mulai',
                                displayText: _startTime != null ? _startTime!.format(context) : 'Pilih Jam',
                                hasValue: _startTime != null,
                                icon: Icons.access_time_rounded,
                                primaryColor: primaryColor,
                                onTap: () => _selectTime(context, true),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: AppPickerField(
                                  label: 'Jam Selesai',
                                  displayText: _endTime != null ? _endTime!.format(context) : 'Pilih Jam',
                                  hasValue: _endTime != null,
                                  icon: Icons.access_time_rounded,
                                  primaryColor: primaryColor,
                                  onTap: () => _selectTime(context, false),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Text('Estimasi Biaya (Rp)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 20),
                        child: TextFormField(
                          controller: _costController,
                          keyboardType: TextInputType.number,
                          decoration: buildAppInputDecoration(
                            hintText: 'Cth: 150000',
                            icon: Icons.payments_rounded,
                            primaryColor: primaryColor,
                          ),
                        ),
                      ),

                      const Text('Catatan (Opsional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TextFormField(
                          controller: _noteController,
                          maxLines: 3,
                          decoration: buildAppInputDecoration(
                            hintText: 'Cth: Jangan lupa bawa baju ganti',
                            icon: Icons.notes_rounded,
                            primaryColor: primaryColor,
                            iconBottomPadding: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                PrimaryButton(
                  label: _isEdit ? 'Simpan Perubahan' : 'Simpan Aktivitas',
                  primaryColor: primaryColor,
                  isLoading: _isLoading,
                  margin: const EdgeInsets.only(top: 28),
                  onPressed: _saveActivity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
