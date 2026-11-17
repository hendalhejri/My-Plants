import SwiftUI                                   // مكتبة SwiftUI
import SwiftData                                 // مكتبة SwiftData عشان نحفظ النباتات

@main struct MyApp: App {                        // بداية التطبيق، و@main يعني من هنا يشتغل
    var body: some Scene {                       // محتوى التطبيق
        WindowGroup {                            // نافذة التطبيق
            MyPlantsView()                       // أول شاشة تطلع: الشاشة الرئيسية
        }                                        // نهاية WindowGroup
        .modelContainer(for: Plant.self)         // نجهّز مكان حفظ النباتات في الجهاز
    }                                            // نهاية body
}                                                // نهاية MyApp
