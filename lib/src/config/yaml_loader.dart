import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import 'app_config.dart';

/// Loads and parses YAML configuration files.
class YamlConfigLoader {
  /// Loads configuration from a YAML file in assets.
  static Future<AppConfig> loadFromAsset(String assetPath) async {
    try {
      final yamlString = await rootBundle.loadString(assetPath);
      return loadFromString(yamlString);
    } catch (e) {
      throw Exception('Failed to load YAML from asset: $assetPath. Error: $e');
    }
  }

  /// Loads configuration from a YAML string.
  static AppConfig loadFromString(String yamlString) {
    try {
      final yamlMap = loadYaml(yamlString);
      final map = _convertYamlToMap(yamlMap);
      return AppConfig.fromMap(map);
    } catch (e) {
      throw Exception('Failed to parse YAML configuration. Error: $e');
    }
  }

  /// Converts YamlMap to regular Map recursively.
  static Map<String, dynamic> _convertYamlToMap(dynamic yaml) {
    if (yaml is YamlMap) {
      final map = <String, dynamic>{};
      yaml.forEach((key, value) {
        map[key.toString()] = _convertYamlValue(value);
      });
      return map;
    }
    return {};
  }

  /// Converts YAML values to regular Dart types recursively.
  static dynamic _convertYamlValue(dynamic value) {
    if (value is YamlMap) {
      return _convertYamlToMap(value);
    } else if (value is YamlList) {
      return value.map((e) => _convertYamlValue(e)).toList();
    } else {
      return value;
    }
  }
}
