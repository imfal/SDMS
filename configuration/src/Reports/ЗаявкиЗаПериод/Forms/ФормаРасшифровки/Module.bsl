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
	
	РегистрыСведений.ОтслеживаниеИспользованияФункциональности.ОткрытиеФормы(ЭтотОбъект.ИмяФормы);

	ДатаНачало = Параметры.ДатаНачало;
	ДатаОкончание = Параметры.ДатаОкончание;
	
	Если Параметры.Свойство("Направление") Тогда
		Направление = Параметры.Направление;
	КонецЕсли;
	Если Параметры.Свойство("Автор") Тогда
		Автор = Параметры.Автор;
	КонецЕсли;
	Если Параметры.Свойство("Система") Тогда
		Система = Параметры.Система;
	КонецЕсли;
	Если Параметры.Свойство("ГруппаЗаказчиков") Тогда
		ГруппаЗаказчиков = Параметры.ГруппаЗаказчиков;
	КонецЕсли;
	
	СформироватьОтчет();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура ТаблицаРасшифровкиОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка, ДополнительныеПараметры)
	
	СтандартнаяОбработка = Ложь;	
	ПараметрыРасшифровки = ОбщегоНазначенияВызовСервера.ПолучитьПараметрыРасшифровки(ДанныеРасшифровки, Расшифровка);
	
	Если ПараметрыРасшифровки.Свойство("Заявка") Тогда
		ПоказатьЗначение(, ПараметрыРасшифровки.Заявка);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура НайтиЗначениеПараметраСКД(Знач ИмяПараметра, Знач ЗначениеПараметра, Знач НастройкиСКД)
	
	Параметр = НастройкиСКД.ПараметрыДанных.НайтиЗначениеПараметра(
		Новый ПараметрКомпоновкиДанных(ИмяПараметра));
	
	Если ЗначениеПараметра.Количество() > 0 Тогда 		
		Параметр.Значение = ЗначениеПараметра;
		Параметр.Использование = Истина;
	Иначе
		Параметр.Использование = Ложь;
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ИнициализироватьДополнительныеНастройкиСКД(СхемаКомпоновкиДанных, НастройкиСКД)
	
	Если ЗначениеЗаполнено(ДатаНачало) Тогда
		ПараметрДатаНачала = НастройкиСКД.ПараметрыДанных.НайтиЗначениеПараметра(
			Новый ПараметрКомпоновкиДанных("ДатаНачало"));	
		ПараметрДатаНачала.Значение = НачалоМесяца(ДатаНачало);
		ПараметрДатаНачала.Использование = Истина;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ДатаОкончание) Тогда
		ПараметрДатаОкончания = НастройкиСКД.ПараметрыДанных.НайтиЗначениеПараметра(
			Новый ПараметрКомпоновкиДанных("ДатаОкончание"));	
		ПараметрДатаОкончания.Значение = КонецМесяца(ДатаОкончание);
		ПараметрДатаОкончания.Использование = Истина;
	КонецЕсли;
		
	НайтиЗначениеПараметраСКД("Направление", Направление, НастройкиСКД);
	НайтиЗначениеПараметраСКД("Автор", Автор, НастройкиСКД);
	НайтиЗначениеПараметраСКД("Система", Система, НастройкиСКД);
	НайтиЗначениеПараметраСКД("ГруппаЗаказчиков", ГруппаЗаказчиков, НастройкиСКД);	
	
КонецПроцедуры

&НаСервере
Процедура СформироватьОтчет()
	
	НастройкиОтчета = Новый Структура;
	
	НастройкиОтчета.Вставить("ДатаНачало", ДатаНачало);
	НастройкиОтчета.Вставить("ДатаОкончание", ДатаОкончание);
	Если Направление.Количество() > 0 Тогда 
		НастройкиОтчета.Вставить("Направление", Направление);
	КонецЕсли;
	Если Автор.Количество() > 0 Тогда 
		НастройкиОтчета.Вставить("Автор", Автор);
	КонецЕсли;
	Если Система.Количество() > 0 Тогда 
		НастройкиОтчета.Вставить("Система", Система);
	КонецЕсли;
	Если ГруппаЗаказчиков.Количество() > 0 Тогда 
		НастройкиОтчета.Вставить("ГруппаЗаказчиков", ГруппаЗаказчиков);
	КонецЕсли;
	
	СформироватьОтчетЧерезСКД(НастройкиОтчета);

КонецПроцедуры

&НаСервере
Процедура СформироватьОтчетЧерезСКД(Знач НастройкиОтчета)
                                   
	ДанныеРасшифровкиКомпоновкиДанных = Новый ДанныеРасшифровкиКомпоновкиДанных;                            
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
		
	СхемаКомпоновкиДанных = РеквизитФормыВЗначение("Отчет").ПолучитьМакет("Расшифровка");
		
	Настройки = СхемаКомпоновкиДанных.ВариантыНастроек.Основной.Настройки;
			
	ИнициализироватьДополнительныеНастройкиСКД(СхемаКомпоновкиДанных, Настройки);
	
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, Настройки, ДанныеРасшифровкиКомпоновкиДанных);
				
	ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновки, , ДанныеРасшифровкиКомпоновкиДанных, Истина);
	
	ТаблицаРасшифровки.Очистить();
	
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ТаблицаРасшифровки);
	ПроцессорВывода.Вывести(ПроцессорКомпоновкиДанных);
		
	Элементы.ТаблицаРасшифровки.ОтображениеСостояния.Видимость = Ложь;
	Элементы.ТаблицаРасшифровки.ОтображениеСостояния.ДополнительныйРежимОтображения = 
		ДополнительныйРежимОтображения.НеИспользовать;
			
	ДанныеРасшифровки = ПоместитьВоВременноеХранилище(ДанныеРасшифровкиКомпоновкиДанных, 
		ЭтотОбъект.УникальныйИдентификатор);
		
КонецПроцедуры

#КонецОбласти
