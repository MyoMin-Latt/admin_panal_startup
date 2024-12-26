import 'dart:developer';

import '../../../models/api_response.dart';
import '../../../models/brand.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/sub_category.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';

class BrandProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;

  final addBrandFormKey = GlobalKey<FormState>();
  TextEditingController brandNameCtrl = TextEditingController();
  SubCategory? selectedSubCategory;
  Brand? brandForUpdate;

  BrandProvider(this._dataProvider);

  addBrand() async {
    try {
      Map<String, dynamic> brand = {
        'name': brandNameCtrl.text,
        'subcategoryId': selectedSubCategory?.sId
      };
      final response =
          await service.addItem(endpointUrl: 'brands', itemData: brand);
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(
            ("${apiResponse.message}"),
          );
          log("Brand added");
          _dataProvider.getAllBrands();
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to add Brand: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (err) {
      print(err);
      SnackBarHelper.showErrorSnackBar("An error occurred: $err");
      rethrow;
    }
  }

  updateBrand() async {
    try {
      if (brandForUpdate != null) {
        Map<String, dynamic> subCategory = {
          'name': brandNameCtrl.text,
          'subcategoryId': selectedSubCategory?.sId
        };
        final response = await service.updateItem(
            endpointUrl: 'brands',
            itemId: brandForUpdate?.sId ?? '',
            itemData: subCategory);
        if (response.isOk) {
          ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
          if (apiResponse.success == true) {
            clearFields();
            SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
            log("Brand added");
            _dataProvider.getAllBrands();
          } else {
            SnackBarHelper.showErrorSnackBar(
                'Failed to add brand: ${apiResponse.message}');
          }
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Error ${response.body?['message'] ?? response.statusText}');
        }
      }
    } catch (err) {
      print(err);
      SnackBarHelper.showErrorSnackBar('An error occurred: $err');
      rethrow;
    }
  }

  submitBrand() {
    if (brandForUpdate != null) {
      updateBrand();
    } else {
      addBrand();
    }
  }

  deleteBrand(Brand brand) async {
    try {
      Response response = await service.deleteItem(
          endpointUrl: 'brands', itemId: brand.sId ?? '');
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('Brand deleted successfully');
          _dataProvider.getAllBrands();
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            ('Error ${response.body?['message'] ?? response.statusText}'));
      }
    } catch (err) {
      print(err);
      rethrow;
    }
  }

  //? set data for update on editing
  setDataForUpdateBrand(Brand? brand) {
    if (brand != null) {
      brandForUpdate = brand;
      brandNameCtrl.text = brand.name ?? '';
      selectedSubCategory = _dataProvider.subCategories.firstWhereOrNull(
          (element) => element.sId == brand.subcategoryId?.sId);
    } else {
      clearFields();
    }
  }

  //? to clear text field and images after adding or update brand
  clearFields() {
    brandNameCtrl.clear();
    selectedSubCategory = null;
    brandForUpdate = null;
  }

  updateUI() {
    notifyListeners();
  }
}
