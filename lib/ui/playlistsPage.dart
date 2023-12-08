import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:melodihub/API/melodihub.dart';
import 'package:melodihub/customWidgets/delayed_display.dart';
import 'package:melodihub/customWidgets/drawer.dart';
import 'package:melodihub/customWidgets/spinner.dart';
import 'package:melodihub/style/appTheme.dart';
import 'package:melodihub/ui/playlistPage.dart';

class PlaylistsPage extends StatefulWidget {
  @override
  _PlaylistsPageState createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  final TextEditingController _searchBar = TextEditingController();
  final FocusNode _inputNode = FocusNode();
  String _searchQuery = '';

  Future<void> search() async {
    _searchQuery = _searchBar.text;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const ImageIcon(AssetImage('assets/images/menu.png')),
              color: accent.primary,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.playlists,
          style: TextStyle(
            color: accent.primary,
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
      ),
      drawer: const DrawerWidget(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 20,
                left: 12,
                right: 12,
              ),
              child: TextField(
                onSubmitted: (String value) {
                  search();
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                controller: _searchBar,
                focusNode: _inputNode,
                style: TextStyle(
                  fontSize: 16,
                  color: accent.primary,
                ),
                cursorColor: Colors.green[50],
                decoration: InputDecoration(
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(100),
                    ),
                    borderSide: BorderSide(
                      color: Theme.of(context).backgroundColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(100),
                    ),
                    borderSide: BorderSide(color: accent.primary),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.search,
                      color: accent.primary,
                    ),
                    color: accent.primary,
                    onPressed: () {
                      search();
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                  border: InputBorder.none,
                  hintText: '${AppLocalizations.of(context)!.search}...',
                  hintStyle: TextStyle(
                    color: accent.primary,
                  ),
                  contentPadding: const EdgeInsets.only(
                    left: 18,
                    right: 20,
                    top: 14,
                    bottom: 14,
                  ),
                ),
              ),
            ),
            if (_searchQuery.isEmpty)
              FutureBuilder(
                future: getPlaylists(),
                builder: (context, data) {
                  return (data as dynamic).data != null
                      ? GridView.builder(
                          addAutomaticKeepAlives: false,
                          addRepaintBoundaries: false,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemCount: (data as dynamic).data.length as int,
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 20,
                          ),
                          itemBuilder: (BuildContext context, index) {
                            return Center(
                              child: GetPlaylist(
                                index: index,
                                image: (data as dynamic).data[index]['image'],
                                title: (data as dynamic)
                                    .data[index]['title']
                                    .toString(),
                                subtitle: (data as dynamic).data[index]
                                    ['subtitle'],
                                header_desc: (data as dynamic).data[index]
                                    ['header_desc'],
                                id: (data as dynamic).data[index]['ytid'],
                              ),
                            );
                          },
                        )
                      : const Spinner();
                },
              )
            else
              FutureBuilder(
                future: searchPlaylist(_searchQuery),
                builder: (context, data) {
                  return (data as dynamic).data != null
                      ? GridView.builder(
                          addAutomaticKeepAlives: false,
                          addRepaintBoundaries: false,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemCount: (data as dynamic).data.length as int,
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 20,
                          ),
                          itemBuilder: (BuildContext context, index) {
                            return Center(
                              child: GetPlaylist(
                                index: index,
                                image: (data as dynamic).data[index]['image'],
                                title: (data as dynamic)
                                    .data[index]['title']
                                    .toString(),
                                subtitle: (data as dynamic).data[index]
                                    ['subtitle'],
                                header_desc: (data as dynamic).data[index]
                                    ['header_desc'],
                                id: (data as dynamic).data[index]['ytid'],
                              ),
                            );
                          },
                        )
                      : const Spinner();
                },
              )
          ],
        ),
      ),
    );
  }
}

class GetPlaylist extends StatelessWidget {
  const GetPlaylist({
    super.key,
    required this.index,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.id,
    this.header_desc,
  });
  final int index;
  final dynamic image;
  final String title;
  final String subtitle;
  final dynamic id;
  final String? header_desc;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DelayedDisplay(
      delay: const Duration(milliseconds: 200),
      fadingDuration: const Duration(milliseconds: 400),
      child: GestureDetector(
        onTap: () {
          getPlaylistInfoForWidget(id).then(
            (value) {
              final data = {
                'ytid': id,
                'title': title,
                'subtitle': subtitle,
                'header_desc': header_desc,
                'type': 'playlist',
                'image': image,
                'list': value,
              };
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistPage(playlist: data),
                ),
              );
            },
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: SizedBox.fromSize(
                  size: const Size(230, 125),
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: MediaQuery.of(context).size.width * 0.4,
                child: Text(
                  HtmlUnescape().convert(title),
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
                width: MediaQuery.of(context).size.width * 0.4,
                child: Text(
                  HtmlUnescape().convert(subtitle),
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
      ),
    );
  }
}
