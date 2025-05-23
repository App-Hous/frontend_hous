import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  bool _carregando = false;
  String? _mensagemErro;
  bool _mostraSenha = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _login() async {
    String username = usernameController.text.trim();
    String senha = senhaController.text.trim();

    if (username.isEmpty || senha.isEmpty) {
      setState(() {
        _mensagemErro = 'Preencha todos os campos';
      });
      return;
    }

    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    try {
      final sucesso = await AuthService.login(username, senha);

      if (sucesso) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _mensagemErro = 'Nome de usuário ou senha inválidos';
        });
      }
    } catch (e) {
      setState(() {
        _mensagemErro = e.toString().contains('detail')
            ? e.toString().split('detail: ')[1].replaceAll('"', '').replaceAll('}', '')
            : 'Erro ao fazer login. Verifique suas credenciais.';
      });
    } finally {
      setState(() => _carregando = false);
    }
  }

  void _irParaCadastro() {
    Navigator.pushNamed(context, '/cadastro/usuario');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,  // Impede que o teclado empurre o conteúdo para cima
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
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                  children: [
                    // Logo e Título
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.construction,
                              size: 50,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'ConstrApp',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Gestão de Obras e Construções',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 40),
                    
                    // Abas Login/Sobre
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        labelColor: Color(0xFF2C3E50),
                        unselectedLabelColor: Colors.white,
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: [
                          Container(
                            height: 46,
                            alignment: Alignment.center,
                            child: Text(
                              'Login', 
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ),
                          Container(
                            height: 46,
                            alignment: Alignment.center,
                            child: Text(
                              'Sobre o App', 
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Conteúdo das abas
                    SizedBox(
                      height: 400, // Altura fixa para o conteúdo das abas
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Aba de Login - SEM scrollabilidade
                          _buildLoginTab(),
                          
                          // Aba Sobre o App - COM scrollabilidade
                          SingleChildScrollView(
                            child: _buildSobreTab(),
                          ),
                        ],
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
                      '© 2025 ConstrApp - Todos os direitos reservados',
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
    );
  }
  
  Widget _buildLoginTab() {
    return Column(
      children: [
        // Campo de usuário
        TextField(
          controller: usernameController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Email ou nome de usuário',
            labelStyle: TextStyle(color: Colors.white70),
            prefixIcon: Icon(Icons.person, color: Colors.white70),
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
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
        
        SizedBox(height: 20),
        
        // Campo de senha
        TextField(
          controller: senhaController,
          style: TextStyle(color: Colors.white),
          obscureText: !_mostraSenha,
          decoration: InputDecoration(
            labelText: 'Senha',
            labelStyle: TextStyle(color: Colors.white70),
            prefixIcon: Icon(Icons.lock, color: Colors.white70),
            suffixIcon: IconButton(
              icon: Icon(
                _mostraSenha ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: () {
                setState(() {
                  _mostraSenha = !_mostraSenha;
                });
              },
            ),
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
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          onSubmitted: (_) => _login(),
        ),
        
        SizedBox(height: 12),
        
        // Mensagem de erro
        if (_mensagemErro != null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Text(
              _mensagemErro!,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        
        SizedBox(height: 24),
        
        // Botão de login
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _carregando ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF2C3E50),
              disabledBackgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _carregando
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C3E50)),
                    ),
                  )
                : Text(
                    'Entrar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        
        SizedBox(height: 16),
        
        // Link para cadastro
        TextButton(
          onPressed: _irParaCadastro,
          child: Text(
            'Não possui cadastro? Crie sua conta',
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSobreTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoSection(
          'O que é o ConstrApp?',
          'O ConstrApp é uma solução completa para gerenciamento de obras e construções, desenvolvida para otimizar processos e aumentar a produtividade de construtoras e profissionais da construção civil.'
        ),
        
        SizedBox(height: 16),
        
        _buildInfoSection(
          'Principais Funcionalidades',
          null,
          features: [
            'Gerenciamento de múltiplas obras simultaneamente',
            'Controle de orçamentos e gastos em tempo real',
            'Gestão de contratos com clientes e fornecedores',
            'Acompanhamento do cronograma e prazos',
            'Relatórios detalhados de performance',
            'Dashboard com indicadores de desempenho',
          ],
        ),
        
        SizedBox(height: 16),
        
        _buildInfoSection(
          'Benefícios',
          'Reduza custos, aumente a eficiência operacional e tenha total controle sobre seus projetos. Com o ConstrApp, sua empresa estará preparada para crescer com organização e qualidade.'
        ),
        
        SizedBox(height: 16),
        
        Center(
          child: TextButton(
            onPressed: () {
              _tabController.animateTo(0);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF2C3E50),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Voltar para o Login'),
          ),
        ),
        
        SizedBox(height: 20),
      ],
    );
  }
  
  Widget _buildInfoSection(String title, String? description, {List<String>? features}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        if (description != null)
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        if (features != null) ...[
          SizedBox(height: 8),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ],
    );
  }
}
