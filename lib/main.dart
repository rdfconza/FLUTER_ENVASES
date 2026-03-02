import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const SistemaGuiasApp());
}

class SistemaGuiasApp extends StatelessWidget {
  const SistemaGuiasApp({super.key});

  static const Color primaryBlue = Color(0xFF0033CC);
  static const Color accentYellow = Color(0xFFFFC107);
  static const Color background = Color(0xFFF5F5F5);
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFFF3D00);
  static const Color beerGreen = Color(0xFF2E7D32);
  static const Color infoCyan = Color(0xFFE0F7FA);
  static const Color infoText = Color(0xFF006064);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liqui',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue),
        scaffoldBackgroundColor: background,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animacionEscala;
  late Animation<Offset> _animacionMovimiento;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animacionEscala = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut, 
    );

    _animacionMovimiento = Tween<Offset>(
      begin: const Offset(0, -1.5), 
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    ));

    _controller.forward().then((_) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.heavyImpact();
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SistemaGuiasApp.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SlideTransition(
              position: _animacionMovimiento,
              child: ScaleTransition(
                scale: _animacionEscala,
                child: FadeTransition(
                  opacity: _animacionEscala,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white, 
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        )
                      ]
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo_embid.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.local_shipping, size: 100, color: SistemaGuiasApp.primaryBlue),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            FadeTransition(
              opacity: _animacionEscala,
              child: Column(
                children: const [
                  Text("SISTEMAS", style: TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 3)),
                  Text("EMBID JULIACA", style: TextStyle(color: SistemaGuiasApp.accentYellow, fontSize: 34, fontWeight: FontWeight.w900)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ProductoItem {
  final String codigo;
  final String desc;
  final String pkg;
  final String caja;
  final int factor;
  final bool esCerveza;
  final bool ignoraCajas;

  int cargaCaja = 0;
  int cargaUnd = 0;
  int rechazoCaja = 0;
  int rechazoUnd = 0;

  final TextEditingController ctrlCCaja = TextEditingController();
  final TextEditingController ctrlCUnd = TextEditingController();
  final TextEditingController ctrlRCaja = TextEditingController();
  final TextEditingController ctrlRUnd = TextEditingController();

  ProductoItem({
    required this.codigo,
    required this.desc,
    required this.pkg,
    required this.caja,
    required this.factor,
    required this.esCerveza,
    required this.ignoraCajas,
  });
}

class DescuentoGlobal {
  final String codigoItem; 
  final bool esCaja;
  final int cajas;
  final int unds;
  final String tipo; 

  DescuentoGlobal({
    required this.codigoItem,
    required this.esCaja,
    required this.cajas,
    required this.unds,
    required this.tipo,
  });
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final List<ProductoItem> _inventario = [];
  final List<DescuentoGlobal> _descuentos = [];

  final Map<String, Map<String, dynamic>> catalogoRaw = {
    '6181': {'desc': 'CC RP 2LX8 RF', 'factor': 8, 'pkg': '7700', 'caja': '7733', 'cerveza': false}, 
    '101':  {'desc': 'INCA KOLA REF PET 2LX8 RF 2.', 'factor': 8, 'pkg': '7700', 'caja': '7733', 'cerveza': false}, 
    '1038': {'desc': 'COCA COLA VR 1500X08', 'factor': 8, 'pkg': '7693', 'caja': '7733', 'cerveza': false},
    '155':  {'desc': 'INCA KOLA VR 1500X08', 'factor': 8, 'pkg': '7605', 'caja': '7733', 'cerveza': false},
    '694':  {'desc': 'FANTA NARANJA VR 1.5LX8 RF', 'factor': 8, 'pkg': '7728', 'caja': '7733', 'cerveza': false}, 
    '2038': {'desc': 'FANTA KOLA INGLESA VR 1.5LX8', 'factor': 8, 'pkg': '7728', 'caja': '7733', 'cerveza': false}, 
    
    '1025': {'desc': 'COCA COLA VR1000X12', 'factor': 12, 'pkg': '7661', 'caja': '7732', 'cerveza': false},
    '103':  {'desc': 'INCA KOLA VR1000X12', 'factor': 12, 'pkg': '7603', 'caja': '7732', 'cerveza': false},
    '1041': {'desc': 'COCA COLA VR 625X12', 'factor': 12, 'pkg': '7659', 'caja': '7732', 'cerveza': false},
    
    '11':   {'desc': 'IK VR 625MLX12 TP ROSCA-PROV', 'factor': 12, 'pkg': '7114', 'caja': '31', 'cerveza': false, 'ignore_cajas': true}, 
    
    '164':  {'desc': 'IK 400 ML VR CJ*20', 'factor': 20, 'pkg': '7566', 'caja': '7724', 'cerveza': false},
    '1392': {'desc': 'CC 400 ML VR CJ*20', 'factor': 20, 'pkg': '7567', 'caja': '7724', 'cerveza': false},

    '562':  {'desc': 'FANTA NAR VR 296MLX24 RF-ANI', 'factor': 24, 'pkg': '7666', 'caja': '7731', 'cerveza': false},
    '1023': {'desc': 'COCA COLA VR296X24', 'factor': 24, 'pkg': '7660', 'caja': '7731', 'cerveza': false},
    '102':  {'desc': 'INCA KOLA VR296X24', 'factor': 24, 'pkg': '7602', 'caja': '7731', 'cerveza': false},
    '1022': {'desc': 'COCA COLA VR192X24', 'factor': 24, 'pkg': '7682', 'caja': '7731', 'cerveza': false},
    '123':  {'desc': 'INCA KOLA VR192X24', 'factor': 24, 'pkg': '7606', 'caja': '7731', 'cerveza': false},
    '564':  {'desc': 'FANTA NARANJA VR192X24 RF', 'factor': 24, 'pkg': '7665', 'caja': '7731', 'cerveza': false},
    
    '1775': {'desc': 'SAN LUIS 20 LT REF PET', 'factor': 1, 'pkg': '7538', 'caja': 'SIN_CAJA', 'cerveza': false},

    '919':  {'desc': 'HEINEKEN RGB 600 MLX12', 'factor': 12, 'pkg': '7763', 'caja': '7749', 'cerveza': true}, 
    '367':  {'desc': 'AMSTEL RGB 600 MLX12 PE CRAT', 'factor': 12, 'pkg': '7766', 'caja': '7749', 'cerveza': true}, 

    '5803': {'desc': '12CC 192ML VR+12 IKPAPSAL 25', 'factor': 12, 'pkg': '5722', 'caja': '7764', 'cerveza': false}, 
    '5804': {'desc': '12IK 192ML VR+12 IKPAPSAL 25', 'factor': 12, 'pkg': '5719', 'caja': '7764', 'cerveza': false}, 
  };

  final Map<String, String> nombresEnvases = {
    '7700': 'ENV.GENERICO REF PET 2LX8',
    '7693': 'ENV CC 1.5 VRE X 8',
    '7605': 'BOTELLA INCA KOLA LT 1/2',
    '7728': 'ENVASE VR GENERICO 1.5LT X8',
    '7661': 'BOT CC VR 1.0 LT',
    '7603': 'BOTELLA INCA KOLA LT',
    '7659': 'BOTELLA CC 625 VR',
    '7114': 'BOTELLA INCA KOLA 625 VRE',
    '7566': 'ENVASE IK 400 VR CJ*20',
    '7567': 'ENVASE CC 400 VR CJ*20',
    '7666': 'BOT FTA VR 10 OZ',
    '7660': 'BOT CC VR 295 ML',
    '7602': 'BOTELLA INCA KOLA 296 VRE',
    '7682': 'BOTELLA CC 6.5',
    '7606': 'BOT IK VRE 192 ML',
    '7665': '1 BT FTA VR 6.5 OZ',
    '7538': 'ENV.BIDON SAN LUIS 20L CILIN',
    '7763': 'ENV. HEINEKEN 600X12',
    '7766': 'ENVASE AMSTEL RGB 600ML X 12',
    '5722': 'ENVASE COCA COLA 192ML X 12',
    '5719': 'BOT IK VRE 192 ML',
  };

  final Map<String, String> nombresCajas = {
    '7733': 'CAJA PLASTICA X 8 DIV',
    '7732': 'CAJA PLASTICA X 12 DIV',
    '7724': 'CAJA PLAST X 20 DIV',
    '7731': 'CAJA PLASTICA X 24 DIV',
    '31': 'CAJA PLAST X 12 D 1/2 G',
    '7749': 'CAJA PLASTICA X 12 HEINEKEN',
    '7764': 'CAJA PLASTICA SIN DIV PICKUN',
  };

  @override
  void initState() {
    super.initState();
    catalogoRaw.forEach((codigo, datos) {
      _inventario.add(ProductoItem(
        codigo: codigo,
        desc: datos['desc'],
        pkg: datos['pkg'],
        caja: datos['caja'],
        factor: datos['factor'],
        esCerveza: datos['cerveza'],
        ignoraCajas: datos['ignore_cajas'] ?? false,
      ));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _revisarPrimeraVez();
    });
  }

  Future<void> _revisarPrimeraVez() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool visto = (prefs.getBool('tutorial_v1_popup') ?? false);
    if (!visto) {
      _mostrarTutorialDialog(true);
    }
  }

  void _mostrarTutorialDialog(bool esPrimeraVez) {
    showDialog(
      context: context,
      barrierDismissible: !esPrimeraVez,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: SistemaGuiasApp.primaryBlue),
            SizedBox(width: 8),
            Text("Guia Rapida", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: SistemaGuiasApp.primaryBlue)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("1. DIGITACION:", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              Text("Copia los numeros de tu guia fisica. Pon cuantas cajas y unidades salieron en CARGA, y cuantas regresaron en RECHAZO.\n", style: TextStyle(fontSize: 12, color: Colors.black87)),
              Text("2. DESCUENTOS:", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              Text("• Si tienes papel SDG: toca el boton SDG, pon el codigo de envase o caja y la cantidad de tu papel.\n• Si tienes COMODATO: toca el boton COMODATO, elige la cerveza y pon las cajas y botellas exactas de tu papel.\n", style: TextStyle(fontSize: 12, color: Colors.black87)),
              Text("3. RESULTADOS:", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              Text("Ve a la pestaña RESULTADOS. Ahi tendras los totales listos para copiarlos a tu liquidacion final.\n", style: TextStyle(fontSize: 12, color: Colors.black87)),
              Text("4. REGLAS:", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              Text("Si te equivocas al escribir un producto, usa el boton del tachito de basura rojo para limpiar esa fila.", style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: SistemaGuiasApp.primaryBlue),
            onPressed: () async {
              if (esPrimeraVez) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('tutorial_v1_popup', true);
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text("¡Entendido!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      )
    );
  }

  void _alertaRapida(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 3), 
    ));
  }

  void _validarFila(ProductoItem item) {
    if (item.factor > 1) {
      if (item.cargaUnd >= item.factor) {
        _alertaRapida("Maximo de unidades para este producto es ${item.factor - 1}", Colors.red);
        item.cargaUnd = 0;
        item.ctrlCUnd.clear();
      }
      if (item.rechazoUnd >= item.factor) {
        _alertaRapida("Maximo de unidades para este producto es ${item.factor - 1}", Colors.red);
        item.rechazoUnd = 0;
        item.ctrlRUnd.clear();
      }
    }

    int cargaTotal = (item.cargaCaja * item.factor) + item.cargaUnd;
    int rechazoTotal = (item.rechazoCaja * item.factor) + item.rechazoUnd;

    if (rechazoTotal > cargaTotal) {
      _alertaRapida("El rechazo no puede ser mayor a la carga", Colors.red);
      item.rechazoCaja = 0;
      item.rechazoUnd = 0;
      item.ctrlRCaja.clear();
      item.ctrlRUnd.clear();
    }
    setState(() {});
  }

  void _limpiarFila(ProductoItem item) {
    setState(() {
      item.ctrlCCaja.clear();
      item.ctrlCUnd.clear();
      item.ctrlRCaja.clear();
      item.ctrlRUnd.clear();
      item.cargaCaja = 0;
      item.cargaUnd = 0;
      item.rechazoCaja = 0;
      item.rechazoUnd = 0;
    });
    _alertaRapida("Fila limpiada", Colors.grey[700]!);
  }

  void _mostrarDialogoGlobal(String tipo) {
    TextEditingController codeCtrl = TextEditingController();
    TextEditingController cajCtrl = TextEditingController();
    TextEditingController undCtrl = TextEditingController();
    String marcaComodato = '7763'; 
    String msgErrorInt = ""; 

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            String codActual = tipo == 'SDG' ? codeCtrl.text.trim() : marcaComodato;
            bool esEnvase = nombresEnvases.containsKey(codActual);
            bool esCaja = tipo == 'SDG' ? nombresCajas.containsKey(codActual) : false; 
            
            int factorEnvase = 1;
            String catCaja = "";
            if (esEnvase) {
              for (var v in catalogoRaw.values) {
                if (v['pkg'] == codActual) {
                  factorEnvase = v['factor'];
                  catCaja = v['caja'];
                  break;
                }
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text("AÑADIR $tipo", style: TextStyle(color: tipo == 'COMODATO' ? SistemaGuiasApp.beerGreen : Colors.orange[800], fontWeight: FontWeight.w900, fontSize: 15)),
              content: SingleChildScrollView( 
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tipo == 'SDG') ...[
                      const Text("Codigo (Caja o Envase):", style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: codeCtrl,
                        decoration: InputDecoration(
                          labelText: "Ej. 7693 (Envase) o 7733 (Caja)", 
                          filled: true,
                          fillColor: Colors.blue[50],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        ), 
                        keyboardType: TextInputType.number, 
                        inputFormatters: [LengthLimitingTextInputFormatter(4)], 
                        onChanged: (val) {
                          setStateDialog(() { msgErrorInt = ""; }); 
                        },
                      ),
                    ] else ...[
                      const Text("Selecciona la cerveza:", style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ChoiceChip(
                            label: const Text("HEINEKEN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            selected: marcaComodato == '7763',
                            selectedColor: Colors.green[200],
                            onSelected: (val) {
                              setStateDialog(() { marcaComodato = '7763'; msgErrorInt = ""; });
                            },
                          ),
                          ChoiceChip(
                            label: const Text("AMSTEL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            selected: marcaComodato == '7766',
                            selectedColor: Colors.green[200],
                            onSelected: (val) {
                              setStateDialog(() { marcaComodato = '7766'; msgErrorInt = ""; });
                            },
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 10),

                    if (codActual.isNotEmpty) ...[
                      if (esEnvase) ...[
                        Text("ENVASE: ${nombresEnvases[codActual]}", style: TextStyle(fontSize: 11, color: Colors.blue[700], fontWeight: FontWeight.bold)),
                        Text(tipo == 'COMODATO' 
                            ? "Resta exacto a cascos y envases" 
                            : "Afecta solo a botellas (x$factorEnvase)", 
                            style: TextStyle(fontSize: 9, color: Colors.grey[800], fontStyle: FontStyle.italic)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: TextField(
                              controller: cajCtrl,
                              decoration: InputDecoration(labelText: "Cajas", filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12)), 
                              keyboardType: TextInputType.number, 
                              onChanged: (v) => setStateDialog(() => msgErrorInt = ""),
                            )),
                            const SizedBox(width: 10),
                            Expanded(child: TextField(
                              controller: undCtrl,
                              decoration: InputDecoration(labelText: "Unidades", filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12)), 
                              keyboardType: TextInputType.number, 
                              onChanged: (v) => setStateDialog(() => msgErrorInt = ""),
                            )),
                          ],
                        ),
                      ] else if (esCaja) ...[
                        Text("CAJA: ${nombresCajas[codActual]}", style: TextStyle(fontSize: 11, color: Colors.orange[800], fontWeight: FontWeight.bold)),
                        const Text("Resta directamente a los cascos generales", style: TextStyle(fontSize: 9, color: Colors.black54, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: cajCtrl,
                          decoration: InputDecoration(labelText: "Cajas a descontar", filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12)), 
                          keyboardType: TextInputType.number, 
                          onChanged: (v) => setStateDialog(() => msgErrorInt = ""),
                        ),
                      ] else ...[
                        const Text("Codigo no reconocido", style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold)),
                      ]
                    ],

                    if (msgErrorInt.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.red.shade200)),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 16),
                              const SizedBox(width: 6),
                              Expanded(child: Text(msgErrorInt, style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),
                      ),

                    if (_descuentos.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: Colors.black12, thickness: 1),
                      ),
                      const Text("DESCUENTOS APLICADOS:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black54)),
                      const SizedBox(height: 6),
                      ..._descuentos.asMap().entries.map((entry) {
                        int idx = entry.key;
                        DescuentoGlobal d = entry.value;
                        
                        String nombreAMostrar = d.codigoItem;
                        if (d.tipo == 'COMODATO') {
                          nombreAMostrar = d.codigoItem == '7763' ? 'HEINEKEN' : 'AMSTEL';
                        }
                        
                        String textoDesc = d.esCaja ? "${d.cajas} Cajas" : "${d.cajas} Cajas / ${d.unds} Unidades";
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blue.shade100)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text("$nombreAMostrar: $textoDesc", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() { _descuentos.removeAt(idx); });
                                  setStateDialog(() { msgErrorInt = ""; }); 
                                },
                                child: const Icon(Icons.close, color: Colors.red, size: 18),
                              )
                            ],
                          )
                        );
                      }).toList(),
                    ]
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text("Cerrar", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: tipo == 'COMODATO' ? SistemaGuiasApp.beerGreen : Colors.orange[700], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () {
                    String cod = tipo == 'SDG' ? codeCtrl.text.trim() : marcaComodato;
                    if (cod.isEmpty) {
                      setStateDialog(() => msgErrorInt = "Te falta ingresar un codigo.");
                      return;
                    }
                    
                    if (!esEnvase && !esCaja) {
                      setStateDialog(() => msgErrorInt = "El codigo ingresado no existe.");
                      return;
                    }

                    int c = int.tryParse(cajCtrl.text) ?? 0;
                    int u = int.tryParse(undCtrl.text) ?? 0;

                    if (c == 0 && u == 0) {
                      setStateDialog(() => msgErrorInt = "Ingresa una cantidad a descontar.");
                      return;
                    }

                    if (tipo == "SDG" && esEnvase && u >= factorEnvase) {
                      setStateDialog(() => msgErrorInt = "En SDG, los envases sueltos maximos son ${factorEnvase - 1}. Si tienes mas, conviertelos a caja.");
                      return;
                    }

                    int totalCascosBase = 0;
                    int totalEnvasesBase = 0;

                    String boxCategoryToCheck = esCaja ? cod : catCaja;

                    for (var r in _inventario) {
                      int fac = r.factor;
                      int cCaja = r.cargaCaja;
                      int cUnd = r.cargaUnd;
                      int rCaja = r.rechazoCaja;
                      int rUnd = r.rechazoUnd;

                      if (fac > 1 && cUnd >= fac) { cCaja += cUnd ~/ fac; cUnd = cUnd % fac; }

                      int difCajas = cCaja - rCaja;
                      int difUnds = cUnd - rUnd;
                      int envasesNeto = (difCajas * fac) + difUnds;
                      if (envasesNeto < 0) envasesNeto = 0;

                      int netoGuia = r.ignoraCajas ? 0 : (envasesNeto / fac).ceil();

                      if (r.caja == boxCategoryToCheck) totalCascosBase += netoGuia;
                      if (esEnvase && r.pkg == cod) totalEnvasesBase += envasesNeto;
                    }

                    int cascosUsados = 0;
                    int envasesUsados = 0;

                    for (var d in _descuentos) {
                      String dCat = "";
                      int dFac = 1;
                      if (d.esCaja) {
                        dCat = d.codigoItem;
                      } else {
                        for (var v in catalogoRaw.values) {
                          if (v['pkg'] == d.codigoItem) { dCat = v['caja']; dFac = v['factor']; break; }
                        }
                      }

                      if (dCat == boxCategoryToCheck) {
                        if (d.tipo == 'COMODATO' || d.esCaja) {
                          cascosUsados += d.cajas;
                        }
                      }
                      
                      if (esEnvase && d.codigoItem == cod) {
                        if (d.tipo == 'SDG') {
                          envasesUsados += (d.cajas * dFac) + d.unds;
                        } else if (d.tipo == 'COMODATO') {
                          envasesUsados += d.unds;
                        }
                      }
                    }

                    int cascosDisponibles = totalCascosBase - cascosUsados;
                    int envasesDisponibles = totalEnvasesBase - envasesUsados;

                    if (tipo == 'COMODATO') {
                      if (c > cascosDisponibles) {
                        setStateDialog(() => msgErrorInt = "Excede el descuento. Solo te quedan $cascosDisponibles cajas disponibles.");
                        return;
                      }
                      if (u > envasesDisponibles) {
                        setStateDialog(() => msgErrorInt = "Excede el descuento. Solo te quedan $envasesDisponibles envases disponibles.");
                        return;
                      }
                    } else if (tipo == 'SDG') {
                      if (esCaja) {
                        if (c > cascosDisponibles) {
                          setStateDialog(() => msgErrorInt = "Excede el descuento. Solo te quedan $cascosDisponibles cajas $cod disponibles.");
                          return;
                        }
                      } else if (esEnvase) {
                        int totalSolicitadoEnvases = (c * factorEnvase) + u;
                        if (totalSolicitadoEnvases > envasesDisponibles) {
                          setStateDialog(() => msgErrorInt = "Excede el descuento. Intentas restar $totalSolicitadoEnvases envases, pero solo te quedan $envasesDisponibles.");
                          return;
                        }
                      }
                    }

                    setState(() { 
                      _descuentos.add(DescuentoGlobal(codigoItem: cod, esCaja: esCaja, cajas: c, unds: u, tipo: tipo));
                    });

                    setStateDialog(() { 
                      msgErrorInt = "";
                      codeCtrl.clear();
                      cajCtrl.clear();
                      undCtrl.clear();
                    });
                  },
                  child: const Text("Agregar", style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildHeaderBtn(String tipo, Color btnColor, Color bgColor) {
    return InkWell(
      onTap: () => _mostrarDialogoGlobal(tipo),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 85, 
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4), border: Border.all(color: btnColor.withOpacity(0.5))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Icon(Icons.add_circle_outline, size: 10, color: btnColor),
            const SizedBox(width: 4),
            Text(tipo, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: btnColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildVistaDigitacion() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.grey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.edit_document, size: 14, color: SistemaGuiasApp.primaryBlue),
                    SizedBox(width: 6),
                    Text("DIGITACION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: SistemaGuiasApp.primaryBlue)),
                  ],
                ),
                Row(
                  children: [
                    _buildHeaderBtn("COMODATO", SistemaGuiasApp.beerGreen, Colors.green[50]!),
                    const SizedBox(width: 6),
                    _buildHeaderBtn("SDG", Colors.orange[800]!, Colors.orange[50]!),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 40),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildCategoriaInput('7733', nombresCajas['7733']!),
                _buildCategoriaInput('7732', nombresCajas['7732']!),
                _buildCategoriaInput('31', nombresCajas['31']!),
                _buildCategoriaInput('7724', nombresCajas['7724']!),
                _buildCategoriaInput('7731', nombresCajas['7731']!),
                _buildCategoriaInput('SIN_CAJA', 'BIDONES / SIN CAJA'),
                _buildCategoriaInput('7749', nombresCajas['7749']!, colorIcono: SistemaGuiasApp.beerGreen),
                _buildCategoriaInput('7764', nombresCajas['7764']!, colorIcono: Colors.purple),
                
                const SizedBox(height: 25),
                const Center(
                  child: Text(
                    "© 2026 Uso exclusivo EMBID Juliaca.\nDesarrollado por el Area de Sistemas.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaInput(String idCaja, String titulo, {Color colorIcono = SistemaGuiasApp.primaryBlue}) {
    List<ProductoItem> grupo = _inventario.where((r) => r.caja == idCaja).toList();
    if (grupo.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 10, bottom: 6, left: 4, right: 4),
          decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2, left: 4),
                  child: Row(
                    children: [
                      Icon(Icons.inventory_2_rounded, size: 12, color: colorIcono),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(titulo, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey[800], letterSpacing: 0.5), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ),
              if (idCaja == '7733') ...[
                const SizedBox(width: 2),
                Expanded(
                  flex: 2, 
                  child: Column(
                    children: [
                      const Text("CARGA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: SistemaGuiasApp.success)),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Expanded(child: Center(child: Text("CAJAS", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: SistemaGuiasApp.success)))),
                          SizedBox(width: 2),
                          Expanded(child: Center(child: Text("UNID", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: SistemaGuiasApp.success)))),
                        ],
                      )
                    ],
                  )
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 2, 
                  child: Column(
                    children: [
                      const Text("RECHAZO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: SistemaGuiasApp.error)),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Expanded(child: Center(child: Text("CAJAS", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: SistemaGuiasApp.error)))),
                          SizedBox(width: 2),
                          Expanded(child: Center(child: Text("UNID", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: SistemaGuiasApp.error)))),
                        ],
                      )
                    ],
                  )
                ),
                const SizedBox(width: 24), 
              ] else ...[
                const SizedBox(width: 2),
                const Spacer(flex: 2),
                const SizedBox(width: 6),
                const Spacer(flex: 2),
                const SizedBox(width: 24),
              ]
            ],
          ),
        ),
        ...grupo.map((item) => _buildFilaUltraCompacta(item)).toList(),
      ],
    );
  }

  Widget _buildFilaUltraCompacta(ProductoItem item) {
    return Container(
      height: 34, 
      padding: const EdgeInsets.symmetric(horizontal: 4), 
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                const SizedBox(width: 2),
                Text(item.codigo, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black87)),
                const SizedBox(width: 4),
                Expanded(child: Text(item.desc, style: TextStyle(fontSize: 9, color: Colors.grey[800], fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          
          const SizedBox(width: 2),
          Expanded(flex: 1, child: _buildMicroInput(item.ctrlCCaja, (v) { item.cargaCaja = int.tryParse(v) ?? 0; _validarFila(item); })),
          const SizedBox(width: 2),
          Expanded(flex: 1, child: _buildMicroInput(item.ctrlCUnd, (v) { item.cargaUnd = int.tryParse(v) ?? 0; _validarFila(item); })),
          
          const SizedBox(width: 6),
          
          Expanded(flex: 1, child: _buildMicroInput(item.ctrlRCaja, (v) { item.rechazoCaja = int.tryParse(v) ?? 0; _validarFila(item); })),
          const SizedBox(width: 2),
          Expanded(flex: 1, child: _buildMicroInput(item.ctrlRUnd, (v) { item.rechazoUnd = int.tryParse(v) ?? 0; _validarFila(item); })),
          
          SizedBox(
            width: 24, 
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 15,
              constraints: const BoxConstraints(),
              icon: Icon(Icons.delete_outline, color: Colors.red[300]),
              onPressed: () => _limpiarFila(item),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMicroInput(TextEditingController ctrl, Function(String) onChanged) {
    return Container(
      height: 26, 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300, width: 1), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 2, offset: const Offset(0, 1))]
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black87, height: 1.1),
        textInputAction: TextInputAction.next,
        onChanged: onChanged,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 5), 
          fillColor: Colors.transparent, 
          filled: true,
          border: InputBorder.none, 
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildVistaResultados() {
    bool hayDatosGlobales = _inventario.any((r) => r.cargaCaja > 0 || r.cargaUnd > 0 || r.rechazoCaja > 0 || r.rechazoUnd > 0) || _descuentos.isNotEmpty;

    if (!hayDatosGlobales) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 50, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text("No hay datos digitados", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      );
    }

    Map<String, int> envasesUnificados = {};
    Map<String, int> cajasUnificadas = {};

    List<String> ordenEnvases = ['7700', '7693', '7605', '7728', '7661', '7603', '7659', '7114', '7566', '7567', '7666', '7660', '7602', '7682', '7606', '7665', '7538', '7763', '7766', '5722', '5719'];
    List<String> ordenCajas = ['7733', '7732', '7724', '7731', '31', '7749', '7764'];

    for (var k in ordenEnvases) { envasesUnificados[k] = 0; }
    for (var k in ordenCajas) { cajasUnificadas[k] = 0; }

    for (var r in _inventario) {
      int factor = r.factor;
      int cCaja = r.cargaCaja;
      int cUnd = r.cargaUnd;
      int rCaja = r.rechazoCaja;
      int rUnd = r.rechazoUnd;

      if (factor > 1 && cUnd >= factor) { cCaja += cUnd ~/ factor; cUnd = cUnd % factor; }

      int difCajas = cCaja - rCaja;
      int difUnds = cUnd - rUnd;
      int envasesNeto = (difCajas * factor) + difUnds;
      if (envasesNeto < 0) envasesNeto = 0;

      int netoGuia = r.ignoraCajas ? 0 : (envasesNeto / factor).ceil();

      if (cajasUnificadas.containsKey(r.caja)) {
        cajasUnificadas[r.caja] = cajasUnificadas[r.caja]! + netoGuia;
      }
      if (envasesUnificados.containsKey(r.pkg)) {
        envasesUnificados[r.pkg] = envasesUnificados[r.pkg]! + envasesNeto;
      }
    }

    for (var d in _descuentos) {
      if (d.esCaja) {
        if (cajasUnificadas.containsKey(d.codigoItem)) {
          cajasUnificadas[d.codigoItem] = cajasUnificadas[d.codigoItem]! - d.cajas;
        }
      } else {
        String catEnvase = "";
        int factor = 1;
        for (var v in catalogoRaw.values) {
          if (v['pkg'] == d.codigoItem) { 
             catEnvase = v['caja']; 
             factor = v['factor'];
             break; 
          }
        }

        if (d.tipo == "SDG") {
          int totalBotellasDescuento = (d.cajas * factor) + d.unds;
          if (envasesUnificados.containsKey(d.codigoItem)) {
            envasesUnificados[d.codigoItem] = envasesUnificados[d.codigoItem]! - totalBotellasDescuento;
          }
        } else if (d.tipo == "COMODATO") {
          if (cajasUnificadas.containsKey(catEnvase)) {
            cajasUnificadas[catEnvase] = cajasUnificadas[catEnvase]! - d.cajas;
          }
          if (envasesUnificados.containsKey(d.codigoItem)) {
            envasesUnificados[d.codigoItem] = envasesUnificados[d.codigoItem]! - d.unds;
          }
        }
      }
    }

    var envasesFinal = envasesUnificados.entries.where((e) => e.value != 0).toList();
    var cajasFinal = cajasUnificadas.entries.where((e) => e.value != 0).toList();

    return ListView(
      padding: const EdgeInsets.only(top: 10, bottom: 30),
      children: [
        if (envasesFinal.isNotEmpty)
          _buildTablaResultados("RESUMEN DE BOTELLAS", envasesFinal, Icons.liquor_rounded, Colors.blue[700]!, nombresEnvases),
        
        const SizedBox(height: 10),

        if (cajasFinal.isNotEmpty)
          _buildTablaResultados("RESUMEN DE CASCOS", cajasFinal, Icons.inventory_2_rounded, Colors.orange[800]!, nombresCajas),
      ],
    );
  }

  Widget _buildTablaResultados(String titulo, List<MapEntry<String, int>> datos, IconData icono, Color color, Map<String, String> nombres) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12))
            ),
            child: Row(
              children: [
                Icon(icono, color: color, size: 20),
                const SizedBox(width: 8),
                Text(titulo, style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 14)),
              ]
            )
          ),
          ...datos.map((e) {
            String nombre = nombres[e.key] ?? e.key;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${e.key} - $nombre", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 11)),
                  Text("${e.value}", style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 16)),
                ]
              )
            );
          }).toList()
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: SistemaGuiasApp.background,
        appBar: AppBar(
          backgroundColor: SistemaGuiasApp.primaryBlue,
          title: const Text('CALCULADORA DE ENVASES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white)),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white),
              onPressed: () => _mostrarTutorialDialog(false),
              tooltip: 'Ver Tutorial',
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40), 
            child: Container(
              height: 30, 
              margin: const EdgeInsets.only(left: 40, right: 40, bottom: 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
              child: TabBar(
                indicator: BoxDecoration(color: SistemaGuiasApp.accentYellow, borderRadius: BorderRadius.circular(16)),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.black87, 
                unselectedLabelColor: Colors.white60, 
                labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
                tabs: const [Tab(text: "DIGITACION"), Tab(text: "RESULTADOS")],
              ),
            ),
          ),
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            _buildVistaDigitacion(),
            _buildVistaResultados(),
          ],
        ),
      ),
    );
  }
}