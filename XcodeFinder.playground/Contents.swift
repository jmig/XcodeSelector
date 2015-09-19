//: Playground - noun: a place where people can play

import Foundation

class XcodeFinder {

    let fileManager = NSFileManager.defaultManager()

    //MARK: - Public

    func findInstalledXcodeApps() -> [String : String]? {
        let applicationPaths = NSSearchPathForDirectoriesInDomains(.ApplicationDirectory, .SystemDomainMask, true)
        guard let applicationPath = applicationPaths.first else {
            print("Could not find the Applications folder.")
            return nil
        }

        do {
            let appFolderContent = try fileManager.contentsOfDirectoryAtPath(applicationPath)
            //TODO: Map directly the filtered array to paths
            let xcodeApps = appFolderContent.filter{$0.containsString("Xcode")}
            if (xcodeApps.count == 0) {
                print("No Xcode-named Apps found in the \(applicationPath) folder")
                return nil
            }

            //TODO: Can we do better than a mutable var?
            var result = Dictionary<String,String>()
            for xcode in xcodeApps {
                let path = applicationPath+"/"+xcode
                if let version = versionForXcodeApp(path) {
                    result[version] = path
                }
            }

            return result

        } catch {
            print("Could not read the contents of the Applications folder.")
            return nil
        }
    }

    //MARK: - Private

    private func versionForXcodeApp(path: String) -> String? {
        //TODO: Create a private enum for those internal paths
        let infoPlistPath = path+"/Contents/Info.plist"

        //TODO: Check if we can have a double guard condition
        guard let infoDict = NSDictionary(contentsOfFile: infoPlistPath) else {
            print("Cannot find Info.plist for this dict")
            return nil
        }
        guard let version = infoDict["CFBundleShortVersionString"] as? String else {
            print("Cannot grab the version for this plist")
            return nil
        }

        return version
    }
}

let finder = XcodeFinder()
if let xcodes = finder.findInstalledXcodeApps() {
    print(xcodes)
}


