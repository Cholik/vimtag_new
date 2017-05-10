//
//  SQLiteUtils.h
//  mipci
//
//  Created by mining on 13-11-12.
//
//
#define X_DBNAME  @"mipci_database.sqlite"



#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "mipc_data_object.h"

@interface SQLiteUtils : NSObject
/*----------- only on mipci ----------*/
//return -1 is fail
+ (SQLiteUtils*)deflautMIPCISQLite;
- (BOOL)create_mipc_msg_table:(NSString*)table_name;
- (mdev_msg *)select_mdev_msg_by_id:(NSString*)table_name msg_id:(long)msg_id flag:(BOOL)flag;
- (BOOL)insert_mdev_msg:(NSString*)table_name mdev_msg:(mdev_msg*)msg;
- (long)numberOfMsgIDByTable:(NSString*)table_name;
- (long)numberOfRecordByTable:(NSString*)table_name;
- (long)maxMsgIDByTable:(NSString*)table_name;
- (long)minMsgIDByTable:(NSString*)table_name;
- (long)maxRecordByTable:(NSString*)table_name;
- (long)minRecordByTable:(NSString*)table_name;
/*------------------------------------*/
- (BOOL)deleteTable:(NSString*)table_name;
- (BOOL)openSQLite:(NSString*)dbname;
- (BOOL)execSQLite:(NSString*)sql;
- (BOOL)checkTableExist:(NSString*)table_name;
//select count(*) from table_name requirement;
- (long)numberOfInformationByTable:(NSString*)table_name requirement:(NSString*)requirement;
@end
