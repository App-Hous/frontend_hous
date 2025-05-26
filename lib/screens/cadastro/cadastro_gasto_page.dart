import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../services/expense_service.dart';
import '../../services/project_service.dart';

class CadastroGastoPage extends StatefulWidget {
  final int? projetoId;

  const CadastroGastoPage({Key? key, this.projetoId}) : super(key: key);

  @override
  State<CadastroGastoPage> createState() => _CadastroGastoPageState();
}

class _CadastroGastoPageState extends State<CadastroGastoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController valorController = TextEditingController();
  final TextEditingController notasController = TextEditingController();
  final TextEditingController propriedadeIdController = TextEditingController();

  int? projetoSelecionadoId;
  DateTime? data = DateTime.now();
  String tipoGastoSelecionado = 'material';
  String categoriaSelecionada = 'construção';
  String localGastoSelecionado = 'obra';
  File? comprovanteFile;
  bool carregando = false;
  String? mensagemErro;

  List<Map<String, dynamic>> projetos = [];
  List<String> categorias = ['construção', 'mão de obra', 'equipamentos', 'administrativo', 'outros'];
  List<String> tiposGasto = ['material', 'serviço', 'imposto', 'outros'];
  List<String> locaisGasto = ['obra', 'escritório', 'fornecedor', 'banco', 'outros'];

  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    projetoSelecionadoId = widget.projetoId;
    _carregarProjetos();
  }

  void _carregarProjetos() async {
    setState(() => carregando = true);
    try {
      final data = await ProjectService.getProjects();
      setState(() {
        projetos = data;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        mensagemErro = 'Erro ao carregar projetos: \${e.toString()}';
        carregando = false;
      });
    }
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: data ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );

    if (dataSelecionada != null) {
      setState(() => data = dataSelecionada);
    }
  }

  Future<void> _selecionarComprovante() async {
    try {
      final ImagePicker picker = ImagePicker();

      if (kIsWeb || Platform.isWindows) return;

      final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);
      if (imagem != null) setState(() => comprovanteFile = File(imagem.path));
    } catch (_) {}
  }

  void _cadastrarGasto() async {
    if (_formKey.currentState?.validate() != true || projetoSelecionadoId == null || data == null) {
      return;
    }

    setState(() {
      carregando = true;
      mensagemErro = null;
    });

    try {
      final valor = double.parse(valorController.text.replaceAll(RegExp(r'[^\d,.]'), '').replaceAll(',', '.'));
      final propertyId = propriedadeIdController.text.isNotEmpty ? int.tryParse(propriedadeIdController.text.trim()) : null;

      await ExpenseService.createExpense(
        projectId: projetoSelecionadoId!,
        description: descricaoController.text.trim(),
        amount: valor,
        date: data!,
        category: categoriaSelecionada,
        propertyId: propertyId,
        notes: notasController.text.trim(),
        receiptFile: comprovanteFile,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto registrado com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => mensagemErro = 'Erro ao cadastrar gasto: \${e.toString()}');
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Registrar Gasto', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (widget.projetoId == null)
                  DropdownButtonFormField<int>(
                    value: projetoSelecionadoId,
                    decoration: _buildInputDecoration('Projeto', Icons.business),
                    items: projetos.map<DropdownMenuItem<int>>((p) {
                      return DropdownMenuItem<int>(
                        value: p['id'] as int,
                        child: Text(p['name']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => projetoSelecionadoId = val),
                    validator: (value) => value == null ? 'Selecione um projeto' : null,
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descricaoController,
                  decoration: _buildInputDecoration('Descrição', Icons.description),
                  validator: (value) => value == null || value.isEmpty ? 'Informe a descrição' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: valorController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration('Valor (R\$)', Icons.attach_money),
                  validator: (value) => value == null || value.isEmpty ? 'Informe o valor' : null,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => _selecionarData(context),
                  child: InputDecorator(
                    decoration: _buildInputDecoration('Data', Icons.calendar_today),
                    child: Text(data != null ? dateFormat.format(data!) : 'Selecionar data'),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: propriedadeIdController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration('ID da Propriedade', Icons.home),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notasController,
                  maxLines: 3,
                  decoration: _buildInputDecoration('Notas adicionais', Icons.note),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _selecionarComprovante,
                  child: Text('Selecionar Comprovante'),
                ),
                const SizedBox(height: 20),
                if (mensagemErro != null)
                  Text(mensagemErro!, style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: Icon(Icons.save),
                  label: Text('REGISTRAR GASTO'),
                  onPressed: _cadastrarGasto,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}