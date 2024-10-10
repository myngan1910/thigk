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

  void _addSanpham() {
    _sanpham.add({
      'TenSP': _tenSPController.text,
      'Gia': _giaController.text,
      'Loai': _loaiController.text,
    });
    _tenSPController.clear();
    _giaController.clear();
    _loaiController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.center,
          child: const Text(
            "Dữ Liệu Sản Phẩm",
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _tenSPController,
              decoration: const InputDecoration(labelText: "Nhập tên sản phẩm"),
            ),
            const SizedBox(
              height: 16,
            ),
            TextFormField(
              controller: _loaiController,
              decoration:
                  const InputDecoration(labelText: "Nhập loại sản phẩm"),
            ),
            const SizedBox(
              height: 16,
            ),
            TextFormField(
              controller: _giaController,
              decoration: const InputDecoration(labelText: "Nhập giá sản phẩm"),
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () {
                _addSanpham();
              },
              child: const Text("Thêm Sản Phẩm"),
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
                child: StreamBuilder(
                    stream: _sanpham.snapshots(),
                    builder: (context, snapshot) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var sanpham = snapshot.data!.docs[index];
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tên sản phẩm: ${sanpham['TenSP']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Loại: ${sanpham['Loai']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'giá sản phẩm: ${sanpham['Gia']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.delete),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.edit),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    })),
          ],
        ),
      ),
    );
  }
}
