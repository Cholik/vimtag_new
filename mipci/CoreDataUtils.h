//
//  CoreDataUtils.h
//  mipci
//
//  Created by mining on 15/8/27.
//
//

#import <Foundation/Foundation.h>
#import "mipc_data_object.h"
@interface CoreDataUtils : NSObject

//add coreData
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

//call coreData
+ (CoreDataUtils *)deflautMIPCCoreData;
- (BOOL)insert_mdev_msg:(NSString*)msg_id mdev_msg:(mdev_msg*)msg;
- (mdev_msg *)select_mdev_msg_by_id:(NSString*)deviceID msg_id:(long)msg_id flag:(BOOL)flag;
- (void)delete_mdev_msg_by_id:(NSString *)deviceID msg_id_min:(long)msg_id_min;
- (long)numberOfMsgIDBydeviceID:(NSString *)deviceID;
- (long)minMsgIDBydeviceID:(NSString *)deviceID;
- (long)maxMsgIDBydeviceID:(NSString *)deviceID;
@end
