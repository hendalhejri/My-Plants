import UserNotifications                         // مكتبة الإشعارات المحلية

// مدير الإشعارات: يطلب الإذن ويجدول الإشعارات ويلغيها، وما يعرف شي عن الشاشات
class NotificationManager: NSObject, UNUserNotificationCenterDelegate { // NSObject و Delegate عشان يطلع الإشعار والتطبيق مفتوح

    static let shared = NotificationManager()    // نسخة وحدة نستخدمها في كل التطبيق
    let center = UNUserNotificationCenter.current() // المسؤول عن الإشعارات في الجهاز

    override init() {                            // يشتغل أول مرة نستخدم shared
        super.init()                             // نجهّز NSObject
        center.delegate = self                   // نقول للجهاز: اسألنا قبل ما تعرض الإشعار والتطبيق مفتوح
    }                                            // نهاية init

    // الإذن
    func requestPermission() async -> Bool {     // يطلب الإذن ويرجع true إذا وافق المستخدم
        (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false // الطلب يطلع للمستخدم أول مرة بس، وبعدها يرجع الجواب المحفوظ
    }                                            // نهاية requestPermission

    // تفاصيل النبتة
    func details(of plant: Plant) -> String {    // نص يجمع الاسم والموعد، نقارنه عشان نعرف إذا النبتة تغيرت
        "\(plant.name)|\(plant.wateringDays)"     // مثلاً: Monstera|Every 2 days
    }                                            // نهاية details

    func days(for wateringDays: String) -> Int { // يحوّل Watering Days لعدد أيام
        if wateringDays == "Every 2 days" { return 2 } // كل يومين
        if wateringDays == "Every 3 days" { return 3 } // كل ثلاث أيام
        if wateringDays == "Once a week" { return 7 } // كل أسبوع
        if wateringDays == "Every 10 days" { return 10 } // كل عشر أيام
        if wateringDays == "Every 2 weeks" { return 14 } // كل أسبوعين
        return 1                                 // غير كذا: كل يوم
    }                                            // نهاية days

    // الجدولة
    func schedule(_ plant: Plant) {              // يجدول إشعار متكرر للنبتة، وإذا كان لها إشعار يستبدله
        let content = UNMutableNotificationContent() // محتوى الإشعار
        content.title = "My Plants"              // العنوان العريض فوق
        content.body = "Hey! let's water your \(plant.name) 🌱" // نص التصميم مع اسم النبتة
        content.sound = .default                 // صوت الإشعار العادي
        content.userInfo = ["details": details(of: plant)] // نخبي تفاصيل النبتة داخل الإشعار عشان نقارنها بعدين

        let seconds = Double(days(for: plant.wateringDays) * 24 * 60 * 60) // عدد الثواني بين كل إشعار والثاني
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: true) // يتكرر كل هالمدة من وقت الجدولة
        let request = UNNotificationRequest(identifier: plant.id.uuidString, content: content, trigger: trigger) // معرّف الإشعار = id النبتة
        center.add(request)                      // نضيفه للجهاز، ونفس المعرّف يستبدل الإشعار القديم
    }                                            // نهاية schedule

    func cancel(id: String) {                    // يلغي إشعار نبتة بالـ id حقها
        center.removePendingNotificationRequests(withIdentifiers: [id]) // نشيله من الإشعارات المجدولة
    }                                            // نهاية cancel

    func scheduledDetails() async -> [String: String] { // الإشعارات المجدولة: [id النبتة: تفاصيلها]
        var result: [String: String] = [:]       // قاموس فاضي نعبيه
        for request in await center.pendingNotificationRequests() where request.identifier != "test" { // كل الإشعارات المجدولة ما عدا التجريبي
            result[request.identifier] = request.content.userInfo["details"] as? String ?? "" // نحفظ تفاصيل كل إشعار
        }                                        // نهاية for
        return result                            // نرجع القاموس
    }                                            // نهاية scheduledDetails

    // إشعار تجريبي (مؤقت)
    func sendTest(plantName: String) {           // يرسل إشعار مرة وحدة بعد ثواني
        let content = UNMutableNotificationContent() // محتوى الإشعار
        content.title = "My Plants"              // العنوان
        content.body = "Hey! let's water your \(plantName) 🌱" // النص مع اسم النبتة
        content.sound = .default                 // الصوت العادي
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false) // بعد 10 ثواني: كبّري الرقم يتأخر الإشعار أكثر
        center.add(UNNotificationRequest(identifier: "test", content: content, trigger: trigger)) // نضيفه بمعرّف "test"
    }                                            // نهاية sendTest

    // الإشعار والتطبيق مفتوح
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) { // الجهاز يسألنا: أعرض الإشعار والتطبيق مفتوح؟
        completionHandler([.banner, .sound])     // نعم: اعرضه فوق مع الصوت
    }                                            // نهاية userNotificationCenter
}                                                // نهاية NotificationManager
