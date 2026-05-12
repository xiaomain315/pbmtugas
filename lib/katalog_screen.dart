import 'package:flutter/material.dart';
import '../product.dart';
import '../user.dart';
import '../api.dart';
import 'login.dart';

// Data komisi untuk tampilan katalog
class KomisiItem {
  final String name;
  final int price;
  final String description;
  final String imagePath;

  KomisiItem({
    required this.name,
    required this.price,
    required this.description,
    required this.imagePath,
  });
}

final List<KomisiItem> daftarKomisi = [
  KomisiItem(
    name: 'Headshot',
    price: 45000,
    description: 'Gambar karakter dari bahu ke atas.',
    imagePath: 'assets/images/headshot.jpeg',
  ),
  KomisiItem(
    name: 'Bustup',
    price: 50000,
    description: 'Gambar karakter dari pinggang ke atas.',
    imagePath: 'assets/images/bustup.jpeg',
  ),
  KomisiItem(
    name: 'Half Body',
    price: 70000,
    description: 'Gambar karakter setengah badan.',
    imagePath: 'assets/images/halfbody.jpeg',
  ),
  KomisiItem(
    name: 'Knee Up',
    price: 90000,
    description: 'Gambar karakter dari lutut ke atas.',
    imagePath: 'assets/images/kneeup.jpeg',
  ),
  KomisiItem(
    name: 'Full Body',
    price: 120000,
    description: 'Gambar karakter full body lengkap.',
    imagePath: 'assets/images/fullbody.jpeg',
  ),
];

class CatalogScreen extends StatefulWidget {
  final User user;
  const CatalogScreen({super.key, required this.user});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await ApiService.getProducts();
      if (!mounted) return;
      setState(() => _products = products);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Komisi'),
        content: Text('Hapus "${product.name}" dari daftar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ApiService.deleteProduct(product.id);
      await _fetchProducts();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  // Tambah produk langsung dari item komisi
  Future<void> _addFromKomisi(KomisiItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tambah ${item.name}?'),
        content: Text(
          'Nama: ${item.name}\nHarga: Rp ${item.price}\nDeskripsi: ${item.description}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ApiService.createProduct(
        name: item.name,
        price: item.price,
        description: item.description,
      );
      await _fetchProducts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name} berhasil ditambahkan!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Tambah Komisi Manual'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Komisi',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga (Rp)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (nameController.text.isEmpty ||
                          priceController.text.isEmpty ||
                          descController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Semua field wajib diisi')),
                        );
                        return;
                      }

                      setStateDialog(() => isLoading = true);

                      try {
                        await ApiService.createProduct(
                          name: nameController.text.trim(),
                          price: int.parse(priceController.text.trim()),
                          description: descController.text.trim(),
                        );
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        await _fetchProducts();
                      } catch (e) {
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(e
                                  .toString()
                                  .replaceFirst('Exception: ', ''))),
                        );
                      } finally {
                        setStateDialog(() => isLoading = false);
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Katalog Komisi'),
            Text(
              widget.user.name,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await ApiService.deleteToken();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProducts,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchProducts,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner header
          Stack(
            children: [
              Image.asset(
                'assets/images/bg.png',
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
              Container(
                width: double.infinity,
                height: 180,
                color: Colors.black.withOpacity(0.4),
              ),
              const Positioned(
                bottom: 16,
                left: 16,
                child: Text(
                  'Commission Open\nby @KAMCHAGIYA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Daftar komisi
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Pilih Jenis Komisi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: daftarKomisi.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final item = daftarKomisi[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    Image.asset(
                      item.imagePath,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${item.price}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _addFromKomisi(item),
                      icon: const Icon(Icons.add_circle_outline),
                      color: Colors.green,
                      tooltip: 'Tambah ke draft',
                    ),
                  ],
                ),
              );
            },
          ),

          // Draft produk yang sudah ditambahkan
          if (_products.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Draft Saya',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: _products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final product = _products[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.brush_outlined),
                    title: Text(product.name),
                    subtitle: Text(
                      'Rp ${product.price.toInt()}',
                      style: const TextStyle(color: Colors.green),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteProduct(product),
                    ),
                  ),
                );
              },
            ),
          ],

          // Tombol tambah manual
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Komisi Manual'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}