/*
 * # Copyright (c) 2016-2017 The Khronos Group Inc.
 * # Copyright (c) 2016 Alexey Knyazev
 * #
 * # Licensed under the Apache License, Version 2.0 (the "License");
 * # you may not use this file except in compliance with the License.
 * # You may obtain a copy of the License at
 * #
 * #     http://www.apache.org/licenses/LICENSE-2.0
 * #
 * # Unless required by applicable law or agreed to in writing, software
 * # distributed under the License is distributed on an "AS IS" BASIS,
 * # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * # See the License for the specific language governing permissions and
 * # limitations under the License.
 */

import 'dart:io';

import 'package:test/test.dart';
import 'package:gltf/gltf.dart';
import 'package:gltf/src/errors.dart';

import '../utils.dart';

void main() {
  group('Animation', () {
    test('Empty array', () async {
      final reader = new GltfJsonReader(
          new File('test/base/data/animation/empty.gltf').openRead());

      final context = new Context()
        ..path.add('animations')
        ..addIssue(SchemaError.emptyEntity);

      await reader.read();

      expect(reader.context.issues, unorderedMatches(context.issues));
    });

    test('Custom Property', () async {
      final reader = new GltfJsonReader(
          new File('test/base/data/animation/custom_property.gltf').openRead(),
          ignoreUnusedContext);

      final context = new Context()
        ..path.add('animations')
        ..path.add('0')
        ..addIssue(SchemaError.unexpectedProperty, name: 'customProperty')
        ..path.add('channels')
        ..path.add('0')
        ..addIssue(SchemaError.unexpectedProperty, name: 'customProperty')
        ..addIssue(SchemaError.undefinedProperty, args: ['sampler'])
        ..path.add('target')
        ..addIssue(SchemaError.unexpectedProperty, name: 'customProperty')
        ..addIssue(SchemaError.undefinedProperty, args: ['path'])
        ..path.removeLast()
        ..path.removeLast()
        ..path.removeLast()
        ..path.add('samplers')
        ..path.add('0')
        ..addIssue(SchemaError.undefinedProperty, args: ['input'])
        ..addIssue(SchemaError.undefinedProperty, args: ['output'])
        ..addIssue(SchemaError.unexpectedProperty, name: 'customProperty');

      await reader.read();

      expect(reader.context.issues, unorderedMatches(context.issues));
    });

    test('Unresolved references', () async {
      final reader = new GltfJsonReader(
          new File('test/base/data/animation/unresolved_references.gltf')
              .openRead(),
          ignoreUnusedContext);

      final context = new Context()
        ..path.add('animations')
        ..path.add('0')
        ..path.add('channels')
        ..path.add('0')
        ..addIssue(LinkError.unresolvedReference, name: 'sampler', args: [1])
        ..path.add('target')
        ..addIssue(LinkError.unresolvedReference, name: 'node', args: [0])
        ..path.removeLast()
        ..path.removeLast()
        ..path.removeLast()
        ..path.add('samplers')
        ..path.add('0')
        ..addIssue(LinkError.unresolvedReference, name: 'input', args: [0])
        ..addIssue(LinkError.unresolvedReference, name: 'output', args: [1]);

      await reader.read();

      expect(reader.context.issues, unorderedMatches(context.issues));
    });

    test('Misc', () async {
      final reader = new GltfJsonReader(
          new File('test/base/data/animation/misc.gltf').openRead(),
          ignoreUnusedContext);

      final context = new Context()
        ..path.add('animations')
        ..path.add('0')
        ..path.add('samplers')
        ..path.add('0')
        ..addIssue(LinkError.animationSamplerInputAccessorInvalidFormat,
            name: 'input',
            args: [
              '{VEC2, FLOAT}',
              ['{SCALAR, FLOAT}']
            ])
        ..addIssue(LinkError.animationSamplerInputAccessorWithoutBounds,
            name: 'input')
        ..addIssue(LinkError.accessorUsageOverride,
            name: 'output', args: ['AnimationInput', 'AnimationOutput'])
        ..path.removeLast()
        ..path.removeLast()
        ..path.add('channels')
        ..path.add('0')
        ..addIssue(LinkError.animationChannelTargetNodeMatrix, name: 'target')
        ..addIssue(LinkError.animationSamplerOutputAccessorInvalidFormat,
            name: 'sampler',
            args: [
              '{SCALAR, FLOAT}',
              ['{VEC3, FLOAT}'],
              'scale'
            ])
        ..addIssue(LinkError.animationSamplerOutputAccessorInvalidCount,
            name: 'sampler', args: [6, 2])
        ..path.removeLast()
        ..path.add('1')
        ..addIssue(LinkError.animationChannelTargetNodeWeightsNoMorphs,
            name: 'target')
        ..addIssue(LinkError.animationSamplerOutputAccessorInvalidCount,
            name: 'sampler', args: [0, 2])
        ..path.removeLast()
        ..path.add('2')
        ..addIssue(LinkError.animationSamplerOutputAccessorInvalidCount,
            name: 'sampler', args: [6, 3])
        ..addIssue(LinkError.animationDuplicateTargets,
            name: 'target', args: [3])
        ..path.removeLast()
        ..path.add('3')
        ..addIssue(LinkError.animationSamplerOutputAccessorInvalidCount,
            name: 'sampler', args: [6, 3])
        ..path.removeLast()
        ..path.removeLast()
        ..path.removeLast()
        ..path.removeLast()
        ..path.add('nodes')
        ..addIssue(SemanticError.nodeEmpty, index: 0)
        ..addIssue(SemanticError.nodeEmpty, index: 1);

      await reader.read();

      expect(reader.context.issues, unorderedMatches(context.issues));
    });

    test('Override interpolation', () async {
      final reader = new GltfJsonReader(
          new File('test/base/data/animation/override_interpolation.gltf')
              .openRead());

      final context = new Context()
        ..path.add('animations')
        ..path.add('0')
        ..path.add('samplers')
        ..path.add('1')
        ..path.add('output')
        ..addIssue(LinkError.animationSamplerOutputInterpolation);

      await reader.read();

      expect(reader.context.issues, unorderedMatches(context.issues));
    });

    test('Too few cubic frames', () async {
      final reader = new GltfJsonReader(
          new File('test/base/data/animation/too_few_cubic_frames.gltf')
              .openRead());

      final context = new Context()
        ..path.add('animations')
        ..path.add('0')
        ..path.add('samplers')
        ..path.add('0')
        ..path.add('input')
        ..addIssue(LinkError.animationSamplerInputAccessorTooFewElements,
            args: ['CUBICSPLINE', 2, 1]);

      await reader.read();

      expect(reader.context.issues, unorderedMatches(context.issues));
    });

    test('Valid', () async {
      final reader = new GltfJsonReader(
          new File('test/base/data/animation/valid_full.gltf').openRead());

      final result = await reader.read();

      final context = new Context()
        ..path.add('nodes')
        ..path.add('0')
        ..addIssue(SemanticError.nodeEmpty);

      expect(reader.context.issues, unorderedMatches(context.issues));

      expect(result.gltf.animations.toString(),
          '[{channels: [{sampler: 0, target: {node: 0, path: scale, extensions: {}}, extensions: {}}], samplers: [{input: 0, interpolation: LINEAR, output: 1, extensions: {}}], extensions: {}}]');
    });
  });
}
