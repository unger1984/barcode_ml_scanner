import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

export 'package:google_ml_kit/google_ml_kit.dart'
    show Barcode, BarcodeType, BarcodeValue;

const double _start = 0.0;
const double _end = 100.0;

final List<Alignment> _alignmentStartList = [
  Alignment.centerLeft,
  Alignment.bottomLeft,
  Alignment.bottomCenter,
  Alignment.bottomRight,
  Alignment.centerRight,
  Alignment.topRight,
  Alignment.topCenter,
  Alignment.topLeft,
];

final List<Alignment> _alignmentEndList = [
  Alignment.centerRight,
  Alignment.topRight,
  Alignment.topCenter,
  Alignment.topLeft,
  Alignment.centerLeft,
  Alignment.bottomLeft,
  Alignment.bottomCenter,
  Alignment.bottomRight,
];

class BarcodeMlScanner extends StatefulWidget {
  const BarcodeMlScanner({
    Key? key,
    this.onFound,
    this.borderOffset = 0.0,
    this.rectBorder = const BorderSide(
      color: Colors.yellow,
      width: 4,
    ),
    this.lineGradientStart = const Color(0xffEE8B7E),
    this.lineGradientEnd = Colors.yellow,
  }) : super(key: key);

  final void Function(List<Barcode> barcodes)? onFound;
  final double borderOffset;
  final BorderSide rectBorder;
  final Color lineGradientStart;
  final Color lineGradientEnd;

  @override
  BarcodeMlScannerState createState() => BarcodeMlScannerState();
}

class BarcodeMlScannerState extends State<BarcodeMlScanner>
    with SingleTickerProviderStateMixin {
  final BarcodeScanner barcodeScanner = GoogleMlKit.vision.barcodeScanner();
  CameraController? _controller;
  late AnimationController animationController;
  late Tween<double> tweenLinePosition;
  late Tween<double> tweenLineGradient;
  late Animation<double> position;
  late Animation<double> gradient;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;
  bool isBusy = false;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    tweenLinePosition = Tween<double>(begin: _start, end: _end);
    tweenLineGradient = Tween<double>(begin: 0.0, end: 7.0);
    position = tweenLinePosition.animate(animationController);
    gradient = tweenLineGradient.animate(animationController);
    Future.delayed(Duration.zero, _initCameras);
  }

  Future<void> _initCameras() async {
    _cameras = await availableCameras();
    _startLiveFeed();
    animationController.addListener(() {
      if (animationController.isCompleted) {
        animationController.reset();
        tweenLinePosition.begin =
            tweenLinePosition.begin == _start ? _end : _start;
        tweenLinePosition.end = tweenLinePosition.end == _end ? _start : _end;
        animationController.forward();
      }
    });
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    _stopLiveFeed();
    super.dispose();
  }

  Future<void> toggleCamera() async {
    await _stopLiveFeed();
    setState(() {
      _controller = null;
      _cameraIndex = _cameraIndex == _cameras.length - 1 ? 0 : _cameraIndex + 1;
      _startLiveFeed();
    });
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final onFound = widget.onFound;
    final barcodes = await barcodeScanner.processImage(inputImage);
    // print('Found ${barcodes.length} barcodes');
    if (barcodes.isNotEmpty && onFound != null) {
      onFound(barcodes);
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, snapshot) {
        return Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: CameraPreview(controller),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 50,
                right: 50,
                top: (MediaQuery.of(context).size.height / 2) -
                    130 -
                    widget.borderOffset,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border(
                            top: widget.rectBorder,
                            left: widget.rectBorder,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 200,
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border(
                            top: widget.rectBorder,
                            right: widget.rectBorder,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: widget.rectBorder,
                            left: widget.rectBorder,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 200,
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: widget.rectBorder,
                            right: widget.rectBorder,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 50,
                right: 50,
                top: (MediaQuery.of(context).size.height / 2) -
                    80 -
                    widget.borderOffset,
              ),
              child: Container(
                margin: EdgeInsets.only(top: position.value),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      begin: _alignmentStartList[gradient.value.toInt()],
                      end: _alignmentEndList[gradient.value.toInt()],
                      colors: [
                        widget.lineGradientStart,
                        widget.lineGradientEnd,
                      ], // red to yellow
                      tileMode: TileMode
                          .repeated, // repeats the gradient over the canvas
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.lineGradientStart.withOpacity(0.5),
                        spreadRadius: 10,
                        blurRadius: 7, // changes position of shadow
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _startLiveFeed() {
    final camera = _cameras[_cameraIndex];
    setState(() {
      _controller = CameraController(
        camera,
        ResolutionPreset.max,
        enableAudio: false,
      );
      _controller?.initialize().then((_) {
        if (!mounted) {
          return;
        }
        _controller?.startImageStream(_processCameraImage);
      });
    });
  }

  Future<void> _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = _cameras[_cameraIndex];
    final imageRotation =
        InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw as int) ??
            InputImageFormat.NV21;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    _processImage(inputImage);
  }
}
