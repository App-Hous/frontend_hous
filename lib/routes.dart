import 'package:flutter/material.dart';
import 'package:frontend_hous/screens/contratos/lista_contratos_page.dart';
import 'package:frontend_hous/screens/contratos/cadastro_contrato_page.dart';
import 'package:frontend_hous/screens/relatorios/relatorios_page.dart';
import 'package:frontend_hous/screens/obras/lista_obras_page.dart';
import 'package:frontend_hous/screens/contratos/detalhes_contrato_page.dart';
import 'package:frontend_hous/screens/contracts/contract_search_page.dart';

import 'screens/splash_screen.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/perfil_page.dart';
import 'screens/obras/obra_detalhe_page.dart';
import 'screens/cadastro/cadastro_obra_page.dart';
import 'screens/cadastro/cadastro_cliente_page.dart';
import 'screens/cadastro/cadastro_servico_page.dart';
import 'screens/cadastro/cadastro_usuario_page.dart';
import 'screens/cadastro/cadastro_gasto_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  // Rotas principais
  '/': (context) => SplashScreen(),
  '/login': (context) => LoginPage(),
  '/home': (context) => HomePage(),
  '/relatorios': (context) => RelatorioPage(),
  '/perfil': (context) => PerfilPage(),

  // Rotas de Contratos (todas em português)
  '/contratos/lista': (context) => ListaContratosPage(),
  '/contratos/novo': (context) => CadastroContratoPage(),
  '/contratos/detalhes': (context) => DetalhesContratoPage(),
  '/contratos/editar': (context) {
    final contrato =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return CadastroContratoPage(contrato: contrato);
  },
  '/contratos/buscar': (context) => ListaContratosPage(),

  // Redirecionamentos das rotas em inglês para português
  '/contracts/list': (context) => ListaContratosPage(),
  '/contracts/new': (context) => CadastroContratoPage(),
  '/contracts/details': (context) => DetalhesContratoPage(),
  '/contracts/edit': (context) {
    final contrato =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return CadastroContratoPage(contrato: contrato);
  },
  '/contracts/search': (context) => ListaContratosPage(),

  // Rotas de Obras
  '/obras/lista': (context) => ListaObrasPage(),
  '/obra/detalhe': (context) => ObraDetalhePage(),
  '/obras/nova': (context) => CadastroObraPage(),
  '/obras/editar': (context) {
    final obra =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return CadastroObraPage(obra: obra);
  },

  // Rotas de Cadastro
  '/cadastro/obra': (context) => CadastroObraPage(),
  '/cadastro/cliente': (context) => CadastroClientePage(),
  '/cadastro/servico': (context) => CadastroServicoPage(),
  '/cadastro/usuario': (context) => CadastroUsuarioPage(),
  '/cadastro/gasto': (context) => CadastroGastoPage(),

  // Rotas de Gastos
  '/gastos/novo': (context) => CadastroGastoPage(),
  '/gastos/lista': (context) =>
      HomePage(), // Temporário, pode criar uma lista de gastos no futuro

  // Rotas temporárias (redirecionando para páginas existentes)
  '/documentos/enviar': (context) => HomePage(), // Temporário
  '/calendario': (context) => HomePage(), // Temporário
  '/relatorios': (context) => RelatorioPage(), // Temporário
};
