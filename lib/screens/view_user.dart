import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite1/models/student_model.dart';
import 'package:sqflite1/screens/AddUser.dart';
import 'package:sqflite1/screens/edit_student.dart';
import 'package:sqflite1/services/studentdatabase.dart';

class ViewUser extends StatefulWidget {
  const ViewUser({super.key});

  @override
  State<ViewUser> createState() => _ViewUserState();
}

class _ViewUserState extends State<ViewUser> {
  final _studentDb = Studentdatabase.instance;
  late Future<List<Student>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _studentDb.getStudents();
  }

   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View User',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Student>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada siswa ditemukan'));
          }
          final students = snapshot.data!;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: student.photoPath != null
                      ? ClipOval(
                          child: Image.file(
                            File(student.photoPath!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(
                    student.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NISN: ${student.nisn}'),
                      Text('Tanggal Lahir: ${student.birthDate}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _navigateToEditStudent(student);
                      } else if (value == 'delete') {
                        _deleteStudent(student.id!);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Hapus'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Adduser();
              },
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  // Navigasi ke halaman edit student
  void _navigateToEditStudent(Student student) {
    Navigator.push(
      context as BuildContext,
      MaterialPageRoute(
        builder: (context) {
          return EditStudent();
        },
      ),
    ).then((_) {
      setState(() {
        _studentsFuture = _studentDb.getStudents();
      });
    });
  }

  // Function untuk delete student
  void _deleteStudent(int id) async {
    await _studentDb.deleteStudent(id);
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      const SnackBar(content: Text('Siswa Dihapus')),
    );
    setState(() {
      _studentsFuture = _studentDb.getStudents();
    });
  }
}
