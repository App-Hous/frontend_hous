import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bem-vindo, Engenheiro',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text('Dashboard', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implementar notificações
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção de Status de Contratos
              _buildSectionTitle(context, 'Status de Contratos'),
              _buildContractStatusCards(context),
              const SizedBox(height: 24),

              // Seção de Progresso das Obras
              _buildSectionTitle(context, 'Progresso das Obras'),
              _buildObrasProgress(context),
              const SizedBox(height: 24),

              // Seção de Vendas
              _buildSectionTitle(context, 'Vendas'),
              _buildVendasCards(context),
              const SizedBox(height: 24),

              // Seção de Leads
              _buildSectionTitle(context, 'Funil de Leads'),
              _buildLeadsFunnel(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildContractStatusCards(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatusCard(
          context,
          'Contratos Ativos',
          '12',
          Icons.description,
          Colors.blue,
        ),
        _buildStatusCard(
          context,
          'Contratos Vencidos',
          '3',
          Icons.warning,
          Colors.red,
        ),
        _buildStatusCard(
          context,
          'Contratos Pendentes',
          '5',
          Icons.pending,
          Colors.orange,
        ),
        _buildStatusCard(
          context,
          'Total de Contratos',
          '20',
          Icons.folder,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObrasProgress(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProgressItem(context, 'Residência A', 0.75, Colors.blue),
            const SizedBox(height: 16),
            _buildProgressItem(context, 'Comercial B', 0.45, Colors.green),
            const SizedBox(height: 16),
            _buildProgressItem(context, 'Reforma C', 0.30, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(
    BuildContext context,
    String title,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(title), Text('${(progress * 100).toInt()}%')],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildVendasCards(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildVendaItem(
              context,
              'Vendas do Mês',
              'R\$ 150.000',
              Icons.trending_up,
              Colors.green,
            ),
            const Divider(),
            _buildVendaItem(
              context,
              'Tempo Médio de Venda',
              '45 dias',
              Icons.timer,
              Colors.blue,
            ),
            const Divider(),
            _buildVendaItem(
              context,
              'Imóveis Disponíveis',
              '8',
              Icons.home,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendaItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(child: Text(title)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadsFunnel(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildLeadsItem(context, 'Novos Leads', '25', Colors.blue),
            const Divider(),
            _buildLeadsItem(context, 'Em Negociação', '12', Colors.orange),
            const Divider(),
            _buildLeadsItem(context, 'Propostas Enviadas', '8', Colors.purple),
            const Divider(),
            _buildLeadsItem(context, 'Vendas Realizadas', '5', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadsItem(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
