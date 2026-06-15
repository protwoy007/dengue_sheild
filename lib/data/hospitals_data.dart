class Hospital {
  final String nameEn, nameBn, address, phone;
  final double lat, lng;
  final String districtId;
  final bool isGovt;
  const Hospital({
    required this.nameEn, required this.nameBn,
    required this.address, required this.phone,
    required this.lat, required this.lng,
    required this.districtId, required this.isGovt,
  });
}

final List<Hospital> allHospitals = [
  Hospital(nameEn:"Dhaka Medical College Hospital",nameBn:"ঢাকা মেডিকেল কলেজ হাসপাতাল",address:"Secretariat Rd, Dhaka 1000",phone:"02-55165001",lat:23.7261,lng:90.3986,districtId:"dhaka",isGovt:true),
  Hospital(nameEn:"Sir Salimullah Medical College",nameBn:"স্যার সলিমুল্লাহ মেডিকেল কলেজ",address:"Mitford Rd, Dhaka 1100",phone:"02-57315001",lat:23.7099,lng:90.4071,districtId:"dhaka",isGovt:true),
  Hospital(nameEn:"Mugda Medical College Hospital",nameBn:"মুগদা মেডিকেল কলেজ হাসপাতাল",address:"Mugda, Dhaka 1214",phone:"02-7271001",lat:23.7456,lng:90.4312,districtId:"dhaka",isGovt:true),
  Hospital(nameEn:"Square Hospital",nameBn:"স্কয়ার হাসপাতাল",address:"18/F West Panthapath, Dhaka",phone:"02-8159457",lat:23.7515,lng:90.3864,districtId:"dhaka",isGovt:false),
  Hospital(nameEn:"Popular Medical Centre",nameBn:"পপুলার মেডিকেল সেন্টার",address:"Shyamoli, Dhaka 1207",phone:"02-9112011",lat:23.7741,lng:90.3588,districtId:"dhaka",isGovt:false),
  Hospital(nameEn:"Chittagong Medical College Hospital",nameBn:"চট্টগ্রাম মেডিকেল কলেজ হাসপাতাল",address:"K B Fazlul Kader Rd, Chittagong",phone:"031-619190",lat:22.3700,lng:91.8300,districtId:"chittagong",isGovt:true),
  Hospital(nameEn:"General Hospital Chittagong",nameBn:"জেনারেল হাসপাতাল চট্টগ্রাম",address:"Pahartali, Chittagong",phone:"031-752901",lat:22.3802,lng:91.7934,districtId:"chittagong",isGovt:true),
  Hospital(nameEn:"Chevron Clinical Laboratory",nameBn:"শেভ্রন ক্লিনিকাল ল্যাবরেটরি",address:"GEC Circle, Chittagong",phone:"031-2850999",lat:22.3602,lng:91.8147,districtId:"chittagong",isGovt:false),
  Hospital(nameEn:"Sylhet MAG Osmani Medical College",nameBn:"সিলেট এমএজি ওসমানী মেডিকেল কলেজ",address:"Sylhet 3100",phone:"0821-716475",lat:24.8972,lng:91.8687,districtId:"sylhet",isGovt:true),
  Hospital(nameEn:"Ibn Sina Hospital Sylhet",nameBn:"ইবনে সিনা হাসপাতাল সিলেট",address:"Ambarkhana, Sylhet",phone:"0821-724400",lat:24.8890,lng:91.8734,districtId:"sylhet",isGovt:false),
  Hospital(nameEn:"Rajshahi Medical College Hospital",nameBn:"রাজশাহী মেডিকেল কলেজ হাসপাতাল",address:"Rajshahi 6000",phone:"0721-772150",lat:24.3745,lng:88.6042,districtId:"rajshahi",isGovt:true),
  Hospital(nameEn:"Khulna Medical College Hospital",nameBn:"খুলনা মেডিকেল কলেজ হাসপাতাল",address:"Khan Jahan Ali Rd, Khulna",phone:"041-761001",lat:22.8167,lng:89.5644,districtId:"khulna",isGovt:true),
  Hospital(nameEn:"Sher-e-Bangla Medical College",nameBn:"শের-ই-বাংলা মেডিকেল কলেজ",address:"Barisal 8200",phone:"0431-62614",lat:22.7010,lng:90.3535,districtId:"barisal",isGovt:true),
  Hospital(nameEn:"Comilla Medical College Hospital",nameBn:"কুমিল্লা মেডিকেল কলেজ হাসপাতাল",address:"Comilla 3500",phone:"081-62614",lat:23.4607,lng:91.1809,districtId:"comilla",isGovt:true),
  Hospital(nameEn:"Mymensingh Medical College Hospital",nameBn:"ময়মনসিংহ মেডিকেল কলেজ হাসপাতাল",address:"Mymensingh 2200",phone:"091-52021",lat:24.7471,lng:90.4203,districtId:"mymensingh",isGovt:true),
  Hospital(nameEn:"Gazipur Sadar Hospital",nameBn:"গাজীপুর সদর হাসপাতাল",address:"Joydebpur, Gazipur",phone:"02-9261234",lat:24.0022,lng:90.4264,districtId:"gazipur",isGovt:true),
  Hospital(nameEn:"Narayanganj General Hospital",nameBn:"নারায়ণগঞ্জ জেনারেল হাসপাতাল",address:"Narayanganj 1400",phone:"02-7641234",lat:23.6238,lng:90.5000,districtId:"narayanganj",isGovt:true),
  Hospital(nameEn:"Rangpur Medical College Hospital",nameBn:"রংপুর মেডিকেল কলেজ হাসপাতাল",address:"Rangpur 5400",phone:"0521-63634",lat:25.7439,lng:89.2752,districtId:"rangpur",isGovt:true),
  Hospital(nameEn:"Cox\'s Bazar Sadar Hospital",nameBn:"কক্সবাজার সদর হাসপাতাল",address:"Cox\'s Bazar 4700",phone:"0341-62001",lat:21.4272,lng:92.0058,districtId:"coxsbazar",isGovt:true),
];

List<Hospital> getHospitalsSortedByDistance(String districtId, double userLat, double userLng) {
  final list = allHospitals.where((h) => h.districtId == districtId).toList();
  list.sort((a, b) {
    final da = _dist(userLat, userLng, a.lat, a.lng);
    final db = _dist(userLat, userLng, b.lat, b.lng);
    return da.compareTo(db);
  });
  return list;
}

double _dist(double lat1, double lng1, double lat2, double lng2) {
  final dlat = (lat2 - lat1).abs();
  final dlng = (lng2 - lng1).abs();
  return dlat * dlat + dlng * dlng;
}
