import UIKit
import CloudKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        print("AppDelegate: userDidAcceptCloudKitShareWith metadata: \(cloudKitShareMetadata.share.recordID)")
        
        // Use the metadata to accept the share
        CloudKitService.shared.acceptShare(cloudKitShareMetadata)
    }
}
