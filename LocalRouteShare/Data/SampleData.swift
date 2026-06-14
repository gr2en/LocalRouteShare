import Foundation

enum SampleData {
    static let shortcuts: [Shortcut] = [
        Shortcut(
            title: "Dormitory → Engineering Shortcut",
            author: "Hyoungkwan KIM",
            startPoint: "Dormitory",
            endPoint: "Engineering Shortcut",
            routeDescription: "Student Union 4F elevator → sky bridge → Engineering 2F",
            tags: ["Rainy Day", "Indoor", "Elevator"],
            estimatedTime: "3 min 30 sec",
            distance: "280m",
            rating: 4.8,
            ratingCount: 89,
            saveCount: 342,
            isSaved: false,
            routeStops: [
                RouteStop(title: "Dormitory", detail: "1st floor"),
                RouteStop(title: "Student Union Elevator", detail: "4th floor"),
                RouteStop(title: "Engineering Shortcut", detail: "2nd floor")
            ],
            routePoints: yonseiDormToEngineeringRoute,
            photoMarkers: [
                RoutePhotoMarker(latitude: 37.5659, longitude: 126.9369, imageData: nil, imageName: "bridge-marker")
            ],
            recordedDistance: 280,
            recordedDuration: 210
        ),
        Shortcut(
            title: "Library → Student Center Indoor Route",
            author: "Lee",
            startPoint: "Library",
            endPoint: "Student Center",
            routeDescription: "An indoor-focused route for rainy days without stepping outside.",
            tags: ["Hot Weather", "Step-free", "Indoor"],
            estimatedTime: "5 min",
            distance: "410m",
            rating: 4.9,
            ratingCount: 61,
            saveCount: 289,
            isSaved: false,
            routeStops: [
                RouteStop(title: "Library", detail: "1st floor"),
                RouteStop(title: "Indoor Hallway", detail: "2nd floor"),
                RouteStop(title: "Student Center", detail: "2nd floor")
            ],
            routePoints: libraryToStudentHallRoute,
            photoMarkers: [
                RoutePhotoMarker(latitude: 37.5647, longitude: 126.9381, imageData: nil, imageName: "indoor-marker")
            ],
            recordedDistance: 410,
            recordedDuration: 300
        ),
        Shortcut(
            title: "Main Gate to Central Library Fast Route",
            author: "Hyoungkwan KIM",
            startPoint: "Main Gate",
            endPoint: "Central Library",
            routeDescription: "A morning commute route past the auditorium with fewer stairs.",
            tags: ["Fast", "Commute", "Morning"],
            estimatedTime: "6 min",
            distance: "520m",
            rating: 4.6,
            ratingCount: 44,
            saveCount: 176,
            isSaved: false,
            routeStops: [
                RouteStop(title: "Main Gate", detail: "Ground level"),
                RouteStop(title: "Auditorium Path", detail: "Outdoor path"),
                RouteStop(title: "Central Library", detail: "2nd floor")
            ],
            routePoints: mainGateToLibraryRoute,
            photoMarkers: [
                RoutePhotoMarker(latitude: 37.5652, longitude: 126.9374, imageData: nil, imageName: "morning-marker")
            ],
            recordedDistance: 520,
            recordedDuration: 360
        )
    ]

    private static let yonseiDormToEngineeringRoute: [RoutePoint] = [
        RoutePoint(latitude: 37.5667, longitude: 126.9358),
        RoutePoint(latitude: 37.5663, longitude: 126.9363),
        RoutePoint(latitude: 37.5659, longitude: 126.9369),
        RoutePoint(latitude: 37.5655, longitude: 126.9375)
    ]

    private static let libraryToStudentHallRoute: [RoutePoint] = [
        RoutePoint(latitude: 37.5642, longitude: 126.9372),
        RoutePoint(latitude: 37.5644, longitude: 126.9376),
        RoutePoint(latitude: 37.5647, longitude: 126.9381),
        RoutePoint(latitude: 37.5650, longitude: 126.9385)
    ]

    private static let mainGateToLibraryRoute: [RoutePoint] = [
        RoutePoint(latitude: 37.5629, longitude: 126.9368),
        RoutePoint(latitude: 37.5636, longitude: 126.9371),
        RoutePoint(latitude: 37.5644, longitude: 126.9373),
        RoutePoint(latitude: 37.5652, longitude: 126.9374),
        RoutePoint(latitude: 37.5658, longitude: 126.9377)
    ]

    static let routeProposals: [RouteProposal] = [
        RouteProposal(
            startPoint: "Yonsei Main Gate",
            endPoint: "Sinchon Stn. Exit 3",
            reason: "The 15-minute walk to Sinchon Station is too long. A shuttle is badly needed.",
            expectedBenefits: [
                "Save 15 minutes of walking",
                "Better access in rain",
                "Safer night commute",
                "Improved accessibility"
            ],
            voteCount: 2847,
            participantCount: 156,
            status: .reviewing,
            hasVoted: true
        ),
        RouteProposal(
            startPoint: "Yonsei East Gate",
            endPoint: "Daewoo Hall",
            reason: "A 15-minute walk to Sinchon Station is too long. A shuttle service would make commuting much easier.",
            expectedBenefits: [
                "Save commuting time",
                "Reduce walking distance",
                "Better access on rainy days"
            ],
            voteCount: 2847,
            participantCount: 156,
            status: .voting,
            hasVoted: false
        ),
        RouteProposal(
            startPoint: "Sinchon Stn. Exit2",
            endPoint: "Daewoo Hall",
            reason: "A shuttle service would make commuting much easier for students.",
            expectedBenefits: [
                "Safer night commute",
                "Improved accessibility"
            ],
            voteCount: 2847,
            participantCount: 156,
            status: .operating,
            hasVoted: true
        )
    ]

    static let userProfile = UserProfile(
        nickname: "Hyoungkwan KIM",
        level: "Local Master",
        school: "Yonsei University",
        localScore: 1247,
        weeklyIncrease: 89,
        shortcutCount: 12,
        votedRouteCount: 28,
        receivedLikes: 342,
        badges: [
            Badge(emoji: "🗺️", title: "10 Routes Shared", subtitle: "Route sharing milestone", isUnlocked: true),
            Badge(emoji: "🚌", title: "100 Votes Cast", subtitle: "Community voting milestone", isUnlocked: true),
            Badge(emoji: "❤️", title: "100 Likes Received", subtitle: "Saved by local students", isUnlocked: true),
            Badge(emoji: "🔥", title: "Hot Contributor", subtitle: "100 pts/month", isUnlocked: false),
            Badge(emoji: "👑", title: "Local Leader", subtitle: "Top nearby", isUnlocked: false),
            Badge(emoji: "💯", title: "Legend", subtitle: "5,000 score", isUnlocked: false)
        ]
    )
}
