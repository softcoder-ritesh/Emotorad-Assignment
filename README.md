# Google Sheets Integration Guide

## Important Notice ⚠️
I am not uploading the Google Sheets credential file (`credentials.json`) to GitHub because it is against GitHub's policies to store sensitive information in repositories. Instead, you need to manually download the credentials file and add it to the project by following these steps.

## Steps to Configure Google Sheets Credentials

1. **Download the credentials file**
   - Download `credentials.json` from the following Google Drive link:  
     [Google Drive - credentials.json](https://drive.google.com/file/d/1jZErxl3GDrXgZw7ktQG65QSyXxatzA13/view?usp=sharing)

2. **Place the file in the project**
   - Move the downloaded `credentials.json` file into the `assets` folder of your project.
   - If the `assets` folder does not exist, create it in the root of your project.

3. **Specify the file path in your project**
   - Use the following path in your code to access the credentials:
     ```dart
     final credentialsPath = 'assets/credentials.json';
     ```

4. **Update `pubspec.yaml` to include the assets folder**
   - Add the following lines to your `pubspec.yaml` file:
     ```yaml
     flutter:
       assets:
         - assets/credentials.json
     ```

5. **Run `flutter pub get`**
   - Execute the command below to ensure the assets are properly included:
     ```sh
     flutter pub get
     ```



