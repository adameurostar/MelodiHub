import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:melodihub/helper/flutter_toast.dart';
import 'package:melodihub/helper/version.dart';
import 'package:melodihub/services/data_manager.dart';
import 'package:melodihub/ui/aboutPage.dart';
import 'package:melodihub/ui/localSongsPage.dart';
import 'package:melodihub/ui/searchPage.dart';
import 'package:melodihub/ui/userLikedSongsPage.dart';
import 'package:melodihub/ui/userPlaylistsPage.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF111c2d),
      shadowColor: Colors.black,
      shape: const BeveledRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 150,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(112, 112, 112, 0.1),
              border: Border(bottom: BorderSide(width: 1, color: Colors.black)),
            ),
            child: const Center(
              child: Image(
                image: AssetImage('assets/images/Logo.png'),
                width: 120,
                height: 120,
              ),
            ),
          ),
          ..._drawerItems(context),
        ],
      ),
    );
  }
}

Iterable<ListTile> _drawerItems(context) {
  final send = [
    {
      'title': AppLocalizations.of(context)!.userPlaylists,
      'asset': MdiIcons.account,
      'onTap': () => {
            Navigator.pop(context),
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserPlaylistsPage(),
              ),
            ),
          },
    },
    {
      'title': AppLocalizations.of(context)!.userLikedSongs,
      'asset': MdiIcons.star,
      'onTap': () => {
            Navigator.pop(context),
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserLikedSongs()),
            ),
          },
    },
    {
      'title': AppLocalizations.of(context)!.localSongs,
      'asset': MdiIcons.download,
      'onTap': () => {
            Navigator.pop(context),
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LocalSongsPage()),
            ),
          },
    },
    {
      'title': AppLocalizations.of(context)!.clearCache,
      'asset': MdiIcons.broom,
      'onTap': () => {
            clearCache(),
            showToast(
              '${AppLocalizations.of(context)!.cacheMsg}!',
            ),
          },
    },
    {
      'title': AppLocalizations.of(context)!.clearSearchHistory,
      'asset': MdiIcons.history,
      'onTap': () => {
            searchHistory = [],
            deleteData('user', 'searchHistory'),
            showToast('${AppLocalizations.of(context)!.searchHistoryMsg}!'),
          },
    },
    {
      'title': AppLocalizations.of(context)!.backupUserData,
      'asset': MdiIcons.cloudUpload,
      'onTap': () => {
            backupData().then(
              (value) => showToast(value.toString()),
            ),
          },
    },
    {
      'title': AppLocalizations.of(context)!.restoreUserData,
      'asset': MdiIcons.cloudDownload,
      'onTap': () => {
            restoreData().then(
              (value) => showToast(value.toString()),
            ),
          },
    },
    {
      'title': AppLocalizations.of(context)!.downloadAppUpdate,
      'asset': MdiIcons.download,
      'onTap': () => {
            checkAppUpdates().then(
              (available) => {
                if (available == true)
                  {
                    showToast(
                      '${AppLocalizations.of(context)!.appUpdateAvailableAndDownloading}!',
                    ),
                    downloadAppUpdates(),
                  }
                else
                  {
                    showToast(
                      '${AppLocalizations.of(context)!.appUpdateIsNotAvailable}!',
                    ),
                  },
              },
            ),
          },
    },
    {
      'title': AppLocalizations.of(context)!.about,
      'asset': MdiIcons.information,
      'onTap': () => {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AboutPage()),
            ),
          },
    },
  ];
  return send.map(
    (e) => ListTile(
      leading: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (Rect bounds) => LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor,
          ],
        ).createShader(bounds),
        child: Icon(
          e['asset'] as IconData?,
        ),
      ),
      textColor: Colors.white,
      title: Container(
        padding: const EdgeInsets.only(bottom: 10, top: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0x33707070))),
        ),
        child: Text(e['title'].toString()),
      ),
      onTap: e['onTap'] as VoidCallback,
    ),
  );
}
