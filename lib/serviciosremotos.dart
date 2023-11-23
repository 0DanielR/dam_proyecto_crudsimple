import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

var baseRemota = FirebaseFirestore.instance;

class DB{
  static Future insertar(Map<String,dynamic> REQUISICION)async{
    return await baseRemota.collection("REQUISICION").add(REQUISICION);
  }

  static Future<List> mostrarTodos() async {
    List tempora =[];
    var query =await baseRemota.collection("REQUISICION").get();
    query.docs.forEach((element) {
      Map<String,dynamic> data =element.data();
      data.addAll({'id':element.id});
      tempora.add(data);
    });
    return tempora;
  }

  static Future eliminar(String id ) async{
    return await baseRemota.collection("REQUISICION").doc(id).delete();
  }


  static Future actualizar(Map<String,dynamic> REQUISICION)async{
    String id=REQUISICION['id'];
    REQUISICION.remove('id');
    return await baseRemota.collection("REQUISICION").doc(id).update(REQUISICION);
  }


}