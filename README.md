# Утилита для автоматической обработки исходных файлов конфигурации, внешних отчетов и обработок для платформы 1С:Предприятие при помещении в репозиторий git

Данное решение базируется на идеях проекта [precommit1c](https://github.com/xDrivenDevelopment/precommit1c/releases), но является самостоятельным решением.

## Почему не precommit1c

Указанным продуктом пользовались долгое время, он очень хорош, но потребность в развитии и невозможность реализации некоторых сценариев работы в публичной версии сподвигли к реализации нового решения.

### Особенности данного решения

- Возможность расширения функциональности под свои нужды без потери совместимости с публичной версией
- Централизованная установка и обновление скриптов без необходимости утяжелять репозиторий проекта
- Максимально использует возможности платформы 1С:Предприятие последних версий (тестировалось на 8.3.10+, возможно на версиях 8.3.8-9 тоже будет работать)
- Возможность хранить внешние отчеты, обработки и расширения с одинаковыми именами
- Корректно обрабатывается удаление файлов

## Установка

Установка на компьютер стандартна

- `opm install precommit4onec` или
- распаковать в нужный каталог архив репозитория или
- для Windows запустить [installlocalhost.bat](/installlocalhost.bat)

## Использование

Перед использованием необходима установка precommit-hook'а в репозиторий:

- для выполнения установки в конкретный репозиторий необходимо выполнить команду `precommit4onec install repo_name`

- для выполнения установки во все репозитории каталога необходимо выполнить команду `precommit4onec install folder_reps -r`

- если каталог исходных файлов в репозитории отличается от стандартного "src" (например, когда исходные файлы в формате EDT), необходимо явно указать его с помощью дополнительного параметра `-source-dir "configuration"`

  После этого, при каждом коммите будет выполняться обработка файлов.

###### **Интерактивная обработка**. 

  Для обработки **измененных, но неиндексированных файлов epf erf cfe** можно воспользоваться командой вида
  `oscript "C:\`Program` Files\OneScript\lib\precommit4onec\src\main.os" precommit ./ -source-dir "src" -interactive`

Для использования  режима  интерактивной обработки <b>установка precommit-hook'а в репозиторий не нужна</b>.



В комплекте присутствуют следующие сценарии обработки файлов:

- `ДобавлениеПробеловПередКлючевымиСловами` - добавляет отсутствующие пробелы перед ключевыми словами в файлах модулей. На данный момент обрабатывается только ключевое слово `Экспорт`.
- `ДобавлениеТестовВРасширение` - добавляет отсутствующие сценарии в расширение с unit-тестами. [См. подробнее](/docs/ДобавлениеТестовВРасширение.md)
- `ЗапретИспользованияПерейти` - проверяет модуль на использование методов `Перейти`.
- `ИсправлениеНеКаноническогоНаписания` - исправляет неканоничное написание ключевых слов в модулях.
- `КорректировкаXMLФорм` - исправляет дубли индексов элементов в файлах описаний форм (могут образоваться при объединениях). Поддерживаются как файлы в формате выгрузки конфигуратора (`Form.xml`), так и в формате EDT (`Form.form`).
- `ОбработкаЮнитТестов` - обновляет метод-загрузчик сценариев в общих модулях расширения с unit-тестами (по умолчанию отключен).
- `ОтключениеПолнотекстовогоПоиска` - отключает полнотекстовый поиск в файлах описаний метаданных. [См. подробнее](/docs/ОтключениеПолнотекстовогоПоиска.md)
- `ОтключениеРазрешенияИзменятьФорму` - снимает флаг `РазрешеноИзменятьФорму` в описаниях форм. [См. подробнее](/docs/ОтключениеРазрешенияИзменятьФорму.md)
- `ПроверкаДублейПроцедурИФункций` - проверяет уникальность названий процедур и функций в модулях.
- `ПроверкаКорректностиИнструкцийПрепроцессора` - проверяет корректность написания инструкций препроцессора в модулях.
- `ПроверкаКорректностиОбластей` - проверяет корректность "скобок" областей в модулях (парность и последовательность).
- `ПроверкаНецензурныхСлов` - проверяет наличие нецензурных слов в модулях. [См. подробнее](/docs/ПроверкаНецензурныхСлов.md)
- `РазборОбычныхФормНаИсходники` - раскладывает файлы обычных форм (`Form.bin`) на исходные файлы с помощью инструмента `v8unpack`.
- `РазборОтчетОбработокРасширений` - раскладывает средствами платформы файлы внешних отчетов, обработок и расширений на исходные файлы. [См. подробнее](/docs/РазборОтчетОбработокРасширений.md)
- `СинхронизацияОбъектовМетаданныхИФайлов` - анализирует наличие файлов и объектов конфигурации. Поддерживается только файл описания конфигурации в формате выгрузки конфигуратора (`Configuration.xml`).
- `СортировкаДереваМетаданных` - упорядочивает объекты метаданных верхнего уровня по алфавиту в файле описания конфигурации (кроме подсистем), удаляет дубли. Помещает объекты с префиксом в низ списка, если настроено. Поддерживается как файл в формате выгрузки конфигуратора (`Configuration.xml`), так и в формате EDT (`Configuration.mdo`).
- `СортировкаСоставаПодсистем` - упорядочивает объекты в подсистемах по алфавиту. Поддерживается как файл в формате выгрузки конфигуратора (`Configuration.xml`), так и в формате EDT (`Configuration.mdo`).
- `УдалениеДублейМетаданных` - удаляет дубли объектов метаданных в файле описания конфигурации (могут образоваться при объединениях). Поддерживается как файл в формате выгрузки конфигуратора (`Configuration.xml`), так и в формате EDT (`Configuration.mdo`)..
- `УдалениеЛишнихКонцевыхПробелов` - удаляет лишние пробелы и табы в конце не пустых строк в файлах модулей.
- `УдалениеЛишнихПустыхСтрок` - удаляет лишние пустые строки в модулях (лишними считаются 2 и более идущих подряд пустых строк).

## Изменение настроек

precommit4onec может читать настройки своей работы из специального конфигурационного файла.

Управление настройками происходит с использованием команды `configure`:

- Печать настроек - `precommit4onec configure -global`
- Сброс настроек на заводские - `precommit4onec configure -global -reset`
- Интерактивное изменение настроек - `precommit4onec configure -global -config`.

Предоставляется возможность в репозитории иметь свои, отличные от глобальных, настройки. Для этого необходимо вместо флага `-global` в указанных выше командах передавать параметр `-rep-path` с указанием пути к каталогу репозитория.

Также можно настроить различное поведение для различных каталогов репозитория, для работы с подкаталогами (проектами) используется ключ `-child-path`.
Настройки проектов полностью переопределяют базовые настройки. Например если в основной настройке указаны `ОтключенныеСценарии`,
а для проекта `configuration\` они не заполнены, то для каталога `configuration` будут выполнены все сценарии.

Конфигурирование дает возможности:

- Изменить список сценариев обработки файлов
- Активизировать алгоритм подключения сценариев из каталогов репозитория

Некоторые сценарии поддерживают возможность изменения своих настроек со значений по умолчанию на установленные в конфигурационном файле. На данный момент реализована возможность указывать необходимую версию платформы 1С:Предприятие в сценарии `РазборОтчетОбработокРасширений`.

### Структура файла настроек

```JSON
{
    "GLOBAL": {                           // необязательная секция
        "ВерсияПлатформы": "8.3.10.2309", // используемая версия платформы например для разбора на исходники
        "version": "2.0",                 // версия конфигурационного файла (необязательно)
        "ФорматEDT": true,                // признак использования исходных файлов в формате EDT
    },
    "Precommt4onecСценарии": {
        "ИспользоватьСценарииРепозитория": false,   // Признак, выполнения проверок из репозитория
        "КаталогЛокальныхСценариев": "",            // Относительный путь к каталогу локальных проверок
        "ГлобальныеСценарии": [...],                // Список проверок, которые будут выполнятся
        "ОтключенныеСценарии": [...],               // Список проверок, которые не будут выполнятся (имеет больший приоритет относительно ГлобальныеСценарии)
        "НастройкиСценариев": {                     // Настройки выполняемых проверок
            ...
        },
        "Проекты":{                 // Настройки проектов (подкаталогов репозитория). Настройки проектов полностью переопределяют настройки и имеют такую же структуру
            "configuration\\": {    // Имя проекта (подкаталога)
                "ИспользоватьСценарииРепозитория": false,
                "ГлобальныеСценарии": []
            }
        }
    }
}
```

## Расширение функциональности

Для создания нового сценария обработки файлов необходимо воспользоваться шаблоном, находящимся в каталоге `СценарииОбработки` скрипта.

### Установка сценария для всех репозиториев

Чтобы сценарий работал для всех репозиториев необходимо

- сохранить файл сценария в каталог `СценарииОбработки`
- выполнить команду сброса настроек либо интерактивного изменения, где указать сценарий в списке загружаемых

### Установка сценария для конкретного репозитория

Чтобы сценарий работал в конкретном репозитории необходимо

- Решить, в каком каталоге в репозиториях будут хранится сценарии, например `tools\СценарииОбработки`
- Создать каталог в репозитории и скопировать в него файл сценария
- Вызвать команду конфигурирования, в которой включить использование сценариев из репозитория
- Указать имя каталога

Если при выполнении precommit4onec не найдет файлов сценариев в указанном каталоге, либо не найдет каталог, он об этом сообщит в лог и продолжит работу без ошибок.

## Ссылки

- [Шаблон скрипта](https://github.com/oscript-library/oscript-app-template)
- [precommit1c](https://github.com/xDrivenDevelopment/precommit1c/releases)
- [Библиотека os-скриптов](https://github.com/oscript-library)
