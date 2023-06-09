#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ЗаполнитьПараметрыСоединенияТекущейБазы(Объект);
КонецПроцедуры

&НаКлиенте
Процедура СерверПриИзменении(Элемент)
	УправлениеВидимостьюДоступностью();
КонецПроцедуры

&НаКлиенте
Процедура ИмяБазыДанныхПриИзменении(Элемент)
	УправлениеВидимостьюДоступностью();
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	УправлениеВидимостьюДоступностью();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КомандаЗаполнитьПараметрыСоединенияТекущейБазы(Команда)
	ЗаполнитьПараметрыСоединенияТекущейБазы(Объект);
	УправлениеВидимостьюДоступностью();
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФормуМакетПеречисления(Команда)
	ОбщийКлиент.ОткрытьФормуПоИмени(ЭтотОбъект, "МакетПеречисления");
КонецПроцедуры

&НаКлиенте
Процедура КомандаВыполнитьЗапрос(Команда)
	Если Объект.ВыполнятьНаСервере Тогда
		КомандаВыполнитьЗапросНаСервере();
		Возврат;
	КонецЕсли;
	ТекстЗапроса = Объект.ТекстЗапроса.ПолучитьТекст(); 
	ПараметрыСоединения = РаботаС_ADODB.ПараметрыСоединения();
	ЗаполнитьЗначенияСвойств(ПараметрыСоединения, Объект);
	Таблица = ВыполнитьЗапрос(ТекстЗапроса, ПараметрыСоединения);
	Если Таблица = Неопределено Тогда
		Объект.РезультатJSON = "";
		Возврат;
	КонецЕсли;
	Объект.РезультатJSON = ОбщийКлиентСервер.ОбъектВJSON(Таблица);
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьТекстЗапроса(Команда)
	ПолучитьТекстЗапросаНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура Печать(Команда)
	Результат = ПолучитьРезультат();
	Результат.Показать();
КонецПроцедуры

&НаКлиенте
Процедура КомандаПоказатьРезультат(Команда)
	ПоказыватьРезультат = НЕ ПоказыватьРезультат;
	УправлениеВидимостьюДоступностью();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиентеНаСервереБезКонтекста
Процедура ЗаполнитьПараметрыСоединенияТекущейБазы(Объект)
	Объект.ТипСУБД = "SQLServer";
	Объект.АутентификацияNTLM = Истина;
	Объект.СмещениеДат2000 = Истина;
	СтрокаСоединения = СтрокаСоединенияИнформационнойБазы();
	Состав = СтрРазделить(СтрокаСоединения, ";");
	КлючЗначениеСервер = СтрРазделить(Состав[0], "=");
	Если КлючЗначениеСервер[0] = "Srvr" Тогда
		КлючЗначениеИмяБазыДанных = СтрРазделить(Состав[1], "=");
		Объект.Сервер = СтрЗаменить(КлючЗначениеСервер[1], """", "");
		Объект.ИмяБазыДанных = СтрЗаменить(КлючЗначениеИмяБазыДанных[1], """", "");
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПолучитьТекстЗапросаНаСервере()
	//@skip-check module-unused-local-variable
	Перем Результат;
	Если ЗначениеЗаполнено(Объект.РезультатJSON) Тогда
		Результат = ОбщийКлиентСервер.JSONВОбъект(Объект.РезультатJSON);
	КонецЕсли;
	МодельЗапросаSQL = Обработки.МодельЗапросаSQL.Создать();
	МодельЗапроса = МодельЗапросаSQL;
	//@skip-check server-execution-safe-mode
	Выполнить(Объект.ТекстМодели.ПолучитьТекст());
	Объект.ТекстЗапроса.УстановитьТекст(МодельЗапросаSQL.ПолучитьТекстЗапросаПакета());	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ВыполнитьЗапрос(ТекстЗапроса, ПараметрыСоединения)
	СоединениеADODB = РаботаС_ADODB.Соединение(
		ПараметрыСоединения.ТипСУБД, 
		ПараметрыСоединения.Сервер, 
		ПараметрыСоединения.ИмяБазыДанных, 
		ПараметрыСоединения.ИмяПользователя, 
		ПараметрыСоединения.Пароль, 
		ПараметрыСоединения.АутентификацияNTLM
	);
	Таблица = РаботаС_ADODB.ВыполнитьЗапрос(СоединениеADODB, ТекстЗапроса);
	РаботаС_ADODB.ЗакрытьСоединение(СоединениеADODB);
	Возврат Таблица;
КонецФункции

&НаСервере
Процедура ВывестиЗаголовок(ТабличныйДокумент, Заголовок)
	Секция = ТабличныйДокумент.ПолучитьОбласть("R1");
	Секция.Область("R1C1").Текст = Заголовок;
	ТабличныйДокумент.Вывести(Секция);
КонецПроцедуры

&НаСервере
Процедура ВывестиТаблицу(ТабличныйДокумент, Таблица, Заголовок)
	ВывестиЗаголовок(ТабличныйДокумент, Заголовок);	
	Построитель = Новый ПостроительОтчета;
	Построитель.ИсточникДанных = Новый ОписаниеИсточникаДанных(Таблица);       
	Построитель.Вывести(ТабличныйДокумент);
КонецПроцедуры

&НаСервере
Функция ПолучитьРезультат()
	Таблица = Общий.СтруктураВТаблицуЗначений(Объект.РезультатJSON);
	Результат = Новый ТабличныйДокумент;
	ВывестиТаблицу(Результат, Таблица, "Результат");
	Возврат Результат;
КонецФункции

&НаКлиенте
Процедура УправлениеВидимостьюДоступностью()
	Элементы.ГруппаНастройки.Заголовок = СтрШаблон("Сервер: %1, БД: %2", Объект.Сервер, Объект.ИмяБазыДанных);
	Элементы.КомандаПоказатьРезультат.Пометка = ПоказыватьРезультат;
	Элементы.РезультатJSON.Видимость = ПоказыватьРезультат;
КонецПроцедуры

&НаСервере
Процедура КомандаВыполнитьЗапросНаСервере()
	ТекстЗапроса = Объект.ТекстЗапроса.ПолучитьТекст(); 
	ПараметрыСоединения = РаботаС_ADODB.ПараметрыСоединения();
	ЗаполнитьЗначенияСвойств(ПараметрыСоединения, Объект);
	Таблица = ВыполнитьЗапрос(ТекстЗапроса, ПараметрыСоединения);
	Если Таблица = Неопределено Тогда
		Объект.РезультатJSON = "";
		Возврат;
	КонецЕсли;
	Объект.РезультатJSON = ОбщийКлиентСервер.ОбъектВJSON(Таблица);
КонецПроцедуры

#КонецОбласти
