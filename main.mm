#import <UIKit/UIKit.h>

// كلاس النقرة القابلة للسحب
@interface MoustacheClickView : UIView
@property (nonatomic, strong) UILabel *label;
@end

@implementation MoustacheClickView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor systemPurpleColor];
    self.layer.cornerRadius = 20;
    self.layer.borderWidth = 2;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.label = [[UILabel alloc] initWithFrame:self.bounds];
    self.label.text = @"●";
    self.label.textColor = [UIColor whiteColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.label];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    return self;
}
- (void)pan:(UIPanGestureRecognizer *)p {
    CGPoint translation = [p translationInView:self.superview];
    self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    [p setTranslation:CGPointZero inView:self.superview];
}
@end

static UIButton *moustacheBtn = nil;
static UISlider *slider = nil;
static BOOL isClicking = NO;

// الوظيفة الرئيسية للنقر
void startClicking() {
    if (!isClicking) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *w = [UIApplication sharedApplication].keyWindow;
        for (UIView *v in w.subviews) {
            if ([v isKindOfClass:[MoustacheClickView class]]) {
                // محاكاة النقر هنا
                UIView *f = [[UIView alloc] initWithFrame:CGRectMake(v.center.x-10, v.center.y-10, 20, 20)];
                f.backgroundColor = [UIColor redColor];
                f.layer.cornerRadius = 10;
                [w addSubview:f];
                [UIView animateWithDuration:0.1 animations:^{ f.alpha = 0; } completion:^(BOOL b){ [f removeFromSuperview]; }];
            }
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(slider.value * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        startClicking();
    });
}

// بناء الواجهة
__attribute__((constructor)) static void setup() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *w = [UIApplication sharedApplication].keyWindow;
        
        moustacheBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        moustacheBtn.frame = CGRectMake(20, 100, 70, 60);
        [moustacheBtn setTitle:@"👨🏻‍🦰\nموستاش" forState:UIControlStateNormal];
        moustacheBtn.titleLabel.numberOfLines = 2;
        moustacheBtn.backgroundColor = [UIColor blackColor];
        moustacheBtn.layer.cornerRadius = 15;
        [w addSubview:moustacheBtn];
        
        slider = [[UISlider alloc] initWithFrame:CGRectMake(100, 100, 200, 30)];
        slider.minimumValue = 0.05; slider.maximumValue = 1.0;
        [w addSubview:slider];
        
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        addBtn.frame = CGRectMake(100, 140, 100, 30);
        [addBtn setTitle:@"إضافة نقرة" forState:UIControlStateNormal];
        [addBtn addTarget:nil action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
        [w addSubview:addBtn];
        
        [moustacheBtn addTarget:nil action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
    });
}

// دالة الإضافة
void addAction() {
    [[UIApplication sharedApplication].keyWindow addSubview:[[MoustacheClickView alloc] initWithFrame:CGRectMake(150, 200, 40, 40)]];
}

// دالة التشغيل
void toggle() {
    isClicking = !isClicking;
    if(isClicking) startClicking();
}
