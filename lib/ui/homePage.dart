import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:melodihub/API/melodihub.dart';
import 'package:melodihub/customWidgets/drawer.dart';
import 'package:melodihub/customWidgets/featured_playlist.dart';
import 'package:melodihub/customWidgets/song_bar.dart';
import 'package:melodihub/customWidgets/spinner.dart';
import 'package:melodihub/style/appTheme.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          AppLocalizations.of(context)!.home,
          style: TextStyle(
            color: accent.primary,
            fontSize: 35,
            fontWeight: FontWeight.w800,
          ),
        ),
        elevation: 0,
      ),
      drawer: const DrawerWidget(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            featuredPlaylistWidget(
              getPlaylists(10),
              AppLocalizations.of(context)!.suggestedPlaylists,
              false,
            ),
            FutureBuilder(
              future: get10Music('PLgzTt0k8mXzEk586ze4BjvDXR7c-TUSnx'),
              builder: (context, data) {
                if (data.connectionState != ConnectionState.done) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(35),
                      child: Spinner(),
                    ),
                  );
                }
                if (data.hasError) {
                  return Center(
                    child: Text(
                      'Error!',
                      style: TextStyle(
                        color: accent.primary,
                        fontSize: 18,
                        fontFamily: 'BebasNeueRegular',
                      ),
                    ),
                  );
                }
                if (!data.hasData) {
                  return Center(
                    child: Text(
                      'Nothing Found!',
                      style: TextStyle(
                        color: accent.primary,
                        fontSize: 18,
                        fontFamily: 'BebasNeueRegular',
                      ),
                    ),
                  );
                }
                return Wrap(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 55,
                        bottom: 10,
                        left: 20,
                        right: 20,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.recommendedForYou,
                        style: TextStyle(
                          color: accent.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: false,
                        physics: const BouncingScrollPhysics(),
                        itemCount: (data as dynamic).data.length as int,
                        itemBuilder: (context, index) {
                          return SongBar(
                            (data as dynamic).data[index],
                            false,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
