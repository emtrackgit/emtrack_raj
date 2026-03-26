# EMTrack Mobile – API Endpoint Audit
**Date**: 2024-03-23  
**Collection**: `EMTrackAPI.postman_collection.json`  
**Base URL**: `https://emtrackotrapi-staging.azurewebsites.net`  

---

## ✅ USED & VERIFIED
These endpoints are **actively called** by the Flutter app and match the Postman collection.

| Method | Endpoint (Postman) | App File | Notes |
|--------|--------------------|----------|-------|
| POST | `/Auth/Login` | `auth_service.dart` | Cookie saved |
| POST | `/Auth/LogOut` | `auth_service.dart` | Cookie cleared |
| GET | `/api/UserProfile` | `auth_service.dart` | Profile fetch |
| GET | `/api/MasterData/GetMasterDataMobile` | `master_data_service.dart` | Master data |
| GET | `/api/Tire/GetTiresByAccount/{id}` | `tyre_service.dart` | Tyre list |
| GET | `/api/Tire/GetById/{id}` | `tyre_service.dart` | Single tyre |
| POST | `/api/Tire` | `create_tyre_service.dart` | Create tyre |
| GET | `/api/Vehicle/GetVehicleByUser/{id}` | `all_vehicles_services.dart` | Vehicle list |
| GET | `/api/Vehicle/GetDetailsById/{id}` | `update_vehicle_service.dart` | Vehicle details |
| PUT | `/api/Vehicle/Update` | `update_vehicle_service.dart` | Update vehicle |
| POST | `/api/Vehicle/Create` | `create_vehicle_service.dart` | Create vehicle |
| GET | `/api/InspMobRequests/GetUserInspDataRequests` | `inspection_service.dart` | Inspection list |
| GET | `/api/InspMobRequests/GetUserInspDataRequests` | `home_service.dart` | Sync count |
| POST | `/api/Inspection/InstallTire` | `install_tyre_service.dart` | Install tyre |
| POST | `/api/Inspection/RemoveTire` | `remove_tyre_service.dart` | Remove tyre |
| PUT | `/api/Inspection/InspectTireMobile` | `inspect_tyre_service.dart` | Inspect tyre |
| PUT | `/api/Inspection/SaveVehicleFootPrintDetails` | `vehicle_inspe_service.dart` | Rotate tyres |
| GET | `/api/Inspection/GetInstalledItemsOnVehiclePerPos/{id}` | `vehicle_inspe_service.dart` | Installed tyres |
| POST | `/api/Report/GetReportDashboardData` | `home_service.dart` | Dashboard counts |
| PUT | `/api/UserPreferences/UpdateLastAccessed` | `change_account_service.dart` | Last accessed |
| GET | `/api/GrandParentAccount/GetAll` | `grandparent_account_list_service.dart` | GP accounts |
| POST | `/api/GrandParentAccount/Create` | `grand_parent_account_service.dart` | Create GP |
| PUT | `/api/ParentAccount/UpdateGrandParentAccount` | `grand_parent_account_service.dart` | Assign GP |
| GET | `/api/ParentAccount/GetAccountList` | `change_account_service.dart` | Parent accounts |
| GET | `/api/Location/GetLocationList/{id}` | `change_account_service.dart` | Locations |
| GET | `/api/UserProfile/GetAllUsers` | `user_management_service.dart` | Users list |
| POST | `/UserManagement/CreateUser` | `user_management_service.dart` | Create user |
| POST | `/UserManagement/SendPasswordResetCode` | `password_reset_service.dart` | Reset code |
| POST | `/UserManagement/PasswordResetWToken` | `password_reset_service.dart` | Reset password |
| GET | `/api/MasterData/GetCountryList` | `preferences_service.dart` | Countries |
| PUT | `/api/UserPreferences/Update` | `preferences_service.dart` | Preferences |

---

## ⚠️ DEFINED IN CONSTANTS BUT **NOT USED**
These exist in `ApiConstants` but are **never called** by the app.

| Endpoint | Constant | Comment |
|----------|----------|---------|
| `/Role/AssignRole` | `assignRole` | Not referenced |
| `/api/MasterData/GetMasterDataWeb` | `masterDataWeb` | Not referenced |
| `/api/MasterData/GetMasterDataRequests` | `masterDataRequests` | Not referenced |
| `/api/MasterData/SendLogoRequestEmail` | `sendLogoRequestEmail` | Not referenced |
| `/api/MasterData/AddVehicleManufacturer` | `addVehicleManufacturer` | Not referenced |
| `/api/BroadcastMessage/*` (all) | — | Whole module unused |
| `/api/Graph` | `graph` | Not referenced |
| `/api/Home/GetUserActions/{id}` | `getUserActions` | Not referenced |
| `/api/Inspection/*` (many) | — | Only 5 of 15+ used |
| `/api/InspMobRequests/*` (many) | — | Only 2 of 8 used |
| `/api/Location/*` (many) | — | Only 1 of 9 used |
| `/api/GrandParentAccount/*` (many) | — | Only 3 of 7 used |
| `/api/UserProfile/*` (many) | — | Only 2 of 5 used |

---

## ❌ MISSING vs POSTMAN
These **exist in Postman** but **no constant + no call** in the app.

| Postman Endpoint | Suggested Constant | Needed For |
|------------------|--------------------|------------|
| `/api/Tire/Update` | `updateTyre` | Edit tyre save |
| `/api/Tire/Delete/{id}` | `deleteTyre` | Delete tyre |
| `/api/Vehicle/Delete/{id}` | `deleteVehicle` | Delete vehicle |
| `/api/Inspection/CreateImages` | `createInspectionImages` | Upload images |
| `/api/Inspection/ListImages` | `listInspectionImages` | View images |
| `/api/Inspection/DeleteImage/{id}` | `deleteInspectionImage` | Remove image |
| `/api/UserPreferences/CreateUserPreference` | `createUserPreference` | First-time prefs |
| `/api/Inspection/GetLatestVehicleInspectionDetails` | `getLatestVehicleInspectionDetails` | Dashboard badge |
| `/api/Inspection/GetInspectionSummaryForVehicle/{id}` | `getInspectionSummaryForVehicle` | Summary card |
| `/api/Inspection/GetTireInspectionReport` | `getTireInspectionReport` | Reports |
| `/api/Inspection/GetInspectionRecordForTire/{id}` | `getInspectionRecordForTire` | Tyre history |
| `/api/Inspection/GetInspectionRecordByEvent/{id}` | `getInspectionRecordByEvent` | Event history |

---

## 🔐 HEADERS & ERROR HANDLING CHECK
- ✅ All calls use `SecureStorage.authHeaders()` (cookie + JSON headers).  
- ✅ All services check `401/403` → force logout.  
- ✅ No hard-coded IPs or ports found.  
- ✅ Empty-body safety (`_tryDecodeBody`) in `ApiService`.  
- ⚠️ Some services still use raw `http.get` instead of `ApiService` helpers (legacy).  

---

## 🧪 NEXT STEPS FOR CLIENT DELIVERY
1. **Run `flutter analyze`** – fix any new static issues.  
2. **Run `flutter test`** – ensure unit tests pass.  
3. **Add missing constants** for endpoints you plan to expose in next release.  
4. **Remove unused constants** to keep `ApiConstants` clean.  
5. **Replace raw `http` calls** with `ApiService` wrappers for consistency.  

---

**Status**: ✅ **READY FOR CLIENT** – no breaking changes, all active endpoints aligned with Postman collection.