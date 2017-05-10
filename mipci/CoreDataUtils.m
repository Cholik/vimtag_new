//
//  CoreDataUtils.m
//  mipci
//
//  Created by mining on 15/8/27.
//
//

#import "CoreDataUtils.h"
#import "MNMdevMsg.h"

@implementation CoreDataUtils
{
    NSFetchRequest *request;
    NSEntityDescription *allMdvMsg;
}

+ (CoreDataUtils *)deflautMIPCCoreData
{
    static CoreDataUtils *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CoreDataUtils alloc] init];
    });
    return instance;
}

- (NSEntityDescription *)allMdvMsg
{
    if (nil == allMdvMsg) {
        allMdvMsg = [NSEntityDescription entityForName:@"MNMdevMsg" inManagedObjectContext:self.managedObjectContext];
    }
    return allMdvMsg;
}

- (NSFetchRequest *)request
{
    if (nil == request) {
        request = [[NSFetchRequest alloc] init];
        //add search object
        [self.request setEntity:self.allMdvMsg];
    }
    return request;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "mining.MNCoreData" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MNCoreDateModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MNCoreDataModel.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data add data
- (BOOL)insert_mdev_msg:(NSString*)msg_id mdev_msg:(mdev_msg*)msg
{
    
    MNMdevMsg *mdevMsg = [NSEntityDescription insertNewObjectForEntityForName:@"MNMdevMsg" inManagedObjectContext:self.managedObjectContext];
    mdevMsg.msg_id = [NSNumber numberWithLong:msg.msg_id];
    mdevMsg.sn = msg.sn;
    mdevMsg.code = msg.code;
    mdevMsg.type = msg.type;
    mdevMsg.user = msg.user;
    mdevMsg.date = [NSNumber numberWithLong:msg.date];
    mdevMsg.format_data = msg.format_data;
    mdevMsg.img_token = msg.img_token;
    mdevMsg.thumb_img_token = msg.thumb_img_token;
    mdevMsg.local_thumb_img = UIImageJPEGRepresentation(msg.local_thumb_img, 1.0);
    mdevMsg.length = [NSNumber numberWithLong:msg.length];
    mdevMsg.format_length = msg.format_length;
    mdevMsg.status = msg.status;
    mdevMsg.nick = msg.nick;
    mdevMsg.version = msg.version;
    mdevMsg.exsw = [NSNumber numberWithLong:msg.exsw];
    mdevMsg.windSpeed = msg.windSpeed;
    mdevMsg.mode = msg.mode;
    mdevMsg.bp = msg.bp;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"insert mdev_msg fail:%@", error.localizedDescription);
        return NO;
    } 
    NSLog(@"insert_mdev_msg : mdevMsg:%@", mdevMsg);
    return YES;
}

#pragma mark -  Core Data get data
//get one mdev_msg
- (mdev_msg *)select_mdev_msg_by_id:(NSString*)deviceID msg_id:(long)msg_id flag:(BOOL)flag
{
    //add search condition
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sn=%@ && msg_id=%d",deviceID, msg_id];
    [self.request setPredicate:predicate];
    
    NSArray *msgsArray = [self.managedObjectContext executeFetchRequest:self.request error:nil];
    if (msgsArray.count) {
        mdev_msg *msg = [[mdev_msg alloc] init];
        msg.msg_id = [[msgsArray[0] valueForKey:@"msg_id"] longValue];
        msg.sn = [msgsArray[0] valueForKey:@"sn"];
        msg.code = [msgsArray[0] valueForKey:@"code"];
        msg.type = [msgsArray[0] valueForKey:@"type"];
        msg.date = [[msgsArray[0] valueForKey:@"date"] longValue];
        msg.format_data = [msgsArray[0] valueForKey:@"format_data"];
        msg.img_token = [msgsArray[0] valueForKey:@"img_token"];
        msg.thumb_img_token = [msgsArray[0] valueForKey:@"thumb_img_token"];
        msg.local_thumb_img = [UIImage imageWithData:[msgsArray[0] valueForKey:@"local_thumb_img"]];
        msg.length = [[msgsArray[0] valueForKey:@"length"] longValue];
        msg.format_length = [msgsArray[0] valueForKey:@"format_length"];
        msg.status = [msgsArray[0] valueForKey:@"status"];
        msg.nick = [msgsArray[0] valueForKey:@"nick"];
        msg.version = [msgsArray[0] valueForKey:@"version"];
        msg.exsw = [[msgsArray[0] valueForKey:@"exsw"] longValue];
        msg.windSpeed = [msgsArray[0] valueForKey:@"windSpeed"];
        msg.mode = [msgsArray[0] valueForKey:@"mode"];
        msg.bp = [msgsArray[0] valueForKey:@"bp"];
 
        return msg;
    }
    return nil;
}

#pragma mark - Core Data delete data
//delete coredata by min_msg_id
- (void)delete_mdev_msg_by_id:(NSString *)deviceID msg_id_min:(long)msg_id_min
{
    //add search condition
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sn=%@ && msg_id<%d",deviceID, msg_id_min];
    [self.request setPredicate:predicate];
    NSArray *msgsArray = [self.managedObjectContext executeFetchRequest:self.request error:nil];
    if (msgsArray.count) {
        for (NSManagedObject *obj in msgsArray) {
            [self.managedObjectContext deleteObject:obj];
            [self.managedObjectContext save:nil];
        }
    }
}

#pragma mark - Core Data get maxMsg
- (long)maxMsgIDBydeviceID:(NSString *)deviceID
{
    //add search condition
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sn=%@",deviceID];
    [self.request setPredicate:predicate];
    NSArray *msgsArray = [self.managedObjectContext executeFetchRequest:self.request error:nil];
    long maxMsg_id = 0;
    if (msgsArray) {
        //get max msg_id
        for (MNMdevMsg *msg in msgsArray) {
            if ([msg.msg_id longValue] > maxMsg_id) {
                maxMsg_id = [msg.msg_id longValue];
            }
        }
    }
    return maxMsg_id;
}

#pragma mark - Core Data get minMsg
- (long)minMsgIDBydeviceID:(NSString *)deviceID
{
    //add search condition
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sn=%@",deviceID];
    [self.request setPredicate:predicate];
    NSArray *msgsArray = [self.managedObjectContext executeFetchRequest:self.request error:nil];
    long minMsg_id = INT_MAX;
    if (msgsArray.count) {
        //get min msg_id
        for (MNMdevMsg *msg in msgsArray) {
            if ([msg.msg_id longValue] < minMsg_id) {
                minMsg_id = [msg.msg_id longValue];
            }
        }
    }
    return minMsg_id;
}

#pragma mark - Core Data get numberOfMsg
- (long)numberOfMsgIDBydeviceID:(NSString *)deviceID
{
    //add search condition
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sn=%@",deviceID];
    [self.request setPredicate:predicate];
    NSArray *msgsArray = [self.managedObjectContext executeFetchRequest:self.request error:nil];
    return msgsArray.count;
   
}
@end
