import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:Melora/models/song.dart';
import 'package:Melora/services/song_service.dart';
import 'package:Melora/repositories/song_repository.dart';

class MockSongService extends Mock implements SongService {}

void main() {
  late MockSongService mockService;
  late SongRepository repository;

  setUp(() {
    mockService = MockSongService();
    repository = SongRepository(service: mockService);
  });

  test('getSongs returns list of songs from service', () async {
    final songs = [
      Song(
        id: '1',
        artistId: 'a1',
        title: 'Test Song',
        durationMs: 200000,
        fileUrl: 'https://example.com/song.mp3',
      ),
    ];

    when(() => mockService.fetchSongs(limit: 20, offset: 0))
        .thenAnswer((_) async => songs);

    final result = await repository.getSongs();

    expect(result, songs);
    verify(() => mockService.fetchSongs(limit: 20, offset: 0)).called(1);
  });
}