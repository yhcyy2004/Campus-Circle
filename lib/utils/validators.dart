class Validators {
  // 验证学号
  static String? validateStudentNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入学号';
    }
    if (value.length != 12) {
      return '学号必须为12位数字';
    }
    if (!RegExp(r'^\d{12}$').hasMatch(value)) {
      return '学号只能包含数字';
    }
    return null;
  }
  
  // 验证邮箱
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@zzuli\.edu\.cn$').hasMatch(value)) {
      return '请输入有效的zzuli.edu.cn邮箱';
    }
    return null;
  }
  
  // 验证密码
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码至少6位';
    }
    return null;
  }
  
  // 验证确认密码
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }
    if (value != password) {
      return '两次输入的密码不一致';
    }
    return null;
  }
  
  // 验证姓名
  static String? validateRealName(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入姓名';
    }
    if (value.length < 2 || value.length > 10) {
      return '姓名长度为2-10个字符';
    }
    return null;
  }
  
  // 验证专业
  static String? validateMajor(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入专业';
    }
    if (value.length > 50) {
      return '专业名称不能超过50个字符';
    }
    return null;
  }
  
  // 验证年级
  static String? validateGrade(String? value) {
    if (value == null || value.isEmpty) {
      return '请选择年级';
    }
    final grade = int.tryParse(value);
    if (grade == null || grade < 2020 || grade > DateTime.now().year + 1) {
      return '请选择有效的年级';
    }
    return null;
  }
  
  // 验证手机号
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 手机号为可选项
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
      return '请输入有效的手机号';
    }
    return null;
  }
  
  // 验证昵称
  static String? validateNickname(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入昵称';
    }
    if (value.length < 2 || value.length > 20) {
      return '昵称长度为2-20个字符';
    }
    return null;
  }
  
  // 验证QQ号
  static String? validateQQ(String? value) {
    if (value == null || value.isEmpty) {
      return null; // QQ号为可选项
    }
    if (!RegExp(r'^\d{5,11}$').hasMatch(value)) {
      return '请输入有效的QQ号';
    }
    return null;
  }
  
  // 验证个人简介
  static String? validateBio(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 个人简介为可选项
    }
    if (value.length > 200) {
      return '个人简介不能超过200个字符';
    }
    return null;
  }
}