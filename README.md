# Резюме - Статический сайт на GitHub Pages

Этот проект представляет статический сайт для отображения профессионального резюме. Сайт генерируется на основе шаблонов **Slim**, используя **Ruby** и **Rake**. Он полностью готов для публикации на **GitHub Pages**.

---

## 🚀 Быстрый старт

### 1. Требования
Для работы требуется:
1. Установленная версия **Ruby** >= 3.3.6 (см. файл `.ruby-version`, если вы используете rbenv или rvm).
2. Установленный **Bundler**. Если Bundler не установлен, выполните:
   ```bash
   gem install bundler
   ```

### 2. Установка зависимостей
Убедитесь, что все зависимости, описанные в `Gemfile`, установлены:
```bash
bundle install
```

### 3. Генерация страниц
Для компиляции HTML-страниц из шаблонов **Slim**, запустите:
```bash
rake build
```
После выполнения команды статические файлы (например, `index.html`) будут созданы в корне проекта и готовы для развертывания.

---

## 🛠 Как работать с зависимостями

Если происходит смена версии Ruby, добавляются/удаляются гемы в `Gemfile`, или возникают проблемы с зависимостями, выполните следующие шаги:

1. **Удалите файл Gemfile.lock**:
   ```bash
   rm Gemfile.lock
   ```

2. **Заново установите зависимости**:
   ```bash
   bundle install
   ```
   Это создаст обновленный `Gemfile.lock` с учетом новой версии Ruby или новых зависимостей.

3. Проверьте, что задача сборки работает корректно:
   ```bash
   rake build
   ```

Есть и альтернативный способ обновления зависимостей без удаления `Gemfile.lock`:
```bash
bundle update
```
Эта команда обновляет версии гемов согласно ограничениям, указанным в `Gemfile`.

---

## 🗂 Структура проекта

```plaintext
.
├── Gemfile
├── Gemfile.lock
├── LICENSE
├── README.md
├── Rakefile
├── docs
│   ├── _about.html
│   ├── _education.html
│   ├── _experience.html
│   ├── _header.html
│   ├── _languages.html
│   ├── _skills.html
│   ├── assets
│   │   ├── custom.css
│   │   └── images
│   │       └── my_photo.jpg
│   └── index.html
├── lib
│   ├── deploy_manager.rb
│   └── slim_compiler.rb
└── views
    ├── _about.slim
    ├── _education.slim
    ├── _experience.slim
    ├── _header.slim
    ├── _languages.slim
    ├── _skills.slim
    └── index.slim
```

---

## 🔧 Задачи Rake

Для автоматизации используется **Rake**, который помогает компилировать файлы `.slim` в статические `.html`:

1. **Скомпилировать все Slim-шаблоны в HTML**:
   ```bash
   rake build
   ```

2. **Очистка старых HTML-страниц** (по необходимости):
   Если в проекте добавится задача очистки, команда может выглядеть как:
   ```bash
   rake clean
   ```

---

## 🛠 Публикация на GitHub Pages

После генерации страниц их можно загрузить на GitHub Pages:

1. Убедитесь, что изменения закоммичены:
   ```bash
   git add .
   git commit -m "Generated HTML files"
   ```

2. Опубликуйте файлы на ветку `gh-pages`:
   ```bash
   git subtree push --prefix ./ origin gh-pages
   ```

Или используйте [GitHub Pages Actions](https://github.com/marketplace/actions/github-pages-action) для автоматического деплоя.

Ваш сайт будет доступен по адресу:

[https://YOUR_USERNAME.github.io/REPO_NAME/](https://YOUR_USERNAME.github.io/REPO_NAME/)

---

## 🤝 Вклад в проект

1. Форкните этот репозиторий.
2. Внесите свои изменения.
3. Отправьте Pull Request с описанием внесенных доработок.

Ваши идеи и замечания всегда приветствуются!

---

## 📋 Лицензия

Проект распространяется под лицензией MIT. Подробнее читайте в файле [LICENSE](LICENSE).
