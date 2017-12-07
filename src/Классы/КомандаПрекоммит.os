///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с реализацией работы команды <precommit>
//
// (с) BIA Technologies, LLC
//
///////////////////////////////////////////////////////////////////////////////

#Использовать gitrunner

Перем Лог;
Перем РепозиторийGit;
Перем СценарииОбработки;

///////////////////////////////////////////////////////////////////////////////

Процедура НастроитьКоманду(Знач Команда, Знач Парсер) Экспорт
	
	// Добавление параметров команды
	Парсер.ДобавитьПозиционныйПараметрКоманды(Команда, "КаталогРепозитория", "Каталог анализируемого репозитория");
	Парсер.ДобавитьИменованныйПараметрКоманды(Команда, "-source-dir", "Каталог расположения исходных файлов относительно корня репозитория. По умолчанию <src>");
	
КонецПроцедуры // НастроитьКоманду

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   Приложение - Модуль - Модуль менеджера приложения
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач Приложение) Экспорт
	
	Лог = Приложение.ПолучитьЛог();
	
	КаталогРепозитория = ПараметрыКоманды["КаталогРепозитория"];
	ФайлКаталогРепозитория = Новый Файл(КаталогРепозитория);
	Если НЕ ФайлКаталогРепозитория.Существует() ИЛИ ФайлКаталогРепозитория.ЭтоФайл() Тогда
		
		Лог.Ошибка("Каталог репозитория '%1' не существует или это файл", КаталогРепозитория);
		Возврат Приложение.РезультатыКоманд().НеверныеПараметры;
		
	КонецЕсли;
	
	УправлениеНастройками = Новый НастройкиРепозитория(КаталогРепозитория);
	Если УправлениеНастройками.ЭтоНовый() ИЛИ УправлениеНастройками.НастройкиПриложения("Precommt4onecСценарии").Количество() = 0 Тогда
		
		Лог.Информация("Используем глобальные настройки");
		УправлениеНастройками = Новый НастройкиРепозитория(Приложение.ПутьКРодительскомуКаталогу());

	Иначе

		Лог.Информация("Используем локальные настройки");
		
	КонецЕсли;

	ЗагрузитьСценарииОбработки(Приложение.КаталогСценариев(), УправлениеНастройками, КаталогРепозитория);
	
	КаталогИсходныхФайлов = ПараметрыКоманды["-source-dir"];
	Если Не ЗначениеЗаполнено(КаталогИсходныхФайлов) Тогда
		
		КаталогИсходныхФайлов = "src";
		
	КонецЕсли;
	
	ТекущийКаталогИсходныхФайлов = ОбъединитьПути(КаталогРепозитория, КаталогИсходныхФайлов);
	ФайлТекущийКаталогИсходныхФайлов = Новый Файл(ТекущийКаталогИсходныхФайлов);
	ТекущийКаталогИсходныхФайлов = ФайлТекущийКаталогИсходныхФайлов.ПолноеИмя;
	Если НЕ ФайлТекущийКаталогИсходныхФайлов.Существует() Тогда
		
		СоздатьКаталог(ТекущийКаталогИсходныхФайлов);
		
	КонецЕсли;
	
	КаталогРепозитория = ФайлКаталогРепозитория.ПолноеИмя;
	РепозиторийGit = Новый ГитРепозиторий();
	РепозиторийGit.УстановитьРабочийКаталог(КаталогРепозитория);
	
	Если НЕ РепозиторийGit.ЭтоРепозиторий() Тогда
		
		Лог.Ошибка("Каталог '%1' не является репозиторием git", КаталогРепозитория);
		Возврат Приложение.РезультатыКоманд().НеверныеПараметры;
		
	КонецЕсли;
	
	ЖурналИзменений = ПолучитьЖурналИзменений();
	
	Ит = 0;
	ПараметрыОбработки = Новый Структура("Лог, ФайлыДляПостОбработки, ИзмененныеКаталоги, КаталогРепозитория", Лог, Новый Массив, Новый Массив, КаталогРепозитория);
	Пока Ит < ЖурналИзменений.Количество() Цикл
		
		АнализируемыйФайл = Новый Файл(ОбъединитьПути(КаталогРепозитория, ЖурналИзменений[Ит].ИмяФайла));
		Лог.Отладка("Анализируется файл <%1>", АнализируемыйФайл.Имя);
		
		Для Каждого СценарийОбработки Из СценарииОбработки Цикл
			
			ФайлОбработан = СценарийОбработки.Сценарий.ОбработатьФайл(АнализируемыйФайл, ТекущийКаталогИсходныхФайлов, ПараметрыОбработки);
			Если ФайлОбработан Тогда
				
				Для каждого ФайлДляДопОбработки Из ПараметрыОбработки.ФайлыДляПостОбработки Цикл
					
					ЖурналИзменений.Добавить(Новый Структура("ИмяФайла, ТипИзменения", СтрЗаменить(ФайлДляДопОбработки, КаталогРепозитория, ""), ВариантИзмененийФайловGit.Изменен));
					
				КонецЦикла;
				
				ПараметрыОбработки.ФайлыДляПостОбработки.Очистить();
				
				Продолжить;
				
			КонецЕсли;
			
		КонецЦикла;
		
		Ит = Ит + 1;
		
	КонецЦикла;
	
	// измененные каталоги необходимо добавить в индекс
	Лог.Отладка("Добавление измененных каталогов в индекс git");
	Для Каждого Каталог Из ПараметрыОбработки.ИзмененныеКаталоги Цикл
		
		РепозиторийGit.ДобавитьФайлВИндекс("""" + Каталог + """");
		
	КонецЦикла;
	
	// При успешном выполнении возвращает код успеха
	Возврат Приложение.РезультатыКоманд().Успех;
	
КонецФункции // ВыполнитьКоманду

///////////////////////////////////////////////////////////////////////////////

Функция ПолучитьЖурналИзменений()
	
	ПараметрыКомандыGit = Новый Массив;
	ПараметрыКомандыGit.Добавить("diff-index --name-status --cached HEAD");
	РепозиторийGit.ВыполнитьКоманду(ПараметрыКомандыGit);
	ПараметрыКомандыGit = Новый Массив;
	ПараметрыКомандыGit.Добавить("status --porcelain");
	РепозиторийGit.ВыполнитьКоманду(ПараметрыКомандыGit);
	РезультатВывода = РепозиторийGit.ПолучитьВыводКоманды();
	СтрокиВывода = СтрРазделить(РезультатВывода, Символы.ПС);
	
	ЖурналИзменений = Новый Массив;
	Для Каждого СтрокаВывода Из СтрокиВывода Цикл
		
		Лог.Отладка("	<%1>", СтрокаВывода);
		СтрокаВывода = СокрЛП(СтрокаВывода);
		ПозицияПробела = СтрНайти(СтрокаВывода, " ");
		СимволИзменения = Лев(СтрокаВывода, 1);
		Если СимволИзменения = "?" Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		ТипИзменения = ВариантИзмененийФайловGit.ОпределитьВариантИзменения(СимволИзменения);
		
		ИмяФайла = СокрЛП(СтрЗаменить(Сред(СтрокаВывода, ПозицияПробела + 1), """", ""));
		
		Если ТипИзменения = ВариантИзмененийФайловGit.Переименован Тогда
			
			// это два события - удален и добавлен
			ПозицияСтрелки = СтрНайти(ИмяФайла, "->");
			ИмяФайлаУдален = СокрЛП(Лев(ИмяФайла, ПозицияСтрелки - 1));
			ЖурналИзменений.Добавить(Новый Структура("ИмяФайла, ТипИзменения", ИмяФайлаУдален, ВариантИзмененийФайловGit.Удален));
			Лог.Отладка("		В журнале git %2 файл <%1>", ИмяФайлаУдален, ВариантИзмененийФайловGit.Удален);
			
			ИмяФайла = СокрЛП(Сред(ИмяФайла, ПозицияСтрелки + 2));
			ТипИзменения = ВариантИзмененийФайловGit.Добавлен;
			
		КонецЕсли;
		
		ЖурналИзменений.Добавить(Новый Структура("ИмяФайла, ТипИзменения", ИмяФайла, ТипИзменения));
		Лог.Отладка("		В журнале git %2 файл <%1>", ИмяФайла, ТипИзменения);
		
	КонецЦикла;
	
	Возврат ЖурналИзменений;
	
КонецФункции

Процедура ЗагрузитьСценарииОбработки(ТекущийКаталогСценариев, УправлениеНастройками, КаталогРепозитория)
	
	СценарииОбработки = Новый Массив;
	ФайлыГлобальныхСценариев = НайтиФайлы(ТекущийКаталогСценариев, "*.os");
	ФайлыЛокальныхСценариев = Новый Массив;
	ИменаЗагружаемыхСценариев = Новый Массив;
	
	Если НЕ УправлениеНастройками.ЭтоНовый() Тогда

		Лог.Информация("Читаем настройки");
		ИменаЗагружаемыхСценариев = УправлениеНастройками.Настройка("Precommt4onecСценарии\ГлобальныеСценарии");
		Если УправлениеНастройками.Настройка("Precommt4onecСценарии\ИспользоватьСценарииРепозитория") Тогда
			
			ЛокальныйКаталог = УправлениеНастройками.Настройка("Precommt4onecСценарии\КаталогЛокальныхСценариев");
			ПутьКЛокальнымСценариям = ОбъединитьПути(КаталогРепозитория, ЛокальныйКаталог);
			ФайлПутьКЛокальнымСценариям = Новый Файл(ПутьКЛокальнымСценариям);

			Если Не ФайлПутьКЛокальнымСценариям.Существует() ИЛИ ФайлПутьКЛокальнымСценариям.ЭтоФайл() Тогда

				Лог.Ошибка("Сценарии из репозитория не загружены т.к. отсутствует каталог %1", ЛокальныйКаталог);

			Иначе
			
				ФайлыЛокальныхСценариев = НайтиФайлы(ФайлПутьКЛокальнымСценариям.ПолноеИмя, "*.os");

			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	ЗагрузитьСценарииИзКаталога(СценарииОбработки, ФайлыГлобальныхСценариев, ИменаЗагружаемыхСценариев);
	ЗагрузитьСценарииИзКаталога(СценарииОбработки, ФайлыЛокальныхСценариев);
	
	Если СценарииОбработки.Количество() = 0 Тогда
		
		ВызватьИсключение "Нет доступных сценариев обработки файлов";
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗагрузитьСценарииИзКаталога(СценарииОбработки, ФайлыСценариев, Знач ИменаЗагружаемыхСценариев = Неопределено)
	
	Если ИменаЗагружаемыхСценариев = Неопределено Тогда

		ИменаЗагружаемыхСценариев = Новый Массив;

	КонецЕсли;

	Для Каждого ФайлСценария Из ФайлыСценариев Цикл		
		
		Если СтрСравнить(ФайлСценария.ИмяБезРасширения, "ШаблонСценария") = 0 Тогда
			
			Продолжить;
			
		КонецЕсли;

		Если ИменаЗагружаемыхСценариев.Количество() И ИменаЗагружаемыхСценариев.Найти(ФайлСценария.Имя) = Неопределено Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		Попытка
			
			СценарийОбработки = ЗагрузитьСценарий(ФайлСценария.ПолноеИмя);
			СценарииОбработки.Добавить(Новый Структура("ИмяСценария, Сценарий", СценарийОбработки.ИмяСценария(), СценарийОбработки));
			
		Исключение
			
			Лог.Ошибка("Ошибка загрузки сценария %1: %2", ФайлСценария.ПолноеИмя, ОписаниеОшибки());
			Продолжить;
			
		КонецПопытки;
		
	КонецЦикла;
	
КонецПроцедуры
