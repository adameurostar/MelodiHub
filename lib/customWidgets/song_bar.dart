import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:melodihub/API/melodihub.dart';
import 'package:melodihub/services/audio_manager.dart';
import 'package:melodihub/services/download_manager.dart';
import 'package:melodihub/style/appTheme.dart';

class SongBar extends StatelessWidget {
  SongBar(this.song, this.moveBackAfterPlay, {super.key});

  late final dynamic song;
  late final bool moveBackAfterPlay;
  late final songLikeStatus =
      ValueNotifier<bool>(isSongAlreadyLiked(song['ytid']));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 15),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          playSong(song);
          if (activePlaylist.isNotEmpty) {
            activePlaylist = [];
            id = 0;
          }
          if (moveBackAfterPlay) {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
        splashColor: accent.primary.withOpacity(0.4),
        hoverColor: accent.primary.withOpacity(0.4),
        focusColor: accent.primary.withOpacity(0.4),
        highlightColor: accent.primary.withOpacity(0.4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            CachedNetworkImage(
              width: 60,
              height: 60,
              imageUrl: song['lowResImage'].toString(),
              imageBuilder: (context, imageProvider) => DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: imageProvider,
                    centerSlice: const Rect.fromLTRB(1, 1, 1, 1),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      HtmlUnescape().convert(song['title']),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: accent.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'BebasNeueRegular',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      HtmlUnescape()
                          .convert(song['more_info']['singers'].toString()),
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        fontFamily: 'BebasNeueRegular',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: songLikeStatus,
                  builder: (_, value, __) {
                    if (value == true) {
                      return IconButton(
                        color: accent.primary,
                        icon: Icon(MdiIcons.star),
                        onPressed: () => {
                          removeUserLikedSong(song['ytid']),
                          songLikeStatus.value = false,
                        },
                      );
                    } else {
                      return IconButton(
                        color: accent.primary,
                        icon: Icon(MdiIcons.starOutline),
                        onPressed: () => {
                          addUserLikedSong(song['ytid']),
                          songLikeStatus.value = true,
                        },
                      );
                    }
                  },
                ),
                IconButton(
                  color: accent.primary,
                  icon: Icon(MdiIcons.downloadOutline),
                  onPressed: () => downloadSong(context, song),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
