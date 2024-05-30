import ProjectDescription
import ProjectDescriptionHelpers
import MyPlugin

// Local plugin loaded
let localHelper = LocalHelper(name: "MyPlugin")

// Project
let project = Project.app(name: "Pokedex",
                          organizationName: "eDreams.com",
                          platform: .iOS,
                          externalDependencies: ["SwiftUINavigation", "Dependencies"],
                          targetDependancies: [],
                          testingDependancies: [.external(name: "SnapshotTesting")],
                          moduleTargets: [makeHomeModule(),
                                          makeBackpackModule(),
                                          makeCatchModule(),
                                          makeCommonModule(),
                                          makeUIComponentsModule(),
                                          makeNetworkModule()
                                         ],
                          testingTargets: [.unitTests],
                          additionalFiles: ["*.md"])

// makeDetailModule(),

func makeHomeModule() -> Module {
    return Module(name: "Home",
                  moduleType: .feature,
                  path: "Home",
                  frameworkDependancies: [.target(name: "Common"), .external(name: "SwiftUINavigation")],
                  exampleDependencies: [],
                  testingDependencies: [],
                  frameworkResources: ["Resources/**"],
                  exampleResources: ["Resources/**"],
                  testResources: [],
                  targets: [.framework, .unitTests])
}

func makeBackpackModule() -> Module {
    return Module(name: "Backpack",
                  moduleType: .feature,
           path: "Backpack",
                  frameworkDependancies: [.target(name: "Common")],
                  exampleDependencies: [.target(name: "Detail")],
                  testingDependencies: [],
           frameworkResources: ["Resources/**"],
           exampleResources: ["Resources/**"],
                  testResources: [],
                  targets: [.framework])
}

func makeDetailModule() -> Module {
    return Module(name: "Detail",
                  moduleType: .feature,
                  path: "Detail",
                  frameworkDependancies: [.target(name: "Common"),
                                          .target(name: "UIComponents")],
                  exampleDependencies: [],
                  testingDependencies: [.external(name: "SnapshotTesting")],
                  frameworkResources: [],
                  exampleResources: ["Resources/**"],
                  testResources: [],
                  targets: [.framework])
}

func makeCatchModule() -> Module {
    Module(name: "Catch",
           moduleType: .feature,
           path: "Catch",
           frameworkDependancies: [.target(name: "Common"),
                                   .target(name: "UIComponents")],
           exampleDependencies: [.target(name: "NetworkKit")],
           testingDependencies: [.external(name: "SnapshotTesting")],
           frameworkResources: ["Resources/**"],
           exampleResources: ["Resources/**"],
           testResources: [],
           targets: [.framework])
}

func makeCommonModule() -> Module {
    return Module(name: "Common",
                  moduleType: .core,
                  path: "Common",
                  frameworkDependancies: [.external(name: "Dependencies")],
                  exampleDependencies: [],
                  testingDependencies: [],
                  frameworkResources: [],
                  exampleResources: ["Resources/**"],
                  testResources: [],
                  targets: [.framework, .unitTests])
}

func makeUIComponentsModule() -> Module {
    Module(name: "UIComponents",
           moduleType: .core,
           path: "UIComponents",
           frameworkDependancies: [],
           exampleDependencies: [.target(name: "Common")],
           testingDependencies: [],
           frameworkResources: [],
           exampleResources: ["Resources/**"],
           testResources: [],
           targets: [.framework])
}

func makeNetworkModule() -> Module {
    return Module(name: "NetworkKit",
                  moduleType: .core,
                  path: "Network",
                  frameworkDependancies: [],
                  exampleDependencies: [.target(name: "Common")],
                  testingDependencies: [],
                  frameworkResources: ["Resources/**"],
                  exampleResources: ["Resources/**"],
                  testResources: [],
                  targets: [.framework])
}

