# 🌟 **О проекте**:  
Иногда хочется иметь набор простых приложений в одном месте.

Мобильное приложение «Mini Hub» сделает процесс использования маленьких приложений максимально простым и удобным для каждого пользователя.

# 🖼️ **Скриншоты**:
<p float="left">
  <img src="https://github.com/user-attachments/assets/9d1b98cb-2697-4a2b-afcb-5d0058e933e7" width="23%" />
  <img src="https://github.com/user-attachments/assets/0d3fd642-1577-415a-a6f5-7b9d39de0043" width="23%" />
  <img src="https://github.com/user-attachments/assets/c0cfb656-66b5-452d-8eca-316344d30fad" width="23%" /> 
  <img src="https://github.com/user-attachments/assets/5199906f-12ad-426e-be32-f0f718bebba3" width="23%" /> 
</p>

# 🔍 **Основные Функции**:

1. **Адаптивный главный экран**:
   - Отображение списка (UITableView) мини - приложений выполнено в двух вариантах, для переключения используется UISegmentedControl.
   - В виде списка, в котором каждый элемент равен 1/8 по высоте экрана и 100% по ширине. При таком отображении пользователь не может с приложениями взаимодействовать, только открыть их.
   - В виде списка, в котором каждый элемент равен 1/2 по высоте экрана и 100% по ширине. При таком отображении пользователь имеет возможность взаимодействовать с приложениями.
   - В любой момент, пользователь может окрыть ViewCotroller мини - приложения.
2. **Мини - приложения реализованы как SPM пакеты**:   
   - Для подключения мини - приложений разработан универсальны интерфейс, выделенный в отдельный SPM пакет и добавленный в зависимсти, к пакетам мини - приложений.
   - Для каждого мини - приложения можно применить уникальную конфигурацию - изменить его отображение в списке.
   - Мини-приложения имеют возможность повторного использования в других проектах. Достаточно подключить унифицированный интерфейс.
  
# 🛠 **Технологии**:

- UIKit
- MVVM + Router
- Combine
- Auto Layout

# 🚀 **Запуск**:

1. Клонировать репозиторий
```
git clone https://github.com/MickeyRU/MiniHub

```

2. Перейти в директорию проекта и основного приложения
```
cd MiniHub
cd MiniHub

```

3. Открыть проект в Xcode
Откройте файл с расширением `.xcodeproj`, MiniHub.xcodeproj.

4. Запустить проект
Запустите приложение, нажав на 'Run', или используя комбинацию клавиш `Cmd + R`. Зависимости проекта(унифицированный интерфейс MiniAppInterface и два пакета с мини приложениями) подключены с использованием Swift Package Manager.
