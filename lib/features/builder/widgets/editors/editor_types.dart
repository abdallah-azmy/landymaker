import 'dart:async';
import 'package:flutter/material.dart';
import '../../controllers/builder_cubit.dart';

typedef GetController = TextEditingController Function(String key, String initialValue);
typedef GetFocusNode = FocusNode Function(String key);
typedef PickImage = FutureOr<void> Function(LandingPageBuilderCubit cubit, int index, {String? itemKey, int? itemIndex});
typedef PickAndUploadImage = FutureOr<void> Function(LandingPageBuilderCubit cubit, int index, {String? itemKey, int? itemIndex});
