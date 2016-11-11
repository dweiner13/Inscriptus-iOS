//
//  AppDelegate.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/18/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

// Dark purple tint
public let INSCRIPTUS_TINT_COLOR = UIColor(red:0.581, green:0.128, blue:0.574, alpha:1)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    // MARK:  - Types
    
    enum ShortcutIdentifier: String {
        case opensearch
        case openfavorites
        case openrecentlyviewed
        
        // MARK: - Initializers
        
        init?(fullType: String) {
            guard let last = fullType.components(separatedBy: ".").last else { return nil }
            
            self.init(rawValue: last)
        }
        
        // MARK: - Properties
        
        var type: String {
            return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
        }
    }

    // MARK:  - Properties
    
    var window: UIWindow?
    
    var launchedShortcutItem: UIApplicationShortcutItem?
    
    // MARK: - AppDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        var shouldPerformAdditionalDelegateHandling = true
        
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers.last as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        
        self.window?.tintColor = INSCRIPTUS_TINT_COLOR
        
        // If a shortcut was launched, take the appropriate action
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            launchedShortcutItem = shortcutItem
            
            shouldPerformAdditionalDelegateHandling = false
        }
        
        return shouldPerformAdditionalDelegateHandling
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        ApplicationState.sharedApplicationState().saveApplicationState()
        AbbreviationCollection.sharedAbbreviationCollection.saveFavorites()
        AbbreviationCollection.sharedAbbreviationCollection.saveRecentlyViewed()
        WhitakerCache.sharedCache.saveCache()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        guard let shortcut = launchedShortcutItem else { return }
        
//        let shortcut = UIApplicationShortcutItem(type: ShortcutIdentifier.openrecentlyviewed.type,
//                                                 localizedTitle: "First one",
//                                                 localizedSubtitle: "Recently viewed",
//                                                 icon: UIApplicationShortcutIcon(type: .time),
//                                                 userInfo: ["recentlyViewedIndex": 0])
        
        // ignore result so we don't get a compiler warning for not using result
        _ = handleShortcutItem(shortcutItem: shortcut);
        
        launchedShortcutItem = nil;
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.portrait
        }
        
        return UIInterfaceOrientationMask.all
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController {
                if topAsDetailController.detailItem == nil {
                    // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                    return true
                }
            }
        }
        return false
    }
    
    func splitViewController(_ svc: UISplitViewController, shouldHide vc: UIViewController, in orientation: UIInterfaceOrientation) -> Bool {
        return false
    }

    // MARK: - Shortcut Items
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handledShortcutItem = handleShortcutItem(shortcutItem: shortcutItem);
        
        completionHandler(handledShortcutItem);
    }
    
    func handleShortcutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        print("handling shortcut item")
        
        var handled = false
        
        // Verify that the provided `shortcutItem`'s `type` is one handled by the application.
        guard ShortcutIdentifier(fullType: shortcutItem.type) != nil else { return false }
        
        guard let shortcutType = shortcutItem.type as String? else { return false }
        
        let visibleViewController = getVisibleViewController()
        
        switch (shortcutType) {
        case ShortcutIdentifier.openfavorites.type:
            if let masterVC = navigateToMasterViewController() {
                masterVC.isShowingFavorites = true
                handled = true
            } else {
                handled = false
                print("Could not navigate to master view controller while attempting to handle shortcut \(shortcutType)")
            }
            break
        case ShortcutIdentifier.opensearch.type:
            if let masterVC = navigateToMasterViewController() {
                masterVC.isShowingFavorites = false
                masterVC.focusSearchBar = true
                handled = true
            } else {
                handled = false
                print("Could not navigate to master view controller while attempting to handle shortcut \(shortcutType)")
            }
        case ShortcutIdentifier.openrecentlyviewed.type:
            let index = shortcutItem.userInfo!["recentlyViewedIndex"] as! Int
            let abbreviation = AbbreviationCollection.sharedAbbreviationCollection.getRecentlyViewedIndex(index: index)
            
            // If already showing detail view, just replace detail item. Otherwise pop to master and perform segue
            if let topViewController = visibleViewController as? DetailViewController {
                topViewController.detailItem = abbreviation
            } else if let masterVC = navigateToMasterViewController() {
                masterVC.performSegue(withIdentifier: "showDetail", sender: abbreviation)
                handled = true
            } else {
                print("Could not navigate to master view controller while attempting to handle shortcut \(shortcutType)")
                handled = false
            }
            break
        default:
            break
        }
        
        return handled;
    }
    
    // TODO: not sure what happens if you're in the unsearchables view
    // Navigates to and returns the MasterViewController
    private func navigateToMasterViewController() -> MasterViewController? {
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        
        // UISplitViewController has either 1 (when collapsed) or 2 (when expanded) view controllers. First is always master.
        let masterNavController = splitViewController.viewControllers.first as! UINavigationController
        
        // If the master view controller is the active visible controller
        if let masterViewController = masterNavController.topViewController as? MasterViewController {
            return masterViewController;
        }
            
        // Otherwise, pop to it
        else {
            let masterViewController = masterNavController.viewControllers.first as! MasterViewController
            masterNavController.popToRootViewController(animated: false)
            return masterViewController;
        }
    }
    
    private func getVisibleViewController() -> UIViewController {
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        
        let masterNavController = splitViewController.viewControllers.first! as! UINavigationController
        
        if let detailNavController = masterNavController.topViewController as? UINavigationController {
            return detailNavController.topViewController!
        } else {
            return masterNavController.topViewController!
        }
    }
}

