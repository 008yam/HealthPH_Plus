class AddressHierarchy {
  // Representative address hierarchy used by registration and self-report forms.
  static const Map<String, Map<String, Map<String, List<String>>>> data = {
    "NCR": {
      "Metro Manila": {
        "Manila": ["Barangay 659", "Barangay 699", "Barangay 734"],
        "Quezon City": ["Batasan Hills", "Commonwealth", "Bagong Silangan"],
        "Taguig": ["Fort Bonifacio", "Western Bicutan", "Ususan"],
      },
    },
    "I": {
      "Ilocos Norte": {
        "Laoag City": ["Barangay 1", "Barangay 17", "Barangay 48-A"],
        "Batac City": ["Ablan Sarat", "Payao", "Valdez"],
      },
      "La Union": {
        "San Fernando City": ["Barangay I", "Barangay II", "Catbangen"],
        "Agoo": ["Nazareno", "Poblacion", "San Nicolas East"],
      },
    },
    "II": {
      "Cagayan": {
        "Tuguegarao City": ["Atulayan", "Carig", "Ugac Norte"],
        "Aparri": ["Bangag", "Centro 1", "Maura"],
      },
      "Isabela": {
        "Ilagan City": ["Alibagu", "Bagong Silang", "San Rafael"],
        "Santiago City": ["Balintocatoc", "Dubinan East", "Mabini"],
      },
    },
    "III": {
      "Bulacan": {
        "Malolos": ["Bagna", "Mojon", "Santo Rosario"],
        "San Jose del Monte": ["Assumption", "Minuyan", "Poblacion"],
      },
      "Pampanga": {
        "Angeles City": ["Balibago", "Cutcut", "Pampang"],
        "San Fernando City": ["Del Pilar", "Lourdes", "Sto. Nino"],
      },
    },
    "IVA": {
      "Laguna": {
        "Calamba City": ["Banadero", "Canlubang", "Real"],
        "Santa Rosa": ["Aplaya", "Balibago", "Tagapo"],
      },
      "Batangas": {
        "Batangas City": ["Alangilan", "Kumintang Ilaya", "Pallocan"],
        "Lipa City": ["Balintawak", "Sabang", "Tambo"],
      },
    },
    "V": {
      "Albay": {
        "Legazpi City": ["Bitano", "Buraguis", "Puro"],
        "Tabaco City": ["Basud", "San Vicente", "Tagas"],
      },
      "Camarines Sur": {
        "Naga City": ["Concepcion Grande", "Dayangdang", "Tinago"],
        "Iriga City": ["La Purisima", "San Nicolas", "Santiago"],
      },
    },
    "VI": {
      "Iloilo": {
        "Iloilo City": ["Jaro", "La Paz", "Mandurriao"],
        "Passi City": ["Aglalana", "Badiangan", "Buenavista"],
      },
      "Negros Occidental": {
        "Bacolod City": ["Alijis", "Mansilingan", "Taculing"],
        "Bago City": ["Abuanan", "Atipuluan", "Ma-ao"],
      },
    },
    "VII": {
      "Cebu": {
        "Cebu City": ["Apas", "Lahug", "Mabolo"],
        "Mandaue City": ["Bakilid", "Centro", "Subangdaku"],
      },
      "Bohol": {
        "Tagbilaran City": ["Bool", "Cogon", "Dao"],
        "Tubigon": ["Bagongbanwa", "Centro", "Pooc Occidental"],
      },
    },
    "VIII": {
      "Leyte": {
        "Tacloban City": ["San Jose", "Sagkahan", "Marasbaras"],
        "Ormoc City": ["Cogon", "Linao", "Naungan"],
      },
      "Samar": {
        "Catbalogan City": ["Bunuanan", "Guindapunan", "Payao"],
        "Calbayog City": ["Aguit-itan", "Balud", "East Awang"],
      },
    },
    "IX": {
      "Zamboanga del Sur": {
        "Pagadian City": ["Balangasan", "Gubac", "San Jose"],
        "Zamboanga City": ["Ayala", "Guiwan", "Tetuan"],
      },
      "Zamboanga Sibugay": {
        "Ipil": ["Bacalan", "Logan", "Poblacion"],
        "Kabasalan": ["Calapan", "Goodyear", "Sanghan"],
      },
    },
    "X": {
      "Misamis Oriental": {
        "Cagayan de Oro": ["Balulang", "Carmen", "Lapasan"],
        "Gingoog City": ["Bagubad", "Binuangan", "Tinabalan"],
      },
      "Bukidnon": {
        "Malaybalay City": ["Aglayan", "Bangcud", "Sumpong"],
        "Valencia City": ["Bagontaas", "Lilingayon", "Poblacion"],
      },
    },
    "XI": {
      "Davao del Sur": {
        "Davao City": ["Buhangin", "Mintal", "Talomo"],
        "Digos City": ["Aplaya", "San Agustin", "Tres de Mayo"],
      },
      "Davao del Norte": {
        "Tagum City": ["Apokon", "Canocotan", "Mankilam"],
        "Panabo City": ["Cacao", "J.P. Laurel", "San Pedro"],
      },
    },
    "XII": {
      "South Cotabato": {
        "Koronadal City": ["Cacub", "General Paulino Santos", "Mabini"],
        "General Santos City": ["Bula", "Lagao", "San Isidro"],
      },
      "Sultan Kudarat": {
        "Tacurong City": ["Buenaflor", "Poblacion", "San Emmanuel"],
        "Isulan": ["Bambad", "Kalawag II", "Tinaungan"],
      },
    },
    "XIII": {
      "Agusan del Norte": {
        "Butuan City": ["Ampayon", "Baan", "Libertad"],
        "Cabadbaran City": ["Bayabas", "Comagascas", "Kauswagan"],
      },
      "Surigao del Norte": {
        "Surigao City": ["Canlanipa", "Taft", "Washington"],
        "Siargao": ["Catangnan", "Dapa", "Poblacion"],
      },
    },
    "CAR": {
      "Benguet": {
        "Baguio City": ["Irisan", "Loakan", "Session Road Area"],
        "La Trinidad": ["Balili", "Pico", "Poblacion"],
      },
      "Mountain Province": {
        "Bontoc": ["Can-eo", "Poblacion", "Samoki"],
        "Sabangan": ["Bagnen", "Poblacion", "Supang"],
      },
    },
    "BARMM": {
      "Maguindanao del Norte": {
        "Cotabato City": ["Bagua I", "Kalanganan Mother", "Rosary Heights"],
        "Datu Odin Sinsuat": ["Awang", "Dalican", "Semba"],
      },
      "Lanao del Sur": {
        "Marawi City": ["Bangon", "Basak Malutlut", "Datu sa Dansalan"],
        "Wao": ["Balatin", "Eastern Wao", "West Kilikili"],
      },
    },
  };

  static List<String> get regions => List<String>.unmodifiable(data.keys);

  static List<String> provincesFor(String? region) {
    if (region == null) return const <String>[];
    final provinces = data[region];
    if (provinces == null) return const <String>[];
    return List<String>.unmodifiable(provinces.keys);
  }

  static List<String> citiesFor(String? region, String? province) {
    if (region == null || province == null) return const <String>[];
    final cities = data[region]?[province];
    if (cities == null) return const <String>[];
    return List<String>.unmodifiable(cities.keys);
  }

  static List<String> barangaysFor(
    String? region,
    String? province,
    String? city,
  ) {
    if (region == null || province == null || city == null) {
      return const <String>[];
    }
    final barangays = data[region]?[province]?[city];
    if (barangays == null) return const <String>[];
    return List<String>.unmodifiable(barangays);
  }
}
