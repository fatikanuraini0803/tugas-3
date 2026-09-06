class StokHabisException implements Exception{
  String pesan;
  StokHabisException(this.pesan);
  String toString() => 'StokHabisException: $pesan';
}
class ProdukTidakAda implements Exception{
  String pesan;
  ProdukTidakAda(this.pesan);
  String toString() => 'ProdukTidakAda: $pesan';

}
abstract class Produk{
  String id, nama;
  double harga;
  int stok;
  Produk(this.id, this.nama, this.harga, this.stok);
  String deskripsi();
  void kurangiStok(int jumlah){
    if(jumlah <= 0) throw Exception('jumlah harus lebih dari 0');
    if(stok < jumlah) throw StokHabisException('stok $nama tidak cukup');
    stok -= jumlah;
  }
}
mixin BisaDiskon on Produk{
  double diskon(double persen){
    if(persen < 0 || persen > 100){
    throw Exception('Diskon 0-100%');

    }
    return harga - (harga * persen / 100);
    
  }
  
}
class ProdukDigital extends Produk with BisaDiskon {
  double ukuran;
  String format;
  ProdukDigital(
    String id, String nama, double harga, int stok, this.ukuran, this.format,
  ): super(id, nama, harga, stok);
  String deskripsi() => 'Digital: $nama |Rp${harga.toStringAsFixed(0)} | Stok: $stok | $ukuran MB |$format';

}
class ProdukFisik extends Produk with BisaDiskon{
double berat;
String dimensi;
ProdukFisik(
String id, String nama, double harga, int stok, this.berat, this.dimensi
): super(id, nama, harga, stok);
String deskripsi() => 'Fisik: $nama |Rp${harga.toStringAsFixed(0)} | Stok: $stok | $berat gram |$dimensi';

}
class Keranjang{
  List<Produk> produk = [];
  void tambah(Produk p){
    if(p.stok <= 0) 
    throw StokHabisException('$p habis');
    produk.add(p);
    print('($p.nama) ditambahkan');
  }
  double total() => produk.fold(0,(sum, p) => sum + p.harga);
  void tampilkan(){
    for(var p in produk) 
    print ('Total: Rp${total()}');
  }
  
}
class TokoService{
  List<Produk> produk;
  TokoService(this.produk);
  Produk cari(String id){
    for(var p in produk){
      if(p.id == id) return p;
    }
    throw ProdukTidakAda('produk tidak ditemukan');
  }
  Future<void> checkout(Keranjang k) async{
    if(k.produk.isEmpty)
    throw Exception('keranjang kosong');
    print('Memeriksa stok...');
    await Future.delayed(Duration(seconds: 1));
    print('pembayaran berhasil');
    print('total: rp${k.total()}');

  }
}
void main() async{
  var ebook = ProdukDigital(
    'D001', 'ebook dart', 50000, 10, 15.5, 'PDF');
  var mouse = ProdukFisik(
    'F002', 'mouse wirelees', 150000, 8, 100, '10 x 6 x 4 cm');
  var toko = TokoService([ebook, mouse]);
  for(var p in toko.produk) print(p.deskripsi());
  print('Diskon ebook: Rp${ebook.diskon(20)}');
  print('Ditemukan: ${toko.cari('F002').nama}');
  var keranjang = Keranjang();
  keranjang.tambah(ebook);
  keranjang.tambah(mouse);
  keranjang.tampilkan();
  await toko.checkout(keranjang);
  for(var p in toko.produk){
    print('${p.nama}: ${p.stok}stok');
  }
  
}
