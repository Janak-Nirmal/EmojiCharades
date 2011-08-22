//
//  ECKeyboardView.m
//  EmojiCharades
//
//  Created by Steve Farrell on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECKeyboardView.h"
#import "Constants.h"

@interface ECKeyboardView (PrivateMethods)
- (void)layoutKeyboardCategoryEntry:(CategoryEntry *)entry;
@end

@implementation CategoryEntry
@synthesize chars = _chars, view = _view, buttonItem = _buttonItem, numPages = _numPages, curPage = _curPage;
@end

@implementation ECKeyboardView

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize toolbar = _toolbar;
@synthesize entries = _entries;
@synthesize backButton = _backButton;
@synthesize spaceButton = _spaceButton;

- (void)layoutKeyboard
{    
    [self layoutSubviews];
    NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:_spaceButton, nil];
    for (CategoryEntry *entry in self.entries) {
        UIView *categoryView = [[UIView alloc] init];
        entry.view = categoryView;
        NSString *title = [entry.chars substringToIndex:1];
        entry.buttonItem = [[UIBarButtonItem alloc] init];
        entry.buttonItem.title = title;
        entry.buttonItem.style = UIBarButtonItemStylePlain;
        [items addObject:entry.buttonItem];
        [self layoutKeyboardCategoryEntry:entry];
        [categoryView release];
    }
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject: spacer];
    [items addObject:_backButton];
    self.toolbar.items = items;
    [items release];
    [spacer release];
}

- (void)layoutKeyboardCategoryEntry:(CategoryEntry *)entry
{
    CGRect frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    CGSize gridSize = CGSizeMake(7, 3);
    CGSize buttonSize = CGSizeMake(frame.size.width / gridSize.width, frame.size.height / gridSize.height);
    CGRect categoryFrame = frame;
    entry.numPages = ceil(entry.chars.length / (gridSize.width * gridSize.height));
    categoryFrame.size.width *= entry.numPages;
    entry.view.frame = categoryFrame;
    for (int page = 0; page < entry.numPages; page++) {
        for (int y = 0; y < gridSize.height; y++) {
            for (int x = 0; x < gridSize.width; x++) {
                int idx = (gridSize.width * gridSize.height * page) + (gridSize.width * y) + x;
                if (idx >= entry.chars.length) break;
                NSString *emoji = [entry.chars substringWithRange:NSMakeRange(idx, 1)];
                CGRect buttonFrame = CGRectMake((page * frame.size.width) + (x * buttonSize.width), y * buttonSize.height, buttonSize.width, buttonSize.height);
                UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
                [button setTitle:emoji forState:UIControlStateNormal];
                // Would be preferable to change font size, but that's not available with ios4.
                button.transform = CGAffineTransformMakeScale(1.5, 1.5);
                [entry.view addSubview:button];
                [button release];
            }
        }
    }
}

- (void)layoutSubviews
{
    int pagerHeight = 10;
    int toolbarHeight = 40;
    _pageControl.frame = CGRectMake(0, 0, self.frame.size.width, pagerHeight);
    _scrollView.frame = CGRectMake(0, pagerHeight, self.frame.size.width, self.frame.size.height - pagerHeight - toolbarHeight);
    _toolbar.frame = CGRectMake(0, pagerHeight + _scrollView.frame.size.height, self.frame.size.width, toolbarHeight);

    [super layoutSubviews];
}

- (void)dealloc
{
    [_scrollView release];
    [_pageControl release];
    [_toolbar release];
    [_backButton release];
    [_spaceButton release];
    [_entries release];
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        NSMutableArray *entries = [[NSMutableArray alloc] init];
        NSString *c0 = [NSString stringWithCharacters:_category0 length:sizeof(_category0) / sizeof(unichar)];
        NSString *c1 = [NSString stringWithCharacters:_category1 length:sizeof(_category1) / sizeof(unichar)];
        NSString *c2 = [NSString stringWithCharacters:_category2 length:sizeof(_category2) / sizeof(unichar)];
        NSString *c3 = [NSString stringWithCharacters:_category3 length:sizeof(_category3) / sizeof(unichar)];
        NSString *c4 = [NSString stringWithCharacters:_category4 length:sizeof(_category4) / sizeof(unichar)];
        for (NSString *chars in [NSArray arrayWithObjects:c0, c1, c2, c3, c4, nil]) { 
            CategoryEntry *entry = [[CategoryEntry alloc] init];
            entry.chars = chars;
            [entries addObject:entry];
        }
        self.entries = [NSArray arrayWithArray: entries];
        [entries release];
    }
    return self;
}

@end

// Emoji keyboard chars for iphone.  See http://pukupi.com/post/1964/

unichar const _category0[] = {
    0xe415, 0xe056, 0xe057, 0xe414, 0xe405, 0xe106, 0xe418,
    0xe417, 0xe40d, 0xe40a, 0xe404, 0xe105, 0xe409, 0xe40e,
    0xe402, 0xe108, 0xe403, 0xe058, 0xe407, 0xe401, 0xe40f,
    0xe40b, 0xe406, 0xe413, 0xe411, 0xe412, 0xe410, 0xe107,
    0xe059, 0xe416, 0xe408, 0xe40c, 0xe11a, 0xe10c, 0xe32c,
    0xe32a, 0xe32d, 0xe328, 0xe32b, 0xe022, 0xe023, 0xe327,
    0xe329, 0xe32e, 0xe32f, 0xe335, 0xe334, 0xe021, 0xe337,
    0xe020, 0xe336, 0xe13c, 0xe330, 0xe331, 0xe326, 0xe03e,
    0xe11d, 0xe05a, 0xe00e, 0xe421, 0xe420, 0xe00d, 0xe010,
    0xe011, 0xe41e, 0xe012, 0xe422, 0xe22e, 0xe22f, 0xe231,
    0xe230, 0xe427, 0xe41d, 0xe00f, 0xe41f, 0xe14c, 0xe201,
    0xe115, 0xe428, 0xe51f, 0xe429, 0xe424, 0xe423, 0xe253,
    0xe426, 0xe111, 0xe425, 0xe31e, 0xe31f, 0xe31d, 0xe001,
    0xe002, 0xe005, 0xe004, 0xe51a, 0xe519, 0xe518, 0xe515,
    0xe516, 0xe517, 0xe51b, 0xe152, 0xe04e, 0xe51c, 0xe51e,
    0xe11c, 0xe536, 0xe003, 0xe41c, 0xe41b, 0xe419, 0xe41a, 
};

unichar const _category1[] = {
    0xe04a, 0xe04b, 0xe049, 0xe048, 0xe04c, 0xe13d, 0xe443,
    0xe43e, 0xe04f, 0xe052, 0xe053, 0xe524, 0xe52c, 0xe52a,
    0xe531, 0xe050, 0xe527, 0xe051, 0xe10b, 0xe52b, 0xe52f,
    0xe528, 0xe01a, 0xe134, 0xe530, 0xe529, 0xe526, 0xe52d,
    0xe521, 0xe523, 0xe52e, 0xe055, 0xe525, 0xe10a, 0xe109,
    0xe522, 0xe019, 0xe054, 0xe520, 0xe306, 0xe030, 0xe304,
    0xe110, 0xe032, 0xe305, 0xe303, 0xe118, 0xe447, 0xe119,
    0xe307, 0xe308, 0xe444, 0xe441,
};

unichar const _category2[] = {
    0xe436, 0xe437, 0xe438, 0xe43a, 0xe439, 0xe43b, 0xe117,
    0xe440, 0xe442, 0xe446, 0xe445, 0xe11b, 0xe448, 0xe033,
    0xe112, 0xe325, 0xe312, 0xe310, 0xe126, 0xe127, 0xe008,
    0xe03d, 0xe00c, 0xe12a, 0xe00a, 0xe00b, 0xe009, 0xe316,
    0xe129, 0xe141, 0xe142, 0xe317, 0xe128, 0xe14b, 0xe211,
    0xe114, 0xe145, 0xe144, 0xe03f, 0xe313, 0xe116, 0xe10f,
    0xe104, 0xe103, 0xe101, 0xe102, 0xe13f, 0xe140, 0xe11f,
    0xe12f, 0xe031, 0xe30e, 0xe311, 0xe113, 0xe30f, 0xe13b,
    0xe42b, 0xe42a, 0xe018, 0xe016, 0xe015, 0xe014, 0xe42c,
    0xe42d, 0xe017, 0xe013, 0xe20e, 0xe20c, 0xe20f, 0xe20d,
    0xe131, 0xe12b, 0xe130, 0xe12d, 0xe324, 0xe301, 0xe148,
    0xe502, 0xe03c, 0xe30a, 0xe042, 0xe040, 0xe041, 0xe12c,
    0xe007, 0xe31a, 0xe13e, 0xe31b, 0xe006, 0xe302, 0xe319,
    0xe321, 0xe322, 0xe314, 0xe503, 0xe10e, 0xe318, 0xe43c,
    0xe11e, 0xe323, 0xe31c, 0xe034, 0xe035, 0xe045, 0xe338,
    0xe047, 0xe30c, 0xe044, 0xe30b, 0xe043, 0xe120, 0xe33b,
    0xe33f, 0xe341, 0xe34c, 0xe344, 0xe342, 0xe33d, 0xe33e,
    0xe340, 0xe34d, 0xe339, 0xe147, 0xe343, 0xe33c, 0xe33a,
    0xe43f, 0xe34b, 0xe046, 0xe345, 0xe346, 0xe348, 0xe347,
    0xe34a, 0xe349,
};

unichar const _category3[] = {
    0xe036, 0xe157, 0xe038, 0xe153, 0xe155, 0xe14d, 0xe156,
    0xe501, 0xe158, 0xe43d, 0xe037, 0xe504, 0xe44a, 0xe146,
    0xe50a, 0xe505, 0xe506, 0xe122, 0xe508, 0xe509, 0xe03b,
    0xe04d, 0xe449, 0xe44b, 0xe51d, 0xe44c, 0xe124, 0xe121,
    0xe433, 0xe202, 0xe135, 0xe01c, 0xe01d, 0xe10d, 0xe136,
    0xe42e, 0xe01b, 0xe15a, 0xe159, 0xe432, 0xe430, 0xe431,
    0xe42f, 0xe01e, 0xe039, 0xe435, 0xe01f, 0xe125, 0xe03a,
    0xe14e, 0xe252, 0xe137, 0xe209, 0xe154, 0xe133, 0xe150,
    0xe320, 0xe123, 0xe132, 0xe143, 0xe50b, 0xe514, 0xe513,
    0xe50c, 0xe50d, 0xe511, 0xe50f, 0xe512, 0xe510, 0xe50e,
};

unichar const _category4[] = {
    0xe21c, 0xe21d, 0xe21e, 0xe21f, 0xe220, 0xe221, 0xe222,
    0xe223, 0xe224, 0xe225, 0xe210, 0xe232, 0xe233, 0xe235,
    0xe234, 0xe236, 0xe237, 0xe238, 0xe239, 0xe23b, 0xe23a,
    0xe23d, 0xe23c, 0xe24d, 0xe212, 0xe24c, 0xe213, 0xe214,
    0xe507, 0xe203, 0xe20b, 0xe22a, 0xe22b, 0xe226, 0xe227,
    0xe22c, 0xe22d, 0xe215, 0xe216, 0xe217, 0xe218, 0xe228,
    0xe151, 0xe138, 0xe139, 0xe13a, 0xe208, 0xe14f, 0xe20a,
    0xe434, 0xe309, 0xe315, 0xe30d, 0xe207, 0xe229, 0xe206,
    0xe205, 0xe204, 0xe12e, 0xe250, 0xe251, 0xe14a, 0xe149,
    0xe23f, 0xe240, 0xe241, 0xe242, 0xe243, 0xe244, 0xe245,
    0xe246, 0xe247, 0xe248, 0xe249, 0xe24a, 0xe24b, 0xe23e,
    0xe532, 0xe533, 0xe534, 0xe535, 0xe21a, 0xe219, 0xe21b,
    0xe02f, 0xe024, 0xe025, 0xe026, 0xe027, 0xe028, 0xe029,
    0xe02a, 0xe02b, 0xe02c, 0xe02d, 0xe02e, 0xe332, 0xe333,
    0xe24e, 0xe24f, 0xe537,
};

