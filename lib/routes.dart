import 'package:flutter/material.dart';
import 'package:frontend_hous/screens/contratos/lista_contratos_page.dart';
import 'package:frontend_hous/screens/contratos/cadastro_contrato_page.dart';
import 'package:frontend_hous/screens/dashboard/dashboard_page.dart';
import 'package:frontend_hous/screens/obras/lista_obras_page.dart';
import 'package:frontend_hous/screens/contratos/detalhes_contrato_page.dart';

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
  // Rotas principais
  '/': (context) => SplashScreen(),
  '/login': (context) => LoginPage(),
  '/home': (context) => HomePage(),
  '/dashboard': (context) => DashboardPage(),
  '/perfil': (context) => PerfilPage(),

  // Rotas de Contratos (todas em português)
  '/contratos/lista': (context) => ListaContratosPage(),
  '/contratos/novo': (context) => CadastroContratoPage(),
  '/contratos/detalhes': (context) => DetalhesContratoPage(),
  '/contratos/editar': (context) => CadastroContratoPage(),
  '/contratos/buscar': (context) => ListaContratosPage(),

  // Redirecionamentos das rotas em inglês para português
  '/contracts/list': (context) => ListaContratosPage(),
  '/contracts/new': (context) => CadastroContratoPage(),
  '/contracts/details': (context) => DetalhesContratoPage(),
  '/contracts/edit': (context) => CadastroContratoPage(),

  // Rotas de Obras
  '/obras/lista': (context) => ListaObrasPage(),
  '/obra/detalhe': (context) => ObraDetalhePage(),
  '/obras/nova': (context) => CadastroObraPage(),

  // Rotas de Cadastro
  '/cadastro/obra': (context) => CadastroObraPage(),
  '/cadastro/cliente': (context) => CadastroClientePage(),
  '/cadastro/servico': (context) => CadastroServicoPage(),
  '/cadastro/usuario': (context) => CadastroUsuarioPage(),

  // Rotas temporárias (redirecionando para páginas existentes)
  '/gastos/novo': (context) => CadastroObraPage(), // Temporário
  '/documentos/enviar': (context) => HomePage(), // Temporário
  '/calendario': (context) => HomePage(), // Temporário
  '/relatorios': (context) => HomePage(), // Temporário
};
