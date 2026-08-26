# HealthPH+ Mobile Schema Handoff

Date: August 7, 2026  
Prepared for: HealthPH+ Web and Mobile Integration  
Prepared by: HealthPH+ Mobile Team

## Purpose

This document describes the current mobile data structures used by HealthPH+ for two functional features:

- Health Literacy Hub
- Self-Reporting in Data Collection

The goal is to help the web/backend team create a unified schema and API contract that both the web application and mobile application can fetch from later.

## Integration Goal

The recommended direction is:

```text
HealthPH+ Mobile App
  -> Backend API
  -> Shared Database

HealthPH+ Web App
  -> Backend API
  -> Shared Database
```

The mobile app currently uses local/static content for Health Literacy and SQLite-backed local storage for Self-Reports. The schemas below are proposed shared backend schemas based on the current mobile feature fields.

## Canonical ID Direction

The mobile app now keeps user-facing labels for display, but stores and exports stable canonical IDs for backend/web integration.

Recommended rule:

```text
Use `id` fields for storage, sync, filtering, and modeling.
Use `label` fields only for UI display, CSV readability, and human review.
```

### User Role IDs

```json
[
  { "id": "guest", "label": "Guest Tester" },
  { "id": "citizen", "label": "Citizen" },
  { "id": "field_health_worker", "label": "Field Health Worker" },
  { "id": "lgu_doh_user", "label": "LGU/DOH User" }
]
```

### Reporter Type IDs

```json
[
  { "id": "guest", "label": "Guest" },
  { "id": "registered", "label": "Registered" }
]
```

## Health Literacy Hub

### Current Mobile Feature

The mobile Health Literacy Hub currently displays:

- Health article cards
- Fact-checking cards
- Article images
- Source/author text
- Descriptions
- Tags
- External article links
- Search/filter by title and tags
- Tabs for Health Articles and Fact Checker

### Proposed Collection

Collection name:

```text
health_literacy_contents
```

### Proposed Schema

```js
HealthLiteracyContent {
  _id: ObjectId,

  contentType: "article" | "video" | "infographic" | "fact_check",

  title: String,
  description: String,

  // For articles, videos, and infographics
  source: String,
  author: String,
  publishedDate: Date,
  externalUrl: String,
  imageUrl: String,
  mediaUrl: String,

  // For fact-checking content
  claim: String,
  verdict: "True" | "Mostly True" | "Needs Context" | "False",
  explanation: String,

  tags: [String],
  topics: [String],
  diseases: [String],

  language: "en" | "fil" | "ceb" | "ilo" | "hil",

  isPublished: Boolean,
  publishToMobile: Boolean,

  viewCount: Number,
  shareCount: Number,

  createdAt: Date,
  updatedAt: Date
}
```

### Example Article Record

```json
{
  "contentType": "article",
  "title": "Protect Your Lungs from Common Respiratory Issues",
  "description": "Learn how to prevent common respiratory issues and protect your lungs.",
  "source": "Doctor Anywhere Team - Community Health",
  "author": "Doctor Anywhere Team",
  "publishedDate": null,
  "externalUrl": "https://www.doctoranywhere.ph/post/prevent-common-respiratory-issues",
  "imageUrl": "assets/images/protectyourlungs.png",
  "mediaUrl": null,
  "tags": ["lungs", "prevention", "wellness"],
  "topics": ["lung health", "prevention"],
  "diseases": ["respiratory"],
  "language": "en",
  "isPublished": true,
  "publishToMobile": true,
  "viewCount": 0,
  "shareCount": 0
}
```

### Example Fact Check Record

```json
{
  "contentType": "fact_check",
  "title": "Steam inhalation cures respiratory infections.",
  "description": "Steam may relieve congestion, but it does not cure infections.",
  "claim": "Steam inhalation cures respiratory infections.",
  "verdict": "Needs Context",
  "explanation": "Steam may relieve congestion, but it does not cure infections.",
  "source": "HealthPH+ Fact Checker",
  "author": "HealthPH+ Team",
  "externalUrl": null,
  "imageUrl": null,
  "mediaUrl": null,
  "tags": ["respiratory", "fact-check", "infection"],
  "topics": ["misinformation", "respiratory health"],
  "diseases": ["respiratory"],
  "language": "en",
  "isPublished": true,
  "publishToMobile": true,
  "viewCount": 0,
  "shareCount": 0
}
```

### Suggested API Endpoints

```text
GET /api/health-literacy/mobile
GET /api/health-literacy/mobile?contentType=article
GET /api/health-literacy/mobile?contentType=video
GET /api/health-literacy/mobile?contentType=infographic
GET /api/health-literacy/mobile?contentType=fact_check
POST /api/health-literacy/analytics/events
```

### Suggested Mobile Response Shape

```json
{
  "items": [
    {
      "id": "content_id",
      "contentType": "article",
      "title": "Protect Your Lungs from Common Respiratory Issues",
      "description": "Learn how to prevent common respiratory issues and protect your lungs.",
      "source": "Doctor Anywhere Team - Community Health",
      "externalUrl": "https://www.doctoranywhere.ph/post/prevent-common-respiratory-issues",
      "imageUrl": "https://domain.com/media/protectyourlungs.png",
      "tags": ["lungs", "prevention", "wellness"],
      "language": "en"
    }
  ]
}
```

## Self-Reporting Feature

### Current Mobile Feature

The mobile Data Collection page allows users to submit respiratory self-reports with:

- Region
- Province
- City/Municipality
- Barangay
- Symptoms
- Possible/consideration condition
- Notes
- Created timestamp
- Latitude
- Longitude
- Geocoded address

Self-reports are currently:

- Saved locally in SQLite
- Reflected in My Reports
- Added as pins in Disease Map Surveillance
- Exportable as CSV for higher-role users

### Current Mobile SQLite Fields

SQLite table:

```text
self_reports
```

Fields:

```text
id
region
province
city
barangay
symptom_ids
symptoms
possible_condition_id
possible_condition
notes
created_at
latitude
longitude
geocoded_address
```

### Proposed Collection

Collection name:

```text
self_reports
```

### Proposed Schema

```js
SelfReport {
  _id: ObjectId,

  reporter: {
    userId: ObjectId | null,
    reporterType: "guest" | "registered",
    roleId: "guest" | "citizen" | "field_health_worker" | "lgu_doh_user",
    roleLabel: String,
    fullName: String | null,
    email: String | null
  },

  location: {
    regionCode: String,
    regionName: String,
    provinceCode: String | null,
    provinceName: String,
    cityCode: String | null,
    cityName: String,
    barangayCode: String | null,
    barangayName: String,

    latitude: Number | null,
    longitude: Number | null,
    geocodedAddress: String | null,
    pinAccuracy: "geocoded" | "region_estimate"
  },

  symptomIds: [String],
  symptomLabels: [String],

  possibleConditionId: String,
  possibleConditionLabel: String,

  notes: String,

  status: "submitted" | "for_review" | "verified" | "rejected",

  source: "mobile_self_report",

  createdAt: Date,
  updatedAt: Date,
  syncedAt: Date | null
}
```

### Example Self-Report Record

```json
{
  "reporter": {
    "userId": null,
    "reporterType": "guest",
    "roleId": "guest",
    "roleLabel": "Guest Tester",
    "fullName": null,
    "email": null
  },
  "location": {
    "regionCode": "130000000",
    "regionName": "NCR",
    "provinceCode": null,
    "provinceName": "NCR",
    "cityCode": "137400000",
    "cityName": "Quezon City",
    "barangayCode": null,
    "barangayName": "Commonwealth",
    "latitude": 14.676,
    "longitude": 121.0437,
    "geocodedAddress": "Commonwealth, Quezon City, Metro Manila, Philippines",
    "pinAccuracy": "geocoded"
  },
  "symptomIds": ["cough", "fever", "fatigue"],
  "symptomLabels": ["Cough", "Fever", "Fatigue"],
  "possibleConditionId": "acute_respiratory_infection_pattern",
  "possibleConditionLabel": "Possible acute respiratory infection pattern",
  "notes": "Symptoms started yesterday.",
  "status": "submitted",
  "source": "mobile_self_report",
  "createdAt": "2026-08-07T10:30:00.000Z",
  "updatedAt": "2026-08-07T10:30:00.000Z",
  "syncedAt": null
}
```

### Current Possible Condition Logic

The mobile app currently derives a possible condition from selected symptom IDs.

Examples:

```text
cough + fever + fatigue/body_aches/loss_of_taste_or_smell/shortness_of_breath
-> covid_like_respiratory_pattern
-> Possible COVID-like respiratory symptom pattern

cough + fever + chills + fatigue
-> pneumonia_pattern
-> Possible pneumonia pattern

cough_2_weeks OR cough + night_sweats + weight_loss
-> tuberculosis_pattern
-> Possible tuberculosis symptom pattern

cough OR sore_throat OR runny_nose
-> acute_respiratory_infection_pattern
-> Possible acute respiratory infection pattern

Fallback
-> respiratory_symptoms_reported
-> Respiratory symptoms reported
```

### Current Supported Symptom IDs

```json
[
  { "id": "cough", "label": "Cough" },
  { "id": "fever", "label": "Fever" },
  { "id": "chills", "label": "Chills" },
  { "id": "fatigue", "label": "Fatigue" },
  { "id": "shortness_of_breath", "label": "Shortness of breath" },
  { "id": "chest_pain", "label": "Chest Pain" },
  { "id": "sore_throat", "label": "Sore throat" },
  { "id": "runny_nose", "label": "Runny nose" },
  { "id": "wheezing", "label": "Wheezing" },
  { "id": "loss_of_taste_or_smell", "label": "Loss of taste or smell" },
  { "id": "headache", "label": "Headache" },
  { "id": "body_aches", "label": "Body aches" },
  { "id": "cough_2_weeks", "label": "Cough for 2+ weeks" },
  { "id": "night_sweats", "label": "Night sweats" },
  { "id": "weight_loss", "label": "Weight loss" }
]
```

### Current Possible Condition IDs

```json
[
  {
    "id": "covid_like_respiratory_pattern",
    "label": "Possible COVID-like respiratory symptom pattern"
  },
  {
    "id": "pneumonia_pattern",
    "label": "Possible pneumonia pattern"
  },
  {
    "id": "tuberculosis_pattern",
    "label": "Possible tuberculosis symptom pattern"
  },
  {
    "id": "acute_respiratory_infection_pattern",
    "label": "Possible acute respiratory infection pattern"
  },
  {
    "id": "respiratory_symptoms_reported",
    "label": "Respiratory symptoms reported"
  }
]
```

### Suggested API Endpoints

```text
POST /api/mobile/self-reports
GET /api/mobile/self-reports/mine
GET /api/mobile/self-reports/map-pins
GET /api/mobile/self-reports/export
```

### Suggested POST Payload

```json
{
  "reporter": {
    "userId": "optional_user_id",
    "reporterType": "registered",
    "roleId": "citizen",
    "roleLabel": "Citizen",
    "fullName": "Juan Dela Cruz",
    "email": "juan@example.com"
  },
  "location": {
    "regionCode": "130000000",
    "regionName": "NCR",
    "provinceCode": null,
    "provinceName": "NCR",
    "cityCode": "137400000",
    "cityName": "Quezon City",
    "barangayCode": null,
    "barangayName": "Commonwealth",
    "latitude": 14.676,
    "longitude": 121.0437,
    "geocodedAddress": "Commonwealth, Quezon City, Metro Manila, Philippines",
    "pinAccuracy": "geocoded"
  },
  "symptomIds": ["cough", "fever", "fatigue"],
  "symptomLabels": ["Cough", "Fever", "Fatigue"],
  "possibleConditionId": "acute_respiratory_infection_pattern",
  "possibleConditionLabel": "Possible acute respiratory infection pattern",
  "notes": "Symptoms started yesterday.",
  "source": "mobile_self_report",
  "createdAt": "2026-08-07T10:30:00.000Z"
}
```

## Disease Map Pin Response

The mobile Disease Map currently expects reports to be converted into map pin-like records.

### Suggested Response Shape

```js
SelfReportMapPin {
  id: String,
  name: String,
  diseaseId: String,
  disease: String,
  category: "Self-reported respiratory symptoms",
  reports: Number,
  updated: String,
  lat: Number,
  lng: Number,
  tagIds: [String],
  tags: [String],
  source: "selfReport",
  pinAccuracy: "geocoded" | "region_estimate",
  geocodedAddress: String | null
}
```

### Example Map Pin

```json
{
  "id": "report_id",
  "name": "Commonwealth, Quezon City, NCR",
  "diseaseId": "acute_respiratory_infection_pattern",
  "disease": "Possible acute respiratory infection pattern",
  "category": "Self-reported respiratory symptoms",
  "reports": 1,
  "updated": "Self-reported on 8/7/2026 at 10:30",
  "lat": 14.676,
  "lng": 121.0437,
  "tagIds": ["cough", "fever", "fatigue"],
  "tags": ["Cough", "Fever", "Fatigue"],
  "source": "selfReport",
  "pinAccuracy": "geocoded",
  "geocodedAddress": "Commonwealth, Quezon City, Metro Manila, Philippines"
}
```

## Recommended Additions For Unified Web/Mobile Sync

The mobile app currently stores only the local self-report fields. For shared backend syncing, the web team should add:

```text
userId
reporterType
roleId
roleLabel
regionName
provinceCode
cityCode
barangayCode
symptomIds
symptomLabels
possibleConditionId
possibleConditionLabel
status
source
syncedAt
updatedAt
```

## Notes For Web Team

- Mobile self-reports should be accepted even when the user is a guest.
- Registered users should send profile-backed address data.
- Guest users should send manually selected address data.
- Latitude and longitude may be null if geocoding fails.
- If coordinates are null, the mobile map falls back to a region-level estimate.
- `possibleConditionLabel` is not a diagnosis. It is a user guidance/consideration field.
- `possibleConditionId` is the stable backend value for filtering, analytics, and modeling.
- Health Literacy content should support filtering by `contentType`, `tags`, `topics`, `diseases`, and `language`.
- The mobile app should eventually fetch Health Literacy content from the backend instead of static local lists.

## Priority For Backend Implementation

Recommended order:

```text
1. POST /api/mobile/self-reports
2. GET /api/mobile/self-reports/mine
3. GET /api/mobile/self-reports/map-pins
4. GET /api/health-literacy/mobile
5. GET /api/health-literacy/mobile?contentType=article
6. GET /api/health-literacy/mobile?contentType=fact_check
7. POST /api/health-literacy/analytics/events
```
