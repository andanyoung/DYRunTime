//
//  DYFMDBManager.m
//  DYRunTime
//
//  Created by tarena on 15/11/5.
//  Copyright © 2015年 ady. All rights reserved.
//

#import "DYFMDBManager.h"
#import <FMDB/FMDB.h>
#import <CoreLocation/CoreLocation.h>
#import "DYLocationManager.h"
#import "DYRunRecord.h"

@implementation DYFMDBManager
+ (FMDatabase *)defaultDatabase{
    static FMDatabase *db = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //数据库对象初始化，需要数据库路径
        NSString *docPath=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        docPath=[docPath stringByAppendingPathComponent:@"sqlite.db"];
        /**
         *      1、当数据库文件不存在时，fmdb会自己创建一个。
         *      2、 如果你传入的参数是空串：@"" ，则fmdb会在临时文件目录下创建这个数据库，数据库断开连接时，数据库文件被删除。
         *      3、如果你传入的参数是 NULL，则它会建立一个在内存中的数据库，数据库断开连接时，数据库文件被删除。
         */
        db = [FMDatabase databaseWithPath:docPath];
        
        
        /**@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY AUTOINCREMENT, '%@' TEXT, '%@' INTEGER, '%@' TEXT)",TABLENAME,ID,NAME,AGE,ADDRESS];
         */
        if([db open]){
            NSString *sqlCreateTable =  @"CREATE TABLE IF NOT EXISTS RecordTable (date TEXT, startTime text, endTime TEXT,totalDistanc TEXT,totalTime Text)";
            BOOL res = [db executeUpdate:sqlCreateTable];
            if (!res) {
                DDLogError(@"error when creating db RecordTable");
            } else {
                DDLogInfo(@"success to creating db RecordTable");
            }
            sqlCreateTable =  @"CREATE TABLE IF NOT EXISTS LocationTable ( date Text, startTime Text, longitude TEXT,latitude TEXT)";
            res = [db executeUpdate:sqlCreateTable];
            if (!res) {
                DDLogError(@"error when creating db LocationTable");
            } else {
                DDLogInfo(@"success to creating db LocationTable");
            }
            [db close];
        }
        
    });
 
    return db;
}

+ (BOOL)executeUpdateWithSql:(NSString *)sql{
    FMDatabase *db = [self defaultDatabase];
    if ([db open]) {
        BOOL res = [db executeUpdate:sql];
        if (!res) {
            DDLogError(@"error when executeUpdate db table with sql: %@",sql);
        } else {
            DDLogInfo(@"success to executeUpdate db table with sql: %@",sql);
        }
        [db close];
        return res;
    }
    
    return NO;
}



+ (NSMutableArray *)resToList:(FMResultSet *)rs{
    NSMutableArray *arr = [NSMutableArray new];

    NSString *date = nil;
    while ([rs next]) {
        DYRunRecord *record = [DYRunRecord new];
        record.date = [rs stringForColumn:@"date"];
        record.startTime = [rs stringForColumn:@"startTime"];
        record.endTime = [rs stringForColumn:@"endTime"];
        record.totalDistanc = [rs stringForColumn:@"totalDistanc"];
        record.totalTime = [rs stringForColumn:@"totalTime"];
        
        if ([record.date isEqualToString:date]) {
            NSMutableArray<DYRunRecord *> *dataArr = [arr lastObject];
            [dataArr addObject:record];
        }else{

            [arr addObject: [[NSMutableArray alloc]initWithObjects:record, nil]];
        }
        date = record.date;
  
    }
    
    return arr;
}

+ (BOOL)deleteRecordsWithDate:(NSString *)date andStartTime:(NSString *)startTime{
    return  [self executeUpdateWithSql:[NSString stringWithFormat:@"delete  from RecordTable where  date = '%@' and startTime = '%@'",date,startTime]];

}

+ (NSArray<CLLocation *> *)getLocationsWithDate:(NSString *)date andStartTime:(NSString *)startTime{
    FMDatabase *db = [self defaultDatabase];
    if ([db open]) {
        
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat: @"select * from LocationTable where date = '%@' and startTime = '%@' ",date,startTime]];
        NSMutableArray<CLLocation *> *array =  [NSMutableArray new];
        while ([rs next]) {
            CLLocation *location = [[CLLocation alloc]initWithLatitude:[rs stringForColumn:@"latitude"].doubleValue longitude:[rs stringForColumn:@"longitude"].doubleValue];
            [array addObject:location];
        }
        [db closeOpenResultSets];
        [db close];
        return [array copy];
    }
    
    return nil;
}

+ (NSMutableArray *)getAllListLocations{
    FMDatabase *db = [self defaultDatabase];
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:@"select * from RecordTable ORDER BY date DESC"];
        NSMutableArray *arr = [self resToList:rs];
        [db closeOpenResultSets];
        [db close];
        return arr;
    }
    
    return nil;
}

+ (DYRunRecord *)saveLocations{

    DYLocationManager *locationManage = [DYLocationManager shareLocationManager];
    NSArray<CLLocation *> *array = locationManage.locations;
    NSTimeInterval timeInterval = [[array lastObject].timestamp timeIntervalSinceDate:[array firstObject].timestamp];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    
    DYRunRecord *record = [DYRunRecord new];
    record.startTime = [dateFormatter stringFromDate: [array firstObject].timestamp];
    record.endTime = [dateFormatter stringFromDate: [array lastObject].timestamp];
    record.totalDistanc = [NSString stringWithFormat:@"%.2lf" ,locationManage.totalDistanc / 1000.0 ];
    record.totalTime = [NSString stringWithFormat:@"%02ld:%02ld",(NSInteger)timeInterval/60,(NSInteger)timeInterval%60];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    record.date = [dateFormatter stringFromDate:[array firstObject].timestamp];
   
#warning 暂时先这么写吧，以后加上事务回滚
    if (record.date == nil) return false;
    BOOL isSuccess = [DYFMDBManager executeUpdateWithSql: [NSString stringWithFormat: @"insert into RecordTable (date ,startTime ,endTime ,totalDistanc ,totalTime) values ('%@','%@','%@','%@','%@')",record.date,record.startTime,record.endTime,record.totalDistanc,record.totalTime]];
    if(!isSuccess)return nil;
  
    for (CLLocation *location in array) {
         isSuccess = [DYFMDBManager executeUpdateWithSql:[NSString stringWithFormat: @"insert into LocationTable (date, startTime , longitude ,latitude ) values ('%@','%@','%lf',%lf)",record.date,record.startTime,location.coordinate.longitude,location.coordinate.latitude]];
        if(!isSuccess)return nil;
    }
    
    return record;
}


@end
