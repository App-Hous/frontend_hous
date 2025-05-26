import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/contract_service.dart';
import '../../services/cliente_service.dart';
import '../../services/servico_service.dart';
import '../../services/project_service.dart';

class CadastroContratoPage extends StatefulWidget {
  @override
  _CadastroContratoPageState createState() => _CadastroContratoPageState();
}

class _CadastroContratoPageState extends State<CadastroContratoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController valorController = TextEditingController();
  final TextEditingController notasController = TextEditingController();
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController tipoImovelController = TextEditingController();

  DateTime? dataAssinatura;
  DateTime? dataExpiracao;

  String? _tipoSelecionadoPt;
  String? _statusSelecionadoPt;
  int? _clienteSelecionado;
  int? _imovelSelecionado;

  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _imoveis = [];

  bool _isLoading = false;
  String? _error;
  bool _loadingDropdowns = true;

  final Map<String, String> tiposMap = {
    'Venda': 'sale',
    'Aluguel': 'rental',
    'Arrendamento': 'lease',
    'Outro': 'other',
  };
  final Map<String, String> statusMap = {
    'Ativo': 'active',
    'Pendente': 'pending',
    'Vencido': 'expired',
    'Cancelado': 'cancelled',
    'Concluído': 'completed',
  };

  @override
  void initState() {
    super.initState();
    _carregarDropdowns();
  }

  Future<void> _carregarDropdowns() async {
    setState(() => _loadingDropdowns = true);
    try {
      final clientes = await ClienteService.getClientes();
      final imoveis = await ServicoService.getServicos();
      setState(() {
        _clientes = clientes;
        _imoveis = imoveis;
        _loadingDropdowns = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar clientes ou imóveis: $e';
        _loadingDropdowns = false;
      });
    }
  }

  InputDecoration _inputDecoration(String label, [IconData? icon]) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Color(0xFF2C3E50)),
      prefixIcon: icon != null ? Icon(icon, color: Color(0xFF2C3E50)) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 90,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF34495E),
                    Color(0xFF2C3E50),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 16, top: 8, bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cadastro de Contrato',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _loadingDropdowns
                ? Padding(
                    padding: const EdgeInsets.only(top: 48.0),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF2C3E50))),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 500),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: tituloController,
                                    decoration: _inputDecoration('Título', Icons.title),
                                    style: GoogleFonts.poppins(),
                                    validator: (v) => v == null || v.isEmpty ? 'Informe o título' : null,
                                  ),
                                  SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    value: _tipoSelecionadoPt,
                                    items: tiposMap.keys
                                        .map((tipoPt) => DropdownMenuItem(
                                              value: tipoPt,
                                              child: Text(tipoPt, style: GoogleFonts.poppins()),
                                            ))
                                        .toList(),
                                    onChanged: (v) => setState(() => _tipoSelecionadoPt = v),
                                    decoration: _inputDecoration('Tipo', Icons.category),
                                    validator: (v) => v == null || v.isEmpty ? 'Selecione o tipo' : null,
                                  ),
                                  SizedBox(height: 16),
                                  TextFormField(
                                    controller: descricaoController,
                                    decoration: _inputDecoration('Descrição', Icons.description),
                                    style: GoogleFonts.poppins(),
                                  ),
                                  SizedBox(height: 16),
                                  TextFormField(
                                    controller: tipoImovelController,
                                    decoration: _inputDecoration('Tipo de Imóvel', Icons.home_work),
                                    style: GoogleFonts.poppins(),
                                  ),
                                  SizedBox(height: 16),
                                  DropdownButtonFormField<int>(
                                    value: _clienteSelecionado,
                                    items: _clientes
                                        .map<DropdownMenuItem<int>>((cliente) => DropdownMenuItem<int>(
                                              value: cliente['id'] as int,
                                              child: Text(cliente['name'] ?? 'Cliente ${cliente['id']}', style: GoogleFonts.poppins()),
                                            ))
                                        .toList(),
                                    onChanged: (v) => setState(() => _clienteSelecionado = v),
                                    decoration: _inputDecoration('Cliente', Icons.person),
                                    validator: (v) => v == null ? 'Selecione o cliente' : null,
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<int>(
                                          value: _imovelSelecionado,
                                          items: _imoveis
                                              .map<DropdownMenuItem<int>>((imovel) => DropdownMenuItem<int>(
                                                    value: imovel['id'] as int,
                                                    child: Text(imovel['name'] ?? 'Imóvel ${imovel['id']}', style: GoogleFonts.poppins()),
                                                  ))
                                              .toList(),
                                          onChanged: (v) => setState(() => _imovelSelecionado = v),
                                          decoration: _inputDecoration('Imóvel', Icons.apartment),
                                          validator: (v) => v == null ? 'Selecione o imóvel' : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  TextFormField(
                                    controller: valorController,
                                    decoration: _inputDecoration('Valor do Contrato', Icons.attach_money),
                                    keyboardType: TextInputType.number,
                                    style: GoogleFonts.poppins(),
                                    validator: (v) => v == null || v.isEmpty ? 'Informe o valor' : null,
                                    onChanged: (value) {
                                      String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                                      if (newValue.isEmpty) newValue = '0';
                                      double val = double.parse(newValue) / 100;
                                      valorController.value = valorController.value.copyWith(
                                        text: val.toStringAsFixed(2).replaceAll('.', ','),
                                        selection: TextSelection.collapsed(
                                            offset: val.toStringAsFixed(2).replaceAll('.', ',').length),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    value: _statusSelecionadoPt,
                                    items: statusMap.keys
                                        .map((statusPt) => DropdownMenuItem(
                                              value: statusPt,
                                              child: Text(statusPt, style: GoogleFonts.poppins()),
                                            ))
                                        .toList(),
                                    onChanged: (v) => setState(() => _statusSelecionadoPt = v),
                                    decoration: _inputDecoration('Status', Icons.flag),
                                    validator: (v) => v == null || v.isEmpty ? 'Selecione o status' : null,
                                  ),
                                  SizedBox(height: 16),
                                  TextFormField(
                                    controller: notasController,
                                    decoration: _inputDecoration('Observações', Icons.note),
                                    style: GoogleFonts.poppins(),
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            final picked = await showDatePicker(
                                              context: context,
                                              initialDate: dataAssinatura ?? DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100),
                                              builder: (context, child) {
                                                return Theme(
                                                  data: Theme.of(context).copyWith(
                                                    colorScheme: ColorScheme.light(
                                                      primary: Color(0xFF2C3E50),
                                                      onPrimary: Colors.white,
                                                      surface: Colors.white,
                                                      onSurface: Colors.black,
                                                    ),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );
                                            if (picked != null) {
                                              setState(() => dataAssinatura = picked);
                                            }
                                          },
                                          child: InputDecorator(
                                            decoration: _inputDecoration('Data de Assinatura', Icons.edit_calendar),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  dataAssinatura == null
                                                      ? 'Selecionar data'
                                                      : '${dataAssinatura!.day.toString().padLeft(2, '0')}/${dataAssinatura!.month.toString().padLeft(2, '0')}/${dataAssinatura!.year}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    color: dataAssinatura == null ? Colors.grey : Colors.black87,
                                                  ),
                                                ),
                                                Icon(Icons.arrow_drop_down, color: Color(0xFF2C3E50)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            final picked = await showDatePicker(
                                              context: context,
                                              initialDate: dataExpiracao ?? DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100),
                                              builder: (context, child) {
                                                return Theme(
                                                  data: Theme.of(context).copyWith(
                                                    colorScheme: ColorScheme.light(
                                                      primary: Color(0xFF2C3E50),
                                                      onPrimary: Colors.white,
                                                      surface: Colors.white,
                                                      onSurface: Colors.black,
                                                    ),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );
                                            if (picked != null) {
                                              setState(() => dataExpiracao = picked);
                                            }
                                          },
                                          child: InputDecorator(
                                            decoration: _inputDecoration('Data de Expiração', Icons.event),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  dataExpiracao == null
                                                      ? 'Selecionar data'
                                                      : '${dataExpiracao!.day.toString().padLeft(2, '0')}/${dataExpiracao!.month.toString().padLeft(2, '0')}/${dataExpiracao!.year}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    color: dataExpiracao == null ? Colors.grey : Colors.black87,
                                                  ),
                                                ),
                                                Icon(Icons.arrow_drop_down, color: Color(0xFF2C3E50)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 24),
                                  if (_error != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Text(_error!, style: TextStyle(color: Colors.red)),
                                    ),
                                  SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _salvarContrato,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF2C3E50),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? CircularProgressIndicator(color: Colors.white)
                                          : Text('Cadastrar Contrato', style: GoogleFonts.poppins(fontSize: 16)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _salvarContrato() async {
    if (!_formKey.currentState!.validate() ||
        dataAssinatura == null ||
        dataExpiracao == null) {
      setState(() => _error = 'Preencha todos os campos obrigatórios e datas.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ContractService.createContract(
        contractNumber: tituloController.text.trim(),
        title: tituloController.text.trim(),
        type: tiposMap[_tipoSelecionadoPt!]!,
        propertyType: tipoImovelController.text.trim(),
        description: descricaoController.text.trim(),
        clientId: _clienteSelecionado!,
        propertyId: _imovelSelecionado!,
        signingDate: dataAssinatura!,
        expirationDate: dataExpiracao!,
        contractValue: _parseValor(valorController.text),
        status: statusMap[_statusSelecionadoPt!]!,
        notes: notasController.text.trim(),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double _parseValor(String valor) {
    return double.tryParse(valor.replaceAll('.', '').replaceAll(',', '.')) ??
        0.0;
  }

  Future<void> _abrirCadastroRapidoImovel() async {
    final novoImovel = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CadastroRapidoImovelDialog(),
    );
    if (novoImovel != null) {
      await _carregarDropdowns();
      setState(() {
        _imovelSelecionado = novoImovel['id'];
      });
    }
  }
}

class CadastroRapidoImovelDialog extends StatefulWidget {
  @override
  State<CadastroRapidoImovelDialog> createState() => _CadastroRapidoImovelDialogState();
}

class _CadastroRapidoImovelDialogState extends State<CadastroRapidoImovelDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController progressoController = TextEditingController();
  int? _obraSelecionada;
  List<Map<String, dynamic>> _obras = [];
  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarObras();
  }

  Future<void> _carregarObras() async {
    try {
      final obras = await ProjectService.getProjects();
      setState(() => _obras = obras);
    } catch (e) {
      setState(() => _erro = 'Erro ao carregar obras: $e');
    }
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      await ServicoService.criarServico(
        nomeController.text.trim(),
        descricaoController.text.trim(),
        int.tryParse(progressoController.text.trim()) ?? 0,
        _obraSelecionada!,
      );
      final imoveis = await ServicoService.getServicos();
      final novo = imoveis.lastWhere(
        (i) => i['name'] == nomeController.text.trim(),
        orElse: () => <String, dynamic>{},
      );
      if (!mounted) return;
      Navigator.of(context).pop(novo);
    } catch (e) {
      setState(() => _erro = 'Erro ao cadastrar imóvel: $e');
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cadastro rápido de Imóvel', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      content: _erro != null
          ? Text(_erro!, style: const TextStyle(color: Colors.red))
          : Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nomeController,
                    decoration: InputDecoration(labelText: 'Nome do imóvel'),
                    validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
                  ),
                  TextFormField(
                    controller: descricaoController,
                    decoration: InputDecoration(labelText: 'Descrição'),
                  ),
                  TextFormField(
                    controller: progressoController,
                    decoration: InputDecoration(labelText: 'Progresso (%)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Informe o progresso' : null,
                  ),
                  DropdownButtonFormField<int>(
                    value: _obraSelecionada,
                    items: _obras
                        .map<DropdownMenuItem<int>>((obra) => DropdownMenuItem<int>(
                              value: obra['id'] as int,
                              child: Text(obra['name'] ?? 'Obra ${obra['id']}'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _obraSelecionada = v),
                    decoration: InputDecoration(labelText: 'Obra'),
                    validator: (v) => v == null ? 'Selecione a obra' : null,
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar', style: GoogleFonts.poppins()),
        ),
        ElevatedButton(
          onPressed: _carregando ? null : _cadastrar,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2C3E50),
            foregroundColor: Colors.white,
          ),
          child: _carregando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text('Cadastrar', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }
}
