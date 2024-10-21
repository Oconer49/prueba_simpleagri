import 'package:flutter/material.dart';
import 'package:prueba_simpleagri/conexion/servicio.dart';
import 'package:prueba_simpleagri/model/terrenos.dart';

class ControladorTerrenos {
  CallService controlador = CallService();
  Future<List<ObjetoTerreno>> listadoTabla({required BuildContext context}) async {
    var resultado = await controlador.callMethod("PruebaTecnica", "obtener_terrenos", Map());
    List<ObjetoTerreno> listado_terreno = [];

    for (var registros in resultado) {
      ObjetoTerreno regtro = ObjetoTerreno.fromJson(registros);

      switch (regtro.status) {
        case "0":
          regtro.texto_status = "Activo";
          break;
        case "1":
          regtro.texto_status = "Inactivo";
          break;
        case "2":
          regtro.texto_status = "Cerrado";
          break;
      }

      listado_terreno.add(regtro);
    }

    return listado_terreno;
  }

Future<List<ObjetoTerreno>> consultar({required BuildContext context, required String texto_busqueda}) async {
    Map<String, dynamic> parametros = {
        "nombre": texto_busqueda,
        "codigo": texto_busqueda
    };

    var resultado = await controlador.callMethod("PruebaTecnica", "cultar_terrenos", parametros);
    List<ObjetoTerreno> lista_resultado = [];
    for (var registros in resultado) {
        ObjetoTerreno regtro = ObjetoTerreno.fromJson(registros);
        switch (regtro.status) {
            case "0":
                regtro.texto_status = "Activo";
                break;
            case "1":
                regtro.texto_status = "Inactivo";
                break;
            case "2":
                regtro.texto_status = "Cerrado";
                break;
        }

        lista_resultado.add(regtro);
    }
    return lista_resultado;
}
}