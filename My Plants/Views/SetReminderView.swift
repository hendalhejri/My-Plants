import SwiftUI                                   // مكتبة SwiftUI عشان نرسم الشاشة
import SwiftData                                 // مكتبة SwiftData عشان ناخذ مكان الحفظ ونعطيه للـ ViewModel

struct SetReminderView: View {                   // شاشة إضافة أو تعديل نبتة: ترسم بس، والمنطق في SetReminderViewModel

    @State private var viewModel: SetReminderViewModel // المنطق والبيانات حق الشاشة
    @Environment(\.modelContext) private var context // مكان الحفظ، نعطيه للـ ViewModel لما نحفظ أو نحذف
    @Environment(\.dismiss) private var dismiss  // نستخدمه عشان نسكّر الشاشة

    init(plant: Plant? = nil) {                  // إذا ما أعطيناها نبتة تصير إضافة، وإذا أعطيناها تصير تعديل
        _viewModel = State(initialValue: SetReminderViewModel(plant: plant)) // نجهّز الـ ViewModel بالنبتة
    }                                            // نهاية init

    var body: some View {                        // محتوى الشاشة
        VStack(spacing: 0) {                     // نرتب العناصر فوق بعض بدون مسافات تلقائية

            // الشريط العلوي
            HStack {                             // زر الإغلاق والعنوان وزر الحفظ جنب بعض
                Button {                         // زر الإغلاق
                    dismiss()                    // نسكّر الشاشة بدون حفظ
                } label: {                       // شكل الزر
                    Image(systemName: "xmark")   // علامة ✕
                        .font(.system(size: 17, weight: .semibold)) // حجم العلامة: كل ما كبر الرقم، كبرت
                        .foregroundStyle(Color.primary) // اللون الأساسي (نكتب Color عشان ما ياخذ لون الزر الأزرق)
                        .frame(width: 44, height: 44) // حجم الدائرة: كبّري الرقمين مع بعض تكبر
                        .background(Color("FieldBackground"), in: Circle()) // خلفية رمادية دائرية
                }                                // نهاية زر الإغلاق

                Spacer()                         // فراغ مرن يدفع العنوان للنص

                Text("Set Reminder")             // عنوان الشاشة
                    .font(.system(size: 17, weight: .semibold)) // حجم الخط 17 وسماكته شبه عريضة
                    .foregroundStyle(.primary)   // اللون الأساسي

                Spacer()                         // فراغ مرن يدفع زر الحفظ لليمين

                Button {                         // زر الحفظ
                    viewModel.save(context: context) // نحفظ النبتة
                    dismiss()                    // نسكّر الشاشة
                } label: {                       // شكل الزر
                    Image(systemName: "checkmark") // علامة ✓
                        .font(.system(size: 17, weight: .semibold)) // حجم العلامة: كل ما كبر الرقم، كبرت
                        .foregroundStyle(.white) // لونها أبيض
                        .frame(width: 44, height: 44) // حجم الدائرة: كبّري الرقمين مع بعض تكبر
                        .background(Color("PrimaryGreen"), in: Circle()) // خلفية خضراء دائرية
                }                                // نهاية زر الحفظ
                .disabled(!viewModel.canSave)    // ما ينضغط إذا اسم النبتة فاضي
            }                                    // نهاية HStack الشريط
            .padding(.horizontal, 28)            // مسافة الأزرار من حواف الشاشة: كل ما كبر الرقم، دخلت الأزرار لجوا
            .padding(.top, 15)                   // مسافة فوق الشريط: كل ما كبر الرقم، نزل الشريط

            // اسم النبتة
            HStack(spacing: 8) {                 // الكلمة جنب مكان الكتابة، والمسافة بينهم 8
                Text("Plant Name")               // الكلمة الثابتة
                    .foregroundStyle(.primary)   // اللون الأساسي
                TextField("Pothos", text: $viewModel.name) // مكان كتابة الاسم، و"Pothos" تطلع رمادية لين يكتب
            }                                    // نهاية HStack
            .font(.system(size: 18))             // حجم الخط 18
            .tint(Color("CheckGreen"))           // لون مؤشر الكتابة أخضر
            .padding(.horizontal, 19)            // مسافة داخلية يمين ويسار: كل ما كبر الرقم، دخل الكلام لجوا
            .frame(height: 62)                   // طول المربع: كل ما كبر الرقم، طال
            .background(Color("FieldBackground"), in: RoundedRectangle(cornerRadius: 30)) // خلفية بزوايا دائرية: كل ما كبر الرقم، صارت الزوايا أدور
            .padding(.horizontal, 17)            // مسافة المربع من حواف الشاشة: كل ما كبر الرقم، ضاق المربع
            .padding(.top, 59)                   // مسافة بين الشريط والمربع: كل ما كبر الرقم، نزل المربع

            // الغرفة والإضاءة
            VStack(spacing: 0) {                 // الصفين فوق بعض
                HStack {                         // صف الغرفة
                    Image(systemName: "location") // أيقونة السهم
                    Text("Room")                 // كلمة Room
                    Spacer()                     // فراغ مرن يدفع الاختيار لليمين
                    Picker("Room", selection: $viewModel.room) { // قائمة اختيار الغرفة
                        ForEach(viewModel.rooms, id: \.self) { option in // خيار لكل غرفة
                            Text(option)         // اسم الغرفة
                        }                        // نهاية ForEach
                    }                            // نهاية Picker
                }                                // نهاية صف الغرفة
                .frame(height: 44)               // طول الصف: كل ما كبر الرقم، طال الصف

                Divider()                        // الخط بين الصفين

                HStack {                         // صف الإضاءة
                    Image(systemName: "sun.max") // أيقونة الشمس
                    Text("Light")                // كلمة Light
                    Spacer()                     // فراغ مرن يدفع الاختيار لليمين
                    Picker("Light", selection: $viewModel.light) { // قائمة اختيار الإضاءة
                        ForEach(viewModel.lights, id: \.self) { option in // خيار لكل نوع إضاءة
                            Text(option)         // اسم الإضاءة
                        }                        // نهاية ForEach
                    }                            // نهاية Picker
                }                                // نهاية صف الإضاءة
                .frame(height: 44)               // طول الصف
            }                                    // نهاية VStack
            .font(.system(size: 18))             // حجم الخط 18
            .tint(.secondary)                    // لون الاختيارات رمادي
            .padding(.horizontal, 16)            // مسافة داخلية يمين ويسار: كل ما كبر الرقم، دخل الكلام لجوا
            .padding(.vertical, 4)               // مسافة داخلية فوق وتحت: كل ما كبر الرقم، طال المربع
            .background(Color("FieldBackground"), in: RoundedRectangle(cornerRadius: 26)) // خلفية بزوايا دائرية
            .padding(.horizontal, 17)            // مسافة المربع من حواف الشاشة
            .padding(.top, 47)                   // مسافة بين اسم النبتة والمربع: كل ما كبر الرقم، نزل المربع

            // أيام السقي وكمية الماء
            VStack(spacing: 0) {                 // الصفين فوق بعض
                HStack {                         // صف أيام السقي
                    Image(systemName: "drop")    // أيقونة القطرة
                    Text("Watering Days")        // كلمة Watering Days
                    Spacer()                     // فراغ مرن يدفع الاختيار لليمين
                    Picker("Watering Days", selection: $viewModel.wateringDays) { // قائمة اختيار أيام السقي
                        ForEach(viewModel.wateringOptions, id: \.self) { option in // خيار لكل مدة
                            Text(option)         // المدة
                        }                        // نهاية ForEach
                    }                            // نهاية Picker
                }                                // نهاية صف أيام السقي
                .frame(height: 44)               // طول الصف

                Divider()                        // الخط بين الصفين

                HStack {                         // صف كمية الماء
                    Image(systemName: "drop")    // أيقونة القطرة
                    Text("Water")                // كلمة Water
                    Spacer()                     // فراغ مرن يدفع الاختيار لليمين
                    Picker("Water", selection: $viewModel.water) { // قائمة اختيار كمية الماء
                        ForEach(viewModel.waterOptions, id: \.self) { option in // خيار لكل كمية
                            Text(option)         // الكمية
                        }                        // نهاية ForEach
                    }                            // نهاية Picker
                }                                // نهاية صف كمية الماء
                .frame(height: 44)               // طول الصف
            }                                    // نهاية VStack
            .font(.system(size: 18))             // حجم الخط 18
            .tint(.secondary)                    // لون الاختيارات رمادي
            .padding(.horizontal, 16)            // مسافة داخلية يمين ويسار
            .padding(.vertical, 4)               // مسافة داخلية فوق وتحت
            .background(Color("FieldBackground"), in: RoundedRectangle(cornerRadius: 26)) // خلفية بزوايا دائرية
            .padding(.horizontal, 17)            // مسافة المربع من حواف الشاشة
            .padding(.top, 40)                   // مسافة بين المربعين: كل ما كبر الرقم، نزل المربع الثاني

            // زر الحذف
            if viewModel.isEditing {             // يطلع بس لما نعدّل نبتة موجودة
                Button {                         // زر الحذف
                    viewModel.delete(context: context) // نحذف النبتة
                    dismiss()                    // نسكّر الشاشة
                } label: {                       // شكل الزر
                    Text("Delete Reminder")      // الكلام على الزر
                        .font(.system(size: 17)) // حجم الخط 17
                        .foregroundStyle(.red)   // لون أحمر
                        .frame(maxWidth: .infinity) // الزر ياخذ كل العرض المتاح
                        .frame(height: 52)       // طول الزر: كل ما كبر الرقم، طال
                        .background(Color("FieldBackground"), in: RoundedRectangle(cornerRadius: 26)) // خلفية بزوايا دائرية
                }                                // نهاية الزر
                .padding(.horizontal, 24)        // مسافة الزر من حواف الشاشة: كل ما كبر الرقم، ضاق الزر
                .padding(.top, 70)               // مسافة بين المربع والزر: كل ما كبر الرقم، نزل الزر
            }                                    // نهاية if

            Spacer()                             // فراغ مرن يدفع كل شي لفوق
        }                                        // نهاية VStack
        .presentationBackground(Color("SheetBackground")) // لون خلفية الشاشة من Assets
    }                                            // نهاية body
}                                                // نهاية SetReminderView

#Preview {                                       // يعرض الشاشة في الـ Canvas
    SetReminderView()                            // شاشة الإضافة
        .modelContainer(for: Plant.self, inMemory: true) // حفظ مؤقت للمعاينة بس
}
