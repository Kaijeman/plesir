import 'package:flutter/material.dart';

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

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _categories = ['Gunung', 'Pantai', 'Kota', 'Hutan', 'Kuliner', 'Transportasi'];

  @override
  void dispose() {
    _placeController.dispose();
    _costController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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

      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _isLoading = false);

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Tambah Aktivitas Harian', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nama Tempat / Aktivitas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _placeController,
                        decoration: _buildInputDecoration(
                          hintText: 'Cth: Pantai Kuta / Makan Siang',
                          icon: Icons.place_rounded,
                          primaryColor: primaryColor,
                        ),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 20),

                      const Text('Kategori Aktivitas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        hint: const Text('Pilih Kategori', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        decoration: _buildInputDecoration(
                          hintText: 'Pilih Kategori',
                          icon: Icons.category_rounded,
                          primaryColor: primaryColor,
                        ),
                        items: _categories.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 14)));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTimePicker(
                              context: context,
                              label: 'Jam Mulai',
                              time: _startTime,
                              primaryColor: primaryColor,
                              onTap: () => _selectTime(context, true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTimePicker(
                              context: context,
                              label: 'Jam Selesai',
                              time: _endTime,
                              primaryColor: primaryColor,
                              onTap: () => _selectTime(context, false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Text('Estimasi Biaya (Rp)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _costController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration(
                          hintText: 'Cth: 150000',
                          icon: Icons.payments_rounded,
                          primaryColor: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text('Catatan (Opsional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Cth: Jangan lupa bawa baju ganti',
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: Icon(Icons.notes_rounded, color: primaryColor, size: 22),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _isLoading ? null : _saveActivity,
                    child: _isLoading
                        ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                        : const Text('Simpan Aktivitas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    required Color primaryColor,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: primaryColor, size: 22),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  Widget _buildTimePicker({
    required BuildContext context,
    required String label,
    required TimeOfDay? time,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time != null ? time.format(context) : 'Pilih Jam',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: time != null ? FontWeight.w600 : FontWeight.normal,
                    color: time != null ? Colors.black87 : Colors.grey,
                  ),
                ),
                Icon(Icons.access_time_rounded, size: 18, color: primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
