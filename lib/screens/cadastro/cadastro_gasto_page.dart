import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../services/expense_service.dart';
import '../../services/project_service.dart';

class CadastroGastoPage extends StatefulWidget {
  final int? projetoId; // Opcional, caso venha de um projeto específico

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
  String tipoGastoSelecionado = 'material'; // Padrão
  String? categoriaSelecionada = 'construção'; // Padrão
  String expenseInSelecionado = 'obra'; // Padrão para o campo obrigatório
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
        mensagemErro = 'Erro ao carregar projetos: ${e.toString()}';
        carregando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemErro!), backgroundColor: Colors.red),
      );
    }
  }
  
  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: data ?? DateTime.now(),
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
          ),
          child: child!,
        );
      },
    );
    
    if (dataSelecionada != null) {
      setState(() => data = dataSelecionada);
    }
  }
  
  Future<void> _selecionarComprovante() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Verifica se está rodando na web (onde Platform._operatingSystem não é suportado)
      if (kIsWeb) {
        // No ambiente web, alertamos que não é possível anexar arquivos
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não é possível anexar comprovantes no ambiente web. Por favor, use o aplicativo nativo para Android ou iOS.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }
      
      // Verifica se está rodando no Windows (onde o image_picker pode ter problemas)
      if (Platform.isWindows) {
        // No Windows, mostra uma mensagem informativa
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A seleção de imagens não está disponível no Windows. Utilize o aplicativo no Android ou iOS.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // Para Android e iOS
      final XFile? imagem = await picker.pickImage(
        source: ImageSource.gallery,
      );
      
      if (imagem != null) {
        setState(() => comprovanteFile = File(imagem.path));
        print("Arquivo selecionado: ${imagem.path}");
      }
    } catch (e) {
      print("Erro ao selecionar imagem: $e");
      String mensagemErro = e.toString();
      
      // Tratamento específico para MissingPluginException
      if (mensagemErro.contains("MissingPluginException") || 
          mensagemErro.contains("No implementation found")) {
        mensagemErro = "Este dispositivo não suporta seleção de imagens. Por favor, utilize o aplicativo no Android ou iOS.";
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagemErro),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _cadastrarGasto() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    if (projetoSelecionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um projeto')),
      );
      return;
    }
    
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma data')),
      );
      return;
    }
    
    setState(() {
      carregando = true;
      mensagemErro = null;
    });
    
    try {
      final valor = double.parse(valorController.text.replaceAll(RegExp(r'[^\d,.]'), '').replaceAll(',', '.'));
      final propertyId = propriedadeIdController.text.isNotEmpty ? 
          int.tryParse(propriedadeIdController.text.trim()) : null;
      
      // Verificar se o arquivo é acessível antes de enviar
      File? fileToSend;
      
      if (comprovanteFile != null) {
        // No ambiente web, não podemos verificar a existência do arquivo
        if (kIsWeb) {
          // No ambiente web, informamos que não podemos anexar o arquivo
          print("Ambiente web: não é possível anexar o arquivo ${comprovanteFile!.path}");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não é possível anexar arquivos no ambiente web. O gasto será registrado sem comprovante.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          fileToSend = null; // No ambiente web, não enviar o arquivo
        } else {
          // Em ambientes nativos, verificamos se o arquivo existe
          try {
            final exists = await comprovanteFile!.exists();
            if (exists) {
              fileToSend = comprovanteFile;
            } else {
              print("Arquivo não existe: ${comprovanteFile!.path}");
            }
          } catch (e) {
            print("Erro ao verificar arquivo: $e");
            fileToSend = null;
          }
        }
      }
      
      await ExpenseService.createExpense(
        projectId: projetoSelecionadoId!,
        description: descricaoController.text.trim(),
        amount: valor,
        date: data!,
        expenseType: tipoGastoSelecionado,
        propertyId: propertyId,
        category: categoriaSelecionada,
        notes: notasController.text.trim(),
        receiptFile: fileToSend,
        expense_in: expenseInSelecionado,
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gasto registrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        mensagemErro = 'Erro ao cadastrar gasto: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemErro!), backgroundColor: Colors.red),
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
                // Cabeçalho simples com seta de volta
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
                        'Registrar Gasto',
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
                
                // Campos do formulário
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    'Informações do Gasto',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                
                // Projeto
                if (widget.projetoId == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: DropdownButtonFormField<int>(
                      value: projetoSelecionadoId,
                      decoration: _buildInputDecoration('Projeto', Icons.business),
                      items: projetos.map((projeto) {
                        return DropdownMenuItem<int>(
                          value: projeto['id'],
                          child: Text(projeto['name'] ?? 'Sem nome'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => projetoSelecionadoId = val),
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor, selecione um projeto';
                        }
                        return null;
                      },
                    ),
                  ),
                
                // Descrição
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: TextFormField(
                    controller: descricaoController,
                    decoration: _buildInputDecoration('Descrição', Icons.description),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, informe uma descrição';
                      }
                      return null;
                    },
                  ),
                ),
                
                // Valor
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: TextFormField(
                    controller: valorController,
                    decoration: _buildInputDecoration('Valor (R\$)', Icons.attach_money),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, informe o valor';
                      }
                      
                      final valorNumerico = double.tryParse(
                        value.replaceAll(RegExp(r'[^\d,.]'), '').replaceAll(',', '.')
                      );
                      
                      if (valorNumerico == null || valorNumerico <= 0) {
                        return 'Valor inválido';
                      }
                      
                      return null;
                    },
                  ),
                ),
                
                // Data
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: InkWell(
                    onTap: () => _selecionarData(context),
                    child: InputDecorator(
                      decoration: _buildInputDecoration('Data', Icons.calendar_today),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data != null 
                              ? dateFormat.format(data!) 
                              : 'Selecionar data',
                            style: TextStyle(
                              fontSize: 16,
                              color: data == null ? Colors.grey : Colors.black87,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Color(0xFF2C3E50)),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Tipo de Gasto
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: tipoGastoSelecionado,
                    decoration: _buildInputDecoration('Tipo de Gasto', Icons.category),
                    items: tiposGasto.map((tipo) {
                      return DropdownMenuItem<String>(
                        value: tipo,
                        child: Text(tipo.capitalize()),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => tipoGastoSelecionado = val!),
                  ),
                ),
                
                // Categoria
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: categoriaSelecionada,
                    decoration: _buildInputDecoration('Categoria', Icons.folder),
                    items: categorias.map((categoria) {
                      return DropdownMenuItem<String>(
                        value: categoria,
                        child: Text(categoria.capitalize()),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => categoriaSelecionada = val),
                  ),
                ),
                
                // Local do Gasto (expense_in)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: expenseInSelecionado,
                    decoration: _buildInputDecoration('Local do Gasto', Icons.location_on),
                    items: locaisGasto.map((local) {
                      return DropdownMenuItem<String>(
                        value: local,
                        child: Text(local.capitalize()),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => expenseInSelecionado = val!),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione onde o gasto foi realizado';
                      }
                      return null;
                    },
                  ),
                ),
                
                // ID da Propriedade (opcional)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: TextFormField(
                    controller: propriedadeIdController,
                    decoration: _buildInputDecoration('ID da Propriedade (opcional)', Icons.house),
                    keyboardType: TextInputType.number,
                  ),
                ),
                
                // Notas
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: TextFormField(
                    controller: notasController,
                    decoration: _buildInputDecoration('Notas adicionais', Icons.note),
                    maxLines: 3,
                  ),
                ),
                
                // Comprovante
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _selecionarComprovante,
                        icon: Icon(Icons.upload_file),
                        label: Text('Anexar Comprovante'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Color(0xFF2C3E50)),
                        ),
                      ),
                      if (comprovanteFile != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Arquivo selecionado: ${comprovanteFile!.path.split('/').last}',
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, size: 16),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                onPressed: () => setState(() => comprovanteFile = null),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Mensagem de erro
                if (mensagemErro != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      mensagemErro!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                // Botão de cadastro
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    height: 50,
                    child: carregando
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: _cadastrarGasto,
                            icon: Icon(Icons.add_circle_outline),
                            label: Text('REGISTRAR GASTO', style: TextStyle(fontSize: 16)),
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

// Extensão para capitalizar strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
} 