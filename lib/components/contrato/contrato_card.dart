import 'package:flutter/material.dart';
import 'contrato_status.dart';
import '../../services/contract_service.dart';

class ContratoCard extends StatefulWidget {
  final Map<String, dynamic> contrato;
  final VoidCallback onTap;
  final VoidCallback? onUpdate;

  const ContratoCard({
    Key? key,
    required this.contrato,
    required this.onTap,
    this.onUpdate,
  }) : super(key: key);

  @override
  State<ContratoCard> createState() => _ContratoCardState();
}

class _ContratoCardState extends State<ContratoCard> {
  bool _isUpdatingStatus = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildInfoRows(context),
              const SizedBox(height: 12),
              _buildDates(context),
              const SizedBox(height: 16),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.description,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.contrato['title']?.toString() ??
                    widget.contrato['contract_number']?.toString() ??
                    '-',
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                widget.contrato['contract_number']?.toString() ?? '-',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        ContratoStatus(status: widget.contrato['status'] ?? 'Não especificado'),
      ],
    );
  }

  Widget _buildInfoRows(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInfoRow(
          context,
          'Cliente',
          (widget.contrato['client_name']?.toString() ??
              widget.contrato['client_id']?.toString() ??
              '-'),
          Icons.person_outline,
        ),
        const SizedBox(height: 6),
        _buildInfoRow(
          context,
          'Imóvel',
          (widget.contrato['property_name']?.toString() ??
              widget.contrato['property_id']?.toString() ??
              '-'),
          Icons.home_outlined,
        ),
        const SizedBox(height: 6),
        _buildInfoRow(
          context,
          'Valor',
          _formatarValor(widget.contrato['contract_value']),
          Icons.attach_money,
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    dynamic value,
    IconData icon,
  ) {
    final safeValue = value?.toString() ?? '-';
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            safeValue,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDates(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildDateInfo(
            context,
            'Início',
            widget.contrato['signing_date']?.toString().split('T')[0] ??
                'Não especificada',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateInfo(
            context,
            'Término',
            widget.contrato['expiration_date']?.toString().split('T')[0] ??
                'Não especificada',
          ),
        ),
      ],
    );
  }

  Widget _buildDateInfo(BuildContext context, String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 2),
        Text(
          date,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Dropdown para editar status
        Expanded(
          flex: 2,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _isUpdatingStatus
                ? const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.contrato['status'],
                      isExpanded: true,
                      hint: const Text('Status'),
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('Ativo')),
                        DropdownMenuItem(
                            value: 'pending', child: Text('Pendente')),
                        DropdownMenuItem(
                            value: 'completed', child: Text('Concluído')),
                        DropdownMenuItem(
                            value: 'cancelled', child: Text('Cancelado')),
                        DropdownMenuItem(
                            value: 'expired', child: Text('Vencido')),
                      ],
                      onChanged: _updateStatus,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),

        // Botão de editar
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: IconButton(
            icon: Icon(Icons.edit, color: Colors.blue[600], size: 18),
            onPressed: () => _editContract(context),
            tooltip: 'Editar contrato',
          ),
        ),
        const SizedBox(width: 8),

        // Botão de excluir
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: IconButton(
            icon: Icon(Icons.delete, color: Colors.red[600], size: 18),
            onPressed: () => _deleteContract(context),
            tooltip: 'Excluir contrato',
          ),
        ),
      ],
    );
  }

  Future<void> _updateStatus(String? newStatus) async {
    if (newStatus == null || newStatus == widget.contrato['status']) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      await ContractService.updateContractStatus(
        id: widget.contrato['id'],
        status: newStatus,
      );

      // Atualizar o status localmente
      widget.contrato['status'] = newStatus;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Status atualizado para: ${_getStatusDisplayName(newStatus)}'),
            backgroundColor: Colors.green,
          ),
        );

        // Chamar callback de atualização se fornecido
        widget.onUpdate?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  void _editContract(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/contratos/editar',
      arguments: widget.contrato,
    ).then((_) {
      // Chamar callback de atualização se fornecido
      widget.onUpdate?.call();
    });
  }

  Future<void> _deleteContract(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o contrato "${widget.contrato['contract_number']}"?\n\nEsta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ContractService.deleteContract(widget.contrato['id']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contrato excluído com sucesso'),
              backgroundColor: Colors.green,
            ),
          );

          // Chamar callback de atualização se fornecido
          widget.onUpdate?.call();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir contrato: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _getStatusDisplayName(String status) {
    const statusMap = {
      'active': 'Ativo',
      'pending': 'Pendente',
      'completed': 'Concluído',
      'cancelled': 'Cancelado',
      'expired': 'Vencido',
    };
    return statusMap[status] ?? status;
  }

  String _formatarValor(dynamic valor) {
    if (valor == null) return 'R\$ 0,00';
    final number = double.tryParse(valor.toString()) ?? 0.0;
    return 'R\$ ' +
        number.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}
