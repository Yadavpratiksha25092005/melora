/// Curated songs for the 5 fixed Home sections (Hindi / Indie, Bollywood
/// Style, Marathi Style, Punjabi, Lofi / Chill). No image assets — each
/// card is a simple gradient color box (see `categoryGradient` in
/// home_screen.dart), keyed off `category`.
class CuratedSong {
  final String id;
  final String title;
  final String fileUrl;
  final String category;

  const CuratedSong({
    required this.id,
    required this.title,
    required this.fileUrl,
    required this.category,
  });
}

class CuratedSection {
  final String title;
  final List<CuratedSong> songs;

  const CuratedSection({required this.title, required this.songs});
}

const List<CuratedSection> curatedHomeSections = [
  CuratedSection(
    title: 'Hindi / Indie',
    songs: [
      CuratedSong(
        id: 'curated_1',
        title: 'Dil Ki Baatein',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      category: 'Hindi / Indie',
      ),
      CuratedSong(
        id: 'curated_2',
        title: 'Safar',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      category: 'Hindi / Indie',
      ),
      CuratedSong(
        id: 'curated_3',
        title: 'Khwabon Mein',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      category: 'Hindi / Indie',
      ),
      CuratedSong(
        id: 'curated_4',
        title: 'Raat Bhar',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      category: 'Hindi / Indie',
      ),
      CuratedSong(
        id: 'curated_5',
        title: 'Tera Intezaar',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
      category: 'Hindi / Indie',
      ),
      CuratedSong(
        id: 'curated_6',
        title: 'Aasmaan',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
      category: 'Hindi / Indie',
      ),
      CuratedSong(
        id: 'curated_7',
        title: 'Chalte Chalte',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
      category: 'Hindi / Indie',
      ),
      CuratedSong(
        id: 'curated_8',
        title: 'Ishq Wali Baarish',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
      category: 'Hindi / Indie',
      ),
      CuratedSong(
        id: 'curated_9',
        title: 'Dil Se',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
      category: 'Hindi / Indie',
      ),
      CuratedSong(
        id: 'curated_10',
        title: 'Yaadein',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
      category: 'Hindi / Indie',
      ),
    ],
  ),
  CuratedSection(
    title: 'Bollywood Style',
    songs: [
      CuratedSong(
        id: 'curated_11',
        title: 'Bhula Dena',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',
      category: 'Bollywood Style',
      ),
      CuratedSong(
        id: 'curated_12',
        title: 'Bol Do Na Zara',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',
      category: 'Bollywood Style',
      ),
      CuratedSong(
        id: 'curated_13',
        title: 'Chahun Main Ya Naa',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3',
      category: 'Bollywood Style',
      ),
      CuratedSong(
        id: 'curated_14',
        title: 'Dilbar',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3',
      category: 'Bollywood Style',
      ),
      CuratedSong(
        id: 'curated_15',
        title: 'Main Rahoon Ya Na Rahoon',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3',
      category: 'Bollywood Style',
      ),
      CuratedSong(
        id: 'curated_16',
        title: 'O Saki Saki',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3',
      category: 'Bollywood Style',
      ),
      CuratedSong(
        id: 'curated_17',
        title: 'Sun Raha Hai Na Tu',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      category: 'Bollywood Style',
      ),
      CuratedSong(
        id: 'curated_18',
        title: 'Tum Hi Ho',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      category: 'Bollywood Style',
      ),
      CuratedSong(
        id: 'curated_19',
        title: 'Wajah Tum Ho',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      category: 'Bollywood Style',
      ),
      CuratedSong(
        id: 'curated_20',
        title: 'Ye Fitoor Mera',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      category: 'Bollywood Style',
      ),
    ],
  ),
  CuratedSection(
    title: 'Marathi Style',
    songs: [
      CuratedSong(
        id: 'curated_21',
        title: 'Mazha Swapna',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
      category: 'Marathi Style',
      ),
      CuratedSong(
        id: 'curated_22',
        title: 'Tu Majhi',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
      category: 'Marathi Style',
      ),
      CuratedSong(
        id: 'curated_23',
        title: 'Kokan Kinara',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
      category: 'Marathi Style',
      ),
      CuratedSong(
        id: 'curated_24',
        title: 'Premachi Goshta',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
      category: 'Marathi Style',
      ),
      CuratedSong(
        id: 'curated_25',
        title: 'Man Udhan',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
      category: 'Marathi Style',
      ),
      CuratedSong(
        id: 'curated_26',
        title: 'Sagar Kinari',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
      category: 'Marathi Style',
      ),
      CuratedSong(
        id: 'curated_27',
        title: 'Chandanyat',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',
      category: 'Marathi Style',
      ),
      CuratedSong(
        id: 'curated_28',
        title: 'Swapnatli Pari',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',
      category: 'Marathi Style',
      ),
      CuratedSong(
        id: 'curated_29',
        title: 'Aai Tuzi Athavan',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3',
      category: 'Marathi Style',
      ),
      CuratedSong(
        id: 'curated_30',
        title: 'Maharashtra Majha',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3',
      category: 'Marathi Style',
      ),
    ],
  ),
  CuratedSection(
    title: 'Punjabi',
    songs: [
      CuratedSong(
        id: 'curated_31',
        title: 'Desi Vibes',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3',
      category: 'Punjabi',
      ),
      CuratedSong(
        id: 'curated_32',
        title: 'Patola',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3',
      category: 'Punjabi',
      ),
      CuratedSong(
        id: 'curated_33',
        title: 'Dil Da King',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      category: 'Punjabi',
      ),
      CuratedSong(
        id: 'curated_34',
        title: 'Brown Munde Style',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      category: 'Punjabi',
      ),
      CuratedSong(
        id: 'curated_35',
        title: 'High Energy',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      category: 'Punjabi',
      ),
      CuratedSong(
        id: 'curated_36',
        title: 'Punjab Beats',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      category: 'Punjabi',
      ),
      CuratedSong(
        id: 'curated_37',
        title: 'Gallan',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
      category: 'Punjabi',
      ),
      CuratedSong(
        id: 'curated_38',
        title: 'Tere Naal',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
      category: 'Punjabi',
      ),
      CuratedSong(
        id: 'curated_39',
        title: 'Jatt Life',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
      category: 'Punjabi',
      ),
      CuratedSong(
        id: 'curated_40',
        title: 'Nachde',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
      category: 'Punjabi',
      ),
    ],
  ),
  CuratedSection(
    title: 'Lofi / Chill',
    songs: [
      CuratedSong(
        id: 'curated_41',
        title: 'Night Drive',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
      category: 'Lofi / Chill',
      ),
      CuratedSong(
        id: 'curated_42',
        title: 'Sunset Dreams',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
      category: 'Lofi / Chill',
      ),
      CuratedSong(
        id: 'curated_43',
        title: 'Coffee & Rain',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',
      category: 'Lofi / Chill',
      ),
      CuratedSong(
        id: 'curated_44',
        title: 'Calm Nights',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',
      category: 'Lofi / Chill',
      ),
      CuratedSong(
        id: 'curated_45',
        title: 'Chill Waves',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3',
      category: 'Lofi / Chill',
      ),
      CuratedSong(
        id: 'curated_46',
        title: 'Lost Memories',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3',
      category: 'Lofi / Chill',
      ),
      CuratedSong(
        id: 'curated_47',
        title: 'Peaceful Mind',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3',
      category: 'Lofi / Chill',
      ),
      CuratedSong(
        id: 'curated_48',
        title: 'City Lights',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3',
      category: 'Lofi / Chill',
      ),
      CuratedSong(
        id: 'curated_49',
        title: 'Dreamscape',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      category: 'Lofi / Chill',
      ),
      CuratedSong(
        id: 'curated_50',
        title: 'Ocean Breeze',
        fileUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      category: 'Lofi / Chill',
      ),
    ],
  ),
];