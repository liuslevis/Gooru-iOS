//
//  CHTCollectionViewSearchLayout.h
//  Gooru
//
//  Created by Nelson on 12/11/19.
//  Copyright (c) 2012 Nelson Tai. All rights reserved.
//
//  Modified by Gooru on 26/11/13

#import <UIKit/UIKit.h>

@class CHTCollectionViewSearchLayout;
@protocol CHTCollectionViewSearchDelegateWaterfallLayout <UICollectionViewDelegate>

- (CGFloat)collectionViewSearch:(UICollectionView *)collectionView
                   layout:(CHTCollectionViewSearchLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (CGFloat)collectionViewSearch:(UICollectionView *)collectionView
  heightForHeaderInLayout:(CHTCollectionViewSearchLayout *)collectionViewLayout;
- (CGFloat)collectionViewSearch:(UICollectionView *)collectionView
  heightForFooterInLayout:(CHTCollectionViewSearchLayout *)collectionViewLayout;

@end

@interface CHTCollectionViewSearchLayout : UICollectionViewLayout
@property (nonatomic, weak) IBOutlet id<CHTCollectionViewSearchDelegateWaterfallLayout> delegate;
@property (nonatomic, assign) NSUInteger columnCount; // How many columns
@property (nonatomic, assign) CGFloat itemWidth; // Width for every column
@property (nonatomic, assign) UIEdgeInsets sectionInset;
@end
