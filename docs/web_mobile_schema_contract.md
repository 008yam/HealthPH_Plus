# HealthPH+ Web and Mobile Schema Contract

Date: August 12, 2026  
Prepared for: HealthPH+ Web Developer  
Prepared by: HealthPH+ Mobile Team

## Purpose

This document defines the shared schema direction for HealthPH+ mobile and web integration. The mobile application now uses canonical IDs for storage, syncing, filtering, analytics, and modeling, while keeping readable labels for user interface display and exports.

## Integration Rule

```text
Use ID fields for storage, filtering, analytics, modeling, and syncing.
Use label fields for UI display, human-readable exports, and review screens.
```

Example:

```json
{
  "roleId": "field_health_worker",
  "roleLabel": "Field Health Worker"
}
```

## Canonical IDs

### User Roles

```json
[
  { "id": "guest", "label": "Guest Tester" },
  { "id": "citizen", "label": "Citizen" },
  { "id": "field_health_worker", "label": "Field Health Worker" },
  { "id": "lgu_doh_user", "label": "LGU/DOH User" }
]
```

### Reporter Types

```json
[
  { "id": "guest", "label": "Guest" },
  { "id": "registered", "label": "Registered" }
]
```

### Languages

```json
[
  { "id": "en", "label": "English" },
  { "id": "fil", "label": "Filipino" },
  { "id": "ceb", "label": "Cebuano" },
  { "id": "ilo", "label": "Ilocano" },
  { "id": "hil", "label": "Hiligaynon" }
]
```

## User / Profile Schema

```js
UserProfile {
  _id: ObjectId,

  fullName: String,
  email: String,

  roleId: "guest" | "citizen" | "field_health_worker" | "lgu_doh_user",
  roleLabel: String,

  address: {
    regionCode: String,
    regionName: String,

    provinceCode: String | null,
    provinceName: String,

    cityCode: String | null,
    cityName: String,

    barangayCode: String | null,
    barangayName: String
  },

  preferredLanguage: "en" | "fil" | "ceb" | "ilo" | "hil",

  createdAt: Date,
  updatedAt: Date,
  lastLoginAt: Date | null
}
```

## Self-Report Schema

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

## Supported Symptom IDs

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

## Possible Condition IDs

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

## Possible Condition Logic

The mobile app derives a possible condition from selected symptom IDs. This is not a diagnosis. It is a guidance/consideration field.

```text
cough + fever + fatigue/body_aches/loss_of_taste_or_smell/shortness_of_breath
-> covid_like_respiratory_pattern

cough + fever + chills + fatigue
-> pneumonia_pattern

cough_2_weeks OR cough + night_sweats + weight_loss
-> tuberculosis_pattern

cough OR sore_throat OR runny_nose
-> acute_respiratory_infection_pattern

Fallback
-> respiratory_symptoms_reported
```

## Disease Map Pin Response

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

## Health Literacy Content Schema

```js
HealthLiteracyContent {
  _id: ObjectId,

  contentType: "article" | "video" | "infographic" | "fact_check",

  title: String,
  description: String,

  source: String | null,
  author: String | null,
  publishedDate: Date | null,

  externalUrl: String | null,
  imageUrl: String | null,
  mediaUrl: String | null,

  claim: String | null,
  verdict: "True" | "Mostly True" | "Needs Context" | "False" | null,
  explanation: String | null,

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

## Suggested API Endpoints

```text
POST /api/mobile/self-reports
GET /api/mobile/self-reports/mine
GET /api/mobile/self-reports/map-pins
GET /api/mobile/self-reports/export

GET /api/health-literacy/mobile
GET /api/health-literacy/mobile?contentType=article
GET /api/health-literacy/mobile?contentType=fact_check
POST /api/health-literacy/analytics/events
```

## Implementation Notes

- Mobile self-reports should be accepted for both guest and registered users.
- Registered users should send profile-backed address data.
- Guest users should send manually selected address data.
- Latitude and longitude may be null if geocoding fails.
- If coordinates are null, the mobile map falls back to a region-level estimate.
- `possibleConditionLabel` is not a diagnosis and should be presented as guidance only.
- `possibleConditionId` should be used for filtering, analytics, and modeling.
- Health Literacy content should support filtering by `contentType`, `tags`, `topics`, `diseases`, and `language`.
