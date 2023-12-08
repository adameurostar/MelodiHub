import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:just_audio/just_audio.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:melodihub/helper/flutter_toast.dart';
import 'package:melodihub/helper/version.dart';
import 'package:melodihub/services/audio_manager.dart';
import 'package:melodihub/style/appTheme.dart';
import 'package:melodihub/ui/homePage.dart';
import 'package:melodihub/ui/morePage.dart';
import 'package:melodihub/ui/player.dart';
import 'package:melodihub/ui/playlistsPage.dart';
import 'package:melodihub/ui/searchPage.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:ultimate_bottom_navbar/ultimate_bottom_navbar.dart';

class MelodiHub extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppState();
  }
}

ValueNotifier<int> activeTab = ValueNotifier<int>(0);

class AppState extends State<MelodiHub> {
  var brightness;
  @override
  void initState() {
    super.initState();
    checkAppUpdates().then(
      (value) => {
        if (value == true)
          {
            showToast(
              '${AppLocalizations.of(context)!.appUpdateIsAvailable}!',
            ),
          },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(),
      SearchPage(),
      PlaylistsPage(),
      MorePage(),
    ];
    return Scaffold(
      bottomNavigationBar: getFooter(),
      body: ValueListenableBuilder<int>(
        valueListenable: activeTab,
        builder: (_, value, __) {
          return pages[value];
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    brightness = MediaQuery.of(context).platformBrightness;
  }

  Widget getFooter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<SequenceState?>(
          stream: audioPlayer.sequenceStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data;
            if (state?.sequence.isEmpty ?? true) {
              return const SizedBox();
            }
            final metadata = state!.currentSource!.tag;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AudioApp(),
                  ),
                );
              },
              child: Container(
                height: 65,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).iconTheme.color!,
                      Theme.of(context).primaryColor,
                      Colors.transparent
                    ],
                    stops: [0, 0.1, 1],
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                  ),
                  // border: Border(top: BorderSide(color: Colors.black, width: 2)),
                ),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: metadata.extras['localSongId'] is int
                          ? QueryArtworkWidget(
                              id: metadata.extras['localSongId'] as int,
                              type: ArtworkType.AUDIO,
                              // artworkBorder: BorderRadius.circular(8),
                              artworkWidth: 120,
                              artworkHeight: 120,
                              artworkFit: BoxFit.cover,
                              nullArtworkWidget: Icon(
                                MdiIcons.musicNoteOutline,
                                size: 60,
                                color: accent.primary,
                              ),
                              keepOldArtwork: true,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: metadata!.artUri.toString(),
                                fit: BoxFit.cover,
                                width: 60,
                                height: 60,
                                errorWidget: (context, url, error) => Container(
                                  width: 50,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(
                                      30,
                                      255,
                                      255,
                                      255,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        MdiIcons.musicNoteOutline,
                                        size: 30,
                                        color: accent.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            HtmlUnescape().convert(metadata!.title.toString()),
                            style: TextStyle(
                              color: Theme.of(context)
                                  .bottomSheetTheme
                                  .surfaceTintColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'BebasNeueRegular',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            HtmlUnescape().convert(
                              metadata!.artist.toString(),
                            ),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .bottomSheetTheme
                                  .surfaceTintColor,
                              fontFamily: 'BebasNeueRegular',
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ValueListenableBuilder<PlayerState>(
                        valueListenable: playerState,
                        builder: (_, value, __) {
                          if (value.processingState ==
                                  ProcessingState.loading ||
                              value.processingState ==
                                  ProcessingState.buffering) {
                            return Container(
                              margin: const EdgeInsets.all(8),
                              width: MediaQuery.of(context).size.width * 0.08,
                              height: MediaQuery.of(context).size.width * 0.08,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  accent.primary,
                                ),
                              ),
                            );
                          } else if (value.playing != true) {
                            return IconButton(
                              icon: Icon(MdiIcons.play, color: accent.primary),
                              iconSize: 45,
                              onPressed: play,
                              splashColor: Colors.transparent,
                            );
                          } else if (value.processingState !=
                              ProcessingState.completed) {
                            return IconButton(
                              icon: Icon(MdiIcons.pause, color: accent.primary),
                              iconSize: 45,
                              onPressed: pause,
                              splashColor: Colors.transparent,
                            );
                          } else {
                            return IconButton(
                              icon: Icon(
                                MdiIcons.replay,
                                color: accent.primary,
                              ),
                              iconSize: 45,
                              onPressed: () => audioPlayer.seek(
                                Duration.zero,
                                index: audioPlayer.effectiveIndices!.first,
                              ),
                              splashColor: Colors.transparent,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        _buildBottomBar(context),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return UltimateBottomNavBar(
      icons: [
        MdiIcons.home,
        MdiIcons.music,
        MdiIcons.playlistMusic,
        MdiIcons.tune,
      ],
      titles: const ['', '', '', ''],
      currentIndex: activeTab.value,
      backgroundColor: Colors.transparent,
      backgroundStrokeBorderColor: Colors.transparent,
      foregroundColor: Theme.of(context).bottomAppBarColor,
      foregroundStrokeBorderColor: Colors.transparent,
      unselectedIconColor: Theme.of(context).hintColor,
      unselectedTextColor: Theme.of(context).hintColor,
      selectedIconColor: accent.primary,
      // selectedTextColor: accent.primary,
      onTap: (index) {
        setState(() {
          activeTab.value = index;
        });
      },
    );
  }
}
