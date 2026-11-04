import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoggedIn = false;
  String _userName = 'Pengelana Plesir';
  String _userEmail = 'user@gmail.com';
  String _lastSyncTime = 'Belum pernah';

  void _handleGoogleLogin() {
    setState(() {
      _isLoggedIn = true;
      _userName = 'Pengelana';
      _userEmail = 'pengelana@gmail.com';
      _lastSyncTime = 'Hari ini, 14:30';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berhasil terhubung dengan Google!')),
    );
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berhasil keluar. Kembali ke mode Tamu.')),
    );
  }

  void _handleSync() {
    setState(() {
      _lastSyncTime = 'Baru saja';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data berhasil disinkronkan!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Akun & Cadangan Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
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
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        _isLoggedIn ? Icons.person_rounded : Icons.person_outline_rounded,
                        size: 36,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isLoggedIn ? _userName : 'Pengguna Tamu',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isLoggedIn ? _userEmail : 'Penyimpanan Perangkat',
                            style: TextStyle(
                              fontSize: 13,
                              color: _isLoggedIn ? Colors.grey.shade700 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (!_isLoggedIn) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.amber.shade900, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Data perjalananmu tersimpan di HP. Hubungkan ke Google agar data aman jika aplikasi dihapus.',
                          style: TextStyle(fontSize: 12, color: Colors.amber.shade900, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _handleGoogleLogin,
                    icon: Image.network(
                      'https://cdn-icons-png.flaticon.com/512/300/300221.png',
                      height: 22,
                      width: 22,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.g_mobiledata_rounded, size: 28);
                      },
                    ),
                    label: const Text(
                      'Masuk dengan Google',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Cadangan Online Aktif',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Terakhir disinkronkan: $_lastSyncTime',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _handleSync,
                          icon: const Icon(Icons.sync_rounded, size: 18),
                          label: const Text('Sinkronkan Data Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: const Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
