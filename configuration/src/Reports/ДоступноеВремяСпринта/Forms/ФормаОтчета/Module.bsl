///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если НЕ Параметры.Свойство("ДатаНачала") Тогда
		ТекстСообщения = "Отчет не предназначен для непосредственного использования.";
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	ДатаНачала = Параметры.ДатаНачала;
	ДатаОкончания = Параметры.ДатаОкончания;
	Филиал = Параметры.Филиал;
	Команда = Параметры.Команда; 
	Спринт = Параметры.Спринт;
	
	ПредставлениеДатаНачала = Формат(Параметры.ДатаНачала, "ДФ=dd.MM.yyyy"); 
	ПредставлениеДатаОкончания = Формат(Параметры.ДатаОкончания, "ДФ=dd.MM.yyyy");
	
	Заголовок = СтрШаблон("Доступное время спринта #%1 (%2 - %3)", Параметры.НомерСпринта, 
		ПредставлениеДатаНачала, ПредставлениеДатаОкончания);
	
	ЗаполнитьТаблицуДоступноеВремя(Новый СписокЗначений);  
	
	ЕстьПраво = ПравоДоступа("Изменение", Метаданные.РегистрыСведений.ДоступноеВремяСпринтов);
	Элементы.ДоступноеВремя.ИзменятьСоставСтрок = ЕстьПраво;
	Элементы.ДоступноеВремяВремя.ТолькоПросмотр = НЕ ЕстьПраво;
	Элементы.ДоступноеВремяВыборПользователей.Видимость = ЕстьПраво;
	Элементы.ФормаСохранитьИзменения.Видимость = ЕстьПраво;  
	ЗакрыватьПриВыборе = Ложь;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура ДоступноеВремяВремяПриИзменении(Элемент)  
	
	Строка = ДоступноеВремя.НайтиПоИдентификатору(Элементы.ДоступноеВремя.ТекущаяСтрока);
	Родитель = Строка.ПолучитьРодителя(); 
	Родитель.Время = Родитель.Время + Строка.Время - ТекущееВремя;
	ТекущееВремя = Строка.Время;
	Модифицированность = Истина;

КонецПроцедуры

&НаКлиенте
Процедура ДоступноеВремяПередУдалением(Элемент, Отказ)
	
	Строка = ДоступноеВремя.НайтиПоИдентификатору(Элементы.ДоступноеВремя.ТекущаяСтрока);
	Родитель = Строка.ПолучитьРодителя(); 
	
	Если Родитель <> Неопределено Тогда
		Родитель.Время = Родитель.Время - Строка.Время;
	КонецЕсли;         
	
	Модифицированность = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура ДоступноеВремяПриАктивизацииСтроки(Элемент)
	
	Если Элементы.ДоступноеВремя.ТекущаяСтрока <> Неопределено Тогда
		ТекущееВремя = Элементы.ДоступноеВремя.ТекущиеДанные.Время;     
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВыборПользователей(Команда)
	
	ВыбранныеПользователи = Новый Массив;
	
	Для Каждого СтрокаКоманда Из ДоступноеВремя.ПолучитьЭлементы() Цикл
		Для Каждого Строка Из СтрокаКоманда.ПолучитьЭлементы() Цикл
			ВыбранныеПользователи.Добавить(Строка.Пользователь);
		КонецЦикла;
	КонецЦикла;
	
	ПараметрыОткрытия = Новый Структура("ВыбранныеПользователи", ВыбранныеПользователи);
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработатьВыборПользователей", ЭтотОбъект);
	
	ОткрытьФорму("Справочник.Пользователи.Форма.МножественныйВыбор", ПараметрыОткрытия, ЭтотОбъект, , , ,
		ОписаниеОповещения, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);

КонецПроцедуры

&НаКлиенте
Процедура ЗакрытьФорму(Команда)
	
	Если Модифицированность Тогда		
		Отказ = Истина;
		Режим = РежимДиалогаВопрос.ДаНетОтмена;
		Оповещение = Новый ОписаниеОповещения("ПослеЗакрытияВопроса", ЭтотОбъект);
		ПоказатьВопрос(Оповещение, "Сохранить изменения?", Режим, 0);
	Иначе		
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьИзменения(Команда)
	
	Модифицированность = Ложь;  
	СохранитьИзмененияСервер();	
	ОбщееВремя = 0;
	
	Для Каждого СтрокаКоманда Из ДоступноеВремя.ПолучитьЭлементы() Цикл 
		ОбщееВремя = ОбщееВремя + СтрокаКоманда.Время;
	КонецЦикла;
	
	ОповеститьОВыборе(ОбщееВремя);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗаполнитьТаблицуДоступноеВремя(Знач СписокПользователей)
	
	ПостроительЗапроса = Новый ПостроительЗапроса;
	ПостроительЗапроса.Текст =
	#Область ТекстЗапроса
	"ВЫБРАТЬ
	|	ДоступноеВремяСпринтов.Пользователь КАК Пользователь,
	|	ДоступноеВремяСпринтов.Команда КАК Команда,
	|	ДоступноеВремяСпринтов.Время КАК Время
	|ПОМЕСТИТЬ ДоступноеВремяСпринтов
	|ИЗ
	|	РегистрСведений.ДоступноеВремяСпринтов КАК ДоступноеВремяСпринтов
	|ГДЕ
	|	ДоступноеВремяСпринтов.Спринт = &Спринт
	|	И &СмотретьДоступноеВремяСпринтов
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЛичныеДелаСрезПоследних.Сотрудник КАК Сотрудник,
	|	ЛичныеДелаСрезПоследних.Период КАК Период,
	|	ВЫРАЗИТЬ(ЛичныеДелаСрезПоследних.Данные КАК Справочник.Филиалы) КАК Филиал
	|ПОМЕСТИТЬ ИсторияФилиалСотрудника
	|ИЗ
	|	РегистрСведений.ЛичныеДела.СрезПоследних(&ДатаНачала, Событие = ЗНАЧЕНИЕ(Перечисление.СобытияПоЛичнымДелам.ПереведенВДругоеПодразделение)) КАК ЛичныеДелаСрезПоследних
	|ГДЕ
	|	НЕ 1 В
	|				(ВЫБРАТЬ
	|					1
	|				ИЗ
	|					ДоступноеВремяСпринтов)
	|{ГДЕ
	|	(ВЫРАЗИТЬ(ЛичныеДелаСрезПоследних.Данные КАК Справочник.Филиалы)) КАК Филиал,
	|	ЛичныеДелаСрезПоследних.Сотрудник КАК Сотрудник}
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ЛичныеДела.Сотрудник,
	|	ЛичныеДела.Период,
	|	ВЫРАЗИТЬ(ЛичныеДела.Данные КАК Справочник.Филиалы)
	|ИЗ
	|	РегистрСведений.ЛичныеДела КАК ЛичныеДела
	|ГДЕ
	|	ЛичныеДела.Период МЕЖДУ &ДатаНачала И &ДатаОкончания
	|	И ЛичныеДела.Событие = ЗНАЧЕНИЕ(Перечисление.СобытияПоЛичнымДелам.ПереведенВДругоеПодразделение)
	|	И НЕ 1 В
	|				(ВЫБРАТЬ
	|					1
	|				ИЗ
	|					ДоступноеВремяСпринтов)
	|{ГДЕ
	|	ЛичныеДела.Сотрудник КАК Сотрудник}
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ИсторияФилиалСотрудника.Сотрудник КАК Сотрудник,
	|	ИсторияФилиалСотрудника.Филиал КАК Филиал,
	|	ИсторияФилиалСотрудника.Период КАК ДатаНачала,
	|	ЕСТЬNULL(МИНИМУМ(ДОБАВИТЬКДАТЕ(ИсторияФилиалСотрудника1.Период, ДЕНЬ, -1)), &ДатаОкончания) КАК ДатаОкончания
	|ПОМЕСТИТЬ ПериодыНахожденияВФилиале
	|ИЗ
	|	ИсторияФилиалСотрудника КАК ИсторияФилиалСотрудника
	|		ЛЕВОЕ СОЕДИНЕНИЕ ИсторияФилиалСотрудника КАК ИсторияФилиалСотрудника1
	|		ПО ИсторияФилиалСотрудника.Сотрудник = ИсторияФилиалСотрудника1.Сотрудник
	|			И ИсторияФилиалСотрудника.Период < ИсторияФилиалСотрудника1.Период
	|{ГДЕ
	|	ИсторияФилиалСотрудника.Филиал КАК Филиал,
	|	ИсторияФилиалСотрудника.Сотрудник КАК Сотрудник}
	|
	|СГРУППИРОВАТЬ ПО
	|	ИсторияФилиалСотрудника.Сотрудник,
	|	ИсторияФилиалСотрудника.Филиал,
	|	ИсторияФилиалСотрудника.Период
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ПериодыНахожденияВФилиале.Сотрудник КАК Сотрудник
	|ПОМЕСТИТЬ СотрудникиФилиала
	|ИЗ
	|	ПериодыНахожденияВФилиале КАК ПериодыНахожденияВФилиале
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	КомандыСрезПоследних.Сотрудник КАК Сотрудник,
	|	ВЫРАЗИТЬ(КомандыСрезПоследних.Данные КАК Справочник.Филиалы) КАК Команда,
	|	КомандыСрезПоследних.Период КАК Период
	|ПОМЕСТИТЬ ИсторияКомандаСотрудника
	|ИЗ
	|	РегистрСведений.ЛичныеДела.СрезПоследних(
	|			&ДатаНачала,
	|			Событие = ЗНАЧЕНИЕ(Перечисление.СобытияПоЛичнымДелам.ПереведенВКоманду)
	|				И Сотрудник В
	|					(ВЫБРАТЬ
	|						СотрудникиФилиала.Сотрудник
	|					ИЗ
	|						СотрудникиФилиала)) КАК КомандыСрезПоследних
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	Команды.Сотрудник,
	|	ВЫРАЗИТЬ(Команды.Данные КАК Справочник.Филиалы),
	|	Команды.Период
	|ИЗ
	|	РегистрСведений.ЛичныеДела КАК Команды
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ СотрудникиФилиала КАК СотрудникиФилиала
	|		ПО Команды.Сотрудник = СотрудникиФилиала.Сотрудник
	|ГДЕ
	|	Команды.Период МЕЖДУ &ДатаНачала И &ДатаОкончания
	|	И Команды.Событие = ЗНАЧЕНИЕ(Перечисление.СобытияПоЛичнымДелам.ПереведенВКоманду)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ИсторияКомандаСотрудника.Сотрудник КАК Сотрудник,
	|	ИсторияКомандаСотрудника.Команда КАК Команда,
	|	ИсторияКомандаСотрудника.Период КАК ДатаНачала,
	|	ЕСТЬNULL(МИНИМУМ(ДОБАВИТЬКДАТЕ(ИсторияКомандаСотрудника1.Период, ДЕНЬ, -1)), &ДатаОкончания) КАК ДатаОкончания
	|ПОМЕСТИТЬ ПериодыНахожденияВКоманде
	|ИЗ
	|	ИсторияКомандаСотрудника КАК ИсторияКомандаСотрудника
	|		ЛЕВОЕ СОЕДИНЕНИЕ ИсторияКомандаСотрудника КАК ИсторияКомандаСотрудника1
	|		ПО ИсторияКомандаСотрудника.Сотрудник = ИсторияКомандаСотрудника1.Сотрудник
	|			И ИсторияКомандаСотрудника.Период < ИсторияКомандаСотрудника1.Период
	|
	|СГРУППИРОВАТЬ ПО
	|	ИсторияКомандаСотрудника.Сотрудник,
	|	ИсторияКомандаСотрудника.Команда,
	|	ИсторияКомандаСотрудника.Период
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	КастомныеКомандыСрезПоследних.Сотрудник КАК Сотрудник,
	|	ВЫРАЗИТЬ(КастомныеКомандыСрезПоследних.Данные КАК Справочник.Филиалы) КАК Команда,
	|	КастомныеКомандыСрезПоследних.Период КАК Период
	|ПОМЕСТИТЬ ИсторияКастомнаяКомандаСотрудника
	|ИЗ
	|	РегистрСведений.ЛичныеДела.СрезПоследних(&ДатаНачала, Событие = ЗНАЧЕНИЕ(Перечисление.СобытияПоЛичнымДелам.ПереведенВКастомнуюКоманду)) КАК КастомныеКомандыСрезПоследних
	|ГДЕ
	|	(ВЫРАЗИТЬ(КастомныеКомандыСрезПоследних.Данные КАК Справочник.Филиалы)) = &Команда
	|	И (ВЫРАЗИТЬ(КастомныеКомандыСрезПоследних.Данные КАК Справочник.Филиалы)) <> ЗНАЧЕНИЕ(Справочник.Филиалы.ПустаяСсылка)
	|	И НЕ 1 В
	|				(ВЫБРАТЬ
	|					1
	|				ИЗ
	|					ДоступноеВремяСпринтов)
	|{ГДЕ
	|	КастомныеКомандыСрезПоследних.Сотрудник КАК Сотрудник}
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	КастомныеКоманды.Сотрудник,
	|	ВЫРАЗИТЬ(КастомныеКоманды.Данные КАК Справочник.Филиалы),
	|	КастомныеКоманды.Период
	|ИЗ
	|	РегистрСведений.ЛичныеДела КАК КастомныеКоманды
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ СотрудникиФилиала КАК СотрудникиФилиала
	|		ПО КастомныеКоманды.Сотрудник = СотрудникиФилиала.Сотрудник
	|ГДЕ
	|	КастомныеКоманды.Период МЕЖДУ &ДатаНачала И &ДатаОкончания
	|	И КастомныеКоманды.Событие = ЗНАЧЕНИЕ(Перечисление.СобытияПоЛичнымДелам.ПереведенВКастомнуюКоманду)
	|	И (ВЫРАЗИТЬ(КастомныеКоманды.Данные КАК Справочник.Филиалы)) <> ЗНАЧЕНИЕ(Справочник.Филиалы.ПустаяСсылка)
	|	И НЕ 1 В
	|				(ВЫБРАТЬ
	|					1
	|				ИЗ
	|					ДоступноеВремяСпринтов)
	|{ГДЕ
	|	КастомныеКоманды.Сотрудник КАК Сотрудник}
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ИсторияКастомнаяКомандаСотрудника.Сотрудник КАК Сотрудник,
	|	ИсторияКастомнаяКомандаСотрудника.Команда КАК Команда,
	|	ЗНАЧЕНИЕ(Справочник.Филиалы.КастомныеКоманды) КАК Филиал,
	|	ИсторияКастомнаяКомандаСотрудника.Период КАК ДатаНачала,
	|	ЕСТЬNULL(МИНИМУМ(ДОБАВИТЬКДАТЕ(ИсторияКастомнаяКомандаСотрудника1.Период, ДЕНЬ, -1)), &ДатаОкончания) КАК ДатаОкончания
	|ПОМЕСТИТЬ ПериодыНахожденияВКастомнойКоманде
	|ИЗ
	|	ИсторияКастомнаяКомандаСотрудника КАК ИсторияКастомнаяКомандаСотрудника
	|		ЛЕВОЕ СОЕДИНЕНИЕ ИсторияКастомнаяКомандаСотрудника КАК ИсторияКастомнаяКомандаСотрудника1
	|		ПО ИсторияКастомнаяКомандаСотрудника.Сотрудник = ИсторияКастомнаяКомандаСотрудника1.Сотрудник
	|			И ИсторияКастомнаяКомандаСотрудника.Период < ИсторияКастомнаяКомандаСотрудника1.Период
	|
	|СГРУППИРОВАТЬ ПО
	|	ИсторияКастомнаяКомандаСотрудника.Сотрудник,
	|	ИсторияКастомнаяКомандаСотрудника.Команда,
	|	ИсторияКастомнаяКомандаСотрудника.Период
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПроизводственныйКалендарь.ДатаКалендаря КАК ДатаКалендаря,
	|	ПроизводственныйКалендарь.КоличествоРабочихЧасов КАК КоличествоРабочихЧасов,
	|	ЕСТЬNULL(ПериодыНахожденияВКастомнойКоманде.Сотрудник, ПериодыНахожденияВФилиале.Сотрудник) КАК Сотрудник,
	|	ЕСТЬNULL(ПериодыНахожденияВКастомнойКоманде.Филиал, ПериодыНахожденияВФилиале.Филиал) КАК Филиал,
	|	ЕСТЬNULL(ПериодыНахожденияВКастомнойКоманде.Команда, ЕСТЬNULL(ПериодыНахожденияВКоманде.Команда, ЗНАЧЕНИЕ(Справочник.Филиалы.ПустаяСсылка))) КАК Команда
	|ПОМЕСТИТЬ ПользователиСДнямиКалендаря
	|ИЗ
	|	РегистрСведений.ПроизводственныйКалендарь КАК ПроизводственныйКалендарь
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПериодыНахожденияВКастомнойКоманде КАК ПериодыНахожденияВКастомнойКоманде
	|		ПО (ПроизводственныйКалендарь.ДатаКалендаря МЕЖДУ ПериодыНахожденияВКастомнойКоманде.ДатаНачала И ПериодыНахожденияВКастомнойКоманде.ДатаОкончания)
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПериодыНахожденияВФилиале КАК ПериодыНахожденияВФилиале
	|		ПО (ПроизводственныйКалендарь.ДатаКалендаря МЕЖДУ ПериодыНахожденияВФилиале.ДатаНачала И ПериодыНахожденияВФилиале.ДатаОкончания)
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПериодыНахожденияВКоманде КАК ПериодыНахожденияВКоманде
	|		ПО (ПериодыНахожденияВФилиале.Сотрудник = ПериодыНахожденияВКоманде.Сотрудник)
	|			И (ПроизводственныйКалендарь.ДатаКалендаря МЕЖДУ ПериодыНахожденияВКоманде.ДатаНачала И ПериодыНахожденияВКоманде.ДатаОкончания)
	|ГДЕ
	|	ПроизводственныйКалендарь.ДатаКалендаря МЕЖДУ &ДатаНачала И &ДатаОкончания
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЕСТЬNULL(ПериодыНахожденияВКастомнойКоманде.Сотрудник, СотрудникиФилиала.Сотрудник) КАК Сотрудник
	|ПОМЕСТИТЬ ОтобранныеСотрудники
	|ИЗ
	|	ПериодыНахожденияВКастомнойКоманде КАК ПериодыНахожденияВКастомнойКоманде
	|		ПОЛНОЕ СОЕДИНЕНИЕ СотрудникиФилиала КАК СотрудникиФилиала
	|		ПО ПериодыНахожденияВКастомнойКоманде.Сотрудник = СотрудникиФилиала.Сотрудник
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТабельУчетаРабочегоВремени.Дата КАК Дата,
	|	ТабельУчетаРабочегоВремени.Сотрудник КАК Сотрудник,
	|	МАКСИМУМ(ТабельУчетаРабочегоВремени.ПриоритетДляТабеля) КАК ПриоритетДляТабеля
	|ПОМЕСТИТЬ АктуальныеЗаписиТабеля
	|ИЗ
	|	РегистрСведений.ТабельУчетаРабочегоВремени КАК ТабельУчетаРабочегоВремени
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ОтобранныеСотрудники КАК ОтобранныеСотрудники
	|		ПО ТабельУчетаРабочегоВремени.Сотрудник = ОтобранныеСотрудники.Сотрудник
	|ГДЕ
	|	ТабельУчетаРабочегоВремени.Дата МЕЖДУ &ДатаНачала И &ДатаОкончания
	|
	|СГРУППИРОВАТЬ ПО
	|	ТабельУчетаРабочегоВремени.Дата,
	|	ТабельУчетаРабочегоВремени.Сотрудник
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТабельУчетаРабочегоВремени.Дата КАК Дата,
	|	ТабельУчетаРабочегоВремени.Сотрудник КАК Сотрудник,
	|	ТабельУчетаРабочегоВремени.ОтработаноЧасов КАК ОтработаноЧасов,
	|	ТабельУчетаРабочегоВремени.ВидВремени КАК ВидВремени
	|ПОМЕСТИТЬ ПриведенныйТабельУчетаРабочегоВремени
	|ИЗ
	|	РегистрСведений.ТабельУчетаРабочегоВремени КАК ТабельУчетаРабочегоВремени
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ АктуальныеЗаписиТабеля КАК АктуальныеЗаписиТабеля
	|		ПО ТабельУчетаРабочегоВремени.Дата = АктуальныеЗаписиТабеля.Дата
	|			И ТабельУчетаРабочегоВремени.Сотрудник = АктуальныеЗаписиТабеля.Сотрудник
	|			И ТабельУчетаРабочегоВремени.ПриоритетДляТабеля = АктуальныеЗаписиТабеля.ПриоритетДляТабеля
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПользователиСДнямиКалендаря.Команда КАК Команда,
	|	ПользователиСДнямиКалендаря.Сотрудник КАК Пользователь,
	|	ВЫРАЗИТЬ(СУММА(ВЫБОР
	|				КОГДА НЕ ОтсутствияСотрудниковНаРабочемМесте.Сотрудник ЕСТЬ NULL
	|					ТОГДА 0
	|				КОГДА НЕ ТабельУчетаРабочегоВремени.Сотрудник ЕСТЬ NULL
	|					ТОГДА ВЫБОР
	|							КОГДА КлассификаторИспользованияРабочегоВремени.РабочееВремя
	|								ТОГДА ТабельУчетаРабочегоВремени.ОтработаноЧасов
	|							ИНАЧЕ 0
	|						КОНЕЦ
	|				ИНАЧЕ ПользователиСДнямиКалендаря.КоличествоРабочихЧасов
	|			КОНЕЦ) * 0.8 КАК ЧИСЛО(10, 1)) КАК Время
	|ПОМЕСТИТЬ ПланируемоеВремяПоСотрудникамДатам
	|ИЗ
	|	ПользователиСДнямиКалендаря КАК ПользователиСДнямиКалендаря
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ОтсутствияСотрудниковНаРабочемМесте КАК ОтсутствияСотрудниковНаРабочемМесте
	|		ПО ПользователиСДнямиКалендаря.ДатаКалендаря = ОтсутствияСотрудниковНаРабочемМесте.ДатаОтсутствия
	|			И ПользователиСДнямиКалендаря.Сотрудник = ОтсутствияСотрудниковНаРабочемМесте.Сотрудник
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПриведенныйТабельУчетаРабочегоВремени КАК ТабельУчетаРабочегоВремени
	|		ПО (ТабельУчетаРабочегоВремени.Дата = ПользователиСДнямиКалендаря.ДатаКалендаря)
	|			И (ТабельУчетаРабочегоВремени.Сотрудник = ПользователиСДнямиКалендаря.Сотрудник)
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.КлассификаторИспользованияРабочегоВремени КАК КлассификаторИспользованияРабочегоВремени
	|		ПО (ТабельУчетаРабочегоВремени.ВидВремени = КлассификаторИспользованияРабочегоВремени.Ссылка)
	|{ГДЕ
	|	ПользователиСДнямиКалендаря.Команда КАК Команда}
	|
	|СГРУППИРОВАТЬ ПО
	|	ПользователиСДнямиКалендаря.Команда,
	|	ПользователиСДнямиКалендаря.Сотрудник
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ДоступноеВремяСпринтов.Команда,
	|	ДоступноеВремяСпринтов.Пользователь,
	|	ДоступноеВремяСпринтов.Время
	|ИЗ
	|	ДоступноеВремяСпринтов КАК ДоступноеВремяСпринтов
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВЫБОР
	|		КОГДА ПланируемоеВремяПоСотрудникамДатам.Команда = ЗНАЧЕНИЕ(Справочник.Филиалы.ПустаяСсылка)
	|			ТОГДА ""Нет команды""
	|		ИНАЧЕ ПланируемоеВремяПоСотрудникамДатам.Команда
	|	КОНЕЦ КАК КомандаРазработчиков,
	|	ПланируемоеВремяПоСотрудникамДатам.Команда КАК КомандаСсылка,
	|	ПланируемоеВремяПоСотрудникамДатам.Пользователь КАК Пользователь,
	|	ПланируемоеВремяПоСотрудникамДатам.Время КАК Время,
	|	ЕСТЬNULL(СправочникКоманды.Наименование, """") КАК КомандаНаименование
	|ПОМЕСТИТЬ КомандаПользователь
	|ИЗ
	|	ПланируемоеВремяПоСотрудникамДатам КАК ПланируемоеВремяПоСотрудникамДатам
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Филиалы КАК СправочникКоманды
	|		ПО (СправочникКоманды.Ссылка = ПланируемоеВремяПоСотрудникамДатам.Команда)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	КомандаПользователь.КомандаРазработчиков КАК КомандаРазработчиков,
	|	КомандаПользователь.КомандаСсылка КАК КомандаСсылка,
	|	КомандаПользователь.Время КАК Время,
	|	Пользователи.Ссылка КАК ПользовательСсылка,
	|	Пользователи.Наименование КАК Пользователь
	|ИЗ
	|	КомандаПользователь КАК КомандаПользователь
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Пользователи КАК Пользователи
	|		ПО (Пользователи.Ссылка = КомандаПользователь.Пользователь)
	|
	|УПОРЯДОЧИТЬ ПО
	|	КомандаПользователь.КомандаНаименование,
	|	Пользователь
	|ИТОГИ
	|	МАКСИМУМ(КомандаСсылка)
	|ПО
	|	КомандаРазработчиков";	
	#КонецОбласти
	
	ПостроительЗапроса.Параметры.Вставить("ДатаНачала", ДатаНачала);
	ПостроительЗапроса.Параметры.Вставить("ДатаОкончания", ДатаОкончания); 
	ПостроительЗапроса.Параметры.Вставить("Спринт", Спринт);
	ПостроительЗапроса.Параметры.Вставить("Команда", Команда);
	ПостроительЗапроса.Параметры.Вставить("СмотретьДоступноеВремяСпринтов", СписокПользователей.Количество() = 0);	
	
	Если СписокПользователей.Количество() > 0 Тогда
		ЭлементОтбора = ПостроительЗапроса.Отбор.Добавить("Сотрудник");
		ЭлементОтбора.ВидСравнения  = ВидСравнения.ВСписке;
		ЭлементОтбора.Значение      = СписокПользователей;
		ЭлементОтбора.Использование = Истина;
	Иначе
		ЭлементОтбора = ПостроительЗапроса.Отбор.Добавить("Филиал");
		ЭлементОтбора.ВидСравнения  = ВидСравнения.Равно;
		ЭлементОтбора.Значение      = Филиал;
		ЭлементОтбора.Использование = Истина;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Команда) Тогда
		ЭлементОтбора = ПостроительЗапроса.Отбор.Добавить("Команда");
		ЭлементОтбора.ВидСравнения  = ВидСравнения.Равно;
		ЭлементОтбора.Значение      = Команда;
		ЭлементОтбора.Использование = Истина;
	КонецЕсли;
	
	ПостроительЗапроса.Выполнить();	
	РезультатЗапроса = ПостроительЗапроса.Результат;
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	КартинкаГруппа = БиблиотекаКартинок.ГруппаПользователей;
	КартинкаПользователь = БиблиотекаКартинок.Пользователь;
	Дерево = РеквизитФормыВЗначение("ДоступноеВремя");
	
	Пока Выборка.Следующий() Цикл             
		
		НоваяКоманда = Дерево.Строки.Найти(Выборка.КомандаСсылка, "Команда");  
		
		Если НоваяКоманда = Неопределено Тогда
			НоваяКоманда = Дерево.Строки.Добавить();
			НоваяКоманда.КартинкаСтроки = КартинкаГруппа;
			НоваяКоманда.КомандаПользователь = Выборка.КомандаРазработчиков;
			НоваяКоманда.Команда = Выборка.КомандаСсылка;
		КонецЕсли;
		
		ВыборкаПользователей = Выборка.Выбрать();
		
		Пока ВыборкаПользователей.Следующий() Цикл
			
			НоваяСтрока = НоваяКоманда.Строки.Найти(ВыборкаПользователей.ПользовательСсылка, "Пользователь");  
			
			Если НоваяСтрока = Неопределено Тогда
				НоваяСтрока = НоваяКоманда.Строки.Добавить();
				НоваяСтрока.КартинкаСтроки = КартинкаПользователь;
				НоваяСтрока.КомандаПользователь = ВыборкаПользователей.Пользователь;
				НоваяСтрока.Пользователь = ВыборкаПользователей.ПользовательСсылка;
				НоваяСтрока.Команда = ВыборкаПользователей.КомандаСсылка;
				НоваяСтрока.Время = ВыборкаПользователей.Время;
			КонецЕсли;
		КонецЦикла;   
		
		НоваяКоманда.Строки.Сортировать("КомандаПользователь");
		НоваяКоманда.Время = НоваяКоманда.Строки.Итог("Время");
	КонецЦикла;  
	
	ЗначениеВРеквизитФормы(Дерево, "ДоступноеВремя");
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьВыборПользователей(Результат, ДополнительныеПараметры) Экспорт
		
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Кэш = Новый Массив; 
	Добавленные = Новый СписокЗначений;
	
	// Удаляю строки, которых нет в подборе
	Для Каждого СтрокаКоманда Из ДоступноеВремя.ПолучитьЭлементы() Цикл  
		
		СтрокиСотрудник = СтрокаКоманда.ПолучитьЭлементы();
		
		Для Счетчик = -СтрокиСотрудник.Количество() + 1 По 0 Цикл
			
			Строка = СтрокиСотрудник[-Счетчик];
			
			Если Результат.Найти(Строка.Пользователь) = Неопределено Тогда
				СтрокаКоманда.Время = СтрокаКоманда.Время - Строка.Время; 
				СтрокиСотрудник.Удалить(Строка);
			Иначе
				Кэш.Добавить(Строка.Пользователь);
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;     
	
	// Теперь определяю добавленых и у них заполняю время и команду
	Для Каждого Пользователь Из Результат Цикл
		Если Кэш.Найти(Пользователь) = Неопределено Тогда
			Добавленные.Добавить(Пользователь);
		КонецЕсли;
	КонецЦикла; 
	
	Если Добавленные.Количество() > 0 Тогда
		ЗаполнитьТаблицуДоступноеВремя(Добавленные);
	КонецЕсли;
	
	Для Каждого СтрокаКоманда Из ДоступноеВремя.ПолучитьЭлементы() Цикл  
		Элементы.ДоступноеВремя.Развернуть(СтрокаКоманда.ПолучитьИдентификатор());
	КонецЦикла;
	
	Модифицированность = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗакрытияВопроса(Результат, Параметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		СохранитьИзменения(Неопределено);
	КонецЕсли;
	
	Если Результат <> КодВозвратаДиалога.Отмена Тогда		
		Модифицированность = Ложь;      
		ЗакрытьФорму(Неопределено);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура СохранитьИзмененияСервер() 
	
	Набор = РегистрыСведений.ДоступноеВремяСпринтов.СоздатьНаборЗаписей();
	Набор.Отбор.Спринт.Установить(Спринт);
	
	Для Каждого СтрокаКоманда Из ДоступноеВремя.ПолучитьЭлементы() Цикл
		Для Каждого Строка Из СтрокаКоманда.ПолучитьЭлементы() Цикл    
			НоваяЗапись = Набор.Добавить();
			НоваяЗапись.Спринт = Спринт;
			НоваяЗапись.Пользователь = Строка.Пользователь;
			НоваяЗапись.Команда = Строка.Команда;
			НоваяЗапись.Время = Строка.Время;
		КонецЦикла;
	КонецЦикла;
	
	Набор.Записать();
	
КонецПроцедуры

#КонецОбласти
