import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RelatorioPage extends StatelessWidget {
  const RelatorioPage({super.key});

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Status de Contratos'),
              _buildContractStatusCards(context),
              SizedBox(height: 24),
              _buildSectionTitle('Progresso das Obras'),
              _buildObrasProgress(context),
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
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (context, index) => SizedBox(width: 16),
        itemBuilder: (context, index) {
          final data = [
            {
              'title': 'Contratos Ativos',
              'value': '12',
              'icon': Icons.description,
              'color': Colors.blue,
            },
            {
              'title': 'Contratos Vencidos',
              'value': '3',
              'icon': Icons.warning,
              'color': Colors.red,
            },
            {
              'title': 'Contratos Pendentes',
              'value': '5',
              'icon': Icons.pending,
              'color': Colors.orange,
            },
            {
              'title': 'Total de Contratos',
              'value': '20',
              'icon': Icons.folder,
              'color': Colors.green,
            },
          ];
          final item = data[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Container(
              width: 180,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 24),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2C3E50),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Text(
                    item['value'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: item['color'] as Color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildObrasProgress(BuildContext context) {
    final obras = [
      {'title': 'Residência A', 'progress': 0.75, 'color': Colors.blue},
      {'title': 'Comercial B', 'progress': 0.45, 'color': Colors.green},
      {'title': 'Reforma C', 'progress': 0.30, 'color': Colors.orange},
    ];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: obras.map((obra) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      obra['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${((obra['progress'] as double) * 100).toInt()}%',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: obra['color'] as Color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: obra['progress'] as double,
                    backgroundColor: (obra['color'] as Color).withOpacity(0.1),
                    color: obra['color'] as Color,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildVendasCards(BuildContext context) {
    final vendas = [
      {
        'title': 'Vendas do Mês',
        'value': 'R\$ 150.000',
        'icon': Icons.trending_up,
        'color': Colors.green,
      },
      {
        'title': 'Tempo Médio de Venda',
        'value': '45 dias',
        'icon': Icons.timer,
        'color': Colors.blue,
      },
      {
        'title': 'Imóveis Disponíveis',
        'value': '8',
        'icon': Icons.home,
        'color': Colors.orange,
      },
    ];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: vendas.map((venda) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (venda['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(venda['icon'] as IconData, color: venda['color'] as Color, size: 20),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    venda['title'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                Text(
                  venda['value'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: venda['color'] as Color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildLeadsFunnel(BuildContext context) {
    final leads = [
      {'title': 'Novos Leads', 'value': '25', 'color': Colors.blue},
      {'title': 'Em Negociação', 'value': '12', 'color': Colors.orange},
      {'title': 'Propostas Enviadas', 'value': '8', 'color': Colors.purple},
      {'title': 'Vendas Realizadas', 'value': '5', 'color': Colors.green},
    ];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: leads.map((lead) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: lead['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    lead['title'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                Text(
                  lead['value'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: lead['color'] as Color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }
}
