import 'package:flutter/material.dart';
import '../../services/contract_service.dart';

class ContractDetailsPage extends StatefulWidget {
  const ContractDetailsPage({super.key});

  @override
  State<ContractDetailsPage> createState() => _ContractDetailsPageState();
}

class _ContractDetailsPageState extends State<ContractDetailsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _contract;
  List<Map<String, dynamic>> _documents = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadContract);
  }

  Future<void> _loadContract() async {
    final args = ModalRoute.of(context)!.settings.arguments;
    int contractId;

    // Handle receiving either a contract object or just an ID
    if (args is int) {
      contractId = args;
    } else if (args is Map<String, dynamic>) {
      // If we receive the full contract object, we can use it directly
      if (args.containsKey('id')) {
        contractId = args['id'];
        // Optional: we could set the contract data directly if it's complete
        // But we'll fetch it from the API to ensure we have the latest data
      } else {
        setState(() {
          _error = 'Contrato não possui ID válido';
          _isLoading = false;
        });
        return;
      }
    } else {
      setState(() {
        _error = 'Parâmetros inválidos para detalhes do contrato';
        _isLoading = false;
      });
      return;
    }

    try {
      final contract = await ContractService.getContract(contractId);
      final documents = await ContractService.getContractDocuments(contractId);
      setState(() {
        _contract = contract;
        _documents = documents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar contrato: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Contrato'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)))
              : _contract == null
                  ? const Center(child: Text('Contrato não encontrado'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Contrato: ${_contract!['contract_number']?.toString() ?? '-'}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow('Tipo',
                                      _traduzirTipo(_contract!['type'])),
                                  _buildInfoRow('Status',
                                      _traduzirStatus(_contract!['status'])),
                                  _buildInfoRow(
                                      'Valor',
                                      _formatarValor(
                                          _contract!['contract_value'])),
                                  _buildInfoRow(
                                      'Data de Assinatura',
                                      _formatarData(
                                          _contract!['signing_date'])),
                                  _buildInfoRow(
                                      'Data de Expiração',
                                      _formatarData(
                                          _contract!['expiration_date'])),
                                  _buildInfoRow(
                                      'ID do Cliente',
                                      _contract!['client_id']?.toString() ??
                                          '-'),
                                  _buildInfoRow(
                                      'ID do Imóvel',
                                      _contract!['property_id']?.toString() ??
                                          '-'),
                                  _buildInfoRow('Descrição',
                                      _contract!['description'] ?? '-'),
                                  _buildInfoRow('Observações',
                                      _contract!['notes'] ?? '-'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text('Documentos',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          if (_documents.isEmpty)
                            const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('Nenhum documento encontrado'),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _documents.length,
                              itemBuilder: (context, index) {
                                final document = _documents[index];
                                return Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.description),
                                    title: Text(
                                        document['filename']?.toString() ??
                                            'Documento sem nome'),
                                    subtitle: Text(
                                        document['file_type']?.toString() ??
                                            'Tipo não especificado'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.download),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Download em desenvolvimento'),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    final safeValue = value?.toString() ?? '-';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(safeValue)),
        ],
      ),
    );
  }

  String _formatarValor(dynamic valor) {
    if (valor == null) return 'R\$ 0,00';
    final number = double.tryParse(valor.toString()) ?? 0.0;
    return 'R\$ ' +
        number.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  String _formatarData(dynamic data) {
    if (data == null) return '-';
    final str = data.toString();
    if (str.contains('T')) return str.split('T')[0];
    return str;
  }

  String _traduzirTipo(String? type) {
    switch (type) {
      case 'sale':
        return 'Venda';
      case 'rental':
        return 'Aluguel';
      case 'lease':
        return 'Arrendamento';
      case 'other':
        return 'Outro';
      default:
        return type ?? '-';
    }
  }

  String _traduzirStatus(String? status) {
    switch (status) {
      case 'active':
        return 'Ativo';
      case 'pending':
        return 'Pendente';
      case 'expired':
        return 'Vencido';
      case 'cancelled':
        return 'Cancelado';
      case 'completed':
        return 'Concluído';
      default:
        return status ?? '-';
    }
  }
}
