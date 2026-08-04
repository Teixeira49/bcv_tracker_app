---
metadata:
  last_modified: "2026-03-12 11:18:17 (GMT+8)"
---

# 09 - Pricing & Cost Optimization

## Goal
Prevent unpredictable and catastrophic billing spikes (often affectionately termed "Firebase Bill Shock"). Firebase is incredibly fast to build with, but its NoSQL pricing models (Firestore, Realtime Database) punish inefficient querying architectures severely. 

Every AI generating Firebase code MUST review these constraints before proposing database architectures.

## The Core Firebase Billing Vectors

### 1. Cloud Firestore (The Silent Killer)
Firestore charges primarily by **Document Reads**, **Document Writes**, and **Document Deletes**. Storage space is generally cheap; the I/O operations are what bankrupt startups.

#### 🔴 The Bad Architecture (Unbounded Queries)
Imagine a social feed where you query: 
```dart
// BAD: Fetching all posts without a limit.
final snapshot = await firestore.collection('posts').orderBy('createdAt', descending: true).get();
```
If your app has 100,000 posts, and 50 users open the app simultaneously: 
100,000 reads * 50 users = **5,000,000 Document Reads generated in 1 second**.

#### 🟢 The Optimized Architecture (Pagination & Limits)
**Rule:** NEVER write a `.get()` or `.snapshots()` without a `.limit()`.

```dart
// GOOD: Only fetch what the user can physically see on their screen right now.
final snapshot = await firestore.collection('posts')
    .orderBy('createdAt', descending: true)
    .limit(20) // Only pay for 20 reads!
    .get();
```

#### 🔴 The Bad Architecture (N+1 Queries)
Imagine rendering a list of 20 posts, and for *each* post, you render the user's avatar by querying the `users` collection.
```dart
// BAD: Inside a ListView builder
final userDoc = await firestore.collection('users').doc(post.authorId).get();
```
Fetching 20 posts = 20 reads. Fetching 20 authors = 20 reads. Every time the user scrolls, you multiply your reads exponentially.

#### 🟢 The Optimized Architecture (Data Duplication)
In SQL, duplicating data is a sin. In NoSQL (Firestore), **Data Duplication is a Best Practice**. 
Store the `authorName` and `authorAvatarUrl` *inside* the Post document itself when the post is created. This turns an N+1 query problem into a single read operation.

### 2. Cloud Functions (Egress Pricing)
If you deploy Node.js Cloud Functions (or trigger Serverpod endpoints hosted on GCP), you pay for **Egress** (data leaving Google's network).

**Rule:** Do not pipe enormous JSON arrays through Cloud Functions if the client only needs a summary count. 
Example: Do not download 10,000 User documents to a Cloud Function just to calculate `users.length`. Use Firestore's native `count()` aggregation function, which costs a fraction of a single document read.

### 3. Firebase Authentication (SMS Verification Limits)
Firebase Authentication handles email/password logins practically for free. However, **Phone Number Verification (SMSOTP)** is extremely expensive. 

**Rule:** Firebase usually gives a small free tier for SMS verifications (e.g., 10k/month). After that, the cost per SMS is extraordinarily high compared to bulk SMS providers like Twilio. Avoid defaulting to Phone Auth unless absolutely necessary for your app's core business model. Use Email/Password + Google/Apple Sign-In as your primary authentication vectors.

### 4. Realtime Database vs Firestore
*   **Firestore**: Charges per Document Read/Write. Use it for massive, structured, queryable data (users, products, posts).
*   **Realtime Database (RTDB)**: Charges primarily by **Bandwidth (GB downloaded)** and **Storage**, not per individual node read. 
If you are building a collaborative whiteboard or a live multiplayer game where X/Y coordinates update 60 times a second, **DO NOT USE FIRESTORE**. Writing coordinates 60 times a second to Firestore will obliterate your budget. Use RTDB for ephemeral, hyper-frequent updates.

## Constraints
* **Limit Enforcement:** Before providing a Flutter code snippet containing `.get()` or `.snapshots()` on a Firestore collection, you MUST consider if a `.limit()` is necessary to protect the user from unbounded read costs.
* **Denormalization Awareness:** When designing a data schema, proactively suggest denormalizing (duplicating) read-heavy data into parent documents to minimize sub-query billing.
