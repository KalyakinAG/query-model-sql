//@skip-check object-module-export-variable
//@skip-check module-structure-top-region

//  Подсистема "Модель запроса"
//	Автор: Калякин Андрей Г.
//  https://github.com/KalyakinAG/query-model-sql
//  https://infostart.ru/public/1871072/

//  Не поддерживаются: объединения запросов, вложенные запросы

#Область ОписаниеПеременных

//  Общее состояние
Перем Таблицы Экспорт;
Перем ПакетЗапросов;
Перем ЗапросПакета;
Перем Схема1С;
Перем Схема;

// Текущее состояние
Перем Соединение;

#КонецОбласти

#Область ПрограммныйИнтерфейс

Процедура ПрочитатьСостояние(ИндексПакета = Неопределено)
	ЗапросПакета = ПакетЗапросов[?(ИндексПакета = Неопределено, ПакетЗапросов.ВГраница(), ИндексПакета)];
КонецПроцедуры

Процедура НовоеСостояние(Имя = "")
	ЗапросПакета = Новый Структура;
	//  Запрос
	ЗапросПакета.Вставить("Схема1С", Схема1С);
	ЗапросПакета.Вставить("Схема", Схема);
	ЗапросПакета.Вставить("ИмяЗапросаПакета", Имя);
	ЗапросПакета.Вставить("ИспользоватьЗапросКакВременнуюТаблицу", Ложь);
	ЗапросПакета.Вставить("ВыраженияПорядка", Новый Массив);
	//  Тип запроса
	ЗапросПакета.Вставить("ИмяВременнойТаблицы", "");
	ЗапросПакета.Вставить("ИмяУдаляемойТаблицы", "");
	ЗапросПакета.Вставить("ИзменяемаяТаблица", "");
	ЗапросПакета.Вставить("ИзменяемыеПоля", Новый Массив);
	//  Оператор
	ЗапросПакета.Вставить("Источники", Новый Массив);
	ЗапросПакета.Вставить("ДоступныеИсточники", Новый Соответствие);
	ЗапросПакета.Вставить("ВыбранныеПоля", Новый Массив);
	ЗапросПакета.Вставить("Соединения", Новый Массив);
	ЗапросПакета.Вставить("Отборы", Новый Массив);
	ЗапросПакета.Вставить("КоличествоПолучаемыхЗаписей");
	ЗапросПакета.Вставить("ВыбиратьРазличные", Ложь);
	ПакетЗапросов.Добавить(ЗапросПакета);
КонецПроцедуры

Функция ИспользоватьМетаданные(_Метаданные) Экспорт
	Если _Метаданные = Метаданные.Перечисления Тогда
		Макет = ПолучитьМакет("Перечисления");
		_Перечисления = ОбщийКлиентСервер.JSONВОбъект(Макет.ПолучитьТекст());
		Для Каждого ОписаниеПеречисления Из _Перечисления Цикл
			ЗначенияПеречисления = Новый Структура;
			Для Каждого ЗначениеПеречисления Из ОписаниеПеречисления.Значения Цикл
				ЗначенияПеречисления.Вставить(ЗначениеПеречисления.Наименование, ЗначениеПеречисления.uuid);
			КонецЦикла;
			Таблицы["Перечисление." + ОписаниеПеречисления.Имя] = ЗначенияПеречисления;
		КонецЦикла;
		Возврат ЭтотОбъект;
	КонецЕсли;
	ТаблицыХранения = ПолучитьСтруктуруХраненияБазыДанных(ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(_Метаданные), Истина);
	Для Каждого ОписаниеТаблицы из ТаблицыХранения Цикл
		Если ОписаниеТаблицы.Назначение <> "Основная" И ОписаниеТаблицы.Назначение <> "ТабличнаяЧасть" Тогда
			Продолжить;
		КонецЕсли;
		Поля = Новый Структура;
		Для Каждого ОписаниеПоля Из ОписаниеТаблицы.Поля Цикл
			Если ПустаяСтрока(ОписаниеПоля.ИмяПоля) Тогда
				Продолжить;
			КонецЕсли;
			Поля.Вставить(ОписаниеПоля.ИмяПоля, Новый Структура("ИмяПоляХранения, ИмяПоля", ОписаниеПоля.ИмяПоляХранения, ОписаниеПоля.ИмяПоля));
		КонецЦикла;
		Таблица = Новый Структура("ИмяТаблицыХранения, ИмяТаблицы, Поля", ОписаниеТаблицы.ИмяТаблицыХранения, ОписаниеТаблицы.ИмяТаблицы, Поля);
		Таблицы[ОписаниеТаблицы.ИмяТаблицы] = Таблица;
	КонецЦикла;
	Возврат ЭтотОбъект;
КонецФункции

Функция Схема(_Схема) Экспорт
	Если ЗапросПакета = Неопределено Тогда
		Схема = _Схема;
		Возврат ЭтотОбъект;
	КонецЕсли;
	ЗапросПакета.Схема = _Схема;
	Возврат ЭтотОбъект;
КонецФункции

Функция Схема1С(_Схема) Экспорт
	Если ЗапросПакета = Неопределено Тогда
		Схема1С = _Схема;
		Возврат ЭтотОбъект;
	КонецЕсли;
	ЗапросПакета.Схема1С = _Схема;
	Возврат ЭтотОбъект;
КонецФункции

// Добавляет оператор уничтожения временной таблицы
// 
// Параметры:
//  ЗапросПакета.ИмяВременнойТаблицы - Строка
// 
// Возвращаемое значение:
//  ОбработкаОбъект.МодельЗапроса
Функция Уничтожить(ИмяТаблицы) Экспорт
	ЗапросПакета.ИмяУдаляемойТаблицы = ИмяТаблицы;
	Возврат ЭтотОбъект;
КонецФункции

Функция Удалить(ИмяТаблицы) Экспорт
	ЗапросПакета.ИмяУдаляемойТаблицы = ИмяТаблицы;
	Возврат ЭтотОбъект;
КонецФункции

Функция Очистить() Экспорт
	ПакетЗапросов = Новый Массив;
	ЗапросПакета = Неопределено;
	Возврат ЭтотОбъект;
КонецФункции

Функция ЗапросПакета(Имя = "") Экспорт
	НовоеСостояние(Имя);
	Возврат ЭтотОбъект;
КонецФункции

Функция ПолучитьПакетЗапросов() Экспорт
	Запросы = Новый Массив;
	Для ИндексПакета = 0 По ПакетЗапросов.ВГраница() Цикл
		ПрочитатьСостояние(ИндексПакета);
		Запросы.Добавить(Новый Структура("Имя, ТекстЗапроса", ЗапросПакета.ИмяЗапросаПакета, ПолучитьТекстЗапроса()));
	КонецЦикла;
	Возврат Запросы;
КонецФункции

Функция ПолучитьТекстЗапросаПакета() Экспорт
	СтрокиТекста = Новый Массив;
	Запросы = ПолучитьПакетЗапросов();
	Для ИндексЗапроса = 0 По Запросы.ВГраница() Цикл
		Запрос = Запросы[ИндексЗапроса];
		Если ЗначениеЗаполнено(Запрос.Имя) Тогда
			СтрокиТекста.Добавить(СтрШаблон("-- ЗАПРОС ПАКЕТА %1. %2", Формат(ИндексЗапроса + 1, "ЧГ="), Запрос.Имя));
		Иначе
			ЗапросПакета = ПакетЗапросов[ИндексЗапроса];
			Если ЗначениеЗаполнено(ЗапросПакета.ИмяВременнойТаблицы) Тогда
				СтрокиТекста.Добавить(СтрШаблон("-- ЗАПРОС ПАКЕТА %1. %2", Формат(ИндексЗапроса + 1, "ЧГ="), ЗапросПакета.ИмяВременнойТаблицы));
			ИначеЕсли ЗначениеЗаполнено(ЗапросПакета.ИмяУдаляемойТаблицы) Тогда
				СтрокиТекста.Добавить(СтрШаблон("-- ЗАПРОС ПАКЕТА %1. %2", Формат(ИндексЗапроса + 1, "ЧГ="), ЗапросПакета.ИмяУдаляемойТаблицы));
			ИначеЕсли ЗначениеЗаполнено(ЗапросПакета.ИзменяемаяТаблица) Тогда
				СтрокиТекста.Добавить(СтрШаблон("-- ЗАПРОС ПАКЕТА %1. %2", Формат(ИндексЗапроса + 1, "ЧГ="), ЗапросПакета.ИзменяемаяТаблица));
			Иначе
				СтрокиТекста.Добавить(СтрШаблон("-- ЗАПРОС ПАКЕТА %1.", Формат(ИндексЗапроса + 1, "ЧГ=")));
			КонецЕсли;
		КонецЕсли;
		СтрокиТекста.Добавить(Запрос.ТекстЗапроса);
	КонецЦикла;
	Возврат СтрСоединить(СтрокиТекста, Символы.ПС);
КонецФункции

Функция Поместить(ИмяТаблицы) Экспорт
	ЗапросПакета.ИмяВременнойТаблицы = ИмяТаблицы;
	Возврат ЭтотОбъект;
КонецФункции

Функция Использовать(ИмяТаблицы) Экспорт
	ЗапросПакета.ИмяВременнойТаблицы = ИмяТаблицы;
	ЗапросПакета.ИспользоватьЗапросКакВременнуюТаблицу = Истина;
	Возврат ЭтотОбъект;
КонецФункции

Функция Изменить(ИмяТаблицы) Экспорт
	ЗапросПакета.ИзменяемаяТаблица = ИмяТаблицы;
	Возврат ЭтотОбъект;
КонецФункции

Функция Установить(ИмяПоля, Выражение) Экспорт
	ЗапросПакета.ИзменяемыеПоля.Добавить(Новый Структура("ИмяПоля, Выражение", ИмяПоля, Выражение));
	Возврат ЭтотОбъект;
КонецФункции

Функция Выбрать() Экспорт
	Возврат ЭтотОбъект;
КонецФункции

Функция Первые(Количество) Экспорт
	ЗапросПакета.КоличествоПолучаемыхЗаписей = Количество;
	Возврат ЭтотОбъект;
КонецФункции

Функция Различные() Экспорт
	ЗапросПакета.ВыбиратьРазличные = Истина;
	Возврат ЭтотОбъект;
КонецФункции

Функция Порядок(Выражение, Знач Направление = "") Экспорт
	Направление = ВРег(Направление);
	Если Направление = "+" Тогда
		Направление = "";
	ИначеЕсли Направление = "-" Тогда
		Направление = "Desc";
	КонецЕсли;
	ЗапросПакета.ВыраженияПорядка.Добавить(Новый Структура("Выражение, Направление", Выражение, Направление));
	Возврат ЭтотОбъект;
КонецФункции

Функция Источник(ИмяТаблицыИсточника, Знач Псевдоним = "") Экспорт
	Если ТипЗнч(ИмяТаблицыИсточника) <> Тип("Строка") Тогда
		Если НЕ ЗначениеЗаполнено(Псевдоним) Тогда
			Псевдоним = ОбщийКлиентСервер.ИмяПоУникальномуИдентификатору();
		КонецЕсли;
		Таблица = Новый Структура("Источник", ИмяТаблицыИсточника);
		Источник = Новый Структура("Псевдоним, Таблица, Схема", Псевдоним, Таблица, "");
		ЗапросПакета.Источники.Добавить(Источник);
		ЗапросПакета.ДоступныеИсточники.Вставить(Псевдоним, Источник);
		Возврат ЭтотОбъект;
	КонецЕсли;
	Если НЕ ЗначениеЗаполнено(Псевдоним) Тогда
		Псевдоним = Псевдоним(ИмяТаблицыИсточника);
	КонецЕсли;
	Таблица = Таблицы[ИмяТаблицыИсточника];
	Если НЕ ЗначениеЗаполнено(Таблица) Тогда
		Состав = СтрРазделить(ИмяТаблицыИсточника, ". ", Ложь);
		Если Состав.ВГраница() >= 1 Тогда
			ИмяТаблицыМетаданных = Состав[0] + "." + Состав[1];
			_Метаданные = Метаданные.НайтиПоПолномуИмени(ИмяТаблицыМетаданных);
			Если _Метаданные = Неопределено Тогда
				Таблица = Новый Структура("ИмяТаблицыХранения", ИмяТаблицыИсточника);
			Иначе
				ИспользоватьМетаданные(_Метаданные);
				Таблица = Таблицы[ИмяТаблицыИсточника];
			КонецЕсли;
		Иначе
			Таблица = Новый Структура("ИмяТаблицыХранения", ИмяТаблицыИсточника);
		КонецЕсли;
	КонецЕсли;
	Если СтрНачинаетсяС(ИмяТаблицыИсточника, "#") Тогда
		СхемаИсточника = "";
	ИначеЕсли Таблица.Свойство("ИмяТаблицы") Тогда
		СхемаИсточника = ЗапросПакета.Схема1С;
	Иначе
		СхемаИсточника = ЗапросПакета.Схема;
	КонецЕсли;
	Источник = Новый Структура("Псевдоним, Таблица, Схема", Псевдоним, Таблица, СхемаИсточника);
	ЗапросПакета.Источники.Добавить(Источник);
	ЗапросПакета.ДоступныеИсточники.Вставить(Псевдоним, Источник);
	Возврат ЭтотОбъект;
КонецФункции

Функция ВнутреннееСоединение(ИсточникСлева, ИсточникСправа) Экспорт
	Соединение = Новый Структура("ИсточникСлева, ИсточникСправа, ТипСоединения, Условия", ИсточникСлева, ИсточникСправа, "INNER", Новый Массив);
	ЗапросПакета.Соединения.Добавить(Соединение);
	Возврат ЭтотОбъект;
КонецФункции

Функция ЛевоеСоединение(ИсточникСлева, ИсточникСправа) Экспорт
	Соединение = Новый Структура("ИсточникСлева, ИсточникСправа, ТипСоединения, Условия", ИсточникСлева, ИсточникСправа, "LEFT", Новый Массив);
	ЗапросПакета.Соединения.Добавить(Соединение);
	Возврат ЭтотОбъект;
КонецФункции

Функция ПравоеСоединение(ИсточникСлева, ИсточникСправа) Экспорт
	Соединение = Новый Структура("ИсточникСлева, ИсточникСправа, ТипСоединения, Условия", ИсточникСлева, ИсточникСправа, "RIGHT", Новый Массив);
	ЗапросПакета.Соединения.Добавить(Соединение);
	Возврат ЭтотОбъект;
КонецФункции

Функция СодержитАгрегатнуюФункцию(Знач Выражение) Экспорт
	Выражение = ВРег(Выражение);
	Возврат СтрНайти(Выражение, "SUM") > 0
		ИЛИ СтрНайти(Выражение, "COUNT") > 0
		ИЛИ СтрНайти(Выражение, "MIN") > 0
		ИЛИ СтрНайти(Выражение, "MAX") > 0
		ИЛИ СтрНайти(Выражение, "AVG") > 0
	;
КонецФункции

Функция Поле(ПутьКПолю, Псевдоним = "") Экспорт
	Попытка
		Если СтрЗаканчиваетсяНа(ПутьКПолю, "*") Тогда
			ЗапросПакета.ВыбранныеПоля.Добавить(Новый Структура("Выражение, Псевдоним, СодержитАгрегатнуюФункцию", ПутьКПолю, "", Ложь));
			Возврат ЭтотОбъект;
		КонецЕсли;
		Состав = СтрРазделить(ПутьКПолю, ".");
		ПоследнийИндекс = Состав.ВГраница();
		ИмяПоля = Состав[ПоследнийИндекс];
		Источник = ЗапросПакета.ДоступныеИсточники[Состав[0]];
		Если НЕ ЗначениеЗаполнено(Источник) ИЛИ НЕ Источник.Таблица.Свойство("ИмяТаблицы") Тогда
			Выражение = ПутьКПолю;
			ЗапросПакета.ВыбранныеПоля.Добавить(Новый Структура("Выражение, Псевдоним, СодержитАгрегатнуюФункцию", Выражение, ?(ЗначениеЗаполнено(Псевдоним), Псевдоним, Псевдоним(Выражение)), СодержитАгрегатнуюФункцию(Выражение)));
			Возврат ЭтотОбъект;
		КонецЕсли;
		Таблица = Источник.Таблица;
		Поле = Таблица.Поля[ИмяПоля];
		Выражение = Источник.Псевдоним + "." + Поле.ИмяПоляХранения;
		ЗапросПакета.ВыбранныеПоля.Добавить(Новый Структура("Выражение, Псевдоним, СодержитАгрегатнуюФункцию", Выражение, ?(ЗначениеЗаполнено(Псевдоним), Псевдоним, ИмяПоля), СодержитАгрегатнуюФункцию(Выражение)));
	Исключение
		Выражение = ПутьКПолю;
		ЗапросПакета.ВыбранныеПоля.Добавить(Новый Структура("Выражение, Псевдоним, СодержитАгрегатнуюФункцию", Выражение, ?(ЗначениеЗаполнено(Псевдоним), Псевдоним, Псевдоним(Выражение)), СодержитАгрегатнуюФункцию(Выражение)));
	КонецПопытки;
	Возврат ЭтотОбъект;
КонецФункции

Функция Отбор(Выражение) Экспорт
	ЗапросПакета.Отборы.Добавить(Новый Структура("Выражение, СодержитАгрегатнуюФункцию", Выражение, СодержитАгрегатнуюФункцию(Выражение)));
	Возврат ЭтотОбъект;
КонецФункции

Функция УсловиеСвязи(Выражение) Экспорт
	Соединение.Условия.Добавить(Выражение);
	Возврат ЭтотОбъект;
КонецФункции

Функция Связь(СоответствиеПолей) Экспорт
	Для Каждого ПоляСвязи Из ОбщийКлиентСервер.Массив(СоответствиеПолей) Цикл
		Поля = СтрРазделить(ПоляСвязи, "=");
		ИсточникСлева = ЗапросПакета.ДоступныеИсточники[Соединение.ИсточникСлева];
		ИсточникСправа = ЗапросПакета.ДоступныеИсточники[Соединение.ИсточникСправа];
		ИмяПоляСлева = ?(ИсточникСлева.Таблица.Свойство("ИмяТаблицы"), ИмяПоляХранения(Соединение.ИсточникСлева + "." + Поля[0]), Соединение.ИсточникСлева + "." + Поля[0]);
		ИмяПоляСправа = ?(ИсточникСправа.Таблица.Свойство("ИмяТаблицы"), ИмяПоляХранения(Соединение.ИсточникСправа + "." + Поля[Поля.ВГраница()]), Соединение.ИсточникСправа + "." + Поля[Поля.ВГраница()]);
		УсловиеСвязи(СтрШаблон("%1 = %2", ИмяПоляСлева, ИмяПоляСправа));
	КонецЦикла;
	Возврат ЭтотОбъект;
КонецФункции

Функция Псевдоним(ПутьКПолю)
	Состав = СтрРазделить(ПутьКПолю, ".");
	Если Состав.ВГраница() = 0 Тогда
		Возврат ПутьКПолю;
	КонецЕсли;
	Состав.Удалить(0);
	Возврат СтрСоединить(Состав, "");
КонецФункции

Функция ИмяПоляХранения(ПутьКПолю) Экспорт
	Состав = СтрРазделить(ПутьКПолю, ".");
	ПоследнийИндекс = Состав.ВГраница();
	ИмяПоля = Состав[ПоследнийИндекс];
	Источник = ЗапросПакета.ДоступныеИсточники[Состав[0]];
	Таблица = Источник.Таблица;
	Возврат Источник.Псевдоним + "." + Таблица.Поля[ИмяПоля].ИмяПоляХранения;
КонецФункции

Функция ИдентификаторПеречисления(ПутьКПолю)
	Состав = СтрРазделить(ПутьКПолю, ".");
	Вид = Состав[0];
	ПоследнийИндекс = Состав.ВГраница();
	ИмяПоля = Состав[ПоследнийИндекс];
	Состав.Удалить(ПоследнийИндекс);
	ПолноеИмя = СтрСоединить(Состав, ".");
	Если Вид = "Перечисление" Тогда
		Таблица = Таблицы[ПолноеИмя];
		Если НЕ ЗначениеЗаполнено(Таблица) Тогда
			ИспользоватьМетаданные(Метаданные.Перечисления);
			Таблица = Таблицы[ПолноеИмя];
		КонецЕсли;
		Возврат РаботаС_ADODB.HexToBin(Таблица[ИмяПоля]);
	Иначе
		ВызватьИсключение "Неизвестный путь к данным значения " + ПутьКПолю;
	КонецЕсли;
КонецФункции

Функция ИД(Ссылка) Экспорт
	_Метаданные = Ссылка.Метаданные();
	ПолноеИмя = _Метаданные.ПолноеИмя();
	Если СтрНачинаетсяС(ПолноеИмя, "Перечисление.") Тогда
		ИмяПеречисления = _Метаданные.ЗначенияПеречисления[Перечисления[_Метаданные.Имя].Индекс(Ссылка)].Имя;
		Возврат ИдентификаторПеречисления(ПолноеИмя + "." + ИмяПеречисления);
	КонецЕсли;
	Возврат РаботаС_ADODB.HexToBin(Строка(Ссылка.УникальныйИдентификатор()));
КонецФункции

Процедура ДобавитьИсточник(Строки, Источник, Уровень)
	Перем Соединение;
	СтрокаОтступа = СтроковыеФункцииКлиентСервер.СформироватьСтрокуСимволов(Символы.Таб, Уровень + 1);
	НайденныеСоединения = РаботаСМассивом.АТДМассив(ЗапросПакета.Соединения)
		.Отобрать(СтрШаблон("Элемент.ИсточникСлева = '%1'", Источник.Псевдоним))
		.ВМассив()
	;
	Для Каждого Соединение Из НайденныеСоединения Цикл
		ИсточникСправа = РаботаСМассивом.АТДМассив(ЗапросПакета.Источники)
			.НайтиЭлемент(СтрШаблон("Элемент.Псевдоним = '%1'", Соединение.ИсточникСправа))
		;
		СхемаИсточникаСправа = ИсточникСправа.Схема;
		Строки.Добавить(СтрокаОтступа + СтрШаблон("%1 JOIN %2", Соединение.ТипСоединения, СтрШаблон("%1 AS %2", ?(ЗначениеЗаполнено(СхемаИсточникаСправа), СхемаИсточникаСправа + ".", "") + ИсточникСправа.Таблица.ИмяТаблицыХранения, ИсточникСправа.Псевдоним)));
		Строки.Добавить(СтрокаОтступа + СтрШаблон("ON %1", СтрСоединить(Соединение.Условия, " AND ")));
		ДобавитьИсточник(Строки, ИсточникСправа, Уровень + 1);
	КонецЦикла;
КонецПроцедуры	

Функция СекцияОператор()
	Строки = Новый Массив;
	Если ЗначениеЗаполнено(ЗапросПакета.КоличествоПолучаемыхЗаписей) Тогда
		Строки.Добавить(СтрШаблон("TOP %1", Формат(ЗапросПакета.КоличествоПолучаемыхЗаписей, "ЧГ=")));
	КонецЕсли;
	Если ЗапросПакета.ВыбиратьРазличные Тогда
		Строки.Добавить("DISTINCT");
	КонецЕсли;
	Возврат "SELECT " + СтрСоединить(Строки, " ");
КонецФункции

Функция СекцияВыбранныеПоля()
	Строки = Новый Массив;
	СтрокаОтступа = СтроковыеФункцииКлиентСервер.СформироватьСтрокуСимволов(Символы.Таб, 1);
	Для Каждого ОписаниеПоля Из ЗапросПакета.ВыбранныеПоля Цикл
		Если ЗначениеЗаполнено(ОписаниеПоля.Псевдоним) Тогда
			Строки.Добавить(СтрШаблон("%1 AS %2", ОписаниеПоля.Выражение, ОписаниеПоля.Псевдоним));
		Иначе
			Строки.Добавить(ОписаниеПоля.Выражение);
		КонецЕсли;
	КонецЦикла;
	Возврат СтрокаОтступа + СтрСоединить(Строки, Символы.ПС + СтрокаОтступа + ", ");
КонецФункции

Функция ИсточникИзКоллекции(Источник)
	Таблица = Источник.Таблица.Источник;
	Колонки = Таблица.Колонки;
	СтрокиЗначений = Новый Массив;
	Для Каждого СтрокаЗначений Из Таблица.Строки Цикл
		Значения = Новый Массив;
		Для ИндексКолонки = 0 По Колонки.ВГраница() Цикл
			Колонка = Колонки[ИндексКолонки];
			Значение = СтрокаЗначений[ИндексКолонки];
			Если СтрНачинаетсяС(Колонка.ТипЗначения, "СТРОКА") ИЛИ СтрНачинаетсяС(Колонка.ТипЗначения, "ДАТА") Тогда
				Если СтрНачинаетсяС(Значение, "0x") Тогда
					Значения.Добавить(Значение);
				Иначе
					Значения.Добавить(СтрШаблон("'%1'", Значение));
				КонецЕсли;
			ИначеЕсли СтрНачинаетсяС(Колонка.ТипЗначения, "ЧИСЛО") Тогда
				Значения.Добавить(Формат(Значение, "ЧН=0; ЧГ="));
			Иначе
				Значения.Добавить(Значение);
			КонецЕсли;
		КонецЦикла;
		СтрокиЗначений.Добавить("(" + СтрСоединить(Значения, ", ") + ")");
	КонецЦикла;
	СтрокиЗапроса = Новый Массив;
	СтрокиЗапроса.Добавить("(VALUES");
	СтрокиЗапроса.Добавить(Символы.Таб + Символы.Таб + СтрСоединить(СтрокиЗначений, Символы.ПС + Символы.Таб + Символы.Таб + ", "));
	СтрокиЗапроса.Добавить(Символы.Таб + СтрШаблон(") AS %1 (%2)", Источник.Псевдоним, СтрСоединить(РаботаСМассивом.АТДМассив(Колонки)
		.Отобразить("Элемент.Имя")
		.ВМассив(), ", ")
	));
	Возврат СтрСоединить(СтрокиЗапроса, Символы.ПС);
КонецФункции

Функция СекцияИсточники()
	СтрокаОтступа = СтроковыеФункцииКлиентСервер.СформироватьСтрокуСимволов(Символы.Таб, 1);
	СтрокиИсточников = Новый Массив;
	Для Каждого Источник Из ЗапросПакета.Источники Цикл
		СхемаИсточника = Источник.Схема;
		НайденныеСоединения = РаботаСМассивом.АТДМассив(ЗапросПакета.Соединения)
			.Отобрать(СтрШаблон("Элемент.ИсточникСправа = '%1'", Источник.Псевдоним))
			.ВМассив()
		;
		Если ЗначениеЗаполнено(НайденныеСоединения) Тогда
			Продолжить;//  Этот источник является участником соединения справа
		КонецЕсли;
		СтрокиСоединений = Новый Массив;
		Если Источник.Таблица.Свойство("Источник") Тогда
			СтрокиСоединений.Добавить(ИсточникИзКоллекции(Источник));
			ДобавитьИсточник(СтрокиСоединений, Источник, 1);
			СтрокиИсточников.Добавить(СтрСоединить(СтрокиСоединений, Символы.ПС));
		Иначе
			СтрокиСоединений.Добавить(СтрШаблон("%1 AS %2", ?(ЗначениеЗаполнено(СхемаИсточника), СхемаИсточника + ".", "") + Источник.Таблица.ИмяТаблицыХранения, Источник.Псевдоним));
			ДобавитьИсточник(СтрокиСоединений, Источник, 1);
			СтрокиИсточников.Добавить(СтрСоединить(СтрокиСоединений, Символы.ПС));
		КонецЕсли;
	КонецЦикла;
	Строки = Новый Массив;
	Строки.Добавить(СтрокаОтступа + СтрСоединить(СтрокиИсточников, Символы.ПС + ", "));
	Возврат СтрСоединить(Строки, Символы.ПС);
КонецФункции

Функция СекцияОтборы(Выражения)
	СтрокаОтступа = СтроковыеФункцииКлиентСервер.СформироватьСтрокуСимволов(Символы.Таб, 1);
	Строки = Новый Массив;
	Строки.Добавить(СтрокаОтступа + СтрСоединить(Выражения, Символы.ПС + СтрокаОтступа + " AND "));
	Возврат СтрСоединить(Строки, Символы.ПС);
КонецФункции

Функция СекцияОтборыСАгрегатнойФункцией()
	Строки = Новый Массив;
	СтрокаОтступа = СтроковыеФункцииКлиентСервер.СформироватьСтрокуСимволов(Символы.Таб, 1);
	Строки.Добавить("HAVING");
	Строки.Добавить(СтрокаОтступа + СтрСоединить(РаботаСМассивом.АТДМассив(ЗапросПакета.Отборы)
		.Отобрать("Элемент.СодержитАгрегатнуюФункцию")
		.Отобразить("Элемент.Выражение")
		.ВМассив(), Символы.ПС + СтрокаОтступа + " AND "));
	Возврат СтрСоединить(Строки, Символы.ПС);
КонецФункции

Функция СекцияПорядок()
	Строки = Новый Массив;
	СтрокаОтступа = СтроковыеФункцииКлиентСервер.СформироватьСтрокуСимволов(Символы.Таб, 1);
	Строки.Добавить("ORDER BY");
	Строки.Добавить(СтрокаОтступа + СтрСоединить(РаботаСМассивом.АТДМассив(ЗапросПакета.ВыраженияПорядка)
		.Отобразить("Элемент.Выражение + ?(ЗначениеЗаполнено(Элемент.Направление), ' ' + Элемент.Направление, '')")
		.ВМассив(), ", ")
	);
	Возврат СтрСоединить(Строки, Символы.ПС);
КонецФункции

Функция СекцияГруппировка(ПоляБезАгрегатныхФункций)
	Строки = Новый Массив;
	СтрокаОтступа = СтроковыеФункцииКлиентСервер.СформироватьСтрокуСимволов(Символы.Таб, 1);
	Строки.Добавить("GROUP BY");
	Строки.Добавить(СтрокаОтступа + СтрСоединить(РаботаСМассивом.АТДМассив(ПоляБезАгрегатныхФункций)
		.Отобразить("Элемент.Выражение")
		.ВМассив(), ", ")
	);
	Возврат СтрСоединить(Строки, Символы.ПС);
КонецФункции

Функция ПолучитьТекстЗапроса() Экспорт
	//  Сборка запроса
	СтрокиЗапроса = Новый Массив;
	Если ЗначениеЗаполнено(ЗапросПакета.ИмяУдаляемойТаблицы) Тогда
		Если ЗапросПакета.Источники.Количество() = 0 Тогда
			Возврат СтрШаблон("DROP TABLE %1", ЗапросПакета.ИмяУдаляемойТаблицы);
		КонецЕсли;
		СтрокиЗапроса.Добавить(СтрШаблон("DELETE %1", ЗапросПакета.ИмяУдаляемойТаблицы));
	КонецЕсли;
	Если ЗначениеЗаполнено(ЗапросПакета.ИзменяемаяТаблица) Тогда
		СтрокиЗапроса.Добавить("UPDATE " + ЗапросПакета.ИзменяемаяТаблица);
		Источник = ЗапросПакета.ДоступныеИсточники[ЗапросПакета.ИзменяемаяТаблица];
		Если Источник.Таблица.Свойство("ИмяТаблицы") Тогда
			ТаблицаИсточника = Источник.Таблица;
		КонецЕсли;
		Для Каждого Поле Из ЗапросПакета.ИзменяемыеПоля Цикл
			Если ЗначениеЗаполнено(ТаблицаИсточника) Тогда
				ИмяПоля = ТаблицаИсточника.Поля[Поле.ИмяПоля].ИмяПоляХранения;
			Иначе
				ИмяПоля = Поле.ИмяПоля;
			КонецЕсли;
			СтрокиЗапроса.Добавить(СтрШаблон("	SET %1 = %2", ИмяПоля, Поле.Выражение));
		КонецЦикла;
	Иначе
		Если ЗапросПакета.ИспользоватьЗапросКакВременнуюТаблицу Тогда
			ЗапросПакета.ИспользоватьЗапросКакВременнуюТаблицу = Ложь;
			ИмяВременнойТаблицы = ЗапросПакета.ИмяВременнойТаблицы;
			ЗапросПакета.ИмяВременнойТаблицы = "";
			ТекстЗапроса = ПолучитьТекстЗапроса();
			ЗапросПакета.ИспользоватьЗапросКакВременнуюТаблицу = Истина;
			ЗапросПакета.ИмяВременнойТаблицы = ИмяВременнойТаблицы;
			Возврат СтрШаблон("WITH %1 AS (%2)", ЗапросПакета.ИмяВременнойТаблицы, ТекстЗапроса);
		Иначе
			Если НЕ ЗначениеЗаполнено(ЗапросПакета.ИмяУдаляемойТаблицы) Тогда
				СтрокиЗапроса.Добавить(СекцияОператор());
				СтрокиЗапроса.Добавить(СекцияВыбранныеПоля());
			КонецЕсли;
			Если ЗначениеЗаполнено(ЗапросПакета.ИмяВременнойТаблицы) Тогда
				СтрокиЗапроса.Добавить("INTO " + ЗапросПакета.ИмяВременнойТаблицы);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Если ЗапросПакета.Источники.Количество() > 0 Тогда
		СтрокиЗапроса.Добавить("FROM");
		СтрокиЗапроса.Добавить(СекцияИсточники());
	КонецЕсли;
	ВыраженияОтборовБезАгрегатнойФункции = РаботаСМассивом.АТДМассив(ЗапросПакета.Отборы)
		.Отобрать("НЕ Элемент.СодержитАгрегатнуюФункцию")
		.Отобразить("Элемент.Выражение")
		.ВМассив()
	;
	ВыраженияОтборовСАгрегатнойФункцией = РаботаСМассивом.АТДМассив(ЗапросПакета.Отборы)
		.Отобрать("Элемент.СодержитАгрегатнуюФункцию")
		.Отобразить("Элемент.Выражение")
		.ВМассив()
	;
	Если ВыраженияОтборовБезАгрегатнойФункции.Количество() > 0 Тогда
		СтрокиЗапроса.Добавить("WHERE");
		СтрокиЗапроса.Добавить(СекцияОтборы(ВыраженияОтборовБезАгрегатнойФункции));
	КонецЕсли;
	ПоляСАгрегатнойФункцией = РаботаСМассивом.АТДМассив(ЗапросПакета.ВыбранныеПоля)
		.Отобрать("Элемент.СодержитАгрегатнуюФункцию")
		.ВМассив()
	;
	Если ПоляСАгрегатнойФункцией.Количество() > 0 И ПоляСАгрегатнойФункцией.Количество() <> ЗапросПакета.ВыбранныеПоля.Количество() Тогда
		ПоляБезАгрегатныхФункций = РаботаСМассивом.АТДМассив(ЗапросПакета.ВыбранныеПоля)
			.Отобрать("НЕ Элемент.СодержитАгрегатнуюФункцию")
			.ВМассив()
		;
		СтрокиЗапроса.Добавить(СекцияГруппировка(ПоляБезАгрегатныхФункций));
	КонецЕсли;
	Если ВыраженияОтборовСАгрегатнойФункцией.Количество() > 0 Тогда
		СтрокиЗапроса.Добавить("HAVING");
		СтрокиЗапроса.Добавить(СекцияОтборы(ВыраженияОтборовСАгрегатнойФункцией));
	КонецЕсли;
	Если ЗапросПакета.ВыраженияПорядка.Количество() > 0 Тогда
		СтрокиЗапроса.Добавить(СекцияПорядок());
	КонецЕсли;
	ТекстЗапроса = СтрСоединить(СтрокиЗапроса, Символы.ПС);
	Возврат ТекстЗапроса;
КонецФункции

#КонецОбласти

Таблицы = Новый Соответствие;
ПакетЗапросов = Новый Массив;