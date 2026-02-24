# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project overview

- Node.js + Express backend for a parcel tracking application ("TrackColis").
- Uses Sequelize ORM with MySQL; models map to existing database tables with `trc_*` prefixes.
- Authentication is JWT-based, with role-based authorization for admin-only routes.

Key entry points:
- `src/server.js`: boots the HTTP server and reads `PORT`/`NODE_ENV`.
- `src/app.js`: configures Express middlewares, mounts routes, and handles errors.

## Setup and environment

Install dependencies:
- `npm install`

Environment configuration:
- Environment variables are accessed via `src/config/env.js` and `src/config/db.js`:
  - `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST` (MySQL connection)
  - `PORT` (optional, defaults to `3000`)
  - `NODE_ENV` (used only for logging in `server.js`)
- Auth-related env vars (see `src/services/auth.service.js` and `src/middleware/auth.middleware.js`):
  - `JWT_SECRET` (default fallback: `"replace_this_secret"` — override in real environments)
  - `JWT_EXPIRES_IN` (default: `"7d"`)
- `dotenv` is loaded in `src/app.js`, `auth.service.js`, and `auth.middleware.js`, so local development typically uses a `.env` file at the project root.

Database:
- Sequelize is configured in `src/config/db.js` and exported through `src/models/index.js`.
- There is no migration tooling in this repo; it expects the MySQL schema (tables `trc_user`, `trc_role`, `trc_colis`, `trc_colis_type`, `trc_facture`) to exist already.

## Common commands

From the project root:
- Install deps: `npm install`
- Start in development mode (auto-reload via nodemon): `npm run dev`
- Start in production mode: `npm start`

Testing and linting:
- `npm test` is defined but only as a placeholder (`echo "Error: no test specified" && exit 1`).
- There is currently no configured test framework or linting command; running individual tests is not applicable until a test setup is added.

## High-level architecture

### HTTP layer and routing

- Express app setup is in `src/app.js`:
  - Security and utility middlewares: `helmet`, `cors`, `morgan('dev')`, JSON/body parsing.
  - Routes mounted:
    - `/api/auth` → `src/routes/auth.routes.js`
    - `/api/colis` → `src/routes/colis.routes.js`
    - `/colis-types` → `src/routes/colyType.routes.js` (note: not under `/api`)
  - Root route `/` returns a simple JSON health check message.
  - 404 handler and generic 500 error handler are defined at the end of the middleware chain.

- Route modules:
  - `src/routes/auth.routes.js`:
    - `POST /api/auth/register` → `auth.controller.register`
    - `POST /api/auth/login` → `auth.controller.login`
  - `src/routes/colis.routes.js` (all protected by JWT `authenticate`, some additionally by `requireAdmin`):
    - `POST /api/colis` (admin only) → create parcel
    - `GET /api/colis/search` → search by tracking number or client name
    - `GET /api/colis` → list all parcels
    - `GET /api/colis/:package_id` → get parcel with details
    - `GET /api/colis/user/:user_id` → get parcels by user
    - `PATCH /api/colis/:package_id/status` (admin only) → update parcel status
  - `src/routes/colyType.routes.js`:
    - CRUD endpoints on `/colis-types` for `ColisType` (create, list, get by id, update, delete) using the model directly.

### Controllers and services

- Controllers live in `src/controllers` and are thin HTTP adapters that:
  - Parse and validate request data.
  - Call corresponding service functions.
  - Translate service results/errors into appropriate HTTP responses.

- `src/controllers/auth.controller.js`:
  - `register`:
    - Applies a default role (`DEFAULT_ROLE = 'user'`) when not provided.
    - Validates presence of `name`, `email`, `password`.
    - Delegates to `auth.service.register` and returns `{ user, token }` on success.
  - `login`:
    - Validates presence of `email`, `password`.
    - Delegates to `auth.service.login` and returns `{ user, token }`.

- `src/controllers/colis.controller.js`:
  - `createColis`, `getAllColis`, `getColisByIdWithDetails`, `getColisByUserId`, `updateColisStatus`, `searchColis`.
  - These all delegate to functions in `src/services/colis.service.js` and centralize HTTP error codes (400/401/404/500) based on error messages.

- Services in `src/services` encapsulate domain logic and DB access:
  - `auth.service.js`:
    - User registration with bcrypt password hashing and simple role string validation (`agent`,`admin`,`user`).
    - Login with credential verification.
    - JWT generation (`generateToken`) and user fetching (`getUserById`).
  - `colis.service.js`:
    - Creation of parcels, including validation, resolving `ColisType` by `type_id` or `type_label`, uniqueness of `tracking_number`, and verifying that `User` exists.
    - Fetching parcels with eager-loaded `ColisType` and `User` via Sequelize includes.
    - Status updates with validation against an explicit `validStatuses` set.
    - In-memory multi-criteria search that filters Sequelize results by `tracking_number` and client name (`role === 'user'`).

### Models and data layer

- All models are instantiated from the shared Sequelize instance (`src/config/db.js`) and wired together in `src/models/index.js`.

- Model files:
  - `src/models/user.model.js` (`User`): maps to `trc_user`.
  - `src/models/user_role.model.js` (`UserRole`): maps to `trc_role`.
  - `src/models/colis.model.js` (`Colis`): maps to `trc_colis`.
  - `src/models/colis_type.model.js` (`ColisType`): maps to `trc_colis_type`.
  - `src/models/facture.model.js` (`Facture`): maps to `trc_facture`.

- Associations configured in `src/models/index.js`:
  - Users no longer reference a separate role table; their `role` field is an ENUM stored directly on the `User` model.
  - `Colis.belongsTo(User, { foreignKey: 'user_id' })`
  - `Colis.belongsTo(ColisType, { foreignKey: 'type_id' })`
  - `Facture.belongsTo(Colis, { foreignKey: 'package_id' })`

These associations are leveraged in service functions using `include` clauses for joined queries.

### Authentication and authorization

- JWT authentication middleware: `src/middleware/auth.middleware.js`:
  - Expects an `Authorization: Bearer <token>` header.
  - Verifies the token using `JWT_SECRET` and fetches the user via `auth.service.getUserById`.
  - Attaches `req.user = { user_id, email, role_id }`.

- Authorization middleware: `src/middleware/authorize.middleware.js`:
  - `requireAdmin` ensures `req.user.role_id === 1` (admin role) or returns HTTP 403.

### Typical flow for adding a new resource

When adding a new domain resource (e.g., invoices API) follow this repo’s existing layering:
1. Define or update the Sequelize model in `src/models` and wire it in `src/models/index.js` (including associations as needed).
2. Add service functions in `src/services/<resource>.service.js` encapsulating business logic and Sequelize calls.
3. Add a controller in `src/controllers/<resource>.controller.js` to handle HTTP concerns and map to service functions.
4. Add a route file in `src/routes/<resource>.routes.js` that wires Express routes to controller methods, adding `authenticate`/`requireAdmin` where appropriate.
5. Mount the new routes in `src/app.js` under an appropriate base path.
