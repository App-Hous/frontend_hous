import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/perfil_page.dart'; 
import 'screens/obra_detalhe_page.dart';
import 'screens/cadastro/cadastro_obra_page.dart';
import 'screens/cadastro/cadastro_cliente_page.dart';
import 'screens/cadastro/cadastro_servico_page.dart';
import 'screens/cadastro/cadastro_usuario_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => SplashScreen(),
  '/login': (context) => LoginPage(),
  '/home': (context) => HomePage(),
  '/perfil': (context) => PerfilPage(),
  '/obra/detalhe': (context) => ObraDetalhePage(),
  '/cadastro/obra': (context) => CadastroObraPage(),
  '/cadastro/cliente': (context) => CadastroClientePage(),
  '/cadastro/servico': (context) => CadastroServicoPage(),
  '/cadastro/usuario': (context) => CadastroUsuarioPage(),
};
