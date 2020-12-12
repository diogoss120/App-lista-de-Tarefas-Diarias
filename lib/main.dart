import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _tarefas = [];
  TextEditingController controlerTarefa = TextEditingController();
  Map<String, dynamic> _ultimaTarefaRemovida = Map();

  Future<File> _trazerAquivo() async {
    var diretorio = await getApplicationDocumentsDirectory();
    return File(diretorio.path + '/dados.json');
  }

  _salvarTarefa() async {
    Map<String, dynamic> tarefa = Map();
    tarefa['titulo'] = controlerTarefa.text;
    tarefa['situacao'] = false;
    setState(() {
      _tarefas.add(tarefa);
    });
    controlerTarefa.text = '';
  }

  _salvarArquivo() async {
    var arquivo = await _trazerAquivo();
    var dados = json.encode(_tarefas);
    arquivo.writeAsString(dados);
  }

  _lerDados() async {
    try {
      var arquivo = await _trazerAquivo();
      return arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    _lerDados().then((value) {
      setState(() {
        _tarefas = json.decode(value);
      });
    });
    super.initState();
  }

  Widget _tarefa(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _ultimaTarefaRemovida = _tarefas[index];

          setState(() {
            _tarefas.removeAt(index);
          });

          final snackbar = SnackBar(
              duration: Duration(seconds: 5),
              content: Text('Tarefa excluida!'),
              action: SnackBarAction(
                  label: 'Desfazer',
                  onPressed: () {
                    setState(() {
                      _tarefas.insert(index, _ultimaTarefaRemovida);
                    });
                    _salvarArquivo();
                  }));
          Scaffold.of(context).showSnackBar(snackbar);
        } else if (direction == DismissDirection.startToEnd) {
          setState(() {
            _editarTarefa(index);
          });
        }
        _salvarArquivo();
      },
      background: Container(
        color: Colors.green,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.edit,
              color: Colors.white,
            )
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
            )
          ],
        ),
      ),
      child: CheckboxListTile(
        value: _tarefas[index]['situacao'],
        onChanged: (value) {
          setState(() {
            _tarefas[index]['situacao'] = value;
            _salvarArquivo();
          });
        },
        title: Text(
          _tarefas[index]['titulo'],
          style: TextStyle(color: Colors.black, fontSize: 21),
        ),
      ),
    );
  }

  _escreverNovaTarefa() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar nova tarefa'),
          content: TextField(
            controller: controlerTarefa,
            decoration: InputDecoration(labelText: 'Digite sua tarefa'),
          ),
          actions: [
            FlatButton(
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text(
                'Salvar',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                _salvarTarefa();
                _salvarArquivo();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  _editarTarefa(int index) {
    controlerTarefa.text = _tarefas[index]['titulo'];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Alterar tarefa'),
          content: TextField(
            controller: controlerTarefa,
            decoration: InputDecoration(labelText: 'Digite sua tarefa'),
          ),
          actions: [
            FlatButton(
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                controlerTarefa.text = '';
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text(
                'Alterar',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                setState(() {
                  _tarefas[index]['titulo'] = controlerTarefa.text;
                });
                controlerTarefa.text = '';
                _salvarArquivo();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de Tarefas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: _tarefas.length,
        itemBuilder: _tarefa,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        elevation: 10,
        backgroundColor: Colors.deepPurple,
        icon: Icon(Icons.note_add),
        label: Text('Adicionar'),
        onPressed: () {
          _escreverNovaTarefa();
        },
      ),
    );
  }
}
