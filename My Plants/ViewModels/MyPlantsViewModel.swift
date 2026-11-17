import Foundation                                // مكتبة الأساسيات عشان نستخدم Date و UserDefaults
import SwiftData                                 // مكتبة SwiftData عشان نجيب النباتات ونحذفها

@Observable                                      // أي تغيير في المتغيرات هنا يحدّث الشاشة لحاله
class MyPlantsViewModel {                        // المنطق والبيانات حق الشاشة الرئيسية

    // البيانات
    var plants: [Plant] = []                     // كل النباتات المحفوظة، مرتبة من الأقدم للأحدث
    var hasAddedPlant = false                    // هل المستخدم أضاف نبتة قبل؟ نفرّق فيه بين شاشة البداية وشاشة No reminders
    var showAddSheet = false                     // إذا صارت true تطلع شاشة إضافة نبتة
    var selectedPlant: Plant?                    // النبتة اللي ضغط عليها المستخدم عشان يعدلها
    private var context: ModelContext?           // مكان الحفظ، نستلمه من الشاشة أول ما تفتح

    // حسابات تستخدمها الشاشة
    var wateredCount: Int {                      // عدد النباتات اللي انسقت
        plants.filter { $0.isWatered }.count     // نعد بس اللي isWatered حقها true
    }                                            // نهاية wateredCount

    var isNewUser: Bool {                        // مستخدم جديد = ما عنده نباتات وما أضاف قبل
        plants.isEmpty && !hasAddedPlant         // الشرطين لازم يصيرون مع بعض
    }                                            // نهاية isNewUser

    var allWatered: Bool {                       // هل كل النباتات انسقت؟
        !plants.isEmpty && wateredCount == plants.count // فيه نباتات، وعدد اللي انسقت = عددها كلها
    }                                            // نهاية allWatered

    var progress: Double {                       // نسبة اللي انسقت من 0 إلى 1، للشريط الأخضر
        plants.isEmpty ? 0 : Double(wateredCount) / Double(plants.count) // إذا ما فيه نباتات النسبة 0
    }                                            // نهاية progress

    var progressText: String {                   // الجملة اللي فوق الشريط
        wateredCount == 0 ? "Your plants are waiting for a sip 💦" : "\(wateredCount) of your plants feel loved today✨" // إذا ما انسقى شي الجملة الأولى، وإلا العدد
    }                                            // نهاية progressText

    func lightIcon(for plant: Plant) -> String { // اسم أيقونة الإضاءة حسب نوعها
        if plant.light == "Low Light" { return "moon" } // إضاءة قليلة = قمر
        if plant.light == "Partial Sun" { return "sun.haze" } // شمس جزئية = شمس عليها غيم
        return "sun.max"                         // غير كذا = شمس كاملة
    }                                            // نهاية lightIcon

    // أول ما تفتح الشاشة أو يرجع لها المستخدم
    func start(context: ModelContext) {          // تستدعيها الشاشة وتعطينا مكان الحفظ
        self.context = context                   // نحفظ مكان الحفظ عشان نستخدمه بعدين
        fetchPlants()                            // نجيب النباتات المحفوظة
        resetIfNewDay()                          // إذا اليوم جديد نرجّع علامات الصح فاضية
    }                                            // نهاية start

    // جلب النباتات
    func fetchPlants() {                         // نجيب النباتات من الحفظ ونحدّث الشاشة
        guard let context else { return }       // إذا ما عندنا مكان الحفظ، نوقف
        let sortByDate = FetchDescriptor<Plant>(sortBy: [SortDescriptor(\.createdAt)]) // طلب: كل النباتات مرتبة من الأقدم
        plants = (try? context.fetch(sortByDate)) ?? [] // ننفذ الطلب، وإذا صار خطأ نخليها فاضية
        hasAddedPlant = UserDefaults.standard.bool(forKey: "hasAddedPlant") // نقرأ هل أضاف نبتة قبل
        updateReminder()                         // نشغّل أو نلغي الإشعار حسب وجود النباتات
    }                                            // نهاية fetchPlants

    // أفعال المستخدم
    func toggleWatered(_ plant: Plant) {         // لما يضغط الدائرة جنب النبتة
        plant.isWatered.toggle()                 // إذا انسقت تصير لا، والعكس
    }                                            // نهاية toggleWatered

    func delete(_ plant: Plant) {                // لما يسحب الصف ويضغط سلة المهملات
        context?.delete(plant)                   // نحذف النبتة
        try? context?.save()                     // نحفظ الحذف
        fetchPlants()                            // نجيب القائمة من جديد بدون النبتة المحذوفة
    }                                            // نهاية delete

    // يوم جديد
    func resetIfNewDay() {                       // ترجّع علامات الصح فاضية مرة وحدة كل يوم
        let today = Date.now.formatted(date: .numeric, time: .omitted) // تاريخ اليوم كنص
        if today != UserDefaults.standard.string(forKey: "lastOpenedDay") { // إذا آخر يوم فتح فيه التطبيق مو اليوم
            for plant in plants {                // نمر على كل النباتات
                plant.isWatered = false          // نرجّع علامة الصح فاضية
            }                                    // نهاية for
            UserDefaults.standard.set(today, forKey: "lastOpenedDay") // نحفظ إن اليوم هذا خلاص انحسب
        }                                        // نهاية if
    }                                            // نهاية resetIfNewDay

    // الإشعارات
    func updateReminder() {                      // نخلي إشعار كل نبتة مطابق لبياناتها
        let manager = NotificationManager.shared // مدير الإشعارات
        Task {                                   // نشغّله بالخلفية عشان ما يوقف الشاشة
            let scheduled = await manager.scheduledDetails() // الإشعارات المجدولة حالياً
            for id in scheduled.keys where !plants.contains(where: { $0.id.uuidString == id }) { // كل إشعار ما له نبتة
                manager.cancel(id: id)           // النبتة انحذفت، فنلغي إشعارها
            }                                    // نهاية for
            if plants.isEmpty { return }         // ما فيه نباتات، فما نطلب إذن ولا نجدول
            if await !manager.requestPermission() { return } // نطلب الإذن (يطلع أول ما يضيف أول نبتة)، وإذا رفض نوقف
            for plant in plants where scheduled[plant.id.uuidString] != manager.details(of: plant) { // كل نبتة جديدة أو تغيّر اسمها أو موعدها
                manager.schedule(plant)          // نجدول إشعارها أو نحدّثه
            }                                    // نهاية for
        }                                        // نهاية Task
    }                                            // نهاية updateReminder

    // إشعار تجريبي (مؤقت)
    func sendTestNotification() {                // للزر التجريبي: إشعار بعد 10 ثواني
        Task {                                   // بالخلفية عشان ننتظر الإذن
            if await NotificationManager.shared.requestPermission() { // إذا المستخدم سمح بالإشعارات
                NotificationManager.shared.sendTest(plantName: plants.first?.name ?? "plant") // نرسل باسم أول نبتة، أو "plant" إذا ما فيه
            }                                    // نهاية if
        }                                        // نهاية Task
    }                                            // نهاية sendTestNotification
}                                                // نهاية MyPlantsViewModel
