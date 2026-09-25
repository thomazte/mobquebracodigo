import 'package:flutter/material.dart';
import '../theme/qc_theme.dart';

/// Mostra o mockup do Figma inteiro (sem cortar) e áreas clicáveis
/// relativas à imagem, não à janela do Windows.
class ScreenImage extends StatelessWidget {
  const ScreenImage({
    super.key,
    required this.asset,
    this.hotspots = const [],
    this.overlay,
    this.imageWidth = 463,
    this.imageHeight = 975,
  });

  final String asset;
  final List<ImageHotspot> hotspots;
  final Widget? overlay;
  final double imageWidth;
  final double imageHeight;

  double get _imageAspect => imageWidth / imageHeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QcColors.bg0,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final maxH = constraints.maxHeight;

          // Adaptar para a largura do celular (modo mais natural para mockups)
          final width = maxW;
          final height = width / _imageAspect;

          final content = SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    asset,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                ...hotspots.map((hotspot) {
                  return Positioned(
                    left: width * hotspot.left,
                    top: height * hotspot.top,
                    width: width * hotspot.width,
                    height: height * hotspot.height,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: hotspot.onTap,
                        borderRadius: BorderRadius.circular(24),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );

          return Stack(
            children: [
              // Se a imagem for mais alta que a tela, permite scroll.
              // Se for menor, centraliza verticalmente.
              SizedBox(
                width: maxW,
                height: maxH,
                child: SingleChildScrollView(
                  physics: height > maxH ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minHeight: maxH),
                    alignment: Alignment.center,
                    child: content,
                  ),
                ),
              ),
              if (overlay != null)
                Positioned.fill(
                  child: overlay!,
                ),
            ],
          );
        },
      ),
    );
  }
}

class ImageHotspot {
  const ImageHotspot({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.onTap,
  });

  /// Frações de 0 a 1 relativas ao mockup (não à janela).
  final double left;
  final double top;
  final double width;
  final double height;
  final VoidCallback onTap;
}
