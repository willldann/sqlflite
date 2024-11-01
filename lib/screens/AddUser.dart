import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sqflite1/models/student_model.dart';
import 'package:sqflite1/services/studentdatabase.dart';

class Adduser extends StatefulWidget {
  const Adduser({super.key});

  @override
  State<Adduser> createState() => _AdduserState();
}

class _AdduserState extends State<Adduser> {
  final _nameController = TextEditingController();
  final _nisnController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _studentDb = Studentdatabase.instance;
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New User',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Nama Siswa'),
              _buildTextField(_nameController, 'Masukkan Nama'),
              SizedBox(height: 20),
              _buildLabel('NISN Siswa'),
              _buildTextField(_nisnController, 'Masukkan NISN'),
              SizedBox(height: 20),
              _buildLabel('Tanggal Lahir'),
              // _buildTextField(_birthDateController, 'Tanggal Lahir'),
              GestureDetector(
                onTap: _selecDate,
                child: AbsorbPointer(
                  child: _buildTextField(
                      _birthDateController, 'Pilih Tanggal Lahir',
                      suffixIcon: Icons.calendar_today),
                ),
              ),
              SizedBox(height: 20),
              _buildPhotoUpload(),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveStudent,
                  child: Text('Tambah',
                  style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.blue),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk memilih tanggal
  Future<void> _selecDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final PickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (PickedFile != null) {
      setState(() {
        _imageFile = File(PickedFile.path);
      });
    }
  }

  // Fungsi menyimpan data siswa
  Future<void> _saveStudent() async {
    final student = Student(
      name: _nameController.text,
      nisn: _nisnController.text,
      birthDate: _birthDateController.text,
      photoPath: _imageFile?.path,
    );

    await _studentDb.insertStudent(student);
    _clearFields();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Siswa Ditambahkan')),
    );
  }

  // Fungsi untuk mengosongkan field setelah simpan
  void _clearFields() {
    _nameController.clear();
    _nisnController.clear();
    _birthDateController.clear();
    setState(() {
      _imageFile = null;
    });
  }

  // Fungsi membuat label
  Widget _buildLabel(String text) {
    return Text(text, style: TextStyle(fontSize: 18));
  }

  // Fungsi untuk membangun TextField
  Widget _buildTextField(TextEditingController controller, String hintText,
      {IconData? suffixIcon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  // Fungsi mengupload Poto
  Widget _buildPhotoUpload() {
    return Center(
      child: Column(
        children: [
          const Text('Unggah Photo Profil', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : const AssetImage('assets/placeholder.png') as ImageProvider,
              child: _imageFile == null
                  ? const Icon(
                      Icons.camera_alt,
                      size: 50,
                      color: Colors.grey,
                    )
                  : null,
            ),
          )
        ],
      ),
    );
  }
}
