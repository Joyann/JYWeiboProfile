//
//  JYProfileViewController.m
//  
//
//  Created by joyann on 15/10/17.
//  Copyright © 2015年 Joyann. All rights reserved.
//

#import "JYProfileViewController.h"
#import "Masonry.h"
#import "UIImage+ColorImage.h"

#define JYTabViewLabelFont [UIFont systemFontOfSize:15.0]

static const NSInteger JYTabViewSeparatorHeight        = 1;
static const NSInteger JYTableViewCellNumberOfRows     = 20;
static const NSInteger JYTabViewHeight                 = 44;
static const NSInteger JYTabLabelSpacing               = 80;
static const NSInteger JYIconImageOffset               = 80;
static const NSInteger JYIconImageWidthOrHeight        = 100;
static const NSInteger JYIconBackgroundImageViewHeight = 200;
static const NSInteger JYHeadViewMinHeight             = JYTabViewHeight + 20;

static NSString *const JYTableViewCellIdentifier       = @"JYTableViewCellIdentifier";


@interface JYProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UIImageView *backgroundImageView;
@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIView *headView;
@property (nonatomic, assign) CGFloat originOffset;

@end

@implementation JYProfileViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self p_setUpNavigationBar];
    [self p_setStatusBar];
    [self p_addSubviewsAndConstraints];
}

#pragma mark - Private methods

- (void)p_setStatusBar
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)p_setUpNavigationBar
{
    // 默认使用navigation的时候tableView会被挤到navigationBar下面，即使设置的约束是贴着最上面，这需要我们关闭navigation的自动调整
    // 此时tableView在最上方
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 隐藏navigationBar -> 只能通过这种方式设置
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    
    // 隐藏navigationBar下面的黑线 -> 黑线是阴影
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    // 设置标题
    // 如果直接设置navigationItem.title，这样虽然可以成功设置标题，但是是无法设置标题的alpha的，所以这里设置titleView.
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Joyann的微博";
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    // 在开始的时候设置titleLabel的alpha为0，用来隐藏标题
    self.navigationItem.titleView.alpha = 0.0;
}

- (void)p_addSubviewsAndConstraints
{
    // 列表
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    // 关闭了navigation的自动调整，此时tableView在最上方，现在需要让它在tabView的下面，设置contentInset将它"挤下来"
    tableView.contentInset = UIEdgeInsetsMake(JYIconBackgroundImageViewHeight + JYTabViewHeight, 0, 0, 0);
    self.originOffset = -(JYIconBackgroundImageViewHeight + JYTabViewHeight);
    tableView.contentOffset = CGPointMake(0, self.originOffset);
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 60.0;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    // 添加约束
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    // 顶部的view
    UIView *headView = [[UIView alloc] init];
    self.headView = headView;
    headView.clipsToBounds = YES;
    [self.view addSubview:headView];
    // 添加约束
    [headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.top.equalTo(self.view.mas_top);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.equalTo(@(JYIconBackgroundImageViewHeight));
    }];

    
    // 头像后面的背景图片
    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    backgroundImageView.image = [UIImage imageNamed:@"background"];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView = backgroundImageView;
    [headView addSubview:backgroundImageView];
    // 添加约束
    [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(headView.mas_leading);
        make.top.equalTo(headView.mas_top);
        make.trailing.equalTo(headView.mas_trailing);
        make.bottom.equalTo(headView.mas_bottom);
    }];

    // 头像
    UIImageView *iconImageView = [[UIImageView alloc] init];
    iconImageView.image = [UIImage imageNamed:@"icon"];
    iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    iconImageView.layer.cornerRadius = JYIconImageWidthOrHeight * 0.5;
    iconImageView.layer.masksToBounds = YES;
    self.iconImageView = iconImageView;
    [headView addSubview:iconImageView];
    // 添加约束
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(JYIconImageWidthOrHeight, JYIconImageWidthOrHeight));
        make.centerY.equalTo(headView.mas_bottom).offset(-JYIconImageOffset);
        make.centerX.equalTo(headView.mas_centerX);
    }];
    
    // 选择栏
    UIView *tabView = [[UIView alloc] init];
    tabView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tabView];
    // 添加约束
    [tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.top.equalTo(headView.mas_bottom);
        make.height.equalTo(@(JYTabViewHeight));
    }];
    // 在tabView下面添加一个高度为1的view作为分割线
    UIView *separator = [[UIView alloc] init];
    separator.backgroundColor = [UIColor blackColor];
    separator.alpha = 0.3;
    [tabView addSubview:separator];
    // 添加分割线的约束
    [separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(JYTabViewSeparatorHeight));
        make.leading.equalTo(tabView.mas_leading);
        make.trailing.equalTo(tabView.mas_trailing);
        make.bottom.equalTo(tabView.mas_bottom);
    }];
    
    // 添加tabView上的三个标签
    UILabel *mainPageLabel = [[UILabel alloc] init];
    mainPageLabel.text = @"主页";
    mainPageLabel.font = JYTabViewLabelFont;
    [mainPageLabel sizeToFit];
    [tabView addSubview:mainPageLabel];
    
    UILabel *weiboLabel = [[UILabel alloc] init];
    weiboLabel.text = @"微博";
    weiboLabel.font = JYTabViewLabelFont;
    [weiboLabel sizeToFit];
    [tabView addSubview:weiboLabel];
    
    UILabel *photoLabel = [[UILabel alloc] init];
    photoLabel.text = @"相册";
    photoLabel.font = JYTabViewLabelFont;
    [photoLabel sizeToFit];
    [tabView addSubview:photoLabel];
    
    // 设置三个标签的约束
    [weiboLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(tabView.mas_centerX);
        make.centerY.equalTo(tabView.mas_centerY);
    }];
    [mainPageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weiboLabel.mas_centerY);
        make.centerX.equalTo(weiboLabel.mas_centerX).with.offset(-JYTabLabelSpacing);
    }];
    [photoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weiboLabel.mas_centerY);
        make.centerX.equalTo(weiboLabel.mas_centerX).with.offset(JYTabLabelSpacing);
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return JYTableViewCellNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JYTableViewCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:JYTableViewCellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 计算scrollView的offset
    CGFloat scrollViewOffset = scrollView.contentOffset.y;
    // 计算真正移动的距离
    CGFloat offset = scrollViewOffset - self.originOffset;
    // 计算headView的高度，当其小于JYHeadViewMinHeight的时候让它保持JYHeadViewMinHeight不变
    CGFloat headViewHeight = JYIconBackgroundImageViewHeight - offset;
    
    if (headViewHeight < JYHeadViewMinHeight) {
        headViewHeight = JYHeadViewMinHeight;
    }
    
    // 根据scrollView移动距离改变headView的高度
    [self.headView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(headViewHeight));
    }];

    // 根据偏移量计算navigationBar的alpha
    CGFloat alpha = offset / (JYIconBackgroundImageViewHeight - JYHeadViewMinHeight);

    // 当alpha超过1之后会自动被设置为半透明，所以当快接近1的时候我们让alpha最大值取到0.99
    if (alpha >= 1.0) {
        alpha = 0.99;
    }
    
    UIImage *whiteImage = [UIImage jy_imageWithColor:[UIColor colorWithWhite:1.0 alpha:alpha]];
    [self.navigationController.navigationBar setBackgroundImage:whiteImage forBarMetrics:UIBarMetricsDefault];
    
    // 设置title的渐变
    self.navigationItem.titleView.alpha = alpha;
}


@end
