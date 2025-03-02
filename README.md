# SpendTracker  
A simple iOS application for displaying transparent bank accounts using the ČSAS API.  
<div style="display: flex; justify-content: center; gap: 10px;">
    <img src="SpendTracker/Assets.xcassets/Screenshots/screenshot1.imageset/screenshot1.png" width="200">
    <img src="SpendTracker/Assets.xcassets/Screenshots/screenshot2.imageset/screenshot2.png" width="200">
    <img src="SpendTracker/Assets.xcassets/Screenshots/screenshot3.imageset/screenshot3.png" width="200">
</div>

## Technologies Used  
- Swift  
- SwiftUI  
- Combine  
- URLSession  
- MVVM

## Features
- **Bank accounts** showing all my accounts in the list
- **Bank account detail** showing all informations about account: info, balances, transactions

## Installation  
1. Clone the repository:  
   ```bash
   git clone https://github.com/hajducak/SpendTracker.git
   ```
   
2. Use only the main branch.
3. Open the project in Xcode.
4. Open `/Certificates` folder and your P12 certificate here for API communication
5. Open `CertificateManagement.swift` change static properties `fileName` & `password` acording new P12 certificate you put in previous step
4. Run the application in the simulator.

## Autor
@hajducak
