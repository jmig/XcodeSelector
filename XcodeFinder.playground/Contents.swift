//: Playground - noun: a place where people can play

import Foundation

class XcodeFinder {

    let fileManager = NSFileManager.defaultManager()

    enum AppInternalStructure : String {
        case InfoPlist = "Contents/Info.plist"
        case DeveloperFolder = "Contents/Developer"
    }

    //MARK: - Public

    func findInstalledXcodeApps() -> [String : String]? {
        let applicationPaths = NSSearchPathForDirectoriesInDomains(.ApplicationDirectory, .SystemDomainMask, true)
        guard let applicationPath = applicationPaths.first else {
            print("Could not find the Applications folder.")
            return nil
        }

        do {
            let appFolderContent = try fileManager.contentsOfDirectoryAtPath(applicationPath)
            let xcodePaths = appFolderContent.filter{$0.containsString("Xcode")}.map{applicationPath+"/"+$0}
            if (xcodePaths.count == 0) {
                print("No Xcode-named Apps found in the \(applicationPath) folder")
                return nil
            }

            //TODO: Can we do better than a mutable var?
            var result = Dictionary<String,String>()
            for path in xcodePaths {
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

    func developerFolder(xcodePath path: String) -> String? {
        let developerFolderPath = (path as NSString).stringByAppendingPathComponent(AppInternalStructure.DeveloperFolder.rawValue)
        if fileManager.fileExistsAtPath(developerFolderPath) {
            return developerFolderPath
        }
        return nil
    }

    //MARK: - Private

    private func versionForXcodeApp(path: String) -> String? {
        let infoPlistPath = (path as NSString).stringByAppendingPathComponent(AppInternalStructure.InfoPlist.rawValue)
        //TODO: Check if we can have a double guard condition
        guard let infoDict = NSDictionary(contentsOfFile: infoPlistPath) else {
            print("Cannot find Info.plist for this dict. Path : \(infoPlistPath)")
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
    if let path64 = xcodes["6.4"],
        developerPath = finder.developerFolder(xcodePath: path64) {
        print (developerPath)
    }

    if let path70 = xcodes["7.0"],
        developerPath = finder.developerFolder(xcodePath: path70) {
        print (developerPath)
    }
}



