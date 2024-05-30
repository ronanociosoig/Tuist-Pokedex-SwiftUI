import ProjectDescription

let reverseOrganizationName = "com.edreams"
let featuresPath = "Features"
let corePath = "Core"
let appPath = "App"
let exampleAppSuffix = "Example"
let examplePath = "Example"

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://tuist.io/docs/usage/helpers/

public enum uFeatureTarget {
    case framework
    case unitTests
    case snapshotTests
    case uiTests
    case exampleApp
}

public enum AppTestingTargets {
    case unitTests
    case uiTests
    case snapshotTests
}

public enum AppModuleType {
    case core
    case feature
    case app
    
    func path() -> String {
        switch self {
        case .core:
            return corePath
        case .feature:
            return featuresPath
        case .app:
            return appPath
        }
    }
}

public struct Module {
    let name: String
    let path: String
    let frameworkDependancies: [TargetDependency]
    let exampleDependencies: [TargetDependency]
    let testingDependencies: [TargetDependency]
    let frameworkResources: [String]
    let exampleResources: [String]
    let testResources: [String]
    let targets: Set<uFeatureTarget>
    let moduleType: AppModuleType
    
    public init(name: String,
                moduleType: AppModuleType,
                path: String,
                frameworkDependancies: [TargetDependency],
                exampleDependencies: [TargetDependency],
                testingDependencies: [TargetDependency],
                frameworkResources: [String],
                exampleResources: [String],
                testResources: [String],
                targets: Set<uFeatureTarget> = Set([.framework, .unitTests, .exampleApp])) {
        self.name = name
        self.moduleType = moduleType
        self.path = path
        self.frameworkDependancies = frameworkDependancies
        self.exampleDependencies = exampleDependencies
        self.testingDependencies = testingDependencies
        self.frameworkResources = frameworkResources
        self.exampleResources = exampleResources
        self.testResources = testResources
        self.targets = targets
    }
}

extension Project {
    /// Helper function to create the Project for this ExampleApp
    public static func app(name: String,
                           organizationName: String,
                           platform: Platform,
                           externalDependencies: [String],
                           targetDependancies: [TargetDependency],
                           testingDependancies: [TargetDependency],
                           moduleTargets: [Module],
                           testingTargets: Set<AppTestingTargets> = Set([.unitTests]),
                           additionalFiles: [FileElement]) -> Project {
        
        var dependencies = moduleTargets.map { TargetDependency.target(name: $0.name) }
        dependencies.append(contentsOf: targetDependancies)
        
        let externalTargetDependencies = externalDependencies.map {
            TargetDependency.external(name: $0)
        }
        
        dependencies.append(contentsOf: externalTargetDependencies)
        
        var targets = makeAppTargets(name: name,
                                     platform: platform,
                                     dependencies: dependencies,
                                     testingTargets: testingTargets)
        
        targets += moduleTargets.flatMap({ makeFrameworkTargets(module: $0, platform: platform) })
        
        let buildSchemeSuffixes = Set(["Implementation", "Interface", "Mocks", "Testing"])
        let testSchemeSuffixes = Set(["Tests", "IntegrationTests", "UITests", "SnapshotTests"])
        let runnableSchemeSuffixes = Set(["App", "Example"])
        
        let automaticSchemesOptions = Options.AutomaticSchemesOptions.enabled(
            targetSchemesGrouping: .byNameSuffix(build: buildSchemeSuffixes,
                                                 test: testSchemeSuffixes,
                                                 run: runnableSchemeSuffixes),
            codeCoverageEnabled: true,
            testingOptions: []
        )
        
        let options = Project.Options.options(automaticSchemesOptions: automaticSchemesOptions,
                                              developmentRegion: nil,
                                              disableBundleAccessors: false,
                                              disableShowEnvironmentVarsInScriptPhases: false,
                                              disableSynthesizedResourceAccessors: false,
                                              textSettings: Options.TextSettings.textSettings(),
                                              xcodeProjectName: nil)
        
        
        return Project(name: name,
                       organizationName: organizationName,
                       options: options,
                       targets: targets,
                       schemes: [],
                       additionalFiles: additionalFiles)
    }
    
    public static func makeAppInfoPlist() -> InfoPlist {
        let infoPlist: [String: Plist.Value] = [
            "CFBundleShortVersionString": "1.0",
            "CFBundleVersion": "1",
            "UIMainStoryboardFile": "",
            "UILaunchStoryboardName": "LaunchScreen"
        ]
        
        return InfoPlist.extendingDefault(with: infoPlist)
    }
    
    /// Helper function to create a framework target and an associated unit test target and example app
    public static func makeFrameworkTargets(module: Module, platform: Platform) -> [Target] {
        let frameworkPath = "\(module.moduleType.path())/\(module.path)/"
        
        let frameworkResourceFilePaths = module.frameworkResources.map {
            ResourceFileElement.glob(pattern: Path(stringLiteral: frameworkPath + $0))
        }
        
        let exampleResourceFilePaths = module.exampleResources.map {
            ResourceFileElement.glob(pattern: Path(stringLiteral: "\(frameworkPath)\(examplePath)/" + $0))
        }
        
        let testResourceFilePaths = module.testResources.map {
            ResourceFileElement.glob(pattern: Path(stringLiteral: "\(frameworkPath)Tests/" + $0))
        }
        
        var exampleAppDependancies = module.exampleDependencies
        exampleAppDependancies.append(.target(name: module.name))
        
        let exampleSourcesPath = "\(module.moduleType.path())/\(module.path)/\(examplePath)/Sources"
        
        var targets = [Target]()
        
        let exampleAppName = "\(module.name)\(exampleAppSuffix)"
        
        if module.targets.contains(.framework) {
            let headers = Headers.headers(public: ["\(frameworkPath)Sources/**/*.h"])
            let path = Path(stringLiteral: "\(frameworkPath)Resources/**")
            let element = ResourceFileElement.glob(pattern: path, tags: [])
            var frameworkResources = ResourceFileElements(arrayLiteral: element)
            frameworkResources.resources = frameworkResourceFilePaths
            
            targets.append(
                Target.target(name: module.name,
                              destinations: .iOS,
                              product: .framework,
                              bundleId: "\(reverseOrganizationName).\(module.name)",
                              infoPlist: .default,
                              sources: ["\(frameworkPath)Sources/**"],
                              resources: frameworkResources,
                              headers: headers,
                              dependencies: module.frameworkDependancies))
        }
        
        if module.targets.contains(.unitTests) {
            targets.append(Target.target(
                name: "\(module.name)Tests",
                destinations: .iOS,
                product: .unitTests,
                bundleId: "\(reverseOrganizationName).\(module.name)Tests",
                           infoPlist: .default,
                           sources: ["\(frameworkPath)Tests/**"]
            ))
            
//            Target.target(name: <#T##String#>,
//                          destinations: <#T##Destinations#>,
//                          product: <#T##Product#>,
//                          productName: <#T##String?#>,
//                          bundleId: <#T##String#>,
//                          deploymentTargets: <#T##DeploymentTargets?#>,
//                          infoPlist: <#T##InfoPlist?#>,
//                          sources: <#T##SourceFilesList?#>,
//                          resources: <#T##ResourceFileElements?#>,
//                          copyFiles: <#T##[CopyFilesAction]?#>,
//                          headers: <#T##Headers?#>,
//                          entitlements: <#T##Entitlements?#>,
//                          scripts: <#T##[TargetScript]#>,
//                          dependencies: <#T##[TargetDependency]#>,
//                          settings: <#T##Settings?#>,
//                          coreDataModels: <#T##[CoreDataModel]#>,
//                          environmentVariables: <#T##[String : EnvironmentVariable]#>,
//                          launchArguments: <#T##[LaunchArgument]#>,
//                          additionalFiles: <#T##[FileElement]#>,
//                          buildRules: <#T##[BuildRule]#>,
//                          mergedBinaryType: <#T##MergedBinaryType#>,
//                          mergeable: <#T##Bool#>,
//                          onDemandResourcesTags: <#T##OnDemandResourcesTags?#>)
            
            
//            targets.append(Target.target(name: "\(module.name)Tests",
//                                         destinations: .iOS,
//                                         product: .unitTests,
//                                         bundleId: "\(reverseOrganizationName).\(module.name)Tests",
//                                         infoPlist: .default,
//                                         sources: ["\(frameworkPath)Tests/**"],
//                                         resources: ResourceFileElements(arrayLiteral: testResourceFilePaths.first!),
//                                         dependencies: [.target(name: module.name)]))
        }
        
        if module.targets.contains(.exampleApp) {
            targets.append(Target.target(name: exampleAppName,
                                         destinations: .iOS,
                                         product: .app,
                                         bundleId: "\(reverseOrganizationName).\(module.name)\(exampleAppSuffix)",
                                         infoPlist: makeAppInfoPlist(),
                                         sources: ["\(exampleSourcesPath)/**"],
                                         resources: ResourceFileElements(arrayLiteral: exampleResourceFilePaths.first!),
                                         dependencies: exampleAppDependancies))
        }
        
        if module.targets.contains(.uiTests) {
            targets.append(Target.target(name: "\(module.name)UITests",
                                         destinations: .iOS,
                                         product: .uiTests,
                                         bundleId: "\(reverseOrganizationName).\(module.name)UITests",
                                         infoPlist: .default,
                                         sources: ["\(frameworkPath)UITests/**"],
                                         resources: ResourceFileElements(arrayLiteral: testResourceFilePaths.first!),
                                         dependencies: [.target(name: exampleAppName)]))
        }
        
        if module.targets.contains(.snapshotTests) {
            var dependencies = module.testingDependencies
            dependencies.append(.target(name: module.name))
            targets.append(Target.target(name: "\(module.name)SnapshotTests",
                                         destinations: .iOS,
                                         product: .unitTests,
                                         bundleId: "\(reverseOrganizationName).\(module.name)SnapshotTests",
                                         infoPlist: .default,
                                         sources: ["\(frameworkPath)SnapshotTests/**"],
                                         resources: ResourceFileElements(arrayLiteral: testResourceFilePaths.first!),
                                         dependencies: dependencies))
        }
        
        return targets
    }
    
    /// Helper function to create the application target and the unit test target.
    public static func makeAppTargets(name: String,
                                      platform: Platform,
                                      dependencies: [TargetDependency],
                                      testingTargets: Set<AppTestingTargets>) -> [Target] {
        
        var targets = [Target]()
        
        let mainTarget = Target.target(
            name: name,
            destinations: .iOS,
            product: .app,
            bundleId: "\(reverseOrganizationName).\(name)",
            infoPlist: makeAppInfoPlist(),
            sources: ["\(appPath)/\(name)/Sources/**"],
            resources: ["\(appPath)/\(name)/Resources/**",
                        "\(appPath)/\(name)/*.md"
                       ],
            scripts: [
            ],
            dependencies: dependencies
        )
        
        targets.append(mainTarget)
        
        if testingTargets.contains(.unitTests) {
            let testTarget = Target.target(
                name: "\(name)Tests",
                destinations: .iOS,
                product: .unitTests,
                bundleId: "\(reverseOrganizationName).\(name)Tests",
                infoPlist: .default,
                sources: ["\(appPath)/\(name)/Tests/**"],
                resources: ["\(appPath)/\(name)/Tests/**/*.json",
                            "\(appPath)/\(name)/Tests/**/*.png"],
                dependencies: [
                    .target(name: "\(name)")
                ])
            
            targets.append(testTarget)
        }
        
        if testingTargets.contains(.snapshotTests) {
            let snapshotTestsTarget = Target.target(
                name: "\(name)SnapshotTests",
                destinations: .iOS,
                product: .unitTests,
                bundleId: "\(reverseOrganizationName).\(name)SnapshotTests",
                infoPlist: .default,
                sources: ["\(appPath)/\(name)/SnapshotTests/**"],
                resources: [],
                dependencies: [
                    .target(name: "\(name)")
                ])
            targets.append(snapshotTestsTarget)
        }
        
        if testingTargets.contains(.uiTests) {
            let uiTestTarget = Target.target(
                name: "\(name)UITests",
                destinations: .iOS,
                product: .uiTests,
                bundleId: "\(reverseOrganizationName).\(name)UITests",
                infoPlist: .default,
                sources: ["\(appPath)/\(name)/UITests/**"],
                resources: [],
                dependencies: [
                    .target(name: "\(name)")
                ])
            targets.append(uiTestTarget)
        }
        
        return targets
    }
}

