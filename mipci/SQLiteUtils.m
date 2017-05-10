//
//  SQLiteUtils.m
//  mipci
//
//  Created by mining on 13-11-12.
//
//

#import "SQLiteUtils.h"

@implementation SQLiteUtils
{
    sqlite3              *database;
}

+ (SQLiteUtils*)deflautMIPCISQLite
{
    static SQLiteUtils   *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SQLiteUtils alloc] initWithDBName:X_DBNAME];
    });
    return instance;
}

- (void)dealloc
{
    sqlite3_close(database);
//    [super dealloc];
}

- (mdev_msg *)select_mdev_msg_by_id:(NSString*)table_name msg_id:(long)msg_id flag:(BOOL)flag
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM MIPCI_%@ WHERE msg_id=%ld %@",table_name,msg_id,flag?[NSString stringWithFormat:@"AND type='record'"]:@""];
    sqlite3_stmt *statement = NULL;
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if(sqlite3_step(statement) == SQLITE_ROW)
        {
            mdev_msg *msg = [[mdev_msg alloc] init];
            int msg_id = sqlite3_column_int(statement, 1);
            char *sn = (char*)sqlite3_column_text(statement, 2);
            char *type = (char*)sqlite3_column_text(statement, 3);
            char *code = (char*)sqlite3_column_text(statement, 4);
            char *ctime = (char*)sqlite3_column_text(statement, 5);
            int time = sqlite3_column_int(statement, 6);
            char *token = (char*)sqlite3_column_text(statement, 7);
            char *img = (char*)sqlite3_column_text(statement, 8);
            char *bigimg = (char*)sqlite3_column_text(statement, 9);
            int length = sqlite3_column_int(statement, 10);
            char *clength = (char*)sqlite3_column_text(statement, 11);
            char *user = (char*)sqlite3_column_text(statement, 12);
            msg.msg_id = msg_id;
            msg.date = time;
            msg.sn = [[NSString alloc] initWithUTF8String:sn],
            msg.type = [[NSString alloc] initWithUTF8String:type],
            msg.code = [[NSString alloc] initWithUTF8String:code],
            msg.format_data = [[NSString alloc] initWithUTF8String:ctime],
            msg.record_token = [[NSString alloc] initWithUTF8String:token],
            msg.img_token = [[NSString alloc] initWithUTF8String:img],
            msg.thumb_img_token = [[NSString alloc] initWithUTF8String:bigimg];
            msg.length = length;
            msg.format_length = [[NSString alloc]initWithUTF8String:clength];
            msg.user = [[NSString alloc]initWithUTF8String:user];
            return msg;
        }
        else
            nil;
    }
    sqlite3_finalize(statement);
    return nil;
}

- (BOOL)create_mipc_msg_table:(NSString*)table_name
{
    NSLog(@"%@",[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS MIPCI_%@ (ID INTEGER PRIMARY KEY AUTOINCREMENT,msg_id INTEGER,sn TEXT,type TEXT,code TEXT,format_time TEXT,time INTEGER,token TEXT,img TEXT,bigimg TEXT,length INTEGER,format_length TEXT,user TEXT)",table_name]);
    if(![self execSQLite:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS MIPCI_%@ (ID INTEGER PRIMARY KEY AUTOINCREMENT,msg_id INTEGER,sn TEXT,type TEXT,code TEXT,format_time TEXT,time INTEGER,token TEXT,img TEXT,bigimg TEXT,length INTEGER,format_length TEXT,user TEXT)",table_name]])
        return NO;
    [self execSQLite:[NSString stringWithFormat:@"CREATE INDEX msg_id_index ON MIPCI_%@(msg_id)",table_name]];
    return YES;
}

- (BOOL)checkTableExist:(NSString*)table_name;
{
    char sql[256] = {0};
    sprintf(sql, "select count(*) from sqlite_master where tbl_name = 'MIPCI_%s'",table_name.UTF8String);
    int code;
    sqlite3_stmt *statement;
    const char *err;
    if((code = sqlite3_prepare_v2(database, sql, -1, &statement, &err)) != SQLITE_OK)
    {
        return NO;
    }
    sqlite3_step(statement);
    int i = sqlite3_column_int(statement, 0);
    sqlite3_finalize(statement);
    if(i)
        return YES;
    return NO;
}

- (BOOL)insert_mdev_msg:(NSString*)table_name mdev_msg:(mdev_msg*)msg
{
    //char *insert = "INSERT INTO MIPCI_%s (msg_id,sn,type,code,format_time,time,token,img,bigimg,lenght,format_lenght,user) VALUES (?,?,?,?,?,?,?,?,?,?,?,?);";
    char insert_sql[256] = {0};
    char *insert = "INSERT INTO MIPCI_%s (msg_id,sn,type,code,format_time,time,token,img,bigimg,length,format_length,user) VALUES (?,?,?,?,?,?,?,?,?,?,?,?);";
    sprintf(insert_sql, insert,table_name.UTF8String);
    sqlite3_stmt *stmt;
    int code;
    if ((code=sqlite3_prepare_v2(database, insert_sql, -1, &stmt, nil)) == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, msg.msg_id);
        sqlite3_bind_text(stmt, 2, msg.sn.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 3, msg.type.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 4, msg.code.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 5, msg.format_data.UTF8String, -1, NULL);
        sqlite3_bind_int(stmt, 6, msg.date);
        sqlite3_bind_text(stmt, 7, msg.record_token.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 8, msg.img_token.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 9, msg.thumb_img_token.UTF8String, -1, NULL);
        sqlite3_bind_int(stmt, 10, msg.length);
        sqlite3_bind_text(stmt, 11, msg.format_length.UTF8String, -1, NULL);
        sqlite3_bind_text(stmt, 12, msg.user.UTF8String, -1, NULL);
        if (sqlite3_step(stmt) != SQLITE_DONE)
        {
            NSLog(@"insert fail msg_id=%ld type=%@",msg.msg_id,msg.type);
            return NO;
        }
    }
    else
    {
        return NO;
    }
    sqlite3_finalize(stmt);
    return YES;
}

- (long)numberOfMsgIDByTable:(NSString *)table_name
{
    return [self numberOfInformationByTable:table_name requirement:nil];
}

- (long)numberOfRecordByTable:(NSString *)table_name
{
    return [self numberOfInformationByTable:table_name requirement:@"WHERE type='record'"];
}

- (long)maxMsgIDByTable:(NSString *)table_name
{
    char sql[256] = {0};
    sprintf(sql, "select max(msg_id) from MIPCI_%s",table_name.UTF8String);
    int code;
    sqlite3_stmt *statement;
    const char *err;
    if((code = sqlite3_prepare_v2(database, sql, -1, &statement, &err)) != SQLITE_OK)
    {
        NSLog(@"maxMsgIDByTable %d~%s",code,err);
        return -1;
    }
    sqlite3_step(statement);
    int i = sqlite3_column_int(statement, 0);
    sqlite3_finalize(statement);
    return i;
}

- (long)minMsgIDByTable:(NSString *)table_name
{
    char sql[256] = {0};
    sprintf(sql, "select min(msg_id) from MIPCI_%s",table_name.UTF8String);
    int code;
    sqlite3_stmt *statement;
    const char *err;
    if((code = sqlite3_prepare_v2(database, sql, -1, &statement, &err)) != SQLITE_OK)
    {
        NSLog(@"minMsgIDByTable %d~%s",code,err);
        return -1;
    }
    sqlite3_step(statement);
    int i = sqlite3_column_int(statement, 0);
    sqlite3_finalize(statement);
    return i;
}

- (long)maxRecordByTable:(NSString *)table_name
{
    char sql[256] = {0};
    sprintf(sql, "select max(record) from MIPCI_%s",table_name.UTF8String);
    int code;
    sqlite3_stmt *statement;
    const char *err;
    if((code = sqlite3_prepare_v2(database, sql, -1, &statement, &err)) != SQLITE_OK)
    {
        NSLog(@"maxRecordByTable %d~%s",code,err);
        return -1;
    }
    sqlite3_step(statement);
    int i = sqlite3_column_int(statement, 0);
    sqlite3_finalize(statement);
    return i;
}

- (long)minRecordByTable:(NSString *)table_name
{
    char sql[256] = {0};
    sprintf(sql, "select min(record) from MIPCI_%s",table_name.UTF8String);
    int code;
    sqlite3_stmt *statement;
    const char *err;
    if((code = sqlite3_prepare_v2(database, sql, -1, &statement, &err)) != SQLITE_OK)
    {
        NSLog(@"minRecordByTable %d~%s",code,err);
        return -1;
    }
    sqlite3_step(statement);
    int i = sqlite3_column_int(statement, 0);
    sqlite3_finalize(statement);
    return i;
}

- (BOOL)deleteTable:(NSString *)table_name
{
    @synchronized(self)
    {
        char sql[256] = {0};
        sprintf(sql, "select count(*) from sqlite_master where tbl_name = 'MIPCI_%s'",table_name.UTF8String);
        int code;
        sqlite3_stmt *statement;
        const char *err;
        if((code = sqlite3_prepare_v2(database, sql, -1, &statement, &err)) != SQLITE_OK)
        {
            NSLog(@"deleteTable %d~%s",code,err);
            return NO;
        }
        sqlite3_step(statement);
        int i = sqlite3_column_int(statement, 0);
        sqlite3_finalize(statement);
        if(i)
        {
            if (![self execSQLite:[NSString stringWithFormat:@"DELETE FROM MIPCI_%@",table_name]])
                return NO;
            if (![self execSQLite:[NSString stringWithFormat:@"UPDATE sqlite_sequence SET seq=0 WHERE name='MIPCI_%@'",table_name]])
                return NO;
        }
    }
    return YES;
}

- (BOOL)openSQLite:(NSString*)dbname
{
    NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *databaseFilePath = [[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:dbname];
    if (SQLITE_OK != sqlite3_open([databaseFilePath UTF8String], &database))
    {
        return NO;
    }
    return YES;
}

- (id)initWithDBName:(NSString*)dbname
{
    if(self = [super init])
    {
       if (![self openSQLite:dbname])
           return nil;
    }
    return self;
}

- (BOOL)execSQLite:(NSString*)sql
{
    char *err;
    int code;
    if ((code = sqlite3_exec(database, [sql UTF8String], NULL, NULL, &err)) == SQLITE_OK)
        return YES;
    else
    {
        NSLog(@"execSQLite %d,%@",code,[NSString stringWithCString:err encoding:NSUTF8StringEncoding]);
        return NO;
    }
}

- (long)numberOfInformationByTable:(NSString*)table_name requirement:(NSString*)requirement
{
    char sql[256] = {0};
    sprintf(sql, "select count(*) from MIPCI_%s %s",table_name.UTF8String,requirement?requirement.UTF8String:"");
    int code;
    sqlite3_stmt *statement;
    const char *err;
    if((code = sqlite3_prepare_v2(database, sql, -1, &statement, &err)) != SQLITE_OK)
    {
        NSLog(@"numberOfInformationByTable %d~%s",code,err);
        return -1;
    }
    sqlite3_step(statement);
    int i = sqlite3_column_int(statement, 0);
    sqlite3_finalize(statement);
    return i;
}
@end
