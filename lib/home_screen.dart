import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _tenSPController = TextEditingController();
  final TextEditingController _loaiController = TextEditingController();
  final TextEditingController _giaController = TextEditingController();

  final CollectionReference _sanpham =
      FirebaseFirestore.instance.collection("sanpham");

  // Hàm thêm sản phẩm
  void _addSanpham() {
    if (_tenSPController.text.isNotEmpty &&
        _loaiController.text.isNotEmpty &&
        _giaController.text.isNotEmpty) {
      _sanpham.add({
        'TenSP': _tenSPController.text,
        'Gia': double.tryParse(_giaController.text) ?? 0.0,
        'Loai': _loaiController.text,
      });
      _tenSPController.clear();
      _giaController.clear();
      _loaiController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
    }
  }

  // Hàm chỉnh sửa sản phẩm
  void _editSanpham(BuildContext context, DocumentReference sanphamRef,
      Map<String, dynamic> currentData) {
    final TextEditingController _tenSPController =
        TextEditingController(text: currentData['TenSP']);
    final TextEditingController _loaiController =
        TextEditingController(text: currentData['Loai']);
    final TextEditingController _giaController =
        TextEditingController(text: currentData['Gia'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chỉnh sửa sản phẩm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tenSPController,
                decoration: const InputDecoration(labelText: "Tên sản phẩm"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _loaiController,
                decoration: const InputDecoration(labelText: "Loại sản phẩm"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _giaController,
                decoration: const InputDecoration(labelText: "Giá sản phẩm"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog mà không làm gì
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                if (_tenSPController.text.isNotEmpty &&
                    _loaiController.text.isNotEmpty &&
                    _giaController.text.isNotEmpty) {
                  sanphamRef.update({
                    'TenSP': _tenSPController.text,
                    'Loai': _loaiController.text,
                    'Gia': double.tryParse(_giaController.text) ?? 0.0,
                  }).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Chỉnh sửa sản phẩm thành công")),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              "Có lỗi xảy ra khi chỉnh sửa sản phẩm: $error")),
                    );
                  });
                  Navigator.of(context).pop(); // Đóng dialog sau khi lưu
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Vui lòng điền đầy đủ thông tin")),
                  );
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Thông tin Sản Phẩm"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildNeumorphicTextField(
              controller: _tenSPController,
              hintText: "Tên sản phẩm",
            ),
            const SizedBox(height: 16),
            _buildNeumorphicTextField(
              controller: _loaiController,
              hintText: "Loại sản phẩm",
            ),
            const SizedBox(height: 16),
            _buildNeumorphicTextField(
              controller: _giaController,
              hintText: "Giá sản phẩm",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildNeumorphicButton(
              text: "Thêm Sản Phẩm",
              onPressed: _addSanpham,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder(
                stream: _sanpham.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var sanpham = snapshot.data!.docs[index];
                      return _buildNeumorphicProductCard(sanpham);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Neumorphic styled TextField
  Widget _buildNeumorphicTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFecf0f3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            offset: Offset(-5, -5),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Color(0xFFd1d9e6),
            offset: Offset(5, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  // Neumorphic styled Button
  Widget _buildNeumorphicButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFecf0f3),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.white,
              offset: Offset(-5, -5),
              blurRadius: 10,
            ),
            BoxShadow(
              color: Color(0xFFd1d9e6),
              offset: Offset(5, 5),
              blurRadius: 10,
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF34495e),
          ),
        ),
      ),
    );
  }

  // Neumorphic styled Product Card
  Widget _buildNeumorphicProductCard(QueryDocumentSnapshot sanpham) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFecf0f3),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            offset: Offset(-5, -5),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Color(0xFFd1d9e6),
            offset: Offset(5, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tên sản phẩm: ${sanpham['TenSP']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Loại: ${sanpham['Loai']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Giá sản phẩm: ${sanpham['Gia']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  _editSanpham(context, sanpham.reference,
                      sanpham.data() as Map<String, dynamic>);
                },
                icon: const Icon(Icons.edit, color: Color(0xFFf39c12)),
              ),
              IconButton(
                onPressed: () {
                  _deleteSanpham(context, sanpham.reference);
                },
                icon: const Icon(Icons.delete, color: Color(0xFFe74c3c)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Hàm xóa sản phẩm
  void _deleteSanpham(BuildContext context, DocumentReference sanphamRef) {
    sanphamRef.delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xóa sản phẩm thành công")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Có lỗi xảy ra khi xóa sản phẩm: $error")),
      );
    });
  }
}
