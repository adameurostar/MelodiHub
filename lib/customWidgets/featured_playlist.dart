import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:melodihub/API/melodihub.dart';
import 'package:melodihub/style/appTheme.dart';
import 'package:melodihub/ui/playlistPage.dart';

Widget featuredPlaylistWidget(playlists, title, showViewAll) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.all(20),
            child: Text(
              title,
              style: TextStyle(
                color: accent.primary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          showViewAll
              ? Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.all(20),
                  child: const Text(
                    'View All',
                    style: TextStyle(color: Color(0xFFED8770), fontSize: 13),
                    textAlign: TextAlign.left,
                  ),
                )
              : Container(),
        ],
      ),
      ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            colors: [
              Colors.white.withOpacity(0),
              Colors.white,
              Colors.white,
              Colors.white.withOpacity(0),
            ],
            stops: const [0, 0.2, 0.8, 1],
            tileMode: TileMode.mirror,
          ).createShader(bounds);
        },
        child: FutureBuilder(
          future: playlists ?? [],
          builder: (context, data) {
            if ((data as dynamic).data != null) {
              return CarouselSlider(
                items: (data as dynamic).data.map<Widget>((track) {
                  var imageUrl = track['image'];
                  var trackName = track['title'];
                  var artistName = track['header_desc'];
                  if (track != null) {
                    return Builder(
                      builder: (BuildContext context) {
                        return GestureDetector(
                          onTap: () {
                            getSongsFromPlaylist(track['ytid']).then(
                              (value) => {
                                track['list'] = value,
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PlaylistPage(playlist: track),
                                  ),
                                ),
                              },
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: SizedBox.fromSize(
                                    size: const Size(230, 125),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: Text(
                                    HtmlUnescape().convert(trackName),
                                    style: const TextStyle(
                                      color: Color.fromRGBO(255, 255, 255, 0.6),
                                      fontSize: 13,
                                      fontFamily: 'BebasNeueRegular',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: Text(
                                    HtmlUnescape().convert(artistName),
                                    style: const TextStyle(
                                      color: Color.fromRGBO(112, 112, 112, 1),
                                      fontSize: 10,
                                      fontFamily: 'BebasNeueRegular',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Text('No Data');
                  }
                }).toList(),
                options: CarouselOptions(
                  height: 200,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.5,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  scrollDirection: Axis.horizontal,
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    ],
  );
}
