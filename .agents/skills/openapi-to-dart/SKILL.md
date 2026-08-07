---
name: "implementing-openapi-in-dart"
description: "Reads an OpenAPI 3.0 specification and manually implements a type-safe Dart API layer using Dio for HTTP, Freezed or Equatable for models, and json_serializable for serialisation. Use when given an OpenAPI/Swagger file (JSON or YAML) and asked to implement the API in Flutter/Dart, create Dart models from an API schema, build a Dio API client, implement endpoints from a spec, convert openapi to dart, or set up a data/network layer from an API contract. Handles $ref resolution, oneOf union types, enums, query params, request bodies, and DioException error mapping."
metadata:
  last_modified: "2026-04-27 17:41:00 (GMT+8)"
---

# Implementing OpenAPI 3.0 in Dart

Given an OpenAPI 3.0 spec, implement a type-safe Dart API layer with:
- **Freezed** (or **Equatable**) for models
- **Dio** for HTTP with interceptors and error handling
- **json_serializable** for JSON serialisation

## Process

1. Read the OpenAPI spec — parse `components/schemas` for models, `paths` for endpoints.
2. Map schemas → Dart models (Freezed or Equatable — see [Model Strategy](#model-strategy)).
3. Map paths → Dio service methods.
4. Add a repository layer that wraps the service.
5. Wire error handling via `DioException` → domain `ApiError`.

---

## Dependencies

```yaml
dependencies:
  dio: ^5.9.2
  freezed_annotation: ^3.1.0   # if using Freezed
  json_annotation: ^4.11.0
  equatable: ^2.0.5             # if using Equatable

dev_dependencies:
  build_runner: ^2.14.1
  freezed: ^3.2.5               # if using Freezed
  json_serializable: ^6.13.1
```

---

## Directory Structure

```
lib/
└── data/
    ├── network/
    │   ├── dio_client.dart          # Dio instance + interceptors
    │   ├── api_error.dart           # global error model
    │   └── services/
    │       └── product_service.dart # one file per resource tag
    └── models/
        ├── product.dart
        └── ...
```

---

## Dio Client Setup

```dart
import 'package:dio/dio.dart';

Dio createDioClient({required String baseUrl, String? accessToken}) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
      handler.next(options);
    },
    onError: (error, handler) {
      // Convert DioException to domain ApiError before propagating
      handler.next(error);
    },
  ));

  return dio;
}
```

---

## Model Strategy

| Use case | Package | When |
|---|---|---|
| Needs `copyWith`, pattern matching, union types (`oneOf`) | **Freezed** | Complex domain models |
| Only needs value equality (`==` / `hashCode`) | **Equatable** | Simple request/response DTOs |

### Freezed Model (complex / union types)

```dart
// OpenAPI: components/schemas/Product
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
sealed class Product with _$Product {
  const factory Product({
    required String id,
    required String title,
    required double price,
    @JsonKey(name: 'created_at') DateTime? createdAt, // snake_case from spec
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
```

### Equatable Model (simple DTO)

```dart
// OpenAPI: components/schemas/CreateProductRequest
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_product_request.g.dart';

@JsonSerializable()
class CreateProductRequest extends Equatable {
  const CreateProductRequest({required this.title, required this.price});

  final String title;
  final double price;

  Map<String, dynamic> toJson() => _$CreateProductRequestToJson(this);

  @override
  List<Object?> get props => [title, price];
}
```

---

## Type Mapping

### Primitives

| OpenAPI | Dart |
|---|---|
| `string` | `String` |
| `integer` | `int` |
| `number` | `double` |
| `boolean` | `bool` |
| `string` / `format: date-time` | `DateTime` |
| `string` / `format: uuid` | `String` |
| `string` / `format: uri` | `Uri` |

### Nullability

- Property in `required` array → non-nullable (`String id`)
- Property NOT in `required` → nullable (`String? name`)

### Enum

```dart
// OpenAPI: type: string, enum: [active, draft, archived]
@JsonEnum(fieldRename: FieldRename.snake)
enum ProductStatus { active, draft, archived }
```

### oneOf / Union Types → Freezed sealed

```dart
// OpenAPI: oneOf: [{$ref: Cat}, {$ref: Dog}]
@freezed
sealed class Pet with _$Pet {
  const factory Pet.cat(Cat data) = _PetCat;
  const factory Pet.dog(Dog data) = _PetDog;

  factory Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);
}

// Exhaustive pattern matching at the call site:
switch (pet) {
  case Pet(:final cat): ...
  case Pet(:final dog): ...
}
```

### $ref Resolution

`{"$ref": "#/components/schemas/Product"}` → use `Product` class directly. Never inline duplicate definitions.

---

## Service Layer (Dio)

One service class per OpenAPI tag. Method signatures follow: `{httpMethod}{Resource}`.

```dart
// Covers: GET /products, POST /products, GET /products/{id}
class ProductService {
  const ProductService(this._dio);
  final Dio _dio;

  Future<List<Product>> getProducts({int page = 1, int limit = 20}) async {
    final response = await _dio.get<List<dynamic>>(
      '/products',
      queryParameters: {'page': page, 'limit': limit},
    );
    return response.data!.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Product> getProduct(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/products/$id');
    return Product.fromJson(response.data!);
  }

  Future<Product> createProduct(CreateProductRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/products',
      data: request.toJson(),
    );
    return Product.fromJson(response.data!);
  }
}
```

---

## Error Handling

Define a global error model matching the spec's error schema:

```dart
@freezed
sealed class ApiError with _$ApiError {
  const factory ApiError({
    required int status,
    required String message,
    String? detail,
  }) = _ApiError;

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);
}
```

Wrap Dio calls in the repository to catch `DioException`:

```dart
class ProductRepository {
  const ProductRepository(this._service);
  final ProductService _service;

  Future<List<Product>> fetchProducts({int page = 1}) async {
    try {
      return await _service.getProducts(page: page);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw ApiError.fromJson(e.response!.data as Map<String, dynamic>);
      }
      rethrow;
    }
  }
}
```

---

## Naming Conventions

| OpenAPI element | Dart name |
|---|---|
| `components/schemas/ProductItem` | `class ProductItem` |
| `POST /products` request body | `CreateProductRequest` |
| `GET /products` response | `List<Product>` or `typedef GetProductsResponse = List<Product>` |
| `snake_case` JSON key | `@JsonKey(name: 'snake_case')` on camelCase field |

---

## Constraints

- **No `!` operator**: rely on nullability — if spec says required, make it non-nullable.
- **Never duplicate `$ref` schemas**: reference the class; do not inline.
- **Use `@JsonKey(name: ...)` for naming mismatches** — do not rename the JSON key, rename the Dart field.
- **Equatable vs Freezed**: default to Freezed for domain models; use Equatable for pure request DTOs that don't need `copyWith`.
- **DioException always caught at repository level** — services throw raw, repositories map to `ApiError`.
- Run `dart run build_runner build --delete-conflicting-outputs` after generating models.

## Old Patterns (pre-Freezed 3)

Freezed 2.x used `abstract class` instead of `sealed class`. Both patterns still work, but prefer `sealed` for exhaustive pattern matching with Dart 3.

```yaml
# Freezed 2.x (no longer recommended)
dependencies:
  freezed_annotation: ^2.4.1

dev_dependencies:
  freezed: ^2.5.2
```
