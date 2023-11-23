import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dam_proyectosimple/serviciosremotos.dart';

class AppTrabajo extends StatefulWidget {
  const AppTrabajo({Key? key}) : super(key: key);

  @override
  State<AppTrabajo> createState() => _AppTrabajoState();
}

class _AppTrabajoState extends State<AppTrabajo> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2, child: Scaffold(
      appBar: AppBar(
        title: const Text("Sistema de Requisiciones"), centerTitle: true,
        bottom: TabBar(
            tabs: [
              Icon(Icons.list_alt_sharp),
              Icon(Icons.add)
            ]),
      ),
      body: TabBarView(children:[
        verlista(),
        agregarReq()
      ]),
    )
    );
  }

  Widget verlista(){
    return FutureBuilder(
        future: DB.mostrarTodos(),
        builder: (context, listaJSON){
          if(listaJSON.hasData){
            return ListView.builder(
                itemCount: listaJSON.data?.length,
                itemBuilder: (context,indice){
                  return ListTile(
                    title: Text("${listaJSON.data?[indice]['persona']}"),
                    subtitle: Text("${listaJSON.data?[indice]['producto']} ${listaJSON.data?[indice]['precio']}"),
                    trailing: IconButton(onPressed: (){
                      DB.eliminar(listaJSON.data?[indice]['id']).then((value){
                        setState(() {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SE BORRO CON EXITO")));
                        });

                      });
                    }, icon: Icon(Icons.delete)),
                    onTap: (){
                      String id = listaJSON.data?[indice]['id'];
                      String persona = listaJSON.data?[indice]['persona'];
                      Timestamp fechapedA =listaJSON.data?[indice]['fechaped'];
                      DateTime fechaped = fechapedA.toDate();
                      bool comparado = listaJSON.data?[indice]['comprado'];
                      double precio = listaJSON.data?[indice]['precio'];
                      String producto = listaJSON.data?[indice]['producto'];
                      actualizar(id, comparado, fechaped, persona, precio, producto);
                    },
                    );
                }
            );
          }
          return Center(child: CircularProgressIndicator(),);
        }
    );
  }
  void actualizar(String id, bool comprado, DateTime fechaped, String persona, double precio, String producto){
      bool compradoB = comprado;
      final compradoA = TextEditingController();
      final fechapedA = TextEditingController();
      final personaA = TextEditingController();
      final productoA = TextEditingController();
      final precioA = TextEditingController();
      precioA.text=precio.toString();
      fechapedA.text=fechaped.toString();
      personaA.text=persona.toString();
      productoA.text=producto.toString();
      showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (builder){
            return ListView(
              padding: EdgeInsets.all(15),
              children: [
                TextField(
                  readOnly: true,
                  controller: personaA,
                  decoration: InputDecoration(labelText: "persona :"),
                ),
                SizedBox(height: 10,),
                TextField(
                  readOnly: true,
                  controller: fechapedA,
                  decoration: InputDecoration(labelText: "fecha pedido :"),
                ),
                SizedBox(height: 10,),
                TextField(
                  readOnly: true,
                  controller: productoA,
                  decoration: InputDecoration(labelText: "producto :"),
                ),
                SizedBox(height: 10,),
                TextField(
                  controller: precioA,
                  decoration: InputDecoration(labelText: "precio :"),
                ),
                SizedBox(height: 10,),
                DropdownButton(
                  items: [
                    DropdownMenuItem(child: Text("Comprado"),value: true,),
                    DropdownMenuItem(child: Text("Pendiente"),value: false,)
                  ],
                  onChanged:(value){
                    compradoB= value!;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(onPressed: (){
                      setState(() {
                        var JSONtemporal={
                          'id':id,
                          'comprado':compradoB,
                          'fechaped':fechaped,
                          'persona':persona,
                          'precio':double.parse(precioA.text),
                          'producto':producto
                        };
                        DB.actualizar(JSONtemporal).then((value){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SE ACTUALIZO CON EXITO")));
                          Navigator.of(context).pop();
                        });
                      });
                    }, child: Text("ACTUALIZAR")),
                    ElevatedButton(onPressed: (){
                      Navigator.of(context).pop();
                    }, child: Text("CANCELAR"))
                  ],
                )
              ],
            );
          }
      );
  }
  Widget agregarReq(){
    bool? comprado = true;//bolean
    final fechaped = TextEditingController();//date - Timestamp
    final persona = TextEditingController(); //string
    final precio = TextEditingController();//double
    final producto = TextEditingController();//string
    return ListView(
      padding: EdgeInsets.all(30),
      children: [
        TextField(decoration: InputDecoration( labelText: "persona :" ),controller: persona,),
        SizedBox(height: 20,),
        TextField(decoration: InputDecoration( labelText: "precio :" ),controller: precio,),
        SizedBox(height: 20,),
        TextField(decoration: InputDecoration( labelText: "producto :" ),controller: producto,),
        SizedBox(height: 20,),

        DropdownButton(
          items: [
            DropdownMenuItem(child: Text("Comprado"),value: true,),
            DropdownMenuItem(child: Text("Pendiente"),value: false,)
          ],
          onChanged:(value){
            comprado= value;
          },
        ),
        ElevatedButton(onPressed: (){
          var JSonTemporal={
            'persona': persona.text,
            'comprado':comprado,
            'fechaped': DateTime.now(),
            'precio': double.parse(precio.text),
            'producto': producto.text
          };
          DB.insertar(JSonTemporal).then((value){

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SE INSERTÓ CON EXITO")));
              persona.clear();
              precio.clear();
              producto.clear();
          });
        }, child: Text("Insertar"))
      ]
    );
  }
}
