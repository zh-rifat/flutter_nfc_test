
# create project
```dart
flutter create nfc_write
```


# permissions
```xml
<uses-permission android:name="android.permission.NFC" />
<uses-feature android:name="android.hardware.nfc" android:required="true" />
```



# dependencies
```yaml
  dependencies:
  nfc_manager: ^3.2.0
```




# build apk

```bash
flutter build apk --split-per-abi
```
