import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';

import '../../data/user/user.dart';
import '../../main.dart';
import '../../presentation/utils/strings.dart';
import '../repositories/auth_repo.dart';
import 'response/responses.dart';

class AuthProvider extends GetConnect {
  static AuthProvider get value => Get.find<AuthProvider>();

  get _userType => 'AuthRepository.instance.user.value.type.name';

  get _id => AuthRepository.instance.user.value.id;

  @override
  void onInit() {
    httpClient.baseUrl = AppStrings.baseUrl;

    httpClient.defaultDecoder = (val) {
      if (val is String) {
        if (val.contains('Internal Server Error'))
          val = "Oops, An error occured. Please try that again";
        return ApiResponse(true, status: false, message: val);
      }
      return ApiResponse.fromJson(val);
    };

    // Http and websockets if used with no [httpClient] instance

    // It's will attach 'apikey' property on header from all requests

    httpClient.addRequestModifier((Request request) {
      if (AuthRepository.instance.user.value.token != null) {
        request.headers['Authorization'] =
            'Bearer ${AuthRepository.instance.user.value.token!.access_token}';
      }
      return request;
    });

/*     httpClient.addAuthenticator((Request request) async {
      var resp;
      var response;
      var token;
      var refreshToken;

      var body = {
        "refreshToken": AuthRepository.instance.user.value.refreshToken
      };

      //  try {
      resp = await post<ApiResponse>('/$_userType/refresh-token', body);
      response = getErrorMessage(resp);
      if (response != null) {
        AuthRepository.instance.user.value = User();
        Get.offAllNamed(Routes.customerTypeScreen);
        Get.showSnackbar(GetSnackBar(
          message: response,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ));
        await Future.delayed(Duration(milliseconds: 3100));
        Get.closeAllSnackbars();
      } else {
        token = resp.body.data['token'];
        refreshToken = resp.body.data['refreshToken'];

        AuthRepository.instance.user.value = AuthRepository.instance.user.value
            .copyWith(refreshToken: refreshToken, token: token);

        request.headers['Authorization'] = 'Bearer $token';
      }
      return request;
      //}  catch (e) {

      // return request;

      // }
    }); */

    //Autenticator will be called 3 times if HttpStatus is
    //HttpStatus.unauthorized
    httpClient.maxAuthRetries = 1;
    httpClient.timeout = Duration(seconds: 30);

    // Does Rubish
    // httpClient.addResponseModifier<ApiResponse>(
    //   (request, response) {
    //     print(request.decoder.toString());
    //     print(response.bodyString);

    //     return response.body;
    //   },
    // );
    appDebugMode.listen((_) => httpClient.baseUrl = AppStrings.baseUrl);
  }

  Future<User> fetchUser() {
    return get<ApiResponse>('/auth/user').then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          response = User.fromJson(value.body?.data);
        }

        return response;
      },
    );
  }

  Future<UserData> fetchUserData() {
    return get<ApiResponse>('/auth/user-data').then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          response = UserData.fromJson(value.body?.data);
        }

        return response;
      },
    );
  }

  Future<String?> setPassword(String email, password, otp) {
    return post<ApiResponse>('auth/$_userType/reset-password', {
      'email': email,
      'password': password,
      'otp': otp,
    }).then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          response = 'Password reset successfully \nLog in to continue';
        }

        return response;
      },
    );
  }

  // Working
  Future<String?> resetPassword(String email, newPassword, otp) {
    return post<ApiResponse>('/$_userType/reset-password/otp', {
      'email': email,
      'newPassword': newPassword,
      'otp': otp,
    }).then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          print(response);
          throw (response);
        } else {
          response = 'Password reset successfully \nLog in to continue';
        }

        return response;
      },
    );
  }

  Future<String?> changePassword(oldPassword, newPassword) {
    var body = {
      "old_password": oldPassword,
      "new_password": newPassword,
    };

    return post<ApiResponse>('/auth/change-password', body).then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        print(value);
        if (response != null) {
          //  print(response);
          throw (response);
        } else {
          response = 'Password changed successfully';
        }

        return response;
      },
    );
  }

  // Future<String> sendPasswordResetOtp(String email) {
  //   return post<ApiResponse>('auth/$_userType/resend_verification_email', {
  //     'email': email,
  //   }).then(
  //     (value) {
  //       var response;

  //       //Check for error
  //       response = getErrorMessage(value);
  //       if (response != null) {
  //         throw (response);
  //       } else {
  //         response = 'OTP Sent successfully';
  //       }

  //       return response;
  //     },
  //   );
  // }

  // Working
  Future<String> forgotPassword(String email) {
    return post<ApiResponse>('/$_userType/forgot-password', {
      'email': email,
    }).then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          response = 'OTP Sent successfully';
        }

        return response;
      },
    );
  }

  // Working
  Future<String?> verifyEmail({
    required String email,
    required String otp,
  }) {
    return post<ApiResponse>('/$_userType/verify-account', {
      "email": email,
      "otp": otp,
    }).then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          response = 'Email verified';
        }
        return response;
      },
    );
  }

  // Working
  Future<String> resendOtp(
    String email,
  ) {
    return post<ApiResponse>('/$_userType/resend-verification-otp', {
      "email": email,
    }).then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          response = 'OTP Resent';
        }
        return response;
      },
    );
  }

  // Working
  Future<String> sendPinOtp() {
    return get<ApiResponse>('/$_userType/$_id/wallet/forgot-pin').then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          response = value.body?.message ?? 'OTP Resent';
        }
        return response;
      },
    );
  }

  Future<String> submitPinOtp(String otp) {
    return post<ApiResponse>('/$_userType/wallet/reset-pin/otp', {
      "vendorId": _id,
      "otp": otp,
    }).then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          response = value.body?.message ?? 'OTP Submitted';
        }
        return response;
      },
    );
  }

  Future<String> signup({
    required String name,
    required String email,
    required String password,
    required String surname,
    required String phone,
  }) {
/*     {
  "email": "seyi@gmail.com",
  "name": "string",
  "surname": "string",
  "phone": "string",
  "password": "string"
} */
    return post<ApiResponse>('/auth/signup', {
      "email": email.toLowerCase(),
      "name": name,
      "surname": surname,
      "phone": phone,
      "password": password,
    }).then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          response = value.body?.message;
        }

        return response;
      },
    );
  }

  Future<User> buy_data({
    required String identifier,
    required String password,
  }) {
    print(identifier + password);
    return post<ApiResponse>('/auth/login', {
      "identifier": identifier.toLowerCase(),
      "password": password,
    }).then(
      (value) {
        var response;

        print(value);

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          response = User.fromJsonWithToken(
              value.body?.data['user'], value.body?.data['token']);
        }

        return response;
      },
    );
  }

  Future<User> login({
    required String identifier,
    required String password,
  }) {
    return post<ApiResponse>('/auth/login', {
      "identifier": identifier.toLowerCase(),
      "password": password,
    }).then(
      (value) {
        var response;

        print(value);

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          response = User.fromJsonWithToken(
              value.body?.data['user'], value.body?.data['token']);
        }

        return response;
      },
    );
  }

  Future<String?> get_code() {
    return get<ApiResponse>('/auth/code').then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          response = value.body!.data;
        }

        return response;
      },
    );
  }

  Future<String?> uploadToken(String token) {
    var body = {
      "device_token": token,
    };

    return post<ApiResponse>('/auth/upload_token', body).then(
      (value) {
        var response;
        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          // Send response
          response = value.body!.message;
        }

        return response;
      },
    );
  }

  Future<String> payMoney({
    required String id,
    required num amount,
  }) {
    return post<ApiResponse>('/payments/pay/{$id}?amount=$amount', {}).then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          response = value.body?.message;
        }

        return response;
      },
    );
  }

  Future<String> purchasePlan({
    required int plan_id,
    required int discount_id,
  }) {
    return post<ApiResponse>('/plans/purchase', {
      "plan_id": plan_id,
      'discount_id': discount_id,
    }).then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          response = value.body?.message;
        }

        return response;
      },
    );
  }

  Future<String> topUp({
    required num amount,
  }) {
    return post<ApiResponse>('/payments/top-up?amount=$amount', {}).then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          response = value.body?.message;
        }

        return response;
      },
    );
  }

/*   Future<User> vendorSignUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String referrer,
    required UserType type,
    required String branchEmail,
    // required String userName,
    // required String inviteCode,
  }) {
    var body = {
      "vendorName": name,
      "name": name,
      "email": email,
      "phone": phone,
      "password": password,
      "user_type": type.name,
      "parentCompanyMail": branchEmail
      // "userName": userName,
      // 'invite_code': inviteCode
    };

    body.addIf(referrer.isNotEmpty, 'referrer', referrer);
    return post<ApiResponse>('/$_userType/register', body).then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          response = User.fromJsonWithType(value.body?.data, type: type);
        }

        return response;
      },
    );
  } */
/* 
  Future<User> delCartItem({required String cartId, required UserType type}) {
    return post<ApiResponse>('/$_userType/$_id/cart/$cartId', {}).then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          response = User.fromJsonWithType(value.body?.data, type: type);
        }

        return response;
      },
    );
  }
 */
  // Working
/*   Future<User> login(email, password) {
    var body = {
      'email': email,
      'password': password,
    };
    return post<ApiResponse>('/$_userType/login', body).then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          // Convert to Model

          response = User.fromJson(value.body?.data);

          //response = User.fromJson(value.body?.data,  type: userType);
        }

        return response;
      },
    );
  }
 */
/*   Future<User> contactSupport(name, email, message) {
    return post<ApiResponse>('/contact-support', {
      'name': name,
      'email': email,
      'message': message,
    }).then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          // Convert to Model

          response = User.fromJson(value.body?.data);

          //response = User.fromJson(value.body?.data,  type: userType);
        }

        return response;
      },
    );
  } */

  Future<String?> completeRestaurantProfile(bool status) {
    var body = {"completedProfile": "$status"};

    return put<ApiResponse>('/$_userType/$_id/completed-profile', body).then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        if (response != null) {
          throw (response);
        } else {
          response = value.body?.message;
        }

        return response;
      },
    );
  }

  // Working
  Future<String> fetchAccountName(
      String accountNumber, String bankCode, String vendorId) {
    return get<ApiResponse>(
      '/$_userType/$vendorId/banks/verify-account?bankCode=$bankCode&accountNumber=$accountNumber',
    ).then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        print(value);
        if (response != null) {
          throw (response);
        } else {
          // Convert to Model
          response = value.body?.data['account_name'];
        }
        return response;
      },
    );
  }

  Future<String> fetcxhWallet(String limit, String sort, String vendorId) {
    return get<ApiResponse>(
      '/$_userType/$vendorId/wallet?limit=$limit&sort=$sort',
    ).then(
      (value) {
        var response;

        //Check for error
        response = getErrorMessage(value);
        print(value);
        if (response != null) {
          throw (response);
        } else {
          // Convert to Model
          response = value.body?.data['account_name'];
        }
        return response;
      },
    );
  }
}

String? getErrorMessage(Response<ApiResponse> response) {
  if (kDebugMode) {
    log(' Status Code: ${response.statusCode}');
    log(' Status Text: ${response.statusText}');
    log(' Response Body: ${response.bodyString}');
    log(' Headers: ${response.request?.headers.toString()}');
    log(' URL: ${response.request?.url}');
  }

  if (response.statusCode != null &&
      response.isOk &&
      (response.body!.status == true || response.body!.error == false)) {
    print('Response is okay: ${response.isOk}');
    return null;
  } else if (response.body == null) {
    // Send Error Locally
    return "Error: Couldn't connect to the internet, check your connection";
  } else if (response.body!.message != null) {
    return response.body!.message;
  } else {
    return 'Something went wrong, please try again later';
  }
}
