import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_hous/services/project_service.dart';

class RelatorioPage extends StatefulWidget {
  const RelatorioPage({super.key});

  @override
  State<RelatorioPage> createState() => _RelatorioPageState();
}

class _RelatorioPageState extends State<RelatorioPage> {
  List<Map<String, dynamic>> obras = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  void carregarDados() async {
    try {
      final dadosObras = await ProjectService.getProjects();
      setState(() {
        obras = dadosObras;
        carregando = false;
      });
    } catch (e) {
      setState(() => carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar relatórios: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: Text(
          'Relatórios',
          style: GoogleFonts.poppins(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      backgroundColor: Colors.grey[50],
      body: carregando
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Status de Contratos'),
                    _buildContractStatusCards(context),
                    SizedBox(height: 24),
                    _buildSectionTitle('Progresso das Obras'),
                    _buildObrasProgress(),
                    SizedBox(height: 24),
                    _buildSectionTitle('Vendas'),
                    _buildVendasCards(context),
                    SizedBox(height: 24),
                    _buildSectionTitle('Funil de Leads'),
                    _buildLeadsFunnel(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C3E50),
        ),
      ),
    );
  }

  Widget _buildContractStatusCards(BuildContext context) {
    return SizedBox(height: 0); // temporariamente oculto
  }

  Widget _buildObrasProgress() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: obras.map((obra) {
            final nome = obra['name'] ?? 'Sem nome';
            final gasto = (obra['current_expenses'] ?? 0).toDouble();
            final orcamento = (obra['budget'] ?? 1).toDouble();
            final progresso = (orcamento > 0) ? (gasto / orcamento).clamp(0.0, 1.0) : 0.0;
            final cor = progresso > 0.7
                ? Colors.orange
                : progresso > 0.4
                    ? Colors.green
                    : Colors.blue;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        nome,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Color(0xFF2C3E50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(progresso * 100).toInt()}%',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: cor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progresso,
                      backgroundColor: cor.withOpacity(0.1),
                      color: cor,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildVendasCards(BuildContext context) {
    return SizedBox(height: 0); // temporariamente oculto
  }

  Widget _buildLeadsFunnel(BuildContext context) {
    return SizedBox(height: 0); // temporariamente oculto
  }
}
