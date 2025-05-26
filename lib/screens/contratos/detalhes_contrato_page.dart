import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/contract_service.dart';

class DetalhesContratoPage extends StatefulWidget {
  const DetalhesContratoPage({super.key});

  @override
  State<DetalhesContratoPage> createState() => _DetalhesContratoPageState();
}

class _DetalhesContratoPageState extends State<DetalhesContratoPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _contract;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadContract);
  }

  Future<void> _loadContract() async {
    final args = ModalRoute.of(context)!.settings.arguments;
    int contractId;

    if (args is int) {
      contractId = args;
    } else if (args is Map<String, dynamic>) {
      if (args.containsKey('id')) {
        contractId = args['id'];
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
      setState(() {
        _contract = contract;
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Detalhes do Contrato',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF2C3E50),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: CircularProgressIndicator(color: Color(0xFF2C3E50)),
                ),
              )
            : _error != null
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            _error!,
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : _contract == null
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Text(
                            'Contrato não encontrado',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      )
                    : Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _contract!['contract_number']?.toString() ??
                                    '-',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              Divider(height: 32),
                              _buildInfoRow(
                                'Tipo',
                                _traduzirTipo(_contract!['type']),
                                Icons.category,
                              ),
                              _buildInfoRow(
                                'Status',
                                _traduzirStatus(_contract!['status']),
                                Icons.flag,
                              ),
                              _buildInfoRow(
                                'Valor',
                                _formatarValor(_contract!['contract_value']),
                                Icons.attach_money,
                              ),
                              _buildInfoRow(
                                'Data de Assinatura',
                                _formatarData(_contract!['signing_date']),
                                Icons.calendar_today,
                              ),
                              _buildInfoRow(
                                'Data de Expiração',
                                _formatarData(_contract!['expiration_date']),
                                Icons.event,
                              ),
                              _buildInfoRow(
                                'Cliente',
                                _contract!['client_name']?.toString() ??
                                    'Cliente ${_contract!['client_id']}',
                                Icons.person,
                              ),
                              _buildInfoRow(
                                'Imóvel',
                                _contract!['property_name']?.toString() ??
                                    'Imóvel ${_contract!['property_id']}',
                                Icons.home,
                              ),
                              if (_contract!['description']?.isNotEmpty ??
                                  false)
                                _buildInfoRow(
                                  'Descrição',
                                  _contract!['description'],
                                  Icons.description,
                                ),
                              if (_contract!['notes']?.isNotEmpty ?? false)
                                _buildInfoRow(
                                  'Observações',
                                  _contract!['notes'],
                                  Icons.note,
                                ),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF2C3E50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Color(0xFF2C3E50)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
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
