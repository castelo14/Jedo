import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  Location _location = Location();
  LatLng _posicaoAtual = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _atualizarLocalizacao();
  }

  void _atualizarLocalizacao() async {
    var localizacao = await _location.getLocation();
    setState(() {
      _posicaoAtual = LatLng(localizacao.latitude!, localizacao.longitude!);
    });

    _location.onLocationChanged.listen((localizacaoNova) {
      setState(() {
        _posicaoAtual = LatLng(localizacaoNova.latitude!, localizacaoNova.longitude!);
      });

      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _posicaoAtual, zoom: 15),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapa Mototaxi")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _posicaoAtual,
          zoom: 15,
        ),
        onMapCreated: (controller) {
          _controller = controller;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
