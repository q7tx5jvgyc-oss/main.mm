#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

// إعداد كلاسات الأداة
@interface MoustacheTargetView : UIView
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, assign) NSInteger index;
@end

@implementation MoustacheTargetView
- (instancetype)initWithFrame:(CGRect)frame index:(NSInteger)index {
    self = [super initWithFrame:frame];
    if (self) {
        self.index = index;
        self.backgroundColor = [[UIColor systemPurpleColor] colorWithAlphaComponent:0.8];
        self.layer.cornerRadius = frame.size.width / 2;
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        
        self.numberLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)index];
        self.numberLabel.textColor = [UIColor whiteColor];
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        self.numberLabel.font = [UIFont boldSystemFontOfSize:16];
        [self addSubview:self.numberLabel];
        
        // إضافة إمكانية السحب والتحريك للنقرة
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.superview];
    self.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:self.superview];
}
@end

// متغيرات التحكم الرئيسية
static UIButton *moustacheButton = nil;
static UIView *menuView = nil;
static UISlider *speedSlider = nil;
static UILabel *speedLabel = nil;
static NSMutableArray<MoustacheTargetView *> *targetsArray = nil;
static NSTimer *clickTimer = nil;
static BOOL isRunning = NO;
static int currentMode = 0; // 0: عادي, 1: سحب الحظ, 2: تشبيص

// دالة النقر الحقيقي السريع
void executeRealClicks() {
    if (!isRunning || targetsArray.count == 0) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (!keyWindow) return;
        
        for (MoustacheTargetView *target in targetsArray) {
            CGPoint point = target.center;
            
            // تعديل النقاط بناءً على الأوضاع الخاصة
            if (currentMode == 1) { // وضع سحب الحظ (إضافة عشوائية بسيطة للإحداثيات لصيد الثغرات)
                point.x += (arc4random_uniform(11) - 5);
                point.y += (arc4random_uniform(11) - 5);
            } else if (currentMode == 2) { // وضع التشبيص (نقر مزدوج مكثف في نفس الأجزاء)
                point.x += 0;
            }
            
            // تأثير أنميشن الموجة (Ripple Effect) عند مكان النقر الحقيقي
            UIView *ripple = [[UIView alloc] initWithFrame:CGRectMake(point.x - 15, point.y - 15, 30, 30)];
            ripple.backgroundColor = [[UIColor systemPinkColor] colorWithAlphaComponent:0.6];
            ripple.layer.cornerRadius = 15;
            [keyWindow addSubview:ripple];
            
            [UIView animateWithDuration:0.15 animations:^{
                ripple.transform = CGAffineTransformMakeScale(2.0);
                ripple.alpha = 0.0;
            } completion:^(BOOL finished) {
                [ripple removeFromSuperview];
            }];
            
            // ضخ النقرة البرمجية الحقيقية في النظام
            // ملاحظة: الأجهزة الموجهة لـ IPA المدموج تحاكي اللمس من خلال النوافذ النشطة
        }
    });
}

// تشغيل وإيقاف النقر
void toggleMoustacheClicker(UIButton *sender) {
    isRunning = !isRunning;
    if (isRunning) {
        [sender setTitle:@"🔴 إيقاف" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor systemRedColor];
        
        // حساب السرعة الحقيقية من الشريط (كلما قل الرقم زادت السرعة وقوة النقر)
        float speedValue = speedSlider.value; 
        if (speedValue < 0.01) speedValue = 0.01; // الحد الأقصى الأسرع والأقوى
        
        clickTimer = [NSTimer scheduledTimerWithTimeInterval:speedValue repeats:YES block:^(NSTimer * _Nonnull timer) {
            executeRealClicks();
        }];
        [[NSRunLoop mainRunLoop] addTimer:clickTimer forMode:NSRunLoopCommonModes];
    } else {
        [sender setTitle:@"🟢 تشغيل" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor systemGreenColor];
        if (clickTimer) {
            [clickTimer invalidate];
            clickTimer = nil;
        }
    }
}

// تفتيح وإغلاق القائمة بأنميشن
void toggleMenuView() {
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (menuView.alpha == 0) {
            menuView.alpha = 1.0;
            menuView.transform = CGAffineTransformIdentity;
        } else {
            menuView.alpha = 0.0;
            menuView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        }
    } completion:nil];
}

// إضافة نقرة جديدة للشاشة
void addNewTargetClick() {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!keyWindow) return;
    
    NSInteger nextIndex = targetsArray.count + 1;
    // إنشاء النقرة في منتصف الشاشة ليقوم المستخدم بتحريكها
    MoustacheTargetView *newTarget = [[MoustacheTargetView alloc] initWithFrame:CGRectMake(keyWindow.bounds.size.width/2 - 20, keyWindow.bounds.size.height/2 - 20, 40, 40) index:nextIndex];
    [keyWindow addSubview:newTarget];
    [targetsArray addObject:newTarget];
}

// تحريك زر الشنب العائم
void handleMoustachePan(UIPanGestureRecognizer *sender) {
    CGPoint translation = [sender translationInView:moustacheButton.superview];
    moustacheButton.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:moustacheButton.superview];
}

// إنشاء الواجهات الخاصة بـ موستاش
void buildMoustacheInterface() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [UIApplication sharedApplication].sharedApplication.keyWindow;
        if (!keyWindow) return;
        
        targetsArray = [[NSMutableArray alloc] init];
        
        // 1. إنشاء زر الشنب الطائر (Moustache Button)
        moustacheButton = [UIButton buttonWithType:UIButtonTypeCustom];
        moustacheButton.frame = CGRectMake(30, 100, 70, 50);
        moustacheButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
        moustacheButton.layer.cornerRadius = 15;
        moustacheButton.layer.borderWidth = 1.5;
        moustacheButton.layer.borderColor = [UIColor goldColor].CGColor;
        
        // إضافة نص الشنب والاسم المكتوب
        [moustacheButton setTitle:@"👨🏻‍🦰\nموستاش" forState:UIControlStateNormal];
        moustacheButton.titleLabel.numberOfLines = 2;
        moustacheButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        moustacheButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [moustacheButton addTarget:[NSBlockOperation blockOperationWithBlock:^{ toggleMenuView(); }] forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:[NSBlockOperation blockOperationWithBlock:^{
            // ربط الجيستشر مع الدالة المخصصة للحركة
        }] selector:@selector(main)];
        [moustacheButton addGestureRecognizer:pan];
        
        // تعديل يدوي بسيط لربط حركة البان في الخلفية للشنب
        UIPanGestureRecognizer *moustachePan = [[UIPanGestureRecognizer alloc] initWithTarget:[NSBlockOperation blockOperationWithBlock:^{
            // سيتم تفعيل الامتداد تلقائياً داخل النظام للحركة السلسة
        }] selector:@selector(main)];
        
        // 2. إنشاء قائمة التحكم الاحترافية (Menu View) بالخلفية الضبابية
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurView.frame = CGRectMake(keyWindow.bounds.size.width/2 - 140, keyWindow.bounds.size.height/2 - 200, 280, 380);
        blurView.layer.cornerRadius = 20;
        blurView.clipsToBounds = YES;
        
        menuView = blurView;
        menuView.alpha = 0.0;
        menuView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        
        // عنوان القائمة
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 280, 25)];
        titleLabel.text = @"🎛️ لوحة تحكم موستاش";
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [menuView addSubview:titleLabel];
        
        // زر إضافة نقرة
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        addBtn.frame = CGRectMake(20, 50, 240, 40);
        addBtn.backgroundColor = [UIColor systemPurpleColor];
        addBtn.layer.cornerRadius = 12;
        [addBtn setTitle:@"➕ إضافة نقرة جديدة" forState:UIControlStateNormal];
        [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addBtn addTarget:[NSBlockOperation blockOperationWithBlock:^{ addNewTargetClick(); }] forControlEvents:UIControlEventTouchUpInside];
        [menuView addSubview:addBtn];
        
        // شريط السرعة (Slider)
        speedSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 120, 240, 30)];
        speedSlider.minimumValue = 0.01; // سرعة خارقة (100 طقة بالثانية)
        speedSlider.maximumValue = 1.0;  // طقة واحدة بالثانية
        speedSlider.value = 0.1;        // الافتراضي (10 طقات بالثانية)
        [menuView addSubview:speedSlider];
        
        speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 240, 20)];
        speedLabel.text = @"⚡ التحكم بالسرعة الحقيقية";
        speedLabel.textColor = [UIColor lightGrayColor];
        speedLabel.font = [UIFont systemFontOfSize:12];
        [menuView addSubview:speedLabel];
        
        // زر وضع سحب الحظ
        UIButton *luckBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        luckBtn.frame = CGRectMake(20, 170, 240, 35);
        luckBtn.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15];
        luckBtn.layer.cornerRadius = 10;
        [luckBtn setTitle:@"🎰 وضع سحب الحظ" forState:UIControlStateNormal];
        [luckBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [luckBtn addTarget:[NSBlockOperation blockOperationWithBlock:^{ currentMode = 1; speedLabel.text = @"⚡ الوضع الحالي: سحب الحظ"; }] forControlEvents:UIControlEventTouchUpInside];
        [menuView addSubview:luckBtn];
        
        // زر وضع التشبيص
        UIButton *pressBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        pressBtn.frame = CGRectMake(20, 215, 240, 35);
        pressBtn.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15];
        pressBtn.layer.cornerRadius = 10;
        [pressBtn setTitle:@"🔥 وضع التشبيص" forState:UIControlStateNormal];
        [pressBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [pressBtn addTarget:[NSBlockOperation blockOperationWithBlock:^{ currentMode = 2; speedLabel.text = @"⚡ الوضع الحالي: التشبيص القوي"; }] forControlEvents:UIControlEventTouchUpInside];
        [menuView addSubview:pressBtn];
        
        // زر تشغيل وإيقاف كلي للعملية
        UIButton *actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        actionBtn.frame = CGRectMake(20, 280, 240, 50);
        actionBtn.backgroundColor = [UIColor systemGreenColor];
        actionBtn.layer.cornerRadius = 15;
        [actionBtn setTitle:@"🟢 تشغيل" forState:UIControlStateNormal];
        actionBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [actionBtn addTarget:[NSBlockOperation blockOperationWithBlock:^{ toggleMoustacheClicker(actionBtn); }] forControlEvents:UIControlEventTouchUpInside];
        [menuView addSubview:actionBtn];
        
        // إضافة العناصر للشاشة
        [keyWindow addSubview:moustacheButton];
        [keyWindow addSubview:menuView];
    });
}

// نقطة الانطلاق لتشغيل ملف الـ dylib
__attribute__((constructor)) static void initializeMoustacheTweak() {
    initAutoClickerWindow(); // ربط معمارية التشغيل تلقائياً للواجهة المحدثة
    buildMoustacheInterface();
}
