import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders the launcher icons from `assets/brand/dt_icon.svg`.
///
/// **Not a test** — it writes files. It lives outside `test/` and has no
/// `_test.dart` suffix so `flutter test` never picks it up on its own; run it
/// explicitly, and only when the brand art changes:
///
/// ```bash
/// flutter test tool/generate_app_icon.dart
/// dart run flutter_launcher_icons
/// ```
///
/// **Why render the SVG instead of resizing the PNG.** `dt_icon.png` is
/// 1000×1000, below the 1024 the App Store icon wants, and enlarging a bitmap
/// only invents pixels. The SVG's ring is real vector, so rasterising it at
/// 1024 keeps the ring exact; the only bitmap inside is the dollar (206×378),
/// which lands at a 1.02× scale — imperceptible. See `assets/brand/README.md`.
///
/// **Why it draws on a canvas instead of pumping a widget.** `SvgPicture`
/// resolves its source asynchronously, and the test binding's fake clock never
/// completes that load: the first version of this script wrote a blank navy
/// square and said nothing. Loading through `vg` inside `runAsync` uses the
/// real clock, and drawing the `Picture` by hand removes the widget tree from
/// the equation entirely. It runs under `flutter_test` because rasterising
/// needs the engine — the same machinery the golden tests use, and no
/// dependency the project did not already have.
void main() {
  /// The App Store's marketing icon size, and the ceiling every other density
  /// is derived from.
  const double size = 1024;

  /// Taken from the artwork itself (`dt_icon.png`), not from `DESIGN.md`: that
  /// palette dresses the interface, this one belongs to the brand.
  const Color navy = Color(0xFF08253A);

  /// Web's maskable icons keep their content inside the central 80 %, so the
  /// art is inset by half of the rest.
  const double maskableInset = (1 - 0.8) / 2;

  final String svg = _inlineUsedImages(
    File('assets/brand/dt_icon.svg').readAsStringSync(),
  );

  testWidgets('app_icon.png — composed, on the brand navy', (tester) async {
    await _render(
      tester,
      svg: svg,
      size: size,
      background: navy,
      to: 'assets/brand/app_icon.png',
    );
  });

  testWidgets('app_icon_foreground.png — transparent, for the adaptive icon', (
    tester,
  ) async {
    // **No inset here.** `flutter_launcher_icons` wraps the foreground in its
    // own `<inset android:inset="16%">`, so padding it again shrank the ring to
    // about half of the masked area. The art already stops at 82 % of the
    // viewBox, which lands at a comfortable 84 % of the mask once the tool has
    // added its margin.
    await _render(
      tester,
      svg: svg,
      size: size,
      to: 'assets/brand/app_icon_foreground.png',
    );
  });

  // The web icons are written here rather than by `flutter_launcher_icons`:
  // that step needs `web/index.html`, which this project does not have, and
  // fails before touching them. Generating them straight from the same master
  // keeps the favicon as sharp as the rest — a criterion of #10.
  for (final (String file, int px, double inset) in <(String, int, double)>[
    ('web/favicon.png', 32, 0),
    ('web/icons/Icon-192.png', 192, 0),
    ('web/icons/Icon-512.png', 512, 0),
    ('web/icons/Icon-maskable-192.png', 192, maskableInset),
    ('web/icons/Icon-maskable-512.png', 512, maskableInset),
  ]) {
    testWidgets('$file — $px²', (tester) async {
      await _render(
        tester,
        svg: svg,
        size: px.toDouble(),
        background: navy,
        inset: inset,
        to: file,
        // A 32² favicon of flat colour and a thin ring compresses well below
        // the floor that catches a blank 1024².
        floor: px < 64 ? 200 : 2 * 1024,
      );
    });
  }
}

/// Rewrites `<use xlink:href="#id"/>` into the `<image>` it points at.
///
/// **Flutter cannot draw the source as delivered.** `flutter_svg` 2.x renders
/// through `vector_graphics`, which does not resolve a `<use>` pointing at an
/// `<image>` inside `<defs>` — it silently draws nothing. In `dt_icon.svg` that
/// is the dollar sign, so the icon came out as an empty ring and the loss was
/// invisible until someone looked at the PNG.
///
/// The `<use>` carries the same `x`/`y`/`width`/`height` an `<image>` takes, and
/// it sits inside the same `<g transform>`, so moving the data URI onto it in
/// place reproduces the intended geometry exactly.
///
/// This rewrites the string in memory; the file on disk stays as the designer
/// exported it. The same limitation is why `dt_logo.svg` cannot be used for the
/// splash yet — see `assets/brand/README.md`.
String _inlineUsedImages(String svg) {
  final Map<String, String> hrefById = <String, String>{
    for (final RegExpMatch m in RegExp(
      r'<image\s+id="([^"]+)"[^>]*?xlink:href="(data:[^"]+)"',
      dotAll: true,
    ).allMatches(svg))
      m.group(1)!: m.group(2)!,
  };

  return svg.replaceAllMapped(
    RegExp(r'<use\s+xlink:href="#([^"]+)"([^/>]*)/>'),
    (Match m) {
      final String? href = hrefById[m.group(1)];
      return href == null
          ? m.group(0)!
          : '<image${m.group(2)} xlink:href="$href"/>';
    },
  );
}

/// The art is black-on-transparent in the SVG and white in the product, so it
/// is recoloured on the way out. `srcIn` keeps the alpha, so whatever is behind
/// stays visible and the transparent areas stay transparent.
final Paint _whiten = Paint()
  ..colorFilter = const ColorFilter.mode(Colors.white, BlendMode.srcIn);

/// Rasterises [svg] into a [size]×[size] PNG at [to].
///
/// [background] fills the canvas first — omit it for a transparent icon.
/// [inset] shrinks the art by that fraction of the canvas on every side.
Future<void> _render(
  WidgetTester tester, {
  required String svg,
  required double size,
  required String to,
  Color? background,
  double inset = 0,
  int floor = 8 * 1024,
}) async {
  late final Uint8List bytes;

  await tester.runAsync(() async {
    final PictureInfo info = await vg.loadPicture(SvgStringLoader(svg), null);

    final Rect canvasRect = Rect.fromLTWH(0, 0, size, size);
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder, canvasRect);

    if (background != null) {
      canvas.drawRect(canvasRect, Paint()..color = background);
    }

    canvas.saveLayer(canvasRect, _whiten);
    final double art = size * (1 - 2 * inset);
    canvas.translate(size * inset, size * inset);
    canvas.scale(art / info.size.width);
    canvas.drawPicture(info.picture);
    canvas.restore();

    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
    final ByteData? png = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    bytes = png!.buffer.asUint8List();

    image.dispose();
    picture.dispose();
    info.picture.dispose();
  });

  // A generator that silently writes an empty icon is worse than one that
  // fails: the blank would only surface on a device, after a release.
  _assertHasArtwork(bytes, to, floor);

  File(to).writeAsBytesSync(bytes);
  // ignore: avoid_print
  print('escrito $to  (${size.toInt()}², ${bytes.length ~/ 1024} KB)');
}

/// Fails when the PNG is too small to hold artwork.
///
/// A 1024² image of one flat colour compresses to a couple of kilobytes; a ring
/// and a dollar sign do not. Crude, but it catches the failure that actually
/// happens here — the source not rendering at all.
void _assertHasArtwork(Uint8List png, String to, int floor) {
  if (png.length < floor) {
    throw StateError(
      '$to came out at ${png.length} bytes, under $floor — that is a flat '
      'fill, so the SVG did not render. Check the loader, not the art.',
    );
  }
}
