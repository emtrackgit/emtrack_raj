class ApiConstants {
  static const String baseUrl =
      "https://emtrackotrapi-staging.azurewebsites.net";

  // https://emtrackotrapi-staging.azurewebsites.net/UserManagement/CreateUser

  // ================= AUTH =================
  static const String login = "/Auth/Login";
  static const String logout = "/Auth/LogOut";

  // ================= TYRE =================
  static const String createTyre = "/api/Tire";
  static const String getTyreById = "/api/Tire/GetById/";
  static const String getTyresByAccount = "/api/Tire/GetTiresByAccount/";

  // ================= VEHICLE =================
  static const String createVehicle = "/api/Vehicle/Create";

  /// https://emtrackotrapi-staging.azurewebsites.net/api/Vehicle/GetVehicleByUser/11855/0?timeStamp=0
  static String getVehicleByUser(
    int parentAccountId, {
    int pageNumber = 0,
    int timeStamp = 0,
  }) {
    return "/api/Vehicle/GetVehicleByUser/$parentAccountId/$pageNumber?timeStamp=$timeStamp";
  }

  static String getVehicleByAccount(int parentAccountId) {
    return "/api/ParentAccount/GetDetailsByAccount/$parentAccountId";
  }

  //=================== MASTER DATA GET All COUNTRY==============
  static const String getAllCountryName = "/api/MasterData/GetCountryList";
  // ================= USER =================
  static const String updatePreferences = "/api/UserPreferences/Update";
  //================= Master DATA =============
  static const String masterData = "/api/MasterData/GetMasterDataMobile";
  //================= Master DATA =============
  static const String grandParentAccountGetAll =
      "/api/GrandParentAccount/GetAll";

  //=========================User Management==========================
  static const String createUser = "/UserManagement/CreateUser";
  static const String createUserProfile = "/api/UserProfile/CreateUserProfile";
  static const String createUserPreference =
      "/api/UserPreferences/CreateUserPreference";

  static const String assignRole = "/Role/AssignRole";

  // Reset Password
  static const String sendPasswordToken =
      "/UserManagement/SendPasswordResetCode";

  static const String resetPassword = "/UserManagement/PasswordResetWToken";

  // Grant Parent
  static const String createGrandParentAccount =
      "/api/GrandParentAccount/Create";
  static const String updateGrandParentAccount =
      "/api/ParentAccount/UpdateGrandParentAccount";

  // Assign grandparent
  static const String getParentAccountList =
      "/api/ParentAccount/GetAccountList";
  static const String getGrandparentAccountList =
      "/api/GrandParentAccount/GetAll";

  static const getCountryList = "/api/MasterData/GetCountryList/";
  static const getRoleList = "/Role/GetRoles";

  // get All user
  static const getAllUserList = "/api/UserProfile/GetAllUsers";

  static const getUserProfile = "/api/UserProfile";

  
}
