#import <UIKit/UIKit.h>

// كود مبسط لزر "موستاش" لضمان نجاح البناء
__attribute__((constructor)) static void setupMoustache() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 100, 80, 50);
        btn.backgroundColor = [UIColor blackColor];
        [btn setTitle:@"👨🏻‍🦰 موستاش" forState:UIControlStateNormal];
        btn.layer.cornerRadius = 10;
        [window addSubview:btn];
    });
}
