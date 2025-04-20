// lib/feature/admin/screens/employees_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mybookstore/data/models/user.dart';
import 'package:mybookstore/data/repositories/employee_repository.dart';
import 'package:mybookstore/feature/admin/screens/add_employee_screen.dart';
import 'package:mybookstore/feature/admin/screens/edit_employee_screen.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({Key? key}) : super(key: key);

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  List<UserModel> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final employeeRepo = RepositoryProvider.of<EmployeeRepository>(context);
      final storeId = await employeeRepo.getCurrentStoreId() ?? 1;
      final employees = await employeeRepo.getEmployees(storeId);
      
      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar funcionários: $e')),
      );
    }
  }

  void _confirmDelete(UserModel employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmação'),
        content: Text('Deseja excluir o funcionário "${employee.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteEmployee(employee);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEmployee(UserModel employee) async {
    try {
      final employeeRepo = RepositoryProvider.of<EmployeeRepository>(context);
      final storeId = await employeeRepo.getCurrentStoreId() ?? 1;
      
      await employeeRepo.deleteEmployee(storeId, employee.id!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Funcionário excluído com sucesso!')),
      );
      
      _loadEmployees(); // Recarregar a lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir funcionário: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Funcionários',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _employees.isEmpty
              ? const Center(child: Text('Nenhum funcionário encontrado'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _employees.length,
                  itemBuilder: (context, index) {
                    final employee = _employees[index];
                    final initials = employee.name.split(' ')
                        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
                        .take(2)
                        .join();
                        
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF610BEF),
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          employee.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(employee.username),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditEmployeeScreen(
                                      employee: employee,
                                    ),
                                  ),
                                ).then((_) => _loadEmployees());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(employee),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF610BEF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEmployeeScreen(),
            ),
          ).then((_) => _loadEmployees());
        },
      ),
    );
  }
}