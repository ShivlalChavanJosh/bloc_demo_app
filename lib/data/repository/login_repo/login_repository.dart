import 'dart:math';

import 'package:bloc_demo_app/data/request/api_url.dart';
import 'package:bloc_demo_app/model/error_model.dart';
import 'package:bloc_demo_app/model/login_request.dart';

import '../../../model/login_response.dart';
import '../../request/request.dart';

class LoginRepository {

  Request _request = Request(baseUrl: DemoApi.BASE_URL);

  Future<LoginResponse> userLogin(LoginRequest request) async {

    LoginResponse loginResponse = LoginResponse();

    String url = DemoApi.BASE_URL+"/sessions/sign_in";

    Map<String,String> headerMap = {"Accept":"application/vnd.simplysmart.v2+json"};

    var response = await _request.requestApi(method: MethodType.POST, url: url,data: request.toJson(),
     header: headerMap);

    if(response is ErrorModel) return loginResponse;

    var data = (response as Map<String, dynamic>);
    loginResponse = LoginResponse.fromJson(data);
    return loginResponse;

  }


}