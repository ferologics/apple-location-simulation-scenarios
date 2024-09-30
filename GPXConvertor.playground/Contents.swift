import Foundation
import CoreLocation

let dir = FileManager.default.currentDirectoryPath
let inputDir = dir + "/SimulationScenarios/"
let scenarios = ["Apple", "City Bicycle Ride", "City Run", "Freeway Drive"]
let urls = scenarios.map { URL(filePath: inputDir + $0 + ".plist") }
let datas = try urls.map { try Data(contentsOf: $0) }
let plists = try datas.map { try PropertyListSerialization.propertyList(from: $0, format: nil) }
let locationDatas = plists.map { ($0 as! [String: Any])["Locations"] as! [Data] }
let unarchivedLocations = try locationDatas.map { try $0.map {
  try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: $0)!.coordinate
} }
let gpxFiles = unarchivedLocations.map { generateGPX(with: $0) }

let outputDir = dir + "/SimulationScenariosConverted/"
let gpxFileUrls = scenarios.map { URL(filePath: outputDir + $0 + ".gpx") }
for (file, url) in zip(gpxFiles, gpxFileUrls) {
  try file.write(to: url, atomically: true, encoding: .utf8)
}

func generateGPX(with coordinates: [CLLocationCoordinate2D]) -> String {
    var gpxString = """
    <?xml version="1.0" encoding="UTF-8"?>
    <gpx version="1.1" creator="Xcode">
    """

    for c in coordinates {
      gpxString += "\n    <wpt lat=\"\(c.latitude)\" lon=\"\(c.longitude)\"></wpt>"
    }

    gpxString += "\n</gpx>"
    return gpxString
}

