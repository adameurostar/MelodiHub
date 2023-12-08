import 'package:fluttertoast/fluttertoast.dart';
import 'package:melodihub/style/appColors.dart';
import 'package:melodihub/style/appTheme.dart';

void showToast(String text) {
  Fluttertoast.showToast(
    backgroundColor: getMaterialColorFromColor(accent.primary),
    textColor: isAccentWhite(),
    msg: text,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    fontSize: 14,
  );
}
