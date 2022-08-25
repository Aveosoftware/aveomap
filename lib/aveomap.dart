library aveomap;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui' as ui;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:map_launcher/map_launcher.dart' as mapLaunch;

part 'src/widget/aveomap_widget.dart';
part 'src/controller/map_controller.dart';
part 'src/model/marker_model.dart';
part 'src/repository/repo.dart';
part 'src/widget/triangle_clipper.dart';
