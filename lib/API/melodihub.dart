import 'dart:convert';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:melodihub/helper/formatter.dart';
import 'package:melodihub/helper/mediaitem.dart';
import 'package:melodihub/services/audio_handler.dart';
import 'package:melodihub/services/audio_manager.dart';
import 'package:melodihub/services/data_manager.dart';
import 'package:melodihub/services/ext_storage.dart';
import 'package:melodihub/services/lyrics_service.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final yt = YoutubeExplode();
final OnAudioQuery _audioQuery = OnAudioQuery();
const apiKey = 'AIzaSyDuBfsxBK4LvSmpQLm1sJfmnthEpV76L5k';

final random = Random();

List playlists = [];
List userPlaylists = Hive.box('user').get('playlists', defaultValue: []);
List userLikedSongsList = Hive.box('user').get('likedSongs', defaultValue: []);
List suggestedPlaylists = [];
List activePlaylist = [];

final lyrics = ValueNotifier<String>('null');
String lastFetchedLyrics = 'null';

int id = 0;

Future<List> fetchSongsList(String searchQuery) async {
  final List list = await yt.search.search(searchQuery);
  final searchedList = [
    for (final s in list)
      returnSongLayout(
        0,
        s,
      ),
  ];

  return searchedList;
}

Future get10Music(dynamic playlistid) async {
  final List playlistSongs =
      await getData('cache', 'playlist10Songs$playlistid') ?? [];
  if (playlistSongs.isEmpty) {
    var index = 0;
    await for (final song in yt.playlists.getVideos(playlistid).take(10)) {
      playlistSongs.add(
        returnSongLayout(
          index,
          song,
        ),
      );
      index += 1;
    }

    addOrUpdateData('cache', 'playlist10Songs$playlistid', playlistSongs);
  }

  return playlistSongs;
}

Future<List<dynamic>> getUserPlaylists() async {
  final playlistsByUser = [];
  for (final playlistID in userPlaylists) {
    final plist = await yt.playlists.get(playlistID);
    playlistsByUser.add({
      'ytid': plist.id,
      'title': plist.title,
      'subtitle': 'Just Updated',
      'header_desc': plist.description.length < 120
          ? plist.description
          : plist.description.substring(0, 120),
      'type': 'playlist',
      'image': '',
      'list': [],
    });
  }
  return playlistsByUser;
}

String addUserPlaylist(String playlistId, BuildContext context) {
  if (playlistId.length != 34) {
    return '${AppLocalizations.of(context)!.notYTlist}!';
  } else {
    userPlaylists.add(playlistId);
    addOrUpdateData('user', 'playlists', userPlaylists);
    return '${AppLocalizations.of(context)!.addedSuccess}!';
  }
}

void removeUserPlaylist(String playlistId) {
  userPlaylists.remove(playlistId);
  addOrUpdateData('user', 'playlists', userPlaylists);
}

Future<void> addUserLikedSong(dynamic songId) async {
  userLikedSongsList
      .add(await getSongDetails(userLikedSongsList.length, songId));
  addOrUpdateData('user', 'likedSongs', userLikedSongsList);
}

void removeUserLikedSong(dynamic songId) {
  userLikedSongsList.removeWhere((song) => song['ytid'] == songId);
  addOrUpdateData('user', 'likedSongs', userLikedSongsList);
}

bool isSongAlreadyLiked(dynamic songId) {
  return userLikedSongsList.where((song) => song['ytid'] == songId).isNotEmpty;
}

Future<List> getPlaylists([int? playlistsNum]) async {
  final List cachedPlaylists = await getData('cache', 'playlists') ?? [];
  if (cachedPlaylists.isNotEmpty) {
    return cachedPlaylists;
  }

  final response = await http.get(
    Uri.parse(
      'https://www.googleapis.com/youtube/v3/search?part=snippet&type=playlist&q=music&maxResults=$playlistsNum&order=relevance&relevanceLanguage=en&regionCode=us&key=$apiKey',
    ),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    suggestedPlaylists = data['items']
        .map<Map<String, dynamic>>(
          (item) => {
            'ytid': item['id']['playlistId'],
            'title': item['snippet']['title'],
            'subtitle': item['snippet']['description'],
            'header_desc': item['snippet']['channelTitle'],
            'type': 'playlist',
            'image': item['snippet']['thumbnails']['high']['url'],
            'list': [],
          },
        )
        .toList();
    addOrUpdateData('cache', 'playlists', suggestedPlaylists);
    return suggestedPlaylists;
  } else {
    if (playlists.isEmpty) {
      playlists = json.decode(
        await rootBundle.loadString('assets/db/playlists.db.json'),
      ) as List;
    }

    if (playlistsNum != null) {
      if (suggestedPlaylists.isEmpty) {
        suggestedPlaylists =
            (playlists.toList()..shuffle()).take(playlistsNum).toList();
      }
      addOrUpdateData('cache', 'playlists', suggestedPlaylists);
      return suggestedPlaylists;
    } else {
      addOrUpdateData('cache', 'playlists', playlists);
      return playlists;
    }
  }
}

Future<List> searchPlaylist(String query) async {
  final response = await http.get(
    Uri.parse(
      Uri.encodeFull(
          'https://www.googleapis.com/youtube/v3/search?part=snippet&type=playlist&q=music $query&maxResults=100&order=relevance&relevanceLanguage=en&regionCode=us&key=$apiKey'),
    ),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    suggestedPlaylists = data['items']
        .map<Map<String, dynamic>>(
          (item) => {
            'ytid': item['id']['playlistId'],
            'title': item['snippet']['title'],
            'subtitle': item['snippet']['description'],
            'header_desc': item['snippet']['channelTitle'],
            'type': 'playlist',
            'image': item['snippet']['thumbnails']['high']['url'],
            'list': [],
          },
        )
        .toList();
    addOrUpdateData('cache', 'playlists', suggestedPlaylists);
    return suggestedPlaylists;
  } else {
    if (playlists.isEmpty) {
      playlists = json.decode(
          await rootBundle.loadString('assets/db/playlists.db.json')) as List;
    }

    return playlists
        .where(
          (playlist) =>
              playlist['title'].toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}

Future<Map> getRandomSong() async {
  const playlistId = 'PLgzTt0k8mXzEk586ze4BjvDXR7c-TUSnx';
  final List playlistSongs = await getSongsFromPlaylist(playlistId);

  return playlistSongs[random.nextInt(playlistSongs.length)];
}

Future getSongsFromPlaylist(dynamic playlistid) async {
  final List playlistSongs =
      await getData('cache', 'playlistSongs$playlistid') ?? [];
  if (playlistSongs.isEmpty) {
    print('playlistId = $playlistid');
    var index = 0;
    await for (final song in yt.playlists.getVideos(playlistid)) {
      playlistSongs.add(
        returnSongLayout(
          index,
          song,
        ),
      );
      index += 1;
    }
    addOrUpdateData('cache', 'playlistSongs$playlistid', playlistSongs);
  }

  return playlistSongs;
}

Future<void> setActivePlaylist(List plist) async {
  if (plist is List<SongModel>) {
    activePlaylist = [];
    id = 0;
    final activeTempPlaylist = <MediaItem>[
      for (final song in plist) songModelToMediaItem(song, song.data),
    ];

    await MyAudioHandler().addQueueItems(activeTempPlaylist);

    play();
  } else {
    activePlaylist = plist;
    id = 0;
    await playSong(activePlaylist[id]);
  }
}

Future getPlaylistInfoForWidget(dynamic id) async {
  print('id = $id');
  var searchPlaylist = playlists.where((list) => list['ytid'] == id).toList();
  var isUserPlaylist = false;

  if (searchPlaylist.isEmpty) {
    final usPlaylists = await getUserPlaylists();
    searchPlaylist = usPlaylists.where((list) => list['ytid'] == id).toList();
    isUserPlaylist = true;
  }

  if (searchPlaylist.isEmpty) {
    final playlist = await getSongsFromPlaylist(id);
    return playlist;
  } else {
    final playlist = searchPlaylist[0];

    if (playlist['list'].length == 0) {
      searchPlaylist[searchPlaylist.indexOf(playlist)]['list'] =
          await getSongsFromPlaylist(playlist['ytid']);
      if (!isUserPlaylist) {
        playlists[playlists.indexOf(playlist)]['list'] =
            searchPlaylist[searchPlaylist.indexOf(playlist)]['list'];
      }
    }
    return playlist;
  }
}

Future<dynamic> getSong(dynamic songId, bool geturl) async {
  final manifest = await yt.videos.streamsClient.getManifest(songId);
  if (geturl) {
    return manifest.audioOnly.withHighestBitrate().url.toString();
  } else {
    return manifest.audioOnly.withHighestBitrate();
  }
}

Future getSongDetails(dynamic songIndex, dynamic songId) async {
  final song = await yt.videos.get(songId);
  return returnSongLayout(
    songIndex,
    song,
  );
}

Future<List<SongModel>> getLocalSongs() async {
  var localSongs = <SongModel>[];
  if (await ExtStorageProvider.requestPermission(Permission.storage)) {
    localSongs = await _audioQuery.querySongs(
      path: await ExtStorageProvider.getExtStorage(dirName: 'Music'),
    );
  }

  return localSongs;
}

Future<List<Map<String, int>>> getSkipSegments(String id) async {
  try {
    final res = await http.get(
      Uri(
        scheme: 'https',
        host: 'sponsor.ajay.app',
        path: '/api/skipSegments',
        queryParameters: {
          'videoID': id,
          'category': [
            'sponsor',
            'selfpromo',
            'interaction',
            'intro',
            'outro',
            'music_offtopic',
          ],
          'actionType': 'skip',
        },
      ),
    );
    if (res.body != 'Not Found') {
      final data = jsonDecode(res.body);
      final segments = data.map((obj) {
        return Map.castFrom<String, dynamic, String, int>({
          'start': obj['segment'].first.toInt(),
          'end': obj['segment'].last.toInt(),
        });
      }).toList();
      return List.castFrom<dynamic, Map<String, int>>(segments);
    } else {
      return [];
    }
  } catch (e, stack) {
    debugPrint('$e $stack');
    return [];
  }
}

Future getSongLyrics(String artist, String title) async {
  if (lastFetchedLyrics != '$artist - $title') {
    lyrics.value = 'null';
    final _lyrics = await Lyrics().getLyrics(artist: artist, track: title);
    lyrics.value = _lyrics;
    lastFetchedLyrics = '$artist - $title';
    return _lyrics;
  }

  return lyrics.value;
}
