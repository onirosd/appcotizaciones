import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appcotizaciones/src/providers/logo_provider.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          _PurpleBox(),
          const _HeaderIcon(), // Solo _HeaderIcon escucha cambios
          child,
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pathLogo = context.select<LogoProvider, String?>((p) => p.logoPath);
    final exists = pathLogo != null && File(pathLogo).existsSync();

    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 30),
        // alignment: Alignment.center,
        child: exists
            ? Transform.scale(
                scale: 1.2,
                child: Image.file(
                  File(pathLogo!),
                  height: 140,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image, size: 140, color: Colors.red),
                ),
              )
            : Icon(Icons.business, color: Colors.white, size: 140),
      ),
    );
  }
}

class _PurpleBox extends StatelessWidget {
  const _PurpleBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: size.height * 0.4,
      decoration: _purpleBackground(),
      child: Stack(
        children: const [
          Positioned(child: _Bubble(), top: 90, left: 30),
          Positioned(child: _Bubble(), top: -40, left: -30),
          Positioned(child: _Bubble(), top: -50, right: -20),
          Positioned(child: _Bubble(), bottom: -50, left: 10),
          Positioned(child: _Bubble(), bottom: 120, right: 20),
        ],
      ),
    );
  }

  BoxDecoration _purpleBackground() => const BoxDecoration(
        gradient: LinearGradient(colors: [
          Color.fromRGBO(63, 63, 156, 1),
          Color.fromRGBO(90, 70, 178, 1),
        ]),
      );
}

class _Bubble extends StatelessWidget {
  const _Bubble({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: const Color.fromRGBO(255, 255, 255, 0.05),
      ),
    );
  }
}
