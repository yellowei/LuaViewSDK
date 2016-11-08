//
//  LVFlowLayout.m
//  LVFlowlayout
//
//  Created by 城西 on 16/11/7.
//  Copyright © 2016年 alibaba. All rights reserved.
//

#import "LVFlowLayout.h"

@interface LVFlowLayout ()
@property(nonatomic, strong) NSMutableDictionary* pinnedDic;
@end

@implementation LVFlowLayout

-(id)init
{
    self = [super init];
    if ( self ){
    }
    return self;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *superMutAr = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    NSArray* keys = self.pinnedDic.allKeys;
    // 排序
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath*  obj1, NSIndexPath* obj2) {
        return [obj1 compare:obj2];
    }];
    
    UICollectionViewLayoutAttributes* prevAtt = nil;
    int changeYTimes = 0;
    for( int i=keys.count-1; i>=0; i-- ) {
        NSIndexPath* indexPath = keys[i];
        UICollectionViewLayoutAttributes* a = [self layoutAttributesForItemAtIndexPath:indexPath];
        if( a ) {
            CGRect frame = a.frame;
            CGFloat minY = self.collectionView.contentOffset.y+self.collectionView.contentInset.top;
            CGFloat maxY = minY;
            // 浮层不能小于屏幕offset
            if( frame.origin.y < minY ) {
                frame.origin.y = minY;
                a.frame = frame;
                a.zIndex = 10 + i;
                changeYTimes ++;
            }
            if( prevAtt ) {
                // 浮层offset不能盖住上一个浮层
                maxY = prevAtt.frame.origin.y - frame.size.height;
                if( frame.origin.y>maxY ) {
                    frame.origin.y = maxY;
                    a.frame = frame;
                    a.zIndex = 10 + i;
                }
            }
            [superMutAr addObject:a];
            prevAtt = a;
            if( changeYTimes > 1 ) {
                // 这两行一定要有！！！！原因还有待确认@城西
                a.alpha = 0;
                a.zIndex = -1;
                break;
            } else {
                a.alpha = 1;
            }
        }
    }
    return superMutAr;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBound
{
    return YES;
}

-(void) resetPinnedDic{
    self.pinnedDic = [[NSMutableDictionary alloc] initWithCapacity:8];
}
    
-(void) addPinnedIndexPath:(NSIndexPath*)indexPath {
    if( indexPath ) {
        if( self.pinnedDic==nil ) {
            [self resetPinnedDic];
        }
        self.pinnedDic[indexPath] = @(YES);
    }
}

-(void) delPinnedIndexPath:(NSIndexPath*)indexPath{
    if( indexPath ) {
        [self.pinnedDic removeObjectForKey:indexPath];
    }
}

-(BOOL) isPinned:(NSIndexPath*)indexPath{
    if( indexPath ) {
        return self.pinnedDic[indexPath];
    }
    return NO;
}

-(BOOL) pinnedDicIsNil{
    return self.pinnedDic==nil;
}

@end

