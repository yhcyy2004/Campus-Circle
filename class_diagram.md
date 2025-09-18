# 校园圈类图

```mermaid
classDiagram
    %% 核心实体类 (Model层)
    class User {
        -String userId
        -String username
        -String email
        -String password
        -Date createTime
        +login()
        +register()
        +updateProfile()
    }

    class UserProfile {
        -String userId
        -String nickname
        -String avatar
        -String bio
        -String phone
        -Date birthday
        +updateProfile()
        +getProfile()
    }

    class Section {
        -String sectionId
        -String name
        -String description
        -String cover
        -int memberCount
        -Date createTime
        +createSection()
        +updateSection()
        +addMember()
    }

    class SectionPost {
        -String postId
        -String sectionId
        -String userId
        -String title
        -String content
        -List~String~ images
        -int likesCount
        -int commentsCount
        -Date createTime
        +createPost()
        +updatePost()
        +deletePost()
        +addLike()
    }

    class SectionComment {
        -String commentId
        -String postId
        -String userId
        -String content
        -String replyToId
        -Date createTime
        +createComment()
        +deleteComment()
        +replyToComment()
    }

    class PointsModel {
        -String recordId
        -String userId
        -int points
        -String action
        -String description
        -Date createTime
        +addPoints()
        +deductPoints()
    }

    class PointsProfile {
        -String userId
        -int totalPoints
        -int currentPoints
        -int level
        -Date lastUpdate
        +calculateLevel()
        +updatePoints()
    }

    class CheckinModel {
        -String checkinId
        -String userId
        -Date checkinDate
        -int pointsEarned
        +checkin()
        +getCheckinHistory()
    }

    class CheckinStatus {
        -String userId
        -boolean hasCheckedToday
        -int consecutiveDays
        -Date lastCheckinDate
        +updateStatus()
        +resetConsecutive()
    }

    %% 请求/响应类
    class LoginRequest {
        -String username
        -String password
        +validate()
    }

    class RegisterRequest {
        -String username
        -String email
        -String password
        -String confirmPassword
        +validate()
    }

    class LoginResponse {
        -String token
        -User user
        -boolean success
        -String message
    }

    %% 服务类 (Service层)
    class AuthService {
        +login(LoginRequest): LoginResponse
        +register(RegisterRequest): boolean
        +logout(): boolean
        +validateToken(String): boolean
    }

    class UserService {
        +getUserProfile(String): UserProfile
        +updateUserProfile(UserProfile): boolean
        +getUserPosts(String): List~SectionPost~
    }

    class UserApiService {
        +fetchUserData(String): User
        +updateUserData(User): boolean
        +uploadAvatar(File): String
    }

    class PointsService {
        +getUserPoints(String): PointsProfile
        +addPoints(String, int, String): boolean
        +getPointsHistory(String): List~PointsModel~
    }

    class CheckinService {
        +checkin(String): boolean
        +getCheckinStatus(String): CheckinStatus
        +getCheckinHistory(String): List~CheckinModel~
    }

    class ApiService {
        +get(String): Object
        +post(String, Object): Object
        +put(String, Object): Object
        +delete(String): boolean
    }

    class StorageService {
        +save(String, Object): boolean
        +load(String): Object
        +delete(String): boolean
        +clear(): boolean
    }

    %% 管理器类 (Manager层)
    class PointsManager {
        -PointsService pointsService
        +manageUserPoints(String): void
        +calculateBonus(): int
        +processPointsExpiry(): void
    }

    class CheckinManager {
        -CheckinService checkinService
        +processCheckin(String): boolean
        +updateConsecutiveDays(String): void
        +generateCheckinRewards(): void
    }

    %% 数据访问类 (DAO层)
    class UserDao {
        +findById(String): User
        +save(User): boolean
        +update(User): boolean
        +delete(String): boolean
        +findByUsername(String): User
    }

    class DatabaseConnection {
        -String connectionString
        -Connection connection
        +connect(): void
        +disconnect(): void
        +executeQuery(String): ResultSet
        +executeUpdate(String): int
    }

    %% 页面/控制器类
    class HomePage {
        -List~Section~ sections
        -List~SectionPost~ hotPosts
        +loadSections(): void
        +loadHotPosts(): void
        +navigateToSection(String): void
    }

    class ProfilePage {
        -UserProfile userProfile
        -PointsProfile pointsProfile
        +loadUserProfile(): void
        +editProfile(): void
        +viewPointsHistory(): void
    }

    class SectionsPage {
        -List~Section~ sections
        +loadSections(): void
        +joinSection(String): boolean
        +createSection(): void
    }

    class SectionDetailPage {
        -Section section
        -List~SectionPost~ posts
        +loadSectionPosts(): void
        +createPost(): void
        +joinSection(): boolean
    }

    class CreatePostPage {
        -String sectionId
        -SectionPost post
        +createPost(): boolean
        +uploadImages(): List~String~
        +previewPost(): void
    }

    class PostDetailPage {
        -SectionPost post
        -List~SectionComment~ comments
        +loadComments(): void
        +addComment(): boolean
        +likePost(): boolean
    }

    class TaskPage {
        -CheckinStatus checkinStatus
        -List~PointsModel~ pointsHistory
        +loadTasks(): void
        +performCheckin(): boolean
        +viewPointsHistory(): void
    }

    %% 关系定义

    %% 实体关系
    User ||--|| UserProfile : "has"
    User ||--o{ SectionPost : "creates"
    User ||--o{ SectionComment : "creates"
    User ||--|| PointsProfile : "has"
    User ||--o{ PointsModel : "earns"
    User ||--o{ CheckinModel : "performs"
    User ||--|| CheckinStatus : "has"

    Section ||--o{ SectionPost : "contains"
    SectionPost ||--o{ SectionComment : "has"
    SectionComment }o--|| SectionComment : "replies to"

    %% 服务层关系
    AuthService ..> LoginRequest : "uses"
    AuthService ..> RegisterRequest : "uses"
    AuthService ..> LoginResponse : "returns"
    AuthService ..> User : "manages"
    AuthService ..> UserDao : "uses"

    UserService ..> User : "manages"
    UserService ..> UserProfile : "manages"
    UserService ..> UserDao : "uses"

    UserApiService ..> ApiService : "uses"
    UserApiService ..> User : "manages"

    PointsService ..> PointsModel : "manages"
    PointsService ..> PointsProfile : "manages"

    CheckinService ..> CheckinModel : "manages"
    CheckinService ..> CheckinStatus : "manages"

    %% 管理器层关系
    PointsManager o-- PointsService : "uses"
    CheckinManager o-- CheckinService : "uses"

    %% DAO层关系
    UserDao ..> DatabaseConnection : "uses"
    UserDao ..> User : "manages"

    %% 页面控制器关系
    HomePage ..> Section : "displays"
    HomePage ..> SectionPost : "displays"

    ProfilePage ..> UserProfile : "displays"
    ProfilePage ..> PointsProfile : "displays"
    ProfilePage ..> UserService : "uses"

    SectionsPage ..> Section : "displays"

    SectionDetailPage ..> Section : "displays"
    SectionDetailPage ..> SectionPost : "displays"

    CreatePostPage ..> SectionPost : "creates"

    PostDetailPage ..> SectionPost : "displays"
    PostDetailPage ..> SectionComment : "displays"

    TaskPage ..> CheckinStatus : "displays"
    TaskPage ..> PointsModel : "displays"
    TaskPage ..> CheckinService : "uses"
```

## 关系说明

### 实体关系 (Entity Relationships)
- **用户与资料**: User 与 UserProfile 一对一关系
- **用户与内容**: User 与 SectionPost、SectionComment 一对多关系
- **用户与积分**: User 与 PointsProfile 一对一，与 PointsModel 一对多
- **用户与签到**: User 与 CheckinStatus 一对一，与 CheckinModel 一对多
- **版块与帖子**: Section 与 SectionPost 一对多关系
- **帖子与评论**: SectionPost 与 SectionComment 一对多关系
- **评论回复**: SectionComment 之间的自引用关系

### 服务层关系 (Service Layer Relationships)
- **依赖关系**: 服务类依赖于实体类和DAO类
- **组合关系**: Manager类组合Service类
- **使用关系**: API服务使用通用ApiService

### 控制层关系 (Controller Layer Relationships)
- **显示关系**: 页面类显示相应的实体数据
- **使用关系**: 页面类使用相应的服务类获取数据

### 数据访问层关系 (Data Access Layer Relationships)
- **依赖关系**: DAO类依赖于数据库连接和实体类