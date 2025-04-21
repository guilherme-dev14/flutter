import 'package:flutter/material.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/employee_repository.dart';
import '../../../data/repositories/auth_repository.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  List<UserModel> _employees = [];
  bool _loading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    try {
      final storeId = await AuthRepository().getCurrentStoreId();
      if (storeId == null) throw Exception('ID da loja não encontrado');

      final repository = EmployeeRepository();
      final employees = await repository.getEmployees(storeId);
      setState(() => _employees = employees);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }
Future<void> _addOrEditEmployee({UserModel? employee}) async {
  final nameController = TextEditingController(text: employee?.name);
  final usernameController = TextEditingController(text: employee?.username);
  final passwordController = TextEditingController();
  bool obscure = true;
  
  String getAvatarText() {
    if (nameController.text.isEmpty) return '';
    final parts = nameController.text.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '';
  }

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF610BEF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      employee == null ? 'Novo funcionário' : 'Editar funcionário',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                Center(
                  child: AnimatedBuilder(
                    animation: nameController,
                    builder: (context, _) => CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF610BEF),
                      child: Text(
                        getAvatarText(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 245, 245, 245),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (_) => setState(() {}),  
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 250, 250, 250),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Usuário',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                StatefulBuilder(
                  builder: (context, setFieldState) => Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: passwordController,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () => setFieldState(() => obscure = !obscure),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty || 
                          usernameController.text.isEmpty ||
                          (employee == null && passwordController.text.isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
                        );
                        return;
                      }
                      
                      try {
                        final storeId = await AuthRepository().getCurrentStoreId();
                        if (storeId == null) throw Exception('ID da loja não encontrado');
                        
                        final repo = EmployeeRepository();
                        final user = UserModel(
                          id: employee?.id,
                          name: nameController.text,
                          photo: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
                          username: usernameController.text,
                          password: passwordController.text,
                        );

                        if (employee == null) {
                          await repo.addEmployee(storeId, user);
                        } else {
                          await repo.updateEmployee(storeId, employee.id!, user);
                        }
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                          _loadEmployees();
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                employee == null 
                                  ? 'Funcionário adicionado com sucesso!' 
                                  : 'Funcionário atualizado com sucesso!'
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF610BEF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Salvar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Future<void> _confirmDelete(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text('Deseja deletar o funcionário "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final storeId = await AuthRepository().getCurrentStoreId();
      await EmployeeRepository().deleteEmployee(storeId!, user.id!);
      _loadEmployees();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Funcionários', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Erro: $_errorMessage'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadEmployees,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF610BEF)),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _employees.isEmpty
                  ? const Center(child: Text('Nenhum funcionário encontrado'))
                  : ListView.builder(
                      itemCount: _employees.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemBuilder: (context, index) {
                        final user = _employees[index];
                        final initials = _getInitials(user.name);

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF610BEF),
                            child: Text(initials, style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(user.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _addOrEditEmployee(employee: user),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20),
                                onPressed: () => _confirmDelete(user),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditEmployee(),
        backgroundColor: const Color(0xFF610BEF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }
}
