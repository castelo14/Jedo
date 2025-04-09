import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

const String apiKey = "AIzaSyDDXYdwPQFsleuZ1Dkw5x_tYNMAIhDZ5fg"; // Insere tua chave aqui

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  Location _location = Location();
  LatLng _posicaoAtual = LatLng(0, 0);

  final TextEditingController _destinoController = TextEditingController();
  List<dynamic> _sugestoes = [];

  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};  // Variável para armazenar os markers
  LatLng? _destino;

  String _tempoEstimado = ""; // Variável para armazenar o tempo estimado

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

  void _buscarSugestoes(String input) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&location=${_posicaoAtual.latitude},${_posicaoAtual.longitude}&radius=5000&key=$apiKey";

    final resposta = await http.get(Uri.parse(url));
    if (resposta.statusCode == 200) {
      setState(() {
        _sugestoes = jsonDecode(resposta.body)['predictions'];
      });
    }
  }

  void _selecionarSugestao(String placeId) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey";

    final resposta = await http.get(Uri.parse(url));
    if (resposta.statusCode == 200) {
      final resultado = jsonDecode(resposta.body)['result'];
      final local = resultado['geometry']['location'];
      _destino = LatLng(local['lat'], local['lng']);

      _tracarRota();
    }
  }

  void _tracarRota() async {
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${_posicaoAtual.latitude},${_posicaoAtual.longitude}&destination=${_destino!.latitude},${_destino!.longitude}&key=$apiKey";

    final resposta = await http.get(Uri.parse(url));
    if (resposta.statusCode == 200) {
      final dados = jsonDecode(resposta.body);
      final pontos = _decodificarPolyline(dados['routes'][0]['overview_polyline']['points']);

      setState(() {
        _polylines = {
          Polyline(
            polylineId: PolylineId("rota"),
            points: pontos,
            color: Colors.green,
            width: 5,
          ),
        };
        // Adiciona o marker de destino
        _markers = {
          Marker(
            markerId: MarkerId("destino"),
            position: _destino!,
            infoWindow: InfoWindow(title: "Destino", snippet: "Aqui é o destino"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        };
      });

      final duracao = dados['routes'][0]['legs'][0]['duration']['text'];
      _mostrarTempoEstimado(duracao);
    }
  }

  List<LatLng> _decodificarPolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  void _mostrarTempoEstimado(String duracao) {
    setState(() {
      _tempoEstimado = duracao;  // Atualiza o tempo estimado
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("JEDO", style: TextStyle(color: const Color.fromARGB(255, 255, 254, 254))),  backgroundColor: const Color.fromARGB(255, 45, 7, 184), ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _posicaoAtual,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _controller = controller;
            },
            myLocationEnabled: true,
            polylines: _polylines,
            markers: _markers,  // Exibe os markers no mapa
          ),

          // Campo de texto flutuante estilizado
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _destinoController,
                    onChanged: _buscarSugestoes,
                    decoration: InputDecoration(
                      hintText: "Para onde vamos?",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),

                // Lista de sugestões
                if (_sugestoes.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _sugestoes.length,
                      itemBuilder: (context, index) {
                        final sugestao = _sugestoes[index];
                        return ListTile(
                          leading: Icon(Icons.location_on, color: Colors.redAccent),
                          title: Text(
                            sugestao['structured_formatting']['main_text'] ?? '',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            sugestao['structured_formatting']['secondary_text'] ?? '',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          onTap: () {
                            _selecionarSugestao(sugestao['place_id']);
                            setState(() {
                              _destinoController.text =
                                  sugestao['structured_formatting']['main_text'];
                              _sugestoes = [];
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Barra fixa com o tempo estimado
          Positioned(
            top: 0, // Fixa a barra no topo
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.8), // Cor de fundo semi-translúcida
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                _tempoEstimado.isNotEmpty ? "Tempo estimado: $_tempoEstimado" : "Aguardando rota...",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
