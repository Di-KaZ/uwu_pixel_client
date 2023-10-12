// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameConfig _$GameConfigFromJson(Map<String, dynamic> json) => GameConfig(
      json['width'] as int,
      json['height'] as int,
      (json['pixels'] as List<dynamic>)
          .map((e) => Pixel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GameConfigToJson(GameConfig instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'pixels': instance.pixels,
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameConfigHash() => r'6a5d3194f65ed27b012fa5d9631f03f65a6792da';

/// See also [gameConfig].
@ProviderFor(gameConfig)
final gameConfigProvider = AutoDisposeFutureProvider<GameConfig>.internal(
  gameConfig,
  name: r'gameConfigProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$gameConfigHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GameConfigRef = AutoDisposeFutureProviderRef<GameConfig>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, inference_failure_on_uninitialized_variable, inference_failure_on_function_return_type, inference_failure_on_untyped_parameter
