
import 'package:flutter/material.dart';

class GalleryTextScaleValue{

  final double scale;
  final String label;

  const GalleryTextScaleValue(this.scale,this.label);

  /*equal 方法 runtimeType 获取类运行时 的类型*/
  @override
  bool operator ==(other) {
    if(runtimeType!=other.runtimeType){
      return false;
    }
    final GalleryTextScaleValue typeOther = other;
    return scale == typeOther.scale && label == typeOther.label;
  }

  @override
  String toString() {
    // TODO: implement toString
    return '$runtimeType($label)';
  }
}

const List<GalleryTextScaleValue> kAllGalleryTextScaleValues = <GalleryTextScaleValue>[
  GalleryTextScaleValue(null, 'System Default'),
  GalleryTextScaleValue(0.8, 'Small'),
  GalleryTextScaleValue(1.0, 'Normal'),
  GalleryTextScaleValue(1.3, 'Large'),
  GalleryTextScaleValue(2.0, 'Huge'),
];