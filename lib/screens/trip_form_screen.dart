import 'package:flutter/material.dart';
import '../controllers/trip_controller.dart';
import '../widgets/form_fields.dart';
import '../widgets/primary_button.dart';

class TripFormScreen extends StatefulWidget {
  const TripFormScreen({super.key});

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TripController _controller = TripController();

  String? _tripId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  bool _isInit = true;
  bool _isEdit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        _isEdit = args['isEdit'] ?? false;
        if (_isEdit) {
          _tripId = args['id']?.toString();
          _titleController.text = args['judul'] ?? '';
          _startDate = args['tgl_mulai'];
          _endDate = args['tgl_selesai'];
        }
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveTrip() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap pilih tanggal mulai dan selesai!')),
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        if (_isEdit && _tripId != null) {
          await _controller.updateTrip(
            id: _tripId!,
            judul: _titleController.text,
            tglMulai: _startDate!,
            tglSelesai: _endDate!,
          );

          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          final newTripId = await _controller.createTrip(
            judul: _titleController.text,
            tglMulai: _startDate!,
            tglSelesai: _endDate!,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Rencana perjalanan berhasil dibuat!')),
            );
            Navigator.pushReplacementNamed(
              context,
              '/trip-detail',
              arguments: newTripId,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan: $e')),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Rencana Perjalanan' : 'Buat Rencana Baru',
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
                      const Text(
                        'Judul Perjalanan',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 20),
                        child: TextFormField(
                          controller: _titleController,
                          decoration: buildAppInputDecoration(
                            hintText: 'Cth: Liburan Musim Panas di Bali',
                            icon: Icons.flight_takeoff_rounded,
                            primaryColor: primaryColor,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Judul perjalanan tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: AppPickerField(
                              label: 'Tanggal Mulai',
                              displayText: _startDate != null
                                  ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                  : 'Pilih Tgl',
                              hasValue: _startDate != null,
                              icon: Icons.calendar_today_rounded,
                              primaryColor: primaryColor,
                              onTap: () => _selectDate(context, true),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: AppPickerField(
                                label: 'Tanggal Selesai',
                                displayText: _endDate != null
                                    ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                    : 'Pilih Tgl',
                                hasValue: _endDate != null,
                                icon: Icons.calendar_today_rounded,
                                primaryColor: primaryColor,
                                onTap: () {
                                  if (_startDate == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Pilih tanggal mulai terlebih dahulu')),
                                    );
                                    return;
                                  }
                                  _selectDate(context, false);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                PrimaryButton(
                  label: _isEdit ? 'Simpan Perubahan' : 'Simpan Rencana',
                  primaryColor: primaryColor,
                  isLoading: _isLoading,
                  margin: const EdgeInsets.only(top: 28),
                  onPressed: _saveTrip,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
