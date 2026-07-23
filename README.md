# AnalyticsGen

Инструмент для генерации типобезопасного Swift кода аналитических событий из YAML схем.

## 📋 Описание

**AnalyticsGen** — это утилита командной строки, которая автоматически генерирует Swift код для отслеживания аналитических событий на основе декларативных YAML схем. Инструмент обеспечивает типобезопасность, валидацию на основе JSON Schema и поддерживает как внутренние, так и внешние аналитические события.

### Основные возможности

- ✅ **Типобезопасная генерация кода** — автоматическое создание Swift структур и enum'ов
- ✅ **Валидация схем** — проверка YAML схем на соответствие JSON Schema спецификации
- ✅ **Поддержка внутренней и внешней аналитики** — генерация событий для разных систем трекинга
- ✅ **Гибкие шаблоны** — использование Stencil для кастомизации генерируемого кода
- ✅ **Удалённые репозитории** — работа с YAML схемами из Git-репозиториев (Forgejo и др.)
- ✅ **Множественные таргеты** — генерация кода для разных модулей и платформ
- ✅ **Документация в коде** — автоматическое добавление комментариев с описаниями событий

## 🚀 Установка

### Через Makefile

```bash
make build
make install PREFIX=/usr/local
```

### Вручную

```bash
swift build -c release
cp .build/release/analyticsgen /usr/local/bin/
```

## 📖 Использование

### Основные команды

#### Генерация кода

```bash
analyticsgen generate --config .analyticsGen.yml
```

#### С указанием ветки для удалённого репозитория

```bash
analyticsgen generate --config .analyticsGen.yml --branch feature/new-events
```

#### С отладочными логами

```bash
analyticsgen generate --config .analyticsGen.yml --debug
```

#### Проверка версии

```bash
analyticsgen version
```

## ⚙️ Конфигурация

Создайте файл `.analyticsGen.yml` в корне проекта:

```yaml
# Источник YAML схем
source:
  type: remote  # или local
  # Для удалённого репозитория:
  url: https://git.example.com/analytics/schemas
  auth:
    type: keychain  # или token
  # Для локального источника:
  # path: ./schemas

# Платформа (опционально)
platform: iOS

# Шаблоны (опционально)
template:
  type: bundled  # или custom
  # path: ./custom-templates

# Таргеты генерации
targets:
  - name: ApplicantAnalytics
    path: ./Sources/ApplicantAnalytics
    destination: Events
  - name: EmployerAnalytics
    path: ./Sources/EmployerAnalytics
    destination: Events
```

## 📁 Структура YAML схемы

### Пример события внутренней аналитики

```yaml
---
name: Открытие главного экрана
category: Главный экран
application: applicant
description: Событие отправляется при открытии главного экрана

internal:
  event: screen_shown
  screenName:
    const: main
    description: Название экрана
  hhtmSource:
    const: main
    description: Источник события
  actionType:
    description: Тип действия пользователя
    oneOf:
      - name: click
        description: Клик по элементу
      - name: swipe
        description: Свайп по экрану
```

### Пример события внешней аналитики

```yaml
---
name: Клик по кнопке
category: Interactions
application: applicant
description: Событие клика по кнопке

external:
  category: applicant
  action: button_click
  label:
    oneOf:
      - name: login
        description: Кнопка входа
      - name: signup
        description: Кнопка регистрации
  platform: iOS
```

## 🏗️ Генерируемый код

### Пример сгенерированного события (Internal)

```swift
/**
 Открытие главного экрана
 
 - **Описание**: Событие отправляется при открытии главного экрана
 - **Категория**: Главный экран
 */
internal struct MainScreenShowEvent: InternalEvent {
    
    internal var edition: [AnalyticsEventEdition] {
        .any
    }
    
    internal enum ActionType: String, Encodable {
        /// Клик по элементу
        case click = "click"
        
        /// Свайп по экрану
        case swipe = "swipe"
    }
    
    /// Название события
    internal let eventName = "screen_shown"
    
    /// С какого экрана событие будет отправлено
    internal let hhtmSource: HHTMSource?
    
    /// Предыдущий экран
    internal let hhtmFrom: HHTMSource?
    
    /// Название экрана
    internal let screenName = "main"
    
    /// Тип действия пользователя
    internal let actionType: ActionType
    
    internal init(
        hhtmSource: HHTMSource?, 
        hhtmFrom: HHTMSource?,
        actionType: ActionType
    ) {
        self.hhtmSource = hhtmSource
        self.hhtmFrom = hhtmFrom
        self.actionType = actionType
    }
}
```

### Протоколы для интеграции с аналитическими системами

Все сгенерированные события реализуют соответствующие протоколы, что позволяет легко интегрировать их с различными аналитическими системами:

#### InternalEvent

События внутренней аналитики реализуют протокол `InternalEvent`, который можно использовать для отправки данных в собственную систему аналитики:

```swift
protocol InternalEvent: Encodable {
    var eventName: String { get }
    var edition: [AnalyticsEventEdition] { get }
    var hhtmSource: HHTMSource? { get }
    var hhtmFrom: HHTMSource? { get }
}

// Пример использования
class AnalyticsService {
    func track(event: InternalEvent) {        
        // Отправка в собственную систему
        internalAnalytics.send(event)
    }
}
```

#### ExternalEvent

События внешней аналитики реализуют протокол `ExternalEvent` для интеграции с Google Analytics, AppMetrica и подобными системами:

```swift
protocol ExternalEvent {
    var category: String { get }
    var action: String { get }
    var label: String? { get }
    var edition: [AnalyticsEventEdition] { get }
}

// Пример использования
class GoogleAnalyticsService {
    func track(event: ExternalEvent) {
        // Отправка в Google Analytics
        GAEvent.send(
            category: event.category,
            action: event.action,
            label: event.label
        )
    }
}
```

#### Универсальный трекер

Благодаря протоколам, можно создать единый фасад для работы с аналитикой:

```swift
class Analytics {
    static func track(_ event: InternalEvent) {
        internalAnalytics.track(event)
    }
    
    static func track(_ event: ExternalEvent) {
        googleAnalytics.track(event)
        appMetricaAnalytics.track(event)
    }
}

// Использование
Analytics.track(MainScreenShowEvent(
    hhtmSource: .main,
    hhtmFrom: .onboarding,
    actionType: .click
))
```

## 📦 Зависимости

Проект использует следующие библиотеки:

- **swift-argument-parser** — парсинг аргументов командной строки
- **PathKit** — работа с файловыми путями
- **Rainbow** — цветной вывод в консоль
- **Stencil** — шаблонизатор для генерации кода
- **StencilSwiftKit** — расширения Stencil для Swift
- **Yams** — парсинг YAML
- **JSONSchema** — валидация JSON Schema
- **DictionaryCoder** — кодирование/декодирование словарей
- **ZIPFoundation** — работа с архивами
- **KeychainAccess** — доступ к Keychain для хранения токенов

## 🛠️ Разработка

### Требования

- Swift 5.9+
- macOS 10.15+

### Сборка

```bash
swift build
```

### Запуск тестов

```bash
swift test
```

### Релиз

```bash
make release PRODUCT_VERSION=0.6.10
```

Команда создаст архив `analyticsgen-0.6.10.zip` с исполняемым файлом, шаблонами и документацией.

## 📝 Спецификация событий

Проект поддерживает валидацию схем через JSON Schema спецификацию. Файл `specification.yaml` определяет структуру событий:

- **external** — события внешней аналитики (GA, Firebase и т.д.)
- **internal** — события внутренней аналитики
- **event** — общая структура события с метаданными

## 🎯 Примеры использования

### Разработка локально

```bash
# 1. Создайте директорию со схемами
mkdir -p schemas/user-events

# 2. Добавьте YAML схему
cat > schemas/user-events/login.yaml << EOF
---
name: Вход в приложение
category: Авторизация
application: applicant
internal:
  event: user_login
  method:
    oneOf:
      - name: email
      - name: phone
EOF

# 3. Настройте конфигурацию
cat > .analyticsGen.yml << EOF
source:
  type: local
  path: ./schemas
targets:
  - name: MyApp
    path: ./Generated
    destination: Analytics
EOF

# 4. Сгенерируйте код
analyticsgen generate
```

### Работа с удалённым репозиторием

```bash
# Настройте доступ через Keychain
# Добавьте токен в Keychain с именем "analytics-repo-token"

# Настройте конфигурацию
cat > .analyticsGen.yml << EOF
source:
  type: remote
  url: https://git.company.com/analytics/schemas.git
  auth:
    type: keychain
    service: analytics-repo
    account: token
targets:
  - name: Analytics
    path: ./Sources/Analytics
    destination: Events
EOF

# Генерация с указанием ветки
analyticsgen generate --branch develop
```

## iOS Autogen-PR

При запуске `analyticsgen generate --branch AN-XXXX` с удалённым репозиторием
в качестве источника (`source.remoteRepo`) инструмент **сначала** открывает
(или находит, если уже есть) iOS Autogen-PR
`AN-XXXX-ios → develop-ios` в `hhru/hh-mobile-analytics`, и только затем генерирует код.

- PR создаётся с label `Autogen`, заголовком `[Autogen][iOS] <title исходного PR>`
  и ссылкой на исходный PR аналитика.
- Повторный запуск не дублирует PR.
- Если исходный PR аналитика не найден или PR не удалось создать — инструмент
  завершается с ошибкой и **код не генерируется** (fail-closed).

### Forgejo-токен

Для обращения к Forgejo API используется тот же `accessToken`, что и в `source.remoteRepo`
конфигурации. Токен резолвится в порядке: значение в YAML → переменная окружения → Keychain.
Рекомендуемая настройка для локального запуска:

```yaml
source:
  remoteRepo:
    owner: hhru
    repo: hh-mobile-analytics
    defaultBranch: develop
    branchSuffix: ios
    accessToken:
      env: GIT_REMOTE_API_TOKEN
      keychain:
        service: Forgejo Token
        key: hh
```

Получите Personal Access Token в Forgejo (Settings → Applications) с правами на
запись PR в `hhru/hh-mobile-analytics` и положите его в env `GIT_REMOTE_API_TOKEN`
или в Keychain (`service: Forgejo Token`, `key: hh`).

## ✨ Авторы

- https://forgejo.pyn.ru/t.shafigullin
