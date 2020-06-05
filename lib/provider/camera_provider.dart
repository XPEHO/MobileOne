import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CameraProvider with ChangeNotifier {
   File _imageFinale;
  FirebaseUser user;

  set imageFin(File imageFinale) {
    _imageFinale = imageFinale;
    notifyListeners();
  }

  set currentUser(FirebaseUser valeur){
    user = valeur;
    notifyListeners();
  }

  get imageFin => _imageFinale;
  get currentUser => user;
}