import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prueba_simpleagri/widgets/dialogo.dart';
import 'package:prueba_simpleagri/controlador/terrenos.dart';
import 'package:prueba_simpleagri/model/terrenos.dart';
import 'package:prueba_simpleagri/view/menu.dart';
import 'package:prueba_simpleagri/widgets/button_pill.dart';
import 'package:prueba_simpleagri/widgets/header.dart';

class Terreno extends StatefulWidget {
  @override
  _TerrenoState createState() => _TerrenoState();
}

class _TerrenoState extends State<Terreno> {
  bool loading = true;
  TextEditingController controler_texto_busqueda = TextEditingController();
  ControladorTerrenos controllerterreno = ControladorTerrenos();
  List<ObjetoTerreno> lista_data = [];
  List<ObjetoTerreno> lista_auxiliar = [];
  int _selectedIndex = 0;
  final List<String> _options = ["Todos", 'Activo', 'Inactivo', 'Cerrado'];

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), cargar_tabla);
  }

  Future<void> cargar_tabla() async {
    lista_data = await controllerterreno.listadoTabla(context: context);
    lista_auxiliar = List.from(lista_data);
    setState(() {
      loading = false;
    });
  }

Future<void> _search() async {
  if (controler_texto_busqueda.text.isEmpty) {
  Dialogo().showAlert(context,"Por favor ingrese un texto para la busqueda");
  } else {
List<ObjetoTerreno> listaFiltrada = lista_auxiliar.where((terreno) {
      bool estadoCoincide = _selectedIndex == 0 ||
          (terreno.status == '0' && _selectedIndex == 1) ||
          (terreno.status == '1' && _selectedIndex == 2) ||
          (terreno.status == '2' && _selectedIndex == 3);

      bool textoCoincide = controler_texto_busqueda.text.isEmpty ||
          terreno.terrain.toLowerCase().contains(controler_texto_busqueda.text.toLowerCase()) ||
          terreno.crop.toLowerCase().contains(controler_texto_busqueda.text.toLowerCase());
      return estadoCoincide && textoCoincide;
    }).toList();
    setState(() {
      lista_data = listaFiltrada;
      lista_auxiliar = List.from(lista_data);
    });
  }
}

  void cambio_estado(int index) {
    if (index == 0) {
      setState(() {
        lista_data = List.from(lista_auxiliar);
      });
    } else {
        String estadoFiltrado = '';
        switch (index) {
          case 1:
            estadoFiltrado = '0'; 
            break;
          case 2:
            estadoFiltrado = '1'; 
            break;
          case 3:
            estadoFiltrado = '2'; 
            break;
        }
      setState(() {
        lista_data = lista_auxiliar
            .where((terreno) => terreno.status == estadoFiltrado)
            .toList();
      });
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Header(
          text: 'Terreno',
          back: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      drawer: Menu(),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12.0),
              children: [
                TextFormField(
                  controller: controler_texto_busqueda,
                  obscureText: false,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Texto Búsqueda",
                    hintText: "Texto Búsqueda",
                  ),
                ),
                SizedBox(height: 20),
                ButtonPill(
                  text: 'Buscar',
                  onPressed: _search,
                ),
                ButtonPill(
                  text: 'Limpiar filtro',
                  onPressed: () async {
                    await cargar_tabla();
                    setState(() {
                      _selectedIndex = 0;
                      controler_texto_busqueda.clear();
                      lista_data = List.from(lista_auxiliar);
                    });
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ToggleButtons(
                    isSelected: List.generate(_options.length, (index) => index == _selectedIndex),
                    onPressed: (int index) {
                      cambio_estado(index);
                    },
                    children: _options.map((String label) => Row(
                      children: [
                        SizedBox(width: 10),
                        Text(label),
                        SizedBox(width: 10),
                      ],
                    )).toList(),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  alignment: Alignment.centerLeft,
                  color: Colors.lightGreen,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      " Resultados Tabla ",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color.fromARGB(230, 229, 231, 230),
                    ),
                    columns: const [
                      DataColumn(label: Text("Terreno")),
                      DataColumn(label: Text("Código")),
                      DataColumn(label: Text("Estado")),
                      DataColumn(label: Text("Fecha")),
                    ],
                    rows: lista_data.map((regt) => DataRow(cells: [
                      DataCell(Text('${regt.terrain}')),
                      DataCell(Text('${regt.crop}')),
                      DataCell(Text('${regt.texto_status}')),
                      DataCell(Text('${regt.creation_stamp}')),
                    ])).toList(),
                  ),
                )
              ],
            ),
    );
  }
}