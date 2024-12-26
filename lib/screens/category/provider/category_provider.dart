import 'dart:developer';
import 'dart:io';
// import 'package:cloudinary/cloudinary.dart' as cdny;

import '../../../models/api_response.dart';
import '../../../services/http_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../utility/snack_bar_helper.dart';

class CategoryProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addCategoryFormKey = GlobalKey<FormState>();
  TextEditingController categoryNameCtrl = TextEditingController();
  Category? categoryForUpdate;

  File? selectedImage;
  XFile? imgXFile;

  CategoryProvider(this._dataProvider);

  // final cloudinary = cdny.Cloudinary.signedConfig(
  //   apiKey: "963536753934335",
  //   apiSecret: "bJAHR80nCkuxDUCH7QaXT_TigXY",
  //   cloudName: 'duoivoaqm',
  // );

  addCategory() async {
    try {
      if (selectedImage == null) {
        SnackBarHelper.showErrorSnackBar("Please select an image!");
        return; // stop the program eviction
      }

      // test with cloudinary for image upload
      // final cdnyImage = await cloudinary.upload(
      //   file: selectedImage!.path,
      //   resourceType: cdny.CloudinaryResourceType.image,
      //   folder: 'category',
      //   // fileName: 'some-name',
      // );
      // debugPrint("cdnyImage : ${cdnyImage.secureUrl}");
      // Map<String, dynamic> form = {
      //   'name': categoryNameCtrl.text,
      //   'image': cdnyImage.secureUrl, // from cludinary
      // };

      Map<String, dynamic> formDataMap = {
        'name': categoryNameCtrl.text,
        'image': 'no-data', // image path will be added from the server side
      };
      final FormData form =
          await createFormData(imgXFile: imgXFile, formData: formDataMap);

      final response =
          await service.addItem(endpointUrl: 'categories', itemData: form);
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar("${apiResponse.message}");
          _dataProvider.getAllCategory();
          log("Category added");
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to add category: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            "Error ${response.body?['message'] ?? response.statusText}");
      }
    } catch (err) {
      print(err);
      SnackBarHelper.showErrorSnackBar("An error occurred : ${err}");
      rethrow;
    }
    ;
  }

  updateCategory() async {
    try {
      Map<String, dynamic> formDataMap = {
        'name': categoryNameCtrl.text,
        'image': categoryForUpdate?.image ?? "",
      };

      final FormData form =
          await createFormData(imgXFile: imgXFile, formData: formDataMap);

      final response = await service.updateItem(
          endpointUrl: 'categories',
          itemId: categoryForUpdate?.sId ?? '',
          itemData: form);
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          log('category added');
          _dataProvider.getAllCategory();
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to update category: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (err) {
      print(err);
      SnackBarHelper.showErrorSnackBar('An error occurred: $err');
      rethrow;
    }
  }

  submitCategory() {
    if (categoryForUpdate != null) {
      updateCategory();
    } else {
      addCategory();
    }
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      imgXFile = image;
      notifyListeners();
    }
  }

  deleteCategory(Category category) async {
    try {
      Response response = await service.deleteItem(
          endpointUrl: 'categories', itemId: category.sId ?? '');
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('Category deleted successfully');
          _dataProvider.getAllCategory();
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

  //? to create form data for sending image with body
  Future<FormData> createFormData(
      {required XFile? imgXFile,
      required Map<String, dynamic> formData}) async {
    if (imgXFile != null) {
      MultipartFile multipartFile;
      if (kIsWeb) {
        String fileName = imgXFile.name;
        Uint8List byteImg = await imgXFile.readAsBytes();
        multipartFile = MultipartFile(byteImg, filename: fileName);
      } else {
        String fileName = imgXFile.path.split('/').last;
        multipartFile = MultipartFile(imgXFile.path, filename: fileName);
      }
      formData['img'] = multipartFile;
    }
    final FormData form = FormData(formData);
    return form;
  }

  //? set data for update on editing
  setDataForUpdateCategory(Category? category) {
    if (category != null) {
      clearFields();
      categoryForUpdate = category;
      categoryNameCtrl.text = category.name ?? '';
    } else {
      clearFields();
    }
  }

  //? to clear text field and images after adding or update category
  clearFields() {
    categoryNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    categoryForUpdate = null;
  }
}
