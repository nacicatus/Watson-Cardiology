/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/


import UIKit
import Foundation

class Utils {
    

    class func getCurrentViewController() -> UIViewController? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let currentViewController = appDelegate.window?.rootViewController?.presentedViewController
        
        return currentViewController
    }

   

    class func parseRecommendationsJSON (recommendations:NSArray) -> [Management] {
        var recommendedManagements = [Management]()
        for rec in recommendations {
            
            let notes = rec["notes"] as? String ?? ""
                        
            let mgmt = Management(notes: notes)
            recommendedManagements.append(mgmt)
        }
        return recommendedManagements
    }

    
}
