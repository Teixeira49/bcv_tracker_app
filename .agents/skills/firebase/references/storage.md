---
metadata:
  last_modified: "2026-03-12 11:18:17 (GMT+8)"
---

# 05 - Firebase Cloud Storage (`firebase_storage`)

## Goal
Manage large binary files (images, videos, PDFs) by uploading them to Firebase Cloud Storage and linking their final download URLs to Firestore documents.

## Instructions

### 1. Creating Storage References
Firebase Storage uses a folder-like structure. You must construct a `Reference` pointing to a specific path before uploading or downloading.

```dart
final storageRef = FirebaseStorage.instance.ref();

// Create a reference to "avatars/userId123.jpg"
final avatarRef = storageRef.child("avatars").child("userId123.jpg");
```

### 2. Uploading Files
In Flutter, you typically upload `File` objects (from `image_picker`) or `Uint8List` byte arrays (vital for Flutter Web compatibility).

```dart
// Native (iOS/Android) File Upload
Future<String> uploadAvatar(File imageFile, String userId) async {
  final ref = FirebaseStorage.instance.ref().child('avatars/$userId.jpg');
  
  try {
    // 1. Upload the file
    final TaskSnapshot snapshot = await ref.putFile(imageFile);
    
    // 2. Retrieve the public download URL once complete
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl; // Save this URL into Firestore!
  } on FirebaseException catch (e) {
    print("Failed to upload: ${e.code}");
    rethrow;
  }
}

// Web/Bytes Upload
Future<String> uploadWebAvatar(Uint8List bytes, String userId) async {
  final ref = FirebaseStorage.instance.ref().child('avatars/$userId.jpg');
  final TaskSnapshot snapshot = await ref.putData(
    bytes,
    SettableMetadata(contentType: 'image/jpeg'), // Critical for Web to display properly
  );
  return await snapshot.ref.getDownloadURL();
}
```

### 3. Monitoring Upload Progress
For large files (like videos), you should listen to the `UploadTask` stream to show a progress bar.

```dart
final uploadTask = ref.putFile(largeVideoFile);

uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
  final progress = (snapshot.bytesTransferred / snapshot.totalByteCount) * 100;
  print('Upload is $progress% complete.');
});
```

## Constraints
*   **Download URLs vs Storage URIs:** The string returned by `getDownloadURL()` is a standard HTTPS URL (`https://firebasestorage.googleapis.com/...`). This is what you save to Firestore to display images using traditional `.network` image widgets.
*   **Unique Filenames:** Always ensure uploaded files have unique names (e.g., prefixing with a user ID or a UUID) to prevent accidental overwriting of unrelated user data.
*   **Content Types:** When uploading raw `Uint8List` data, failing to provide `SettableMetadata(contentType: '...')` will cause browsers to attempt to download the file rather than displaying it inline when the URL is accessed.
