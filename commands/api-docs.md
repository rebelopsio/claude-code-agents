# /api-docs

Generate comprehensive API documentation from code.

## Usage

```
/api-docs [format] [options]
```

## Formats

- `openapi` - OpenAPI 3.0 specification
- `postman` - Postman collection
- `markdown` - Markdown documentation
- `asyncapi` - For event-driven APIs
- `graphql` - GraphQL schema docs

## Options

- `--include-examples` - Add request/response examples
- `--mock-server` - Generate mock server code
- `--sdk` - Generate client SDKs
- `--test-suite` - Generate test collection
- `--interactive` - Generate interactive docs

## What it does

1. **Scans codebase** for API endpoints
2. **Extracts metadata**: routes, parameters, responses
3. **Generates documentation** in chosen format
4. **Creates examples** from actual code/tests
5. **Produces artifacts**: SDKs, mocks, tests

## Example Output

```markdown
## API Documentation

### Base URL
```

https://api.example.com/v1

````

### Authentication
```http
Authorization: Bearer <token>
````

---

## Endpoints

### 📦 Products

#### GET /products

Get list of products with pagination and filtering.

**Query Parameters**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | integer | No | Page number (default: 1) |
| limit | integer | No | Items per page (default: 20) |
| category | string | No | Filter by category |
| search | string | No | Search in name/description |

**Response** `200 OK`

```json
{
  "data": [
    {
      "id": "prod_123",
      "name": "Premium Widget",
      "price": 29.99,
      "category": "widgets",
      "stock": 150,
      "images": ["https://..."]
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 145,
    "pages": 8
  }
}
```

**Response** `400 Bad Request`

```json
{
  "error": {
    "code": "INVALID_PARAMETER",
    "message": "Invalid category specified",
    "details": {
      "field": "category",
      "value": "invalid",
      "allowed": ["widgets", "gadgets", "tools"]
    }
  }
}
```

**cURL Example**

```bash
curl -X GET "https://api.example.com/v1/products?category=widgets&limit=10" \
  -H "Authorization: Bearer your_token_here"
```

**JavaScript SDK**

```javascript
const products = await client.products.list({
  category: "widgets",
  limit: 10,
});
```

---

#### POST /products

Create a new product (Admin only).

**Request Body**

```typescript
{
  name: string;           // Required, 1-100 chars
  description?: string;   // Optional, max 500 chars
  price: number;         // Required, > 0
  category: string;      // Required, enum
  stock?: number;        // Optional, default: 0
  images?: string[];     // Optional, max 10 URLs
}
```

**Example Request**

```json
{
  "name": "Ultra Widget Pro",
  "description": "The ultimate widget for professionals",
  "price": 99.99,
  "category": "widgets",
  "stock": 50,
  "images": ["https://cdn.example.com/widget-1.jpg", "https://cdn.example.com/widget-2.jpg"]
}
```

**Response** `201 Created`

```json
{
  "id": "prod_456",
  "name": "Ultra Widget Pro",
  "price": 99.99,
  "category": "widgets",
  "stock": 50,
  "images": [...],
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

**Validation Rules**

- `name`: Required, 1-100 characters, unique
- `price`: Required, positive number, max 2 decimal places
- `category`: Must be one of: widgets, gadgets, tools
- `images`: Valid URLs, max 10 items

---

### 🔐 Authentication

#### POST /auth/login

Authenticate user and receive tokens.

**Request**

```json
{
  "email": "user@example.com",
  "password": "secure_password"
}
```

**Response** `200 OK`

```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "expiresIn": 3600,
  "user": {
    "id": "user_123",
    "email": "user@example.com",
    "role": "customer"
  }
}
```

---

## OpenAPI Specification

```yaml
openapi: 3.0.0
info:
  title: Example API
  version: 1.0.0
  description: Product management API

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://staging-api.example.com/v1
    description: Staging

security:
  - bearerAuth: []

paths:
  /products:
    get:
      summary: List products
      tags: [Products]
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
      responses:
        "200":
          description: Success
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/ProductList"
```

## Generated SDK

```typescript
// Generated TypeScript SDK
export class APIClient {
  constructor(private apiKey: string) {}

  products = {
    list: async (params?: ProductListParams): Promise<ProductList> => {
      return this.request("GET", "/products", { params });
    },

    create: async (data: CreateProductDto): Promise<Product> => {
      return this.request("POST", "/products", { data });
    },

    get: async (id: string): Promise<Product> => {
      return this.request("GET", `/products/${id}`);
    },

    update: async (id: string, data: UpdateProductDto): Promise<Product> => {
      return this.request("PATCH", `/products/${id}`, { data });
    },

    delete: async (id: string): Promise<void> => {
      return this.request("DELETE", `/products/${id}`);
    },
  };
}
```

## Mock Server

```javascript
// Generated mock server
const mockServer = {
  "/products": {
    GET: (req) => ({
      data: generateMockProducts(req.query.limit || 20),
      pagination: {
        page: req.query.page || 1,
        limit: req.query.limit || 20,
        total: 145,
      },
    }),

    POST: (req) => ({
      id: `prod_${Date.now()}`,
      ...req.body,
      createdAt: new Date().toISOString(),
    }),
  },
};
```

````

## Implementation

```typescript
async function generateAPIDocs(format: string, options: APIDocOptions) {
  // Scan for API endpoints
  const endpoints = await scanAPIEndpoints();

  // Extract metadata using agent
  const documentation = await invokeAgent('technical-writer', {
    task: 'document-api',
    endpoints,
    includeExamples: options.includeExamples
  });

  // Generate chosen format
  const output = await generateFormat(format, documentation);

  // Generate additional artifacts
  if (options.sdk) {
    await generateSDK(documentation);
  }

  if (options.mockServer) {
    await generateMockServer(documentation);
  }

  return output;
}
````

## Related Commands

- `/api-test` - Generate API tests
- `/api-monitor` - Set up API monitoring
- `/api-version` - API versioning tools
