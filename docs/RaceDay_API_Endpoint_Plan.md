# RaceDay - API Endpoint Plan

This plan covers every endpoint required to support the functional requirements: **Authentication**, **User Profile**, **Events**, **Categories**, **Event Enrolments**, and **Results**[cite: 1]. It also includes supporting endpoints for **Routes** and **Weather**, which the participant-facing "prepare for race day" requirement depends on[cite: 1].

---

### Role Permissions Key
* **None**: Public endpoint (accessible without logging in)[cite: 1].
* **Any**: Any authenticated user (logged-in Participant or Organiser)[cite: 1].
* **Participant**: Only accessible by users with the Participant role[cite: 1].
* **Organiser**: Only accessible by users with the Organiser role[cite: 1].
* **Owner (Organiser)**: The specific Organiser who created the event, category, or resource being acted on[cite: 1].
* **Participant (Own)**: The specific Participant who owns the enrolment/registration or profile[cite: 1].

---

## 1. Authentication

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **POST** | `/api/auth/register` | Registers a new user as either a Participant or an Organiser[cite: 1]. | None | `{ firstName, lastName, email, password, role, phoneNumber }`[cite: 1] | `201 Created` - User object + auth token[cite: 1].<br>`400 Bad Request` - Email already registered or missing fields[cite: 1]. |
| **POST** | `/api/auth/login` | Authenticates a user and issues an auth token[cite: 1]. | None | `{ email, password }`[cite: 1] | `200 OK` - Auth token + user object[cite: 1].<br>`401 Unauthorized` - Invalid credentials[cite: 1]. |

---

## 2. User Profile

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **GET** | `/api/users/me` | Returns the logged-in user's own profile[cite: 1]. | Any | None[cite: 1] | `200 OK` - User object[cite: 1].<br>`401 Unauthorized` - No or invalid token[cite: 1]. |
| **PUT** | `/api/users/me` | Updates the logged-in user's own profile details[cite: 1]. | Any | `{ firstName, lastName, phoneNumber, email }`[cite: 1] | `200 OK` - Updated user object[cite: 1].<br>`400 Bad Request` - Invalid data[cite: 1]. |
| **GET** | `/api/users/me/registrations` | Lists the logged-in participant's past and upcoming event entries[cite: 1]. | Participant | None[cite: 1] | `200 OK` - Array of registrations (with event and category summary)[cite: 1]. |
| **GET** | `/api/users/me/results` | Returns the logged-in participant's personal performance history across all events entered[cite: 1]. | Participant | None[cite: 1] | `200 OK` - Array of result records (with event and category summary)[cite: 1]. |

---

## 3. Events

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **GET** | `/api/events` | Lists all upcoming/published events. Supports optional `?date=` and `location` filters[cite: 1]. | None | None[cite: 1] | `200 OK` - Array of event objects[cite: 1]. |
| **GET** | `/api/events/{id}` | Returns full details for a single event, including its categories and route summary[cite: 1]. | None | None[cite: 1] | `200 OK` - Event object[cite: 1].<br>`404 Not Found` - Event does not exist[cite: 1]. |
| **POST** | `/api/events` | Creates a new event owned by the logged-in organiser[cite: 1]. | Organiser | `{ eventName, eventDate, location, description }`[cite: 1] | `201 Created` - Event object[cite: 1].<br>`400 Bad Request` - Missing/invalid fields[cite: 1]. |
| **PUT** | `/api/events/{id}` | Updates an event's details[cite: 1]. | Owner (Organiser) | `{ eventName, eventDate, location, description, status }`[cite: 1] | `200 OK` - Updated event object[cite: 1].<br>`403 Forbidden` - Not the event owner[cite: 1].<br>`404 Not Found`[cite: 1]. |
| **DELETE** | `/api/events/{id}` | Cancels/removes an event[cite: 1]. | Owner (Organiser) | None[cite: 1] | `204 No Content`[cite: 1].<br>`403 Forbidden` - Not the event owner[cite: 1].<br>`404 Not Found`[cite: 1]. |
| **GET** | `/api/events/{id}/route` | Returns route/course details for an event (distance, elevation, start location, GPX file)[cite: 1]. | None | None[cite: 1] | `200 OK` - Route object[cite: 1].<br>`404 Not Found` - Event or route does not exist[cite: 1]. |
| **POST** | `/api/events/{id}/route` | Adds a route to an event[cite: 1]. | Owner (Organiser) | `{ routeName, distanceKm, elevationGainM, startLocation, gpxFilePath }`[cite: 1] | `201 Created` - Route object[cite: 1].<br>`403 Forbidden` - Not the event owner[cite: 1]. |
| **GET** | `/api/events/{id}/weather` | Returns the live/forecast weather for the event's date and location[cite: 1]. | None | None[cite: 1] | `200 OK` - Weather summary object[cite: 1].<br>`404 Not Found` - Event does not exist[cite: 1]. |

---

## 4. Categories

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **GET** | `/api/events/{id}/categories` | Lists all categories (distances/divisions) for an event[cite: 1]. | None | None[cite: 1] | `200 OK` - Array of category objects[cite: 1].<br>`404 Not Found` - Event does not exist[cite: 1]. |
| **POST** | `/api/events/{id}/categories` | Adds a new category to an event[cite: 1]. | Owner (Organiser) | `{ categoryName, routeId, distanceKm, entryFee, maxParticipants }`[cite: 1] | `201 Created` - Category object[cite: 1].<br>`403 Forbidden` - Not the event owner[cite: 1]. |
| **PUT** | `/api/categories/{id}` | Updates a category's details[cite: 1]. | Owner (Organiser) | `{ categoryName, distanceKm, entryFee, maxParticipants }`[cite: 1] | `200 OK` - Updated category object[cite: 1].<br>`403 Forbidden`<br>`404 Not Found`[cite: 1]. |
| **DELETE** | `/api/categories/{id}` | Removes a category from an event[cite: 1]. | Owner (Organiser) | None[cite: 1] | `204 No Content`[cite: 1].<br>`403 Forbidden`<br>`404 Not Found` - Category does not exist[cite: 1]. |

---

## 5. Event Enrolments (Registrations)

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **POST** | `/api/categories/{id}/register` | Enters the logged-in participant into a category, generating a bib number[cite: 1]. | Participant | `{ paymentReference }` (optional)[cite: 1] | `201 Created` - Registration object with bib number[cite: 1].<br>`400 Bad Request` - Category full[cite: 1].<br>`409 Conflict` - Already registered[cite: 1]. |
| **GET** | `/api/events/{id}/registrations` | Lists everyone registered for an event, for organiser race-day management[cite: 1]. | Owner (Organiser) | None[cite: 1] | `200 OK` - Array of registration objects[cite: 1].<br>`403 Forbidden` - Not the event owner[cite: 1]. |
| **GET** | `/api/registrations/{id}` | Returns a single registration's details[cite: 1]. | Owner (Organiser) or Participant (Own)[cite: 1] | None[cite: 1] | `200 OK` - Registration object[cite: 1].<br>`403 Forbidden`<br>`404 Not Found`[cite: 1]. |
| **DELETE** | `/api/registrations/{id}` | Withdraws/cancels a registration[cite: 1]. | Participant (Own registration)[cite: 1] | None[cite: 1] | `204 No Content`[cite: 1].<br>`403 Forbidden` - Not the registration owner[cite: 1].<br>`404 Not Found`[cite: 1]. |

---

## 6. Results

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **POST** | `/api/registrations/{id}/result` | Captures a finish result against a participant's registration[cite: 1]. | Owner (Organiser) | `{ finishTime, overallPosition, categoryPosition, resultStatus }`[cite: 1] | `201 Created` - Result object[cite: 1].<br>`400 Bad Request` - Result already captured[cite: 1].<br>`403 Forbidden` - Not the event owner[cite: 1]. |
| **GET** | `/api/events/{id}/results` | Returns the full results list/leaderboard for an event, optionally filtered by `?categoryId=`[cite: 1]. | None | None[cite: 1] | `200 OK` - Array of result objects[cite: 1].<br>`404 Not Found` - Event does not exist[cite: 1]. |
| **PUT** | `/api/results/{id}` | Corrects an existing result (e.g., after a timing dispute)[cite: 1]. | Owner (Organiser) | `{ finishTime, overallPosition, categoryPosition, resultStatus }`[cite: 1] | `200 OK` - Updated result object[cite: 1].<br>`403 Forbidden`<br>`404 Not Found`[cite: 1]. |

---

## Notes on Deviations & Security

1. **Route and Weather Endpoints**: These endpoints are nested under `/api/events/{id}/...`[cite: 1]. Although not explicitly titled as a section header in the brief, they satisfy the requirement for participants to *"prepare for race day using live weather and route information"*[cite: 1].
2. **Resource Ownership Enforcement**: The **"Owner (Organiser)"** role permission requires the API layer to verify that the logged-in Organiser's `UserId` matches the `OrganiserId` attached to the event being edited or managed[cite: 1].
