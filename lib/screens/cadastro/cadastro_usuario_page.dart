import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/usuario_service.dart';

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({super.key});

  @override
  _CadastroUsuarioPageState createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();
  bool carregando = false;
  String? mensagemErro;
  bool _mostraSenha = false;
  bool _mostraConfirmarSenha = false;

  bool _validarEmail(String email) {
    final RegExp regex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );
    return regex.hasMatch(email);
  }

  bool _validarSenha(String senha) {
    return senha.length >= 6;
  }

  void _cadastrar() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    String nome = nomeController.text.trim();
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String senha = senhaController.text.trim();

    setState(() {
      carregando = true;
      mensagemErro = null;
    });

    try {
      await UsuarioService.criarUsuario(nome, email, senha, username);
      
      // Cadastro bem-sucedido
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuário cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        String erro = e.toString();
        
        if (erro.contains('email already exists')) {
          mensagemErro = 'Este email já está cadastrado no sistema.';
        } else if (erro.contains('username already exists')) {
          mensagemErro = 'Este nome de usuário já está em uso.';
        } else {
          mensagemErro = 'Erro ao cadastrar usuário: ${e.toString().replaceAll('Exception: ', '')}';
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagemErro!),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C3E50),
              Color(0xFF34495E),
            ],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    children: [
                      // Header com logo e título
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Criar Conta',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 48),
                        ],
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Ícone de usuário
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_add,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 30),
                      
                      // Formulário de cadastro
                      _buildTextField(
                        controller: nomeController,
                        label: 'Nome completo',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, informe seu nome completo';
                          }
                          if (value.trim().split(' ').length < 2) {
                            return 'Informe seu nome e sobrenome';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: usernameController,
                        label: 'Nome de usuário',
                        icon: Icons.account_circle,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, informe um nome de usuário';
                          }
                          if (value.contains(" ")) {
                            return 'O nome de usuário não pode conter espaços';
                          }
                          if (value.length < 4) {
                            return 'O nome de usuário deve ter pelo menos 4 caracteres';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, informe seu email';
                          }
                          if (!_validarEmail(value.trim())) {
                            return 'Email inválido';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: senhaController,
                        label: 'Senha',
                        icon: Icons.lock,
                        obscureText: !_mostraSenha,
                        showPasswordToggle: true,
                        onTogglePassword: () => setState(() => _mostraSenha = !_mostraSenha),
                        passwordVisible: _mostraSenha,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, informe uma senha';
                          }
                          if (!_validarSenha(value)) {
                            return 'A senha deve ter pelo menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: confirmarSenhaController,
                        label: 'Confirmar Senha',
                        icon: Icons.lock_outline,
                        obscureText: !_mostraConfirmarSenha,
                        showPasswordToggle: true,
                        onTogglePassword: () => setState(() => _mostraConfirmarSenha = !_mostraConfirmarSenha),
                        passwordVisible: _mostraConfirmarSenha,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, confirme sua senha';
                          }
                          if (value != senhaController.text) {
                            return 'As senhas não conferem';
                          }
                          return null;
                        },
                      ),
                      
                      // Mensagem de erro
                      if (mensagemErro != null)
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 16),
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Text(
                            mensagemErro!,
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      SizedBox(height: 30),
                      
                      // Botão de cadastrar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: carregando ? null : _cadastrar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF2C3E50),
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: carregando
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C3E50)),
                                ),
                              )
                            : Text(
                                'Cadastrar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Link para voltar ao login
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Já possui conta? Faça login',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Rodapé
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '© 2023 ConstrApp - Todos os direitos reservados',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool showPasswordToggle = false,
    void Function()? onTogglePassword,
    bool passwordVisible = false,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: showPasswordToggle
            ? IconButton(
                icon: Icon(
                  passwordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: onTogglePassword,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.withOpacity(0.5)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.withOpacity(0.7)),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        errorStyle: TextStyle(color: Colors.red[300]),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
