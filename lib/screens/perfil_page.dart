import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  bool isLoading = true;
  String? cargoUsuario;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    try {
      final userData = await AuthService.getUserData();
      if (userData != null && mounted) {
        setState(() {
          nomeController.text = userData['full_name'] ?? 'Usuário';
          emailController.text = userData['email'] ?? '';
          cargoUsuario = userData['role'] ?? 'Engenheiro';
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  void _salvarPerfil() {
    // Aqui você implementaria a lógica para salvar os dados no backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dados atualizados (simulado).')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Perfil'),
        backgroundColor: Color(0xFF2C3E50),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading 
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFF2C3E50).withOpacity(0.1),
                      child: Icon(Icons.person, size: 50, color: Color(0xFF2C3E50)),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Informações Pessoais',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: nomeController,
                      decoration: InputDecoration(
                        labelText: 'Nome completo',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true, // Email não pode ser alterado
                      enableInteractiveSelection: false,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Cargo',
                        hintText: cargoUsuario,
                        prefixIcon: Icon(Icons.work_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      readOnly: true,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Segurança',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: senhaController,
                      decoration: InputDecoration(
                        labelText: 'Nova senha (opcional)',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _salvarPerfil,
                        icon: Icon(Icons.save),
                        label: Text('Salvar alterações'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2C3E50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
