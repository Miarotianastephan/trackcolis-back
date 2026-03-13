# trackcolis-back
Backend Application of Colis Tracking


Pour la BDD il faut executer 2 SQL dans les ordres suivantes :
-  trackcolis.sql en premier pour creer toutes les tables initials
- alter_to_models.sql pour corriger les correspondances avec les models 
- VERFIER enfin si toute les tables ont les memes structures que les models

## Gestion des Factures - API Routes

Toutes les routes ci-dessous nécessitent une authentification via le middleware `authenticate`. Ajoutez un header `Authorization: Bearer <your_token>` dans vos requêtes Postman.

### 1. Créer une Facture pour des Colis
- **Méthode** : `POST`
- **URL** : `/invoice`
- **Body (JSON)** :
  ```json
  {
    "colis_ids_array": [1, 2, 3],  // Tableau des IDs des colis (obligatoire, non vide)
    "invoice_type": "achat",       // Type de facture (obligatoire, string)
    "amount": 150.50               // Montant (obligatoire, nombre)
  }
  ```
- **Description** : Crée une facture et associe les colis spécifiés. Retourne la facture créée.
- **Test Postman** : Envoyez le body ci-dessus avec le header Authorization.

### 2. Récupérer une Facture par ID
- **Méthode** : `GET`
- **URL** : `/invoice/:invoice_id`
- **Paramètre URL** : `invoice_id` (ex: `/invoice/1`)
- **Description** : Récupère la facture avec ses colis associés.
- **Test Postman** : Remplacez `:invoice_id` par un ID valide, ajoutez le header Authorization.

### 3. Récupérer Toutes les Factures
- **Méthode** : `GET`
- **URL** : `/invoices`
- **Description** : Liste toutes les factures.
- **Test Postman** : Ajoutez le header Authorization, pas de body nécessaire.