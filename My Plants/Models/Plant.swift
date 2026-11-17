import Foundation                                // مكتبة الأساسيات عشان نستخدم Date
import SwiftData                                 // مكتبة SwiftData عشان نحفظ النباتات حتى بعد ما يتسكر التطبيق

// بيانات النبتة
@Model                                           // يخلي SwiftData يحفظ هذا النوع تلقائياً في الجهاز
class Plant {                                    // نعرّف شكل بيانات النبتة الوحدة
    var id = UUID()                              // رقم مميز لكل نبتة، نستخدمه كمعرّف لإشعارها
    var name: String                             // اسم النبتة، مثل Monstera
    var room: String                             // الغرفة، مثل Kitchen
    var light: String                            // الإضاءة، مثل Full Sun
    var wateringDays: String                     // كل كم يوم تنسقى، مثل Every day
    var water: String                            // كمية الماء، مثل 20-50 ml
    var isWatered: Bool = false                  // هل انسقت اليوم؟ تبدأ false يعني لا
    var createdAt: Date = Date.now               // وقت إضافة النبتة، عشان نرتب القائمة حسب الأقدم

    init(name: String, room: String, light: String, wateringDays: String, water: String) { // نستخدمها لما نضيف نبتة جديدة
        self.name = name                         // نحفظ الاسم
        self.room = room                         // نحفظ الغرفة
        self.light = light                       // نحفظ الإضاءة
        self.wateringDays = wateringDays         // نحفظ أيام السقي
        self.water = water                       // نحفظ كمية الماء
    }                                            // نهاية init
}                                                // نهاية Plant
