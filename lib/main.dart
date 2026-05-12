import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Commission Catalog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

// ─────────────────────────────────────────────
// LOGIN PAGE
// ─────────────────────────────────────────────

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _errorMsg;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    final nim = _usernameCtrl.text.trim();
    final pass = _passwordCtrl.text.trim();

    if (nim.isEmpty || pass.isEmpty) {
      setState(() => _errorMsg = "Username dan password wajib diisi.");
      return;
    }

    if (nim != pass) {
      setState(() => _errorMsg =
          "Username dan password harus sama (NIM masing-masing).");
      return;
    }

    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    final String authToken = "token_$nim";

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: ProductPage(authToken: authToken, nim: nim),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 28, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // Logo / Brand
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFFB06FFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.brush_rounded,
                      color: Colors.white, size: 28),
                ),

                const SizedBox(height: 32),

                const Text(
                  "Selamat datang\nkembali",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Masuk untuk mengakses katalog commission kamu.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.55),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                _buildLabel("Username (NIM)"),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _usernameCtrl,
                  hint: "Masukkan NIM",
                  icon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 20),

                _buildLabel("Password (NIM)"),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _passwordCtrl,
                  hint: "Masukkan NIM",
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white38,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscure = !_obscure),
                  ),
                ),

                if (_errorMsg != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.redAccent, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMsg!,
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 36),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFF6C63FF).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "Masuk",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: Text(
                    "Gunakan NIM sebagai username & password",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.7),
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.3), fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.white38, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 16, horizontal: 16),
        ),
      ),
    );
  }
}


class ProductPage extends StatefulWidget {
  final String authToken;
  final String nim;

  const ProductPage({
    super.key,
    required this.authToken,
    required this.nim,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with TickerProviderStateMixin {
  List<bool> saved = [false, false, false, false, false];
  List<bool> deleted = [false, false, false, false, false];

  late List<AnimationController> _cardControllers;
  late List<Animation<Offset>> _slideAnims;

  // Gambar menggunakan asset lokal (letakkan di assets/images/)
  // Ganti path sesuai nama file gambar kamu
  final List<Map<String, dynamic>> commissions = [
    {
      "title": "Headshot",
      "price": "Rp 45.000",
      "desc": "Portrait close-up commission",
      "tag": "Populer",
      "image": "assets/images/headshot.jpeg",
    },
    {
      "title": "Bust Up",
      "price": "Rp 50.000",
      "desc": "Karakter sampai bagian dada",
      "tag": "",
      "image": "assets/images/bustup.jpeg",
    },
    {
      "title": "Half Body",
      "price": "Rp 70.000",
      "desc": "Karakter sampai pinggang",
      "tag": "Bestseller",
      "image": "assets/images/halfbody.jpeg",
    },
    {
      "title": "Knee Up",
      "price": "Rp 90.000",
      "desc": "Karakter sampai lutut",
      "tag": "",
      "image": "assets/images/kneeup.jpeg",
    },
    {
      "title": "Full Body",
      "price": "Rp 120.000",
      "desc": "Ilustrasi karakter penuh",
      "tag": "Premium",
      "image": "assets/images/fullbody.jpeg",
    },
  ];

  // Fallback icon jika gambar belum tersedia
  final List<IconData> _fallbackIcons = [
    Icons.face_retouching_natural_outlined,
    Icons.person_outline_rounded,
    Icons.accessibility_new_outlined,
    Icons.directions_walk_outlined,
    Icons.emoji_people_outlined,
  ];

  final List<Map<String, dynamic>> _drafts = [];

  @override
  void initState() {
    super.initState();
    _cardControllers = List.generate(
      commissions.length,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + i * 80),
      ),
    );
    _slideAnims = _cardControllers.map((ctrl) {
      return Tween<Offset>(
        begin: const Offset(0, 0.35),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut));
    }).toList();

    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) _cardControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _cardControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveDraft(int index) {
    setState(() {
      saved[index] = !saved[index];
      if (saved[index]) {
        _drafts.add({
          "index": index,
          "name": commissions[index]["title"],
          "price": commissions[index]["price"],
          "description": commissions[index]["desc"],
          "owner": widget.nim,
        });
      } else {
        _drafts.removeWhere(
            (d) => d["index"] == index && d["owner"] == widget.nim);
      }
    });

    final msg = saved[index] ? "Draft disimpan" : "Draft dihapus";
    _showSnack(msg);
  }

  void _softDeleteDraft(int index) {
    setState(() {
      saved[index] = false;
      _drafts.removeWhere(
          (d) => d["index"] == index && d["owner"] == widget.nim);
    });
    _showSnack("Draft dihapus (soft delete)");
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 13)),
        backgroundColor: const Color(0xFF1E1E2E),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _submitTask() {
    final List<Map<String, String>> products = [];
    for (int i = 0; i < commissions.length; i++) {
      if (!deleted[i]) {
        products.add({
          "name": commissions[i]["title"] as String,
          "price": commissions[i]["price"] as String,
          "description": commissions[i]["desc"] as String,
        });
      }
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFFB06FFF)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(height: 20),
              const Text(
                "Submit Berhasil!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Katalog commission berhasil disubmit!\n${products.length} produk dikirim.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Token: ${widget.authToken}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const LoginPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsRow(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                itemCount: commissions.length,
                itemBuilder: (context, index) {
                  if (deleted[index]) return const SizedBox.shrink();
                  return SlideTransition(
                    position: _slideAnims[index],
                    child: FadeTransition(
                      opacity: _cardControllers[index],
                      child: _buildCommissionCard(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFFB06FFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                widget.nim.isNotEmpty
                    ? widget.nim[widget.nim.length - 1]
                    : "U",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, ${widget.nim}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Commission Catalog",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _logout,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withOpacity(0.08)),
              ),
              child: Icon(Icons.logout_rounded,
                  color: Colors.white.withOpacity(0.6), size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final draftCount = saved.where((s) => s).length;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat("${commissions.length}", "Total Paket"),
          Container(
              width: 1,
              height: 28,
              color: Colors.white.withOpacity(0.1)),
          _buildStat("$draftCount", "Draft Tersimpan"),
          Container(
              width: 1,
              height: 28,
              color: Colors.white.withOpacity(0.1)),
          _buildStat("Open", "Status"),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF6C63FF),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // Widget gambar dengan fallback ke icon jika asset belum ada
  Widget _buildAssetImage(int index) {
    final String assetPath = commissions[index]["image"] as String;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(
        assetPath,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback: tampilkan box icon jika file belum ada
          return Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C63FF).withOpacity(0.2),
                  const Color(0xFFB06FFF).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFF6C63FF).withOpacity(0.2)),
            ),
            child: Icon(
              _fallbackIcons[index],
              color: const Color(0xFF9D97FF),
              size: 28,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommissionCard(int index) {
    final item = commissions[index];
    final bool isSaved = saved[index];
    final String tag = item["tag"] as String;
    final bool hasTag = tag.isNotEmpty;

    Color tagColor = const Color(0xFF6C63FF);
    if (tag == "Bestseller") tagColor = const Color(0xFFFF6B6B);
    if (tag == "Premium") tagColor = const Color(0xFFFFB347);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSaved
              ? const Color(0xFF6C63FF).withOpacity(0.5)
              : Colors.white.withOpacity(0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: isSaved
                ? const Color(0xFF6C63FF).withOpacity(0.12)
                : Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Gambar asset dengan fallback icon
            _buildAssetImage(index),

            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item["title"] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (hasTag) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: tagColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: tagColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: tagColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item["desc"] as String,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item["price"] as String,
                    style: const TextStyle(
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                GestureDetector(
                  onTap: () => _saveDraft(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSaved
                          ? const Color(0xFF6C63FF)
                          : Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: isSaved
                            ? const Color(0xFF6C63FF)
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: isSaved ? Colors.white : Colors.white38,
                      size: 18,
                    ),
                  ),
                ),
                if (isSaved) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _softDeleteDraft(index),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                            color: Colors.red.withOpacity(0.2)),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 17,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (saved.any((s) => s))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Colors.white.withOpacity(0.4), size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "${saved.where((s) => s).length} draft tersimpan (hanya kamu yang dapat melihat)",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _submitTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Submit Tugas",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}