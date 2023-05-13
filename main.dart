//Kelompok 4
// Mochamad Khaairi - 2106416
//Muhammad Fikri Kafilli - 2107264

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

class UmkmModel {
  List<String> ListNama;
  List<String> ListJenis;
  List<String> ListID;
  UmkmModel(
      {required this.ListNama,
      required this.ListJenis,
      required this.ListID}); //constructor
}

class DetailModel {
  String nama;
  String jenis;
  String member_sejak;
  String omzet_bulan;
  String lama_usaha;
  String jumlah_pinjaman_sukses;
  DetailModel(
      {required this.nama,
      required this.jenis,
      required this.member_sejak,
      required this.omzet_bulan,
      required this.lama_usaha,
      required this.jumlah_pinjaman_sukses}); //constructor
}

class UmkmCubit extends Cubit<UmkmModel> {
  //inisialisasi untuk model / datanya
  UmkmCubit() : super(UmkmModel(ListNama: [], ListJenis: [], ListID: []));

  //map dari json ke atribut
  void setFromJson(Map<String, dynamic> json) {
    List<String> ListNama = <String>[];
    List<String> ListJenis = <String>[];
    List<String> ListID = <String>[];

    var data = json["data"];

    for (var val in data) {
      var nama = val["nama"];
      var jenis = val["jenis"];
      var id = val["id"];
      ListNama.add(nama);
      ListJenis.add(jenis);
      ListID.add(id);
    }
    //set data
    emit(UmkmModel(ListNama: ListNama, ListJenis: ListJenis, ListID: ListID));
  }

  void fetchData(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

class DetailCubit extends Cubit<DetailModel> {
  //inisialisasi untuk model / datanya
  DetailCubit()
      : super(DetailModel(
            nama: "",
            jenis: "",
            member_sejak: "",
            omzet_bulan: "",
            lama_usaha: "",
            jumlah_pinjaman_sukses: ""));

  //map dari json ke atribut
  void setFromJson(Map<String, dynamic> json) {
    String nama = json["nama"];
    String jenis = json["jenis"];
    String member_sejak = json["member_sejak"];
    String omzet_bulan = json["omzet_bulan"];
    String lama_usaha = json["lama_usaha"];
    String jumlah_pinjaman_sukses = json["jumlah_pinjaman_sukses"];
    //set data
    emit(DetailModel(
        nama: nama,
        jenis: jenis,
        member_sejak: member_sejak,
        omzet_bulan: omzet_bulan,
        lama_usaha: lama_usaha,
        jumlah_pinjaman_sukses: jumlah_pinjaman_sukses));
  }

  void fetchData(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MultiBlocProvider(
      providers: [
        BlocProvider<UmkmCubit>(
          create: (BuildContext context) => UmkmCubit(),
        ),
        BlocProvider<DetailCubit>(
          create: (BuildContext context) => DetailCubit(),
        ),
      ],
      child: const HalamanUtama(),
    ));
  }
}

class HalamanUtama extends StatelessWidget {
  const HalamanUtama({Key? key}) : super(key: key);
  @override
  Widget build(Object context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('My App')),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
            child: Text(
                "2106416, Mochamad Khaairi; 2107264, Muhammad Fikri Kafilli; Saya berjanji tidak akan berbuat curang data atau membantu orang lain berbuat curang"),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
            child: BlocBuilder<UmkmCubit, UmkmModel>(
              builder: (context, univ) {
                return ElevatedButton(
                  onPressed: () {
                    String url = "http://178.128.17.76:8000/daftar_umkm";
                    context.read<UmkmCubit>().fetchData(url);
                  },
                  child: const Text("Reload Daftar UMKM"),
                );
              },
            ),
          ),
          Expanded(child:
              BlocBuilder<UmkmCubit, UmkmModel>(builder: (context, umkm) {
            return ListView.builder(
              itemCount: umkm.ListNama.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return LayarKedua(
                          url:
                              "http://178.128.17.76:8000/detil_umkm/${umkm.ListID[index]}");
                    }));
                  },
                  child: Card(
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage('https://picsum.photos/200'),
                          ),
                        ),
                      ),
                      title: Text(umkm.ListNama[index]),
                      subtitle: Text(umkm.ListJenis[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () {
                          // Add your functionality here
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          }))
        ]),
      ),
    ));
  }
}

class LayarKedua extends StatelessWidget {
  const LayarKedua({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: const Text('Detil')),
        ),
        body: Column(
          children: [
            BlocBuilder<DetailCubit, DetailModel>(builder: (context, detil) {
              context.read<DetailCubit>().fetchData(url);

              return Column(
                children: [
                  Text("Nama: ${detil.nama}"),
                  Text("Jenis: ${detil.jenis}"),
                  Text("Member Sejak: ${detil.member_sejak}"),
                  Text("Omzet Bulan: ${detil.omzet_bulan}"),
                  Text("Lama Usaha: ${detil.lama_usaha}"),
                  Text(
                      "Jumlah Pinjaman Sukses: ${detil.jumlah_pinjaman_sukses}"),
                ],
              );
            })
          ],
        ));
  }
}
