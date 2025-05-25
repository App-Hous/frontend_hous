import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/project_service.dart';

class CadastroObraPage extends StatefulWidget {
  const CadastroObraPage({Key? key}) : super(key: key);

  @override
  State<CadastroObraPage> createState() => _CadastroObraPageState();
}

class _CadastroObraPageState extends State<CadastroObraPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController areaTotalController = TextEditingController();
  final TextEditingController orcamentoController = TextEditingController();
  final TextEditingController companyIdController = TextEditingController();
  final TextEditingController managerIdController = TextEditingController();

  DateTime? dataInicio;
  DateTime? dataFimPrevista;
  DateTime? dataFimReal;
  String statusSelecionado = 'planning';

  bool carregando = false;
  String? mensagemErro;

  final dateFormat = DateFormat('dd/MM/yyyy');

  Future<void> _selecionarData(BuildContext context, DateTime? initial, Function(DateTime) onConfirmar) async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2C3E50),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (data != null) onConfirmar(data);
  }

  String _traduzirStatus(String status) {
    switch (status) {
      case 'planning':
        return 'Planejamento';
      case 'in_progress':
        return 'Em andamento';
      case 'completed':
        return 'Concluído';
      default:
        return status;
    }
  }

  void _cadastrar() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final nome = nomeController.text.trim();
    final descricao = descricaoController.text.trim();
    final endereco = enderecoController.text.trim();
    final cidade = cidadeController.text.trim();
    final estado = estadoController.text.trim();
    final cep = cepController.text.trim();
    final areaTotal = double.tryParse(areaTotalController.text.trim()) ?? 0;
    final orcamento = double.tryParse(orcamentoController.text.trim()) ?? 0;
    final companyId = int.tryParse(companyIdController.text.trim()) ?? 0;
    final managerId = int.tryParse(managerIdController.text.trim()) ?? 0;

    setState(() => carregando = true);

    try {
      await ProjectService.createProject(
        nome: nome,
        descricao: descricao,
        endereco: endereco,
        cidade: cidade,
        estado: estado,
        cep: cep,
        areaTotal: areaTotal,
        orcamento: orcamento,
        dataInicio: dataInicio!,
        dataFimPrevista: dataFimPrevista!,
        dataFimReal: dataFimReal!,
        status: statusSelecionado,
        companyId: companyId,
        managerId: managerId,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Projeto cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        mensagemErro = 'Erro ao cadastrar obra: ${e.toString()}';
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar projeto: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => carregando = false);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: Color(0xFF2C3E50)) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Color(0xFF2C3E50), size: 20),
                        padding: EdgeInsets.all(0),
                        constraints: BoxConstraints(),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Cadastro de Obra',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    'Informações Básicas',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: TextFormField(
                    controller: nomeController,
                    decoration: _buildInputDecoration('Nome da Obra', Icons.business),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, informe o nome da obra';
                      }
                      return null;
                    },
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: TextFormField(
                    controller: descricaoController,
                    decoration: _buildInputDecoration('Descrição', Icons.description),
                    minLines: 2,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, informe uma descrição';
                      }
                      return null;
                    },
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    'Localização',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: TextFormField(
                    controller: enderecoController,
                    decoration: _buildInputDecoration('Endereço', Icons.location_on),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, informe o endereço';
                      }
                      return null;
                    },
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: cidadeController,
                          decoration: _buildInputDecoration('Cidade', Icons.location_city),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, informe a cidade';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: estadoController,
                          decoration: _buildInputDecoration('Estado', null),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o estado';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: TextFormField(
                    controller: cepController,
                    decoration: _buildInputDecoration('CEP', Icons.pin),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, informe o CEP';
                      }
                      return null;
                    },
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    'Detalhes do Projeto',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: areaTotalController,
                          decoration: _buildInputDecoration('Área Total (m²)', Icons.square_foot),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe a área';
                            }
                            final area = double.tryParse(value);
                            if (area == null || area <= 0) {
                              return 'Área inválida';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: orcamentoController,
                          decoration: _buildInputDecoration('Orçamento (R\$)', Icons.attach_money),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o orçamento';
                            }
                            final orcamento = double.tryParse(value);
                            if (orcamento == null || orcamento <= 0) {
                              return 'Valor inválido';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    'Cronograma',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: InkWell(
                    onTap: () => _selecionarData(
                      context, 
                      dataInicio, 
                      (data) => setState(() => dataInicio = data)
                    ),
                    child: InputDecorator(
                      decoration: _buildInputDecoration('Data de Início', Icons.calendar_today),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dataInicio == null 
                              ? 'Selecionar data' 
                              : dateFormat.format(dataInicio!),
                            style: TextStyle(
                              fontSize: 16,
                              color: dataInicio == null ? Colors.grey : Colors.black87,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Color(0xFF2C3E50)),
                        ],
                      ),
                    ),
                  ),
                ),
                if (dataInicio == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 36, right: 24),
                    child: Text(
                      'Por favor, selecione a data de início',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: InkWell(
                    onTap: () => _selecionarData(
                      context, 
                      dataFimPrevista, 
                      (data) => setState(() => dataFimPrevista = data)
                    ),
                    child: InputDecorator(
                      decoration: _buildInputDecoration('Data Prevista de Término', Icons.event),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dataFimPrevista == null 
                              ? 'Selecionar data' 
                              : dateFormat.format(dataFimPrevista!),
                            style: TextStyle(
                              fontSize: 16,
                              color: dataFimPrevista == null ? Colors.grey : Colors.black87,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Color(0xFF2C3E50)),
                        ],
                      ),
                    ),
                  ),
                ),
                if (dataFimPrevista == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 36, right: 24),
                    child: Text(
                      'Por favor, selecione a data prevista',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: InkWell(
                    onTap: () => _selecionarData(
                      context, 
                      dataFimReal, 
                      (data) => setState(() => dataFimReal = data)
                    ),
                    child: InputDecorator(
                      decoration: _buildInputDecoration('Data Real de Término', Icons.event_available),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dataFimReal == null 
                              ? 'Selecionar data' 
                              : dateFormat.format(dataFimReal!),
                            style: TextStyle(
                              fontSize: 16,
                              color: dataFimReal == null ? Colors.grey : Colors.black87,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Color(0xFF2C3E50)),
                        ],
                      ),
                    ),
                  ),
                ),
                if (dataFimReal == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 36, right: 24),
                    child: Text(
                      'Por favor, selecione a data real',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: statusSelecionado,
                    decoration: _buildInputDecoration('Status do Projeto', Icons.trending_up),
                    items: [
                      DropdownMenuItem(value: 'planning', child: Text('Planejamento')),
                      DropdownMenuItem(value: 'in_progress', child: Text('Em andamento')),
                      DropdownMenuItem(value: 'completed', child: Text('Concluído')),
                    ],
                    onChanged: (val) => setState(() => statusSelecionado = val ?? 'planning'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione o status';
                      }
                      return null;
                    },
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    'Informações Administrativas',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: TextFormField(
                    controller: companyIdController,
                    decoration: _buildInputDecoration('ID da Empresa', Icons.business_center),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, informe o ID da empresa';
                      }
                      final id = int.tryParse(value);
                      if (id == null || id <= 0) {
                        return 'ID inválido';
                      }
                      return null;
                    },
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: TextFormField(
                    controller: managerIdController,
                    decoration: _buildInputDecoration('ID do Gerente', Icons.person),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, informe o ID do gerente';
                      }
                      final id = int.tryParse(value);
                      if (id == null || id <= 0) {
                        return 'ID inválido';
                      }
                      return null;
                    },
                  ),
                ),
                
                if (mensagemErro != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
                    child: Text(
                      mensagemErro!,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    height: 50,
                    child: carregando
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: _cadastrar,
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('CADASTRAR OBRA', style: TextStyle(fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2C3E50),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
