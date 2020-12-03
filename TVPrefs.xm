#import <UIKit/UIKit.h>
#import "UIView+RecursiveFind.m"

@interface TVSettingsBluetoothFacade : NSObject
- (void)stopScanning;
- (void)startScanning;
@end

@interface TVSettingsBluetoothViewController: UIViewController
- (id)initWithFacade:(id)arg1;
@end

@interface _TVSettingsOpenURLConfig : NSObject

+ (id)_keyValueDictionaryForURL:(id)arg1;	// IMP=0x00000001000d1b2c
+ (id)configWithPrefsURL:(id)arg1;	// IMP=0x00000001000d12b8
+ (id)configWithAppSettingsURL:(id)arg1;	// IMP=0x00000001000d117c
+ (id)configWithSettingsURL:(id)arg1;	// IMP=0x00000001000d10cc
@property(nonatomic) _Bool shouldActivateLastComponent; // @synthesize shouldActivateLastComponent=_shouldActivateLastComponent;
@property(copy, nonatomic) NSArray *parsedPathComponents; // @synthesize parsedPathComponents=_parsedPathComponents;
@property(copy, nonatomic) NSDictionary *parameters; // @synthesize parameters=_parameters;
@property(copy, nonatomic) NSURL *originalURL; // @synthesize originalURL=_originalURL;
@end

@interface TVSettingsAppDelegate: NSObject <UIApplicationDelegate>
-(UIViewController *)_controllerForIdentifier:(NSString *)identifier;
@end

%hook TVSettingsBluetoothViewController
- (void)viewDidAppear:(BOOL)animated {
	%orig;
	if (@available(tvOS 14.0, *)){
		id btFacade = [self valueForKey:@"_bluetoothFacade"];
		NSLog(@"[TVSettingsLink] btfacade: %@", btFacade);
		[btFacade startScanning];
		UIView *view = [self view];
		UIActivityIndicatorView *av = (UIActivityIndicatorView*)[view findFirstSubviewWithClass:[UIActivityIndicatorView class]];
		if (av){
			NSLog(@"[TVSettingsLink] av: %@", av);
			[av startAnimating];
		}
	}
}
%end

%hook TVSettingsAppDelegate

%new -(UIViewController *)_controllerForIdentifier:(NSString *)identifier {
	Class cls = nil;
	if ([identifier isEqualToString:@"settings-general"]){
		cls = NSClassFromString(@"TVSettingsGeneralViewController");
	} else if ([identifier isEqualToString:@"settings-accounts"]){
		cls = NSClassFromString(@"TVSettingsUsersViewController");
	} else if ([identifier isEqualToString:@"settings-system"]){
		cls = NSClassFromString(@"TVSettingsSetupViewController");
	} else if ([identifier isEqualToString:@"settings-av"]){
		cls = NSClassFromString(@"TVSettingsAudioVideoViewController");
	} else if ([identifier isEqualToString:@"settings-remotes"]){
		cls = NSClassFromString(@"TVSettingsRemotesViewController");
	} else if ([identifier isEqualToString:@"settings-developer"]){
		cls = NSClassFromString(@"DTTVMainViewController");
	} else if ([identifier isEqualToString:@"settings-remotes-bluetooth"]){
		cls = NSClassFromString(@"TVSettingsBluetoothViewController");
		if (@available(tvOS 14.0, *)){
				id btFacade = [[%c(TVSettingsBluetoothFacade) alloc]init];
				id controller = [[cls alloc] initWithFacade:btFacade];
				[btFacade startScanning];
				return controller;
		}
	} else if ([identifier isEqualToString:@"settings-network"]){
		cls = NSClassFromString(@"TVSettingsNetworkViewController");
	} else if ([identifier isEqualToString:@"settings-tweaks"]){
		cls = NSClassFromString(@"TVSettingsTweakViewController");
	}
	id controller = [cls new];
	return controller;
}


- (_Bool)_openURLConfiguration:(id)arg1 {
	BOOL orig = %orig;
	NSArray *parsedPathComponents = [arg1 parsedPathComponents];
	//NSURL *origUrl = [arg1 originalURL];
	if (parsedPathComponents.count > 0){
		NSString *identifier = parsedPathComponents.lastObject;
		//NSLog(@"identifier: %@", identifier);
		id controller = [self _controllerForIdentifier:identifier];
		if (controller != nil){
			[[[[self window] rootViewController] navigationController] pushViewController:controller animated:FALSE];
			return YES;
		}
	}
	//- (id)_findFirstViewOfClass:(Class)arg1 inViewHierarchy:(id)arg2 depth:(int)arg3
	return orig;
}

- (_Bool)application:(id)arg1 openURL:(id)arg2 options:(id)arg3 {

	%log;
	return %orig;
}

%end

