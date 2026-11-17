import SwiftUI                                   // مكتبة SwiftUI عشان نرسم الشاشة
import SwiftData                                 // مكتبة SwiftData عشان ناخذ مكان الحفظ ونعطيه للـ ViewModel

struct MyPlantsView: View {                      // الشاشة الرئيسية: ترسم بس، والمنطق في MyPlantsViewModel

    @State private var viewModel = MyPlantsViewModel() // المنطق والبيانات حق الشاشة
    @Environment(\.modelContext) private var context // مكان الحفظ، نعطيه للـ ViewModel
    @Environment(\.scenePhase) private var scenePhase // يقول لنا إذا التطبيق مفتوح قدام المستخدم أو بالخلفية

    var body: some View {                        // محتوى الشاشة
        NavigationStack {                        // يعطينا العنوان الكبير فوق
            ZStack(alignment: .bottomTrailing) { // نحط زر + فوق المحتوى في الزاوية تحت يمين
                VStack(spacing: 0) {             // نرتب العناصر فوق بعض بدون مسافات تلقائية
                    Divider()                    // الخط الرفيع تحت العنوان

                    if viewModel.isNewUser {     // أول مرة يفتح التطبيق
                        startContent             // شاشة "Start your plant journey!"
                    } else if viewModel.plants.isEmpty { // حذف كل نباتاته
                        noRemindersContent       // شاشة "No reminders set yet.."
                    } else if viewModel.allWatered { // سقى كل النباتات
                        allDoneContent           // شاشة "All Done! 🎉"
                    } else {                     // باقي نباتات ما انسقت
                        plantsListContent        // قائمة النباتات مع شريط التقدم
                    }                            // نهاية الشروط
                }                                // نهاية VStack

                if !viewModel.isNewUser {        // زر + يطلع في كل الحالات إلا شاشة البداية
                    plusButton                   // الزر الأخضر الدائري
                }                                // نهاية الشرط
            }                                    // نهاية ZStack
            .navigationTitle("My Plants 🌱")     // العنوان الكبير
            .toolbar {                           // أزرار شريط العنوان
                Button("🔔 Test") {              // زر تجريبي مؤقت: احذفيه بعد ما تجربين
                    viewModel.sendTestNotification() // يطلب من الـ ViewModel إشعار بعد 10 ثواني
                }                                // نهاية الزر
            }                                    // نهاية toolbar
            .sheet(isPresented: $viewModel.showAddSheet, onDismiss: viewModel.fetchPlants) { // لما showAddSheet تصير true، ولما تتسكر نحدّث القائمة
                SetReminderView()                // تطلع شاشة إضافة نبتة جديدة
            }                                    // نهاية sheet الإضافة
            .sheet(item: $viewModel.selectedPlant, onDismiss: viewModel.fetchPlants) { plant in // لما يضغط على نبتة، ولما تتسكر نحدّث القائمة
                SetReminderView(plant: plant)    // تطلع شاشة تعديل هذي النبتة
            }                                    // نهاية sheet التعديل
            .onChange(of: scenePhase, initial: true) { // يشتغل لما يفتح التطبيق أو يرجع له المستخدم
                if scenePhase == .active {       // إذا التطبيق قدام المستخدم
                    viewModel.start(context: context) // نجيب النباتات ونشيك إذا اليوم جديد
                }                                // نهاية if
            }                                    // نهاية onChange
        }                                        // نهاية NavigationStack
    }                                            // نهاية body

    // شاشة البداية
    var startContent: some View {                // المحتوى لما المستخدم جديد
        VStack(spacing: 0) {                     // نرتب العناصر فوق بعض
            // صورة النبتة
            Image("PlantHappy")                  // صورة النبتة المبتسمة من Assets
                .resizable()                     // نسمح بتغيير حجمها
                .scaledToFit()                   // نحافظ على نسبتها بدون تمطيط
                .frame(height: 200)              // طول النبتة: كل ما كبر الرقم، كبرت النبتة
                .padding(.top, 77)               // مسافة بين الخط والنبتة: كل ما كبر الرقم، نزلت النبتة

            // العنوان
            Text("Start your plant journey!")    // جملة العنوان
                .font(.system(size: 25, weight: .semibold)) // حجم الخط 25 وسماكته شبه عريضة
                .foregroundStyle(.primary)       // اللون الأساسي (أبيض في الداكن)
                .padding(.top, 37)               // مسافة بين النبتة والعنوان: كل ما كبر الرقم، نزل العنوان

            // النص الوصفي
            Text("Now all your plants will be in one place and we will help you take care of them :)🪴") // النص الرمادي
                .font(.system(size: 16))         // حجم الخط 16
                .foregroundStyle(.secondary)     // لون رمادي يتغير مع Dark Mode
                .multilineTextAlignment(.center) // توسيط النص لما يصير أكثر من سطر
                .fixedSize(horizontal: false, vertical: true) // النص ياخذ طوله الكامل ولا ينقص بـ "..."
                .padding(.horizontal, 40)        // مسافة من الجانبين: كل ما كبر الرقم، ضاق النص ونزل لسطر ثاني
                .padding(.top, 25)               // مسافة بين العنوان والنص: كل ما كبر الرقم، نزل النص

            // الزر
            Button {                             // زر إضافة نبتة
                viewModel.showAddSheet = true    // نفتح شاشة Set Reminder
            } label: {                           // شكل الزر
                Text("Set Plant Reminder")       // الكلام على الزر
                    .font(.system(size: 17, weight: .medium)) // حجم الخط 17 وسماكته متوسطة
                    .foregroundStyle(.white)     // لون الكلام أبيض
                    .frame(width: 280, height: 42) // عرض وطول الزر: كبّري الأرقام يكبر الزر
                    .background(Color("PrimaryGreen"), in: Capsule()) // خلفية خضراء بشكل كبسولة
            }                                    // نهاية الزر
            .padding(.top, 100)                  // مسافة بين النص والزر: كل ما كبر الرقم، نزل الزر

            Spacer()                             // فراغ مرن يدفع كل شي لفوق
        }                                        // نهاية VStack
    }                                            // نهاية startContent

    // شاشة لا توجد تذكيرات
    var noRemindersContent: some View {          // المحتوى لما المستخدم حذف كل نباتاته
        VStack {                                 // نرتب العناصر فوق بعض
            Spacer()                             // فراغ مرن فوق النص
            Text("No reminders set yet..")       // الجملة في نص الشاشة
                .font(.system(size: 20, weight: .semibold)) // حجم الخط 20 وسماكته شبه عريضة
                .foregroundStyle(.secondary)     // لون رمادي
            Spacer()                             // فراغ مرن تحت النص، فيصير النص بالنص
        }                                        // نهاية VStack
    }                                            // نهاية noRemindersContent

    // شاشة كل شي انسقى
    var allDoneContent: some View {              // المحتوى لما كل النباتات انسقت
        VStack(spacing: 0) {                     // نرتب العناصر فوق بعض
            // صورة النبتة
            ZStack {                             // نحط الدائرة ورا النبتة
                Ellipse()                        // الدائرة الغامقة ورا النبتة
                    .fill(Color("ChipBackground")) // لونها من Assets
                    .opacity(0.6)                // شفافية الدائرة: كل ما صغر الرقم، صارت أغمق وأخفى
                    .frame(width: 219, height: 227) // حجم الدائرة: كبّري الأرقام تكبر الدائرة
                Image("PlantWink")               // صورة النبتة اللي تغمز من Assets
                    .resizable()                 // نسمح بتغيير حجمها
                    .scaledToFit()               // نحافظ على نسبتها
                    .frame(height: 200)          // طول النبتة: كل ما كبر الرقم، كبرت النبتة
            }                                    // نهاية ZStack
            .padding(.top, 127)                  // مسافة بين الخط والصورة: كل ما كبر الرقم، نزلت الصورة

            // العنوان
            Text("All Done! 🎉")                 // جملة العنوان
                .font(.system(size: 25, weight: .semibold)) // حجم الخط 25 وسماكته شبه عريضة
                .foregroundStyle(.primary)       // اللون الأساسي
                .padding(.top, 33)               // مسافة بين الصورة والعنوان: كل ما كبر الرقم، نزل العنوان

            // النص الوصفي
            Text("All Reminders Completed")      // الجملة الرمادية
                .font(.system(size: 16))         // حجم الخط 16
                .foregroundStyle(.secondary)     // لون رمادي
                .padding(.top, 14)               // مسافة بين العنوان والنص: كل ما كبر الرقم، نزل النص

            Spacer()                             // فراغ مرن يدفع كل شي لفوق
        }                                        // نهاية VStack
    }                                            // نهاية allDoneContent

    // قائمة النباتات
    var plantsListContent: some View {           // المحتوى لما فيه نباتات ما انسقت
        VStack(spacing: 0) {                     // نرتب العناصر فوق بعض
            // جملة التقدم
            Text(viewModel.progressText)         // الجملة جاهزة من الـ ViewModel
                .font(.system(size: 18))         // حجم الخط 18
                .foregroundStyle(.primary)       // اللون الأساسي
                .padding(.top, 36)               // مسافة بين الخط والجملة: كل ما كبر الرقم، نزلت الجملة

            // شريط التقدم
            GeometryReader { geo in              // يعطينا عرض الشريط عشان نحسب الجزء الأخضر
                ZStack(alignment: .leading) {    // الجزء الأخضر فوق الرمادي ويبدأ من اليسار
                    Capsule()                    // الشريط الرمادي الكامل
                        .fill(Color("ProgressTrack")) // لونه من Assets
                    Capsule()                    // الجزء الأخضر
                        .fill(Color("PrimaryGreen")) // لونه من Assets
                        .frame(width: geo.size.width * viewModel.progress) // عرضه = نسبة النباتات اللي انسقت
                }                                // نهاية ZStack
            }                                    // نهاية GeometryReader
            .frame(height: 8)                    // سماكة الشريط: كل ما كبر الرقم، صار أسمك
            .padding(.horizontal, 34)            // مسافة من الجانبين: كل ما كبر الرقم، قصر الشريط
            .padding(.top, 15)                   // مسافة بين الجملة والشريط: كل ما كبر الرقم، نزل الشريط

            // القائمة
            List {                               // قائمة تقدر تسحب صفوفها
                ForEach(viewModel.plants) { plant in // صف لكل نبتة
                    HStack(spacing: 24) {        // الدائرة جنب معلومات النبتة، والمسافة بينهم 24
                        // دائرة السقي
                        Button {                 // زر الدائرة
                            viewModel.toggleWatered(plant) // نغيّر حالة السقي
                        } label: {               // شكل الدائرة
                            Image(systemName: plant.isWatered ? "checkmark.circle.fill" : "circle") // صح أخضر إذا انسقت، ودائرة فاضية إذا لا
                                .font(.system(size: 25)) // حجم الدائرة: كل ما كبر الرقم، كبرت
                                .foregroundStyle(plant.isWatered ? Color("CheckGreen") : .secondary) // أخضر إذا انسقت، ورمادي إذا لا
                        }                        // نهاية الزر
                        .buttonStyle(.plain)     // عشان الضغط يكون على الدائرة بس، مو الصف كامل

                        // معلومات النبتة
                        VStack(alignment: .leading, spacing: 4) { // نرتبها فوق بعض من اليسار، والمسافة 4
                            HStack(spacing: 4) { // أيقونة الموقع جنب اسم الغرفة
                                Image(systemName: "location") // أيقونة السهم
                                Text("in \(plant.room)") // اسم الغرفة
                            }                    // نهاية HStack
                            .font(.system(size: 15)) // حجم الخط 15
                            .foregroundStyle(.secondary) // لون رمادي

                            Text(plant.name)     // اسم النبتة
                                .font(.system(size: 28)) // حجم الخط 28
                                .foregroundStyle(plant.isWatered ? .secondary : .primary) // رمادي إذا انسقت، وأبيض إذا لا

                            HStack(spacing: 12) { // الشارتين جنب بعض، والمسافة بينهم 12
                                // شارة الإضاءة
                                HStack(spacing: 4) { // الأيقونة جنب الكلام
                                    Image(systemName: viewModel.lightIcon(for: plant)) // أيقونة تتغير حسب الإضاءة
                                    Text(plant.light) // نوع الإضاءة
                                }                // نهاية HStack
                                .font(.system(size: 14)) // حجم الخط 14
                                .foregroundStyle(Color("SunYellow")) // لون أصفر من Assets
                                .padding(.horizontal, 8) // مسافة داخلية يمين ويسار: كل ما كبر الرقم، عرضت الشارة
                                .padding(.vertical, 3) // مسافة داخلية فوق وتحت: كل ما كبر الرقم، طالت الشارة
                                .background(Color("ChipBackground"), in: RoundedRectangle(cornerRadius: 8)) // خلفية بزوايا دائرية: كل ما كبر الرقم، صارت الزوايا أدور

                                // شارة الماء
                                HStack(spacing: 4) { // الأيقونة جنب الكلام
                                    Image(systemName: "drop") // أيقونة قطرة الماء
                                    Text(plant.water) // كمية الماء
                                }                // نهاية HStack
                                .font(.system(size: 14, weight: .medium)) // حجم الخط 14 وسماكته متوسطة
                                .foregroundStyle(Color("WaterBlue")) // لون أزرق فاتح من Assets
                                .padding(.horizontal, 8) // مسافة داخلية يمين ويسار
                                .padding(.vertical, 3) // مسافة داخلية فوق وتحت
                                .background(Color("ChipBackground"), in: RoundedRectangle(cornerRadius: 8)) // خلفية بزوايا دائرية
                            }                    // نهاية HStack الشارات
                            .padding(.top, 8)    // مسافة بين الاسم والشارات: كل ما كبر الرقم، نزلت الشارات
                        }                        // نهاية VStack المعلومات
                        .frame(maxWidth: .infinity, alignment: .leading) // المعلومات تاخذ باقي عرض الصف عشان يصير كله قابل للضغط
                        .contentShape(Rectangle()) // نخلي حتى الفراغ في الصف ينضغط
                        .onTapGesture {          // لما يضغط على معلومات النبتة
                            viewModel.selectedPlant = plant // نفتح شاشة التعديل لهذي النبتة
                        }                        // نهاية onTapGesture
                    }                            // نهاية HStack الصف
                    .listRowSeparator(plant.id == viewModel.plants.first?.id ? .hidden : .visible, edges: .top) // نخفي الخط اللي فوق أول صف بس، والباقي تظهر خطوطه
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 } // الخط اللي تحت الصف يبدأ من أول الصف مو من بداية الكلام
                    .swipeActions {              // لما تسحب الصف لليسار
                        Button(role: .destructive) { // زر أحمر للحذف
                            viewModel.delete(plant) // نحذف النبتة
                        } label: {               // شكل الزر
                            Image(systemName: "trash") // أيقونة سلة المهملات
                        }                        // نهاية زر الحذف
                    }                            // نهاية swipeActions
                }                                // نهاية ForEach
            }                                    // نهاية List
            .listStyle(.plain)                   // شكل بسيط بدون خلفية رمادية حول القائمة
            .padding(.top, 24)                   // مسافة بين الشريط والقائمة: كل ما كبر الرقم، نزلت القائمة
        }                                        // نهاية VStack
    }                                            // نهاية plantsListContent

    // زر الإضافة
    var plusButton: some View {                  // الزر الأخضر الدائري تحت يمين
        Button {                                 // زر إضافة نبتة
            viewModel.showAddSheet = true        // نفتح شاشة Set Reminder
        } label: {                               // شكل الزر
            Image(systemName: "plus")            // علامة +
                .font(.system(size: 25, weight: .medium)) // حجم العلامة: كل ما كبر الرقم، كبرت
                .foregroundStyle(.white)         // لونها أبيض
                .frame(width: 44, height: 44)    // حجم الدائرة: كبّري الرقمين مع بعض تكبر
                .background(Color("PrimaryGreen"), in: Circle()) // خلفية خضراء دائرية
        }                                        // نهاية الزر
        .padding(.trailing, 30)                  // مسافة من يمين الشاشة: كل ما كبر الرقم، راح الزر لليسار
        .padding(.bottom, 8)                     // مسافة من تحت: كل ما كبر الرقم، طلع الزر لفوق
    }                                            // نهاية plusButton
}                                                // نهاية MyPlantsView

#Preview {                                       // يعرض الشاشة في الـ Canvas
    MyPlantsView()                               // الشاشة اللي نبي نشوفها
        .modelContainer(for: Plant.self, inMemory: true) // حفظ مؤقت للمعاينة بس
}
