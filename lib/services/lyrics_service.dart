import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

class Lyrics {
  Lyrics({delimiter1, delimiter2}) {
    setDelimiters(delimiter1: delimiter1, delimiter2: delimiter2);
  }

  final String _url =
      'https://www.google.com/search?client=safari&rls=en&ie=UTF-8&oe=UTF-8&q=';
  String _delimiter1 =
      '</div></div></div></div><div class="hwc"><div class="BNeawe tAd8D AP7Wnd"><div><div class="BNeawe tAd8D AP7Wnd">';
  String _delimiter2 =
      '</div></div></div></div></div><div><span class="hwc"><div class="BNeawe uEec3 AP7Wnd">';

  void setDelimiters({String? delimiter1, String? delimiter2}) {
    _delimiter1 = delimiter1 ?? _delimiter1;
    _delimiter2 = delimiter2 ?? _delimiter2;
  }

  Future<String> getLyrics({String? track, String? artist}) async {
    if (track == null || artist == null)
      throw Exception('track and artist must not be null');

    String lyrics;

    print(Uri.parse(Uri.encodeFull('$_url$track by $artist lyrics')));

    // try multiple queries
    try {
      final url =
          'https://musixmatch-lyrics-songs.p.rapidapi.com/songs/lyrics?t=$track&a=$artist&type=json';
      final response = await http.get(
        Uri.parse(Uri.encodeFull(url)),
        headers: {
          'X-RapidAPI-Key':
              '7cdd1db7d1msh5cbca7730cc7a9dp1a8428jsncebc22579f9c',
          'X-RapidAPI-Host': 'musixmatch-lyrics-songs.p.rapidapi.com',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('lyrics = $jsonData');
        lyrics = '';
        for (var i = 0; i < jsonData.length; i++) {
          lyrics += jsonData[i]['text'] + '\n';
        }
      } else {
        throw Error();
      }
    } catch (_) {
      try {
        final response = await http.get(
          Uri.parse(Uri.encodeFull(
              'http://api.chartlyrics.com/apiv1.asmx/SearchLyricDirect?artist=$artist&song=$track}')),
        );
        print('response = ${response.body}');
        if (response.statusCode == 200) {
          final myTransformer = Xml2Json();
          final jsonData = myTransformer.toParker();
          print('parsed = $jsonData');
          lyrics = json.decode(jsonData)['GetLyricResult']['Lyric'];
          if (lyrics.isEmpty) {
            throw Error();
          }
          lyrics = lyrics.replaceAll('\\r', '').replaceAll('\\\\n', '\n');
          print('lyric = $lyrics');
        } else {
          throw Error();
        }
      } catch (_) {
        try {
          lyrics = (await http.get(
                  Uri.parse(Uri.encodeFull('$_url$track by $artist lyrics'))))
              .body;
          lyrics = lyrics.split(_delimiter1).last;
          lyrics = lyrics.split(_delimiter2).first;
          if (lyrics.contains('<meta charset="UTF-8">')) throw Error();
        } catch (_) {
          try {
            lyrics = (await http.get(
              Uri.parse(
                Uri.encodeFull('$_url$track by $artist song lyrics'),
              ),
            ))
                .body;
            lyrics = lyrics.split(_delimiter1).last;
            lyrics = lyrics.split(_delimiter2).first;
            if (lyrics.contains('<meta charset="UTF-8">')) throw Error();
          } catch (_) {
            try {
              lyrics = (await http.get(
                Uri.parse(
                  Uri.encodeFull(
                    '$_url${track.split("-").first} by $artist lyrics',
                  ),
                ),
              ))
                  .body;
              lyrics = lyrics.split(_delimiter1).last;
              lyrics = lyrics.split(_delimiter2).first;
              if (lyrics.contains('<meta charset="UTF-8">')) throw Error();
            } catch (_) {
              // give up
              return 'not found';
            }
          }
        }
      }
    }

    final split = lyrics.split('\n');
    var result = '';
    for (var i = 0; i < split.length; i++) {
      result = '$result${split[i]}\n';
    }
    return result.trim();
  }
}
