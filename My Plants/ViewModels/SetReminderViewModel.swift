import Foundation                                // مكتبة الأساسيات عشان نستخدم UserDefaults
import SwiftData                                 // مكتبة SwiftData عشان نحفظ ونحذف النبتة

@Observable                                      // أي تغيير في المتغيرات هنا يحدّث الشاشة لحاله
class SetReminderViewModel {                     // المنطق والبيانات حق شاشة إضافة أو تعديل نبتة

    // البيانات
    let plant: Plant?                            // إذا فاضية (nil) نضيف نبتة جديدة، وإذا فيها نبتة نعدلها
    var name = ""                                // اسم النبتة اللي يكتبه المستخدم
    var room = "Bedroom"                         // الغرفة المختارة، تبدأ Bedroom
    var light = "Full Sun"                       // الإضاءة المختارة، تبدأ Full Sun
    var wateringDays = "Every day"               // أيام السقي المختارة، تبدأ Every day
    var water = "20-50 ml"                       // كمية الماء المختارة، تبدأ 20-50 ml

    // الخيارات
    let rooms = ["Bedroom", "Living Room", "Kitchen", "Balcony", "Bathroom"] // خيارات الغرفة
    let lights = ["Full Sun", "Partial Sun", "Low Light"] // خيارات الإضاءة
    let wateringOptions = ["Every day", "Every 2 days", "Every 3 days", "Once a week", "Every 10 days", "Every 2 weeks"] // خيارات أيام السقي
    let waterOptions = ["20-50 ml", "50-100 ml", "100-200 ml", "200-300 ml"] // خيارات كمية الماء

    init(plant: Plant?) {                        // يشتغل لما تفتح الشاشة
        self.plant = plant                       // نحفظ النبتة (أو nil إذا إضافة)
        if let plant {                           // إذا نعدّل نبتة موجودة
            name = plant.name                    // نعبّي الاسم الحالي
            room = plant.room                    // نعبّي الغرفة الحالية
            light = plant.light                  // نعبّي الإضاءة الحالية
            wateringDays = plant.wateringDays    // نعبّي أيام السقي الحالية
            water = plant.water                  // نعبّي كمية الماء الحالية
        }                                        // نهاية if
    }                                            // نهاية init

    // حسابات تستخدمها الشاشة
    var isEditing: Bool {                        // هل نعدّل نبتة موجودة؟ نستخدمه عشان نظهر زر الحذف
        plant != nil                             // true إذا فيه نبتة
    }                                            // نهاية isEditing

    var canSave: Bool {                          // هل نقدر نحفظ؟
        !name.isEmpty                            // بس إذا اسم النبتة مو فاضي
    }                                            // نهاية canSave

    // الحفظ
    func save(context: ModelContext) {           // يشتغل لما يضغط ✓
        if let plant {                           // إذا نعدّل نبتة موجودة
            plant.name = name                    // نحدّث الاسم
            plant.room = room                    // نحدّث الغرفة
            plant.light = light                  // نحدّث الإضاءة
            plant.wateringDays = wateringDays    // نحدّث أيام السقي
            plant.water = water                  // نحدّث كمية الماء
        } else {                                 // إذا نضيف نبتة جديدة
            context.insert(Plant(name: name, room: room, light: light, wateringDays: wateringDays, water: water)) // نحفظ النبتة الجديدة
            UserDefaults.standard.set(true, forKey: "hasAddedPlant") // نسجّل إن المستخدم أضاف نبتة، عشان شاشة البداية ما ترجع
        }                                        // نهاية if
        try? context.save()                      // نحفظ التغييرات في الجهاز
    }                                            // نهاية save

    // الحذف
    func delete(context: ModelContext) {         // يشتغل لما يضغط Delete Reminder
        if let plant {                           // إذا فيه نبتة نعدلها
            context.delete(plant)                // نحذفها
            try? context.save()                  // نحفظ الحذف في الجهاز
        }                                        // نهاية if
    }                                            // نهاية delete
}                                                // نهاية SetReminderViewModel
