import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class TelaMapaUsuario extends StatefulWidget {
  @override
  _TelaMapaUsuarioState createState() => _TelaMapaUsuarioState();
}

class _TelaMapaUsuarioState extends State<TelaMapaUsuario> {
  GoogleMapController? _mapController;
  LatLng? _localizacaoAtual;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _iniciarLocalizacao();
    _timer = Timer.periodic(Duration(seconds: 3), (_) => _atualizarLocalizacao());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _iniciarLocalizacao() async {
    bool permitido = await _verificarPermissao();
    if (!permitido) return;

    Position posicao = await Geolocator.getCurrentPosition();
    setState(() {
      _localizacaoAtual = LatLng(posicao.latitude, posicao.longitude);
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_localizacaoAtual!, 16),
    );
  }

  Future<void> _atualizarLocalizacao() async {
    Position posicao = await Geolocator.getCurrentPosition();
    setState(() {
      _localizacaoAtual = LatLng(posicao.latitude, posicao.longitude);
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(_localizacaoAtual!),
    );
  }

  Future<bool> _verificarPermissao() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    return permissao == LocationPermission.whileInUse || permissao == LocationPermission.always;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapa")),
      body: _localizacaoAtual == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _localizacaoAtual!,
                zoom: 16,
              ),
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }
}
