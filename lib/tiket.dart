import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tugas_3/main.dart';

void main() => runApp(const MyApp());

abstract class Tiket{
  String nama;
  double harga;

  Tiket({required this.nama, required this.harga});
  String deskripsi();
}
mixin BisaDiskon on Tiket{
  double diskon(double persen){
    if (persen < 0 || persen > 100){
    throw Exception('Diskon harus 0-100%');
  }
  return harga - harga * persen / 100;
  }
}
class TiketEkonomi extends Tiket with BisaDiskon{
  TiketEkonomi({required super.nama, required super.harga});
  @override
  String deskripsi() => 'kelas ekonomi - fasilitas standar';
}
class TiketVIP extends Tiket{
  TiketVIP({required super.nama, required super.harga});
  @override
  String deskripsi() => 'kelas VIP - fasilitas premium';

}
class TiketHabisException implements Exception{
  final String pesan;
  TiketHabisException(this.pesan);

}
Future<List<Tiket>>ambilTiket() async{
  await Future.delayed(const Duration(seconds: 2));
  return[
    TiketEkonomi(nama: 'manado - ternate', harga: 250000),
    TiketVIP(nama: 'manado - ternate', harga: 500000),
    TiketEkonomi(nama: 'ternate - jakarta', harga: 750000),
    TiketVIP(nama: 'jakarta - ternate', harga: 1200000),
  ];
}
Future<String>pesanTiket(Tiket tiket) async{
  await Future.delayed(const Duration(seconds: 2));
  int hasil = Random().nextInt(3);
  if(hasil == 1){
    throw TiketHabisException(
      'Tiket${tiket.nama} sedang habis.',
    );
  }
  if(hasil == 2){
    throw Exception('server error.coba lagi.');
  }
  return 'Tiket ${tiket.nama} berhasil dipesan!';
}
Stream<int>countdown() async*{
  for(int i = 30; i >= 0; i--){
    yield i;
    if(i > 0){
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
class MyApp extends StatelessWidget{
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TiketKu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
    ),
    home: const HomePage(),
    );
  }
}
class HomePage extends StatefulWidget{
  const HomePage({super.key});
  @override
  State<HomePage>createState() => _HomePageState();    
}
class _HomePageState extends State<HomePage>{
  late Future<List<Tiket>>tiket;
  @override
  void initState(){
    super.initState();
    tiket = ambilTiket();
  }
  String rupiah(double n) => 'Rp${n.toStringAsFixed(0)}';
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TiketKu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          StreamBuilder<int>(
            stream: countdown(),
            builder: (_, snap){
              if(!snap.hasData) return const SizedBox();
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_offer,
                      color: Colors.white,
                      size: 35,
                    ),
                    const Text(
                      'PROMO TIKET',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      snap.data! > 0
                      ? 'Berakhir ${snap.data} detik'
                      : 'Promo Berakhir',
                      style: const TextStyle(color:Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: FutureBuilder<List<Tiket>>(
              future: tiket,
              builder: (_, snap){
                if(snap.connectionState == ConnectionState.waiting){
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if(snap.hasError){
                  return Center(
                    child: ElevatedButton(
                      onPressed: (){
                        setState(() => tiket = ambilTiket());
                      },
                      child: const Text('coba lagi'), 
                    ),
                  );
                }
                final data = snap.data ?? [];
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: data.length,
                  itemBuilder: (_, i){
                    final t = data[i];
                    final vip = t is TiketVIP;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  child: Icon(
                                    vip
                                    ? Icons.star
                                    : Icons.confirmation_number,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    t.nama,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if(vip)
                                const Chip(
                                  label: Text('VIP'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(t.deskripsi()),
                            const SizedBox(height: 10),
                            Text(
                              rupiah(t.harga),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if(t is TiketEkonomi)
                            Text(
                              'Promo 10%:'
                              '${rupiah(t.diskon(10))}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PesanPage(tiket: t),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.shopping_cart,
                                ),
                                label: const Text('Pesan Tiket'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              
            ),
          ),
        ],
      ),
    );
  }

}
class PesanPage extends StatefulWidget{
  final Tiket tiket;
  const PesanPage({super.key, required this.tiket});
  @override
  State<PesanPage> createState() => _PesanPageState();
}
class _PesanPageState extends State<PesanPage>{
  bool loading = false;
  String pesan = '';
  String rupiah(double n) => 'Rp${n.toStringAsFixed(0)}';
  Future<void>proses()async{
    setState(() {
      loading = true;
      pesan = '';
    });
    try{
      pesan = await pesanTiket(widget.tiket);
    } on TiketHabisException catch (e){
      pesan = e.toString();
    }catch (e){
      pesan = 'pemesanan gagal: $e';
    }finally{
      setState(() => loading = false);
    }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Pemesanan Tiket')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Konfirmasi Pemesanan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tiket.nama,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(widget.tiket.deskripsi()),
                    const SizedBox(height: 10),
                    Text(
                      rupiah(widget.tiket.harga),
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if(pesan.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: pesan.contains('Berhasil')
                ?Colors.green.shade100
                :Colors.red.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                pesan,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: loading ? null : proses,
                icon: loading
                ?const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                : const Icon(Icons.payment),
                label: Text(
                  loading
                  ? 'Memproses...'
                  : 'Konfirmasi & Pesan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}