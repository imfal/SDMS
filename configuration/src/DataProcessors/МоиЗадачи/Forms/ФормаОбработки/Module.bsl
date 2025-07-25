///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

// Пользовательские настройки
&НаКлиенте
Перем НастройкиФормы;

// Кэш вспомогательных данных
&НаКлиенте
Перем КэшДополнительныхДанных;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ВремяНачалаЗамера = ИнтеграцияДополнительныхПодсистем.НачатьЗамерВремени();
	
	ОбновляемыеТаблицы = Новый Массив;
	ОбновляемыеТаблицы.Добавить(Элементы.ЗадачиНаМне.Имя);
	ОбновляемыеТаблицы.Добавить(Элементы.ОтслеживаемыеЗадачи.Имя);
	
	Настройки = ПолучитьНастройкиФормы();
	НастроитьПодсветкуПриПриближенииСрокаРеализации();
	РаботаСПроцессами.СоздатьКнопкиПереходаСтатусов(ЭтотОбъект, Элементы.СписокСтатусов_ЗадачиНаМне);
	ИнструментыСервер.ПриСозданииНаСервере(ЭтотОбъект, ОбновляемыеТаблицы);
	АдресТаблицыВсеОтслеживаемыеЗадачи = ПоместитьВоВременноеХранилище(Неопределено, УникальныйИдентификатор);
	АдресВоВременномХранилище = ПоместитьВоВременноеХранилище(Настройки);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	НастройкиФормы = ПолучитьИзВременногоХранилища(АдресВоВременномХранилище);
	
	ПодключитьОбработчикОжидания("Подключаемый_СохранитьНастройкиФормы", 120);
	
	КэшДополнительныхДанных = Новый Соответствие;
	КэшДополнительныхДанных.Вставить("КэшСтатусов", ЭтотОбъект["КэшСтатусов"]);	
	
	// Изменение гиперссылки на отчет трудозатрат.
	УчетТрудозатратКлиент.ИзменитьЗаголовокТрудозатрат(Элементы.Гиперссылка_ОтчетТрудозатраты);
	ИнструментыКлиент.ПриОткрытии(ЭтотОбъект);
	
	ИнтеграцияДополнительныхПодсистем.ЗакончитьЗамерВремени("МоиЗадачи.ОткрытиеФормы", ВремяНачалаЗамера);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	
	ИнструментыКлиент.ПриЗакрытии(ЗавершениеРаботы, УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	СписокСобытий = СтрРазделить(ИмяСобытия, ";");
	
	Для Каждого Событие Из СписокСобытий Цикл
		Если Событие = СобытияОповещенияКлиент.ИмяСобытияДобавленияТрудозатрат() Тогда
			УчетТрудозатратКлиент.ИзменитьЗаголовокТрудозатрат(Элементы.Гиперссылка_ОтчетТрудозатраты);
		
		ИначеЕсли СобытияОповещенияКлиент.СобытиеОбновлениеСписковИнструментов(Событие)
			ИЛИ СобытияОповещенияКлиент.СобытиеИзменения(Событие) Тогда
			
			ИнструментыКлиент.УстановитьПризнакНеобходимостиОбновления(ЭтотОбъект);
		КонецЕсли;
	КонецЦикла;
	
	ИнструментыКлиент.ОбработкаОповещения(ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура ЗадачиНаМнеВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	ОбработатьВыборЗадачи(Элементы.ЗадачиНаМне.ТекущиеДанные);

КонецПроцедуры

&НаКлиенте
Процедура ЗадачиНаМнеПередРазворачиванием(Элемент, Строка, Отказ)

	УправлениеИнструментамиРазработкиКлиент.ПередРазворачиваниемУзлаДерева(ЗадачиНаМне, Строка, 
		НастройкиФормы.Список_ЗадачиНаМне.РазвернутыеСтроки);

КонецПроцедуры

&НаКлиенте
Процедура ЗадачиНаМнеПередСворачиванием(Элемент, Строка, Отказ)
	
	УправлениеИнструментамиРазработкиКлиент.ПередСворачиваниемУзлаДерева(ЗадачиНаМне, Строка, 
		НастройкиФормы.Список_ЗадачиНаМне.РазвернутыеСтроки);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗадачиНаМнеПриАктивизацииСтроки(Элемент)
	
	СохранитьВыделеннуюСтрокуСписка(Элементы.ЗадачиНаМне, НастройкиФормы.Список_ЗадачиНаМне);
	
	ТекущиеДанные = Элементы.ЗадачиНаМне.ТекущиеДанные;
		
	Если ТекущиеДанные <> Неопределено Тогда
		Элементы.ЗадачиНаМнеКонтекстноеМенюКопироватьВБуфер.Видимость = НЕ ТекущиеДанные.ЭтоГруппа;
		Элементы.ЗадачиНаМнеКонтекстноеМенюОткрытьВариантыСсылок.Видимость = НЕ ТекущиеДанные.ЭтоГруппа;
		Элементы.ЗадачиНаМнеКонтекстноеМенюДобавитьТрудозатраты.Видимость = НЕ ТекущиеДанные.ЭтоГруппа;
		
		ЗаполнитьСтатусыВСписке(ТекущиеДанные.Ссылка, "СписокСтатусов_ЗадачиНаМне");
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗадачиНаМне_ВариантГруппировкиПриИзменении(Элемент)
	
	НастройкиФормы.Список_ЗадачиНаМне_ВариантГруппировки = ВариантГруппировкиЗадачиНаМне;
	ЗапуститьОбновлениеЗадачиНаМне();
	
КонецПроцедуры

&НаКлиенте
Процедура НадписьАктивныйСпринтНажатие(Элемент)
	
	ПараметрыОткрытия = Новый Структура("Ключ", НастройкиФормы.АктивныйСпринт);
	ОткрытьФорму("Документ.Спринт.ФормаОбъекта", ПараметрыОткрытия, ЭтотОбъект);	
	
КонецПроцедуры

&НаКлиенте
Процедура ОтслеживаемыеЗадачиВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	ОбработатьВыборЗадачи(Элементы.ОтслеживаемыеЗадачи.ТекущиеДанные);
	
КонецПроцедуры

&НаКлиенте
Процедура ОтслеживаемыеЗадачиПередРазворачиванием(Элемент, Строка, Отказ)
	
	УправлениеИнструментамиРазработкиКлиент.ПередРазворачиваниемУзлаДерева(ОтслеживаемыеЗадачи, Строка, 
		НастройкиФормы.Список_ОтслеживаемыеЗадачи.РазвернутыеСтроки);

КонецПроцедуры

&НаКлиенте
Процедура ОтслеживаемыеЗадачиПередСворачиванием(Элемент, Строка, Отказ)
	
	УправлениеИнструментамиРазработкиКлиент.ПередСворачиваниемУзлаДерева(ОтслеживаемыеЗадачи, Строка, 
		НастройкиФормы.Список_ОтслеживаемыеЗадачи.РазвернутыеСтроки);
	
КонецПроцедуры

&НаКлиенте
Процедура ОтслеживаемыеЗадачиПриАктивизацииСтроки(Элемент)
		
	СохранитьВыделеннуюСтрокуСписка(Элементы.ОтслеживаемыеЗадачи, НастройкиФормы.Список_ОтслеживаемыеЗадачи);
	
	ТекущиеДанные = Элементы.ОтслеживаемыеЗадачи.ТекущиеДанные;
	
	Если ТекущиеДанные <> Неопределено Тогда
		Элементы.ОтслеживаемыеЗадачиВОпределенномСтатусеКонтекстноеМенюКопироватьВБуфер.Видимость = НЕ ТекущиеДанные.ЭтоГруппа;
		Элементы.ОтслеживаемыеЗадачиВОпределенномСтатусеКонтекстноеМенюОткрытьВариантыСсылок.Видимость = НЕ ТекущиеДанные.ЭтоГруппа;
		Элементы.ОтслеживаемыеЗадачиВОпределенномСтатусеКонтекстноеМенюОтписатьсяОтОповещений.Видимость = НЕ ТекущиеДанные.ЭтоГруппа;
		Элементы.ОтслеживаемыеЗадачиВОпределенномСтатусеКонтекстноеДобавитьТрудозатраты.Видимость = НЕ ТекущиеДанные.ЭтоГруппа;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтслеживаемыеЗадачи_ВариантГруппировкиПриИзменении(Элемент)
		
	НастройкиФормы.Список_ОтслеживаемыеЗадачи_ВариантГруппировки = ВариантГруппировкиОтслеживаемыеЗадачи;
	ЗапуститьОбновлениеОтслеживаемыеЗадачи(Ложь);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Гиперссылка_ОтчетТрудозатратыНажатие(Элемент)
	
	ПараметрыОткрытия = Новый Структура;
	ПараметрыОткрытия.Вставить("ПостроитьОтчетЗаТекущийДень", Истина);
	ПараметрыОткрытия.Вставить("Функциональность", "Открытие инструмента ""Отчет трудозатраты(За текущий день)"""); 
	ПараметрыОткрытия.Вставить("ИмяФормы", ИмяФормы);
	
	ОткрытьФорму("Отчет.Трудозатраты.ФормаОбъекта", ПараметрыОткрытия, ЭтотОбъект,
	ЭтотОбъект.УникальныйИдентификатор, , , , РежимОткрытияОкнаФормы.Независимый);
	
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьТрудозатраты(Команда)
	
	Если ТекущийЭлемент = Неопределено Тогда
		Возврат;
	КонецЕсли;                              
	
	ДанныеОбъект = Неопределено;
	
	Если ТекущийЭлемент.ТекущиеДанные <> Неопределено Тогда 
		ДанныеОбъект = ТекущийЭлемент.ТекущиеДанные;
	Иначе
		Возврат;
	КонецЕсли;
	
	УчетТрудозатратКлиент.ОткрытьФормуДобавленияТрудозатратВКонтекстномМеню(ДанныеОбъект, УникальныйИдентификатор);
		
КонецПроцедуры

&НаКлиенте
Процедура КопироватьВБуфер(Команда)
	
	Если ТекущийЭлемент = Неопределено Тогда
		Возврат;
	КонецЕсли;                              
	
	ОбъектСсылка = Неопределено;
	
	Если ТекущийЭлемент.ТекущиеДанные <> Неопределено Тогда 
		ТекущиеДанные = ТекущийЭлемент.ТекущиеДанные;
		
		Если ТекущиеДанные.Свойство("Ссылка") Тогда
			ОбъектСсылка = ТекущиеДанные.Ссылка;
		ИначеЕсли ТекущиеДанные.Свойство("Задача") Тогда
			ОбъектСсылка = ТекущиеДанные.Задача;
		КонецЕсли; 
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ОбъектСсылка) Тогда
		ОбщегоНазначенияКлиент.КопироватьНавигационнуюСсылкуВБуферОбмена(ОбъектСсылка);	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Обновить(Команда)
	
	ОбновитьДанныеИнструмента();
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьВариантыСсылок(Команда)
	
	Если ТекущийЭлемент = Неопределено Тогда
		Возврат;
	КонецЕсли;                              
	
	ОбъектСсылка = Неопределено;
	
	Если ТекущийЭлемент.ТекущиеДанные <> Неопределено Тогда 
		ТекущиеДанные = ТекущийЭлемент.ТекущиеДанные;
		
		Если ТекущиеДанные.Свойство("Ссылка") Тогда
			ОбъектСсылка = ТекущиеДанные.Ссылка;
		ИначеЕсли ТекущиеДанные.Свойство("Задача") Тогда
			ОбъектСсылка = ТекущиеДанные.Задача;
		КонецЕсли;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ОбъектСсылка) Тогда
		ИнтерфейсПриложенияКлиент.ОткрытьОкноНавигационнойСсылки(ОбъектСсылка, ЭтотОбъект, УникальныйИдентификатор);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтписатьсяОтОповещений(Команда)
	
	ТекущиеДанные = Элементы.ОтслеживаемыеЗадачи.ТекущиеДанные;
		
	Если ТекущиеДанные = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	
	УчастникиПроцессовВызовСервера.Отписаться(ТекущиеДанные.Ссылка);
	Оповестить(СобытияОповещенияКлиент.ИмяСобытияИзменения(), ТекущиеДанные.Ссылка);
		
КонецПроцедуры

&НаКлиенте
Процедура УстановитьСтатусПоКнопке(Команда)
	
	Если ТекущийЭлемент = Неопределено Тогда
		Возврат;
	КонецЕсли;                              
	
	ДанныеОбъект = Неопределено;
	
	Если ТекущийЭлемент.ТекущиеДанные <> Неопределено Тогда 
		ДанныеОбъект = ТекущийЭлемент.ТекущиеДанные;
	Иначе
		Возврат;
	КонецЕсли;

	РаботаСПроцессамиКлиент.УстановитьСтатусПоКнопке(Команда.Имя, ДанныеОбъект.Ссылка,
		КэшДополнительныхДанных);

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗаполнитьСтатусыВСписке(Задача, Список) 
	
	МассивВидимыхСтатусов = ПолучитьВидимыеСтатусы(Задача, КэшДополнительныхДанных, Список);
	ЭлементСписокСтатусов = Элементы.Найти(Список);
	Для Каждого Элемент Из ЭлементСписокСтатусов.ПодчиненныеЭлементы Цикл
		Элемент.Видимость = МассивВидимыхСтатусов.Найти(Элемент.Имя) <> Неопределено;			
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗапуститьОбновлениеЗадачиНаМне()
	
	МетодОбновления = "Обработки.МоиЗадачи.ПолучитьДанныеЗадачиНаМне";
	
	ПараметрыФонового = Новый Массив;
	ПараметрыФонового.Добавить(ВариантГруппировкиЗадачиНаМне);
	
	ИнструментыКлиент.НачатьОбновлениеИнструмента(ЭтотОбъект, МетодОбновления,
		ПараметрыФонового, Элементы.ЗадачиНаМне.Имя, , "ОбработатьДанныеЗадачиНаМне");
	
	Элементы.ЗадачиНаМне_ВариантГруппировки.ТолькоПросмотр = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗапуститьОбновлениеОтслеживаемыеЗадачи(ПолноеОбновление = Истина)
	
	МетодОбновления = "Обработки.МоиЗадачи.ПолучитьДанныеОтслеживаемыеЗадачи";
	
	ПараметрыФонового = Новый Массив;
	ПараметрыФонового.Добавить(ВариантГруппировкиОтслеживаемыеЗадачи);
	ПараметрыФонового.Добавить(АдресТаблицыВсеОтслеживаемыеЗадачи);
	ПараметрыФонового.Добавить(ПолноеОбновление);
	
	ИнструментыКлиент.НачатьОбновлениеИнструмента(ЭтотОбъект, МетодОбновления,
		ПараметрыФонового, Элементы.ОтслеживаемыеЗадачи.Имя, , "ОбработатьДанныеОтслеживаемыеЗадачи");
	
	Элементы.ОтслеживаемыеЗадачи_ВариантГруппировки.ТолькоПросмотр = Истина;
	
КонецПроцедуры

&НаСервере
Процедура НастроитьПодсветкуПриПриближенииСрокаРеализации()
	
	ОформляемыеТаблицы = Новый Массив;
		
	ОписаниеТаблицы = ОбщегоНазначения.ОписаниеОформляемойТаблицыФормы("ЗадачиНаМне", "ЗадачиНаМне");
	ОформляемыеТаблицы.Добавить(ОписаниеТаблицы);
	
	ОбщегоНазначения.НастроитьПодсветкуПриПриближенииСрокаРеализации(ЭтотОбъект, ОформляемыеТаблицы);

КонецПроцедуры

&НаКлиенте
Процедура ОбновитьДанныеИнструмента() Экспорт
	
	ИнструментыКлиент.ОбновлениеДанныхЗапущено(ЭтотОбъект);
	
	УчетТрудозатратКлиент.ИзменитьЗаголовокТрудозатрат(Элементы.Гиперссылка_ОтчетТрудозатраты);
	
	ЗапуститьОбновлениеЗадачиНаМне();
	ЗапуститьОбновлениеОтслеживаемыеЗадачи();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьВыборЗадачи(Знач ТекущиеДанные) Экспорт
	
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ТекущиеДанные.Ссылка) Тогда
		ОткрытьЗначениеАсинх(ТекущиеДанные.Ссылка);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьДанныеЗадачиНаМне() Экспорт
	
	ИнструментыКлиент.ОбработатьОтложенноеОбновлениеИнструмента(ЭтотОбъект, Элементы.ЗадачиНаМне.Имя, "Обработки.МоиЗадачи.ПолучитьДанныеЗадачиНаМне");
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьДанныеОтслеживаемыеЗадачи() Экспорт
	
	ИнструментыКлиент.ОбработатьОтложенноеОбновлениеИнструмента(ЭтотОбъект, Элементы.ОтслеживаемыеЗадачи.Имя, "Обработки.МоиЗадачи.ПолучитьДанныеОтслеживаемыеЗадачи");
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработчикОбновленияИнструмента(Данные, ДополнительныеПараметры) Экспорт
	
	ЭлементыДерева = ЭтотОбъект[ДополнительныеПараметры.ОбновляемаяТаблица].ПолучитьЭлементы();
	ИнструментыКлиент.ЗаполнитьДанныеИнструмента(ЭлементыДерева, Данные, ДополнительныеПараметры.МетодОбновления);
	
	УправлениеИнструментамиРазработкиКлиент.ВосстановитьСписокВПредыдущееСостояние_Дерево(ЭтотОбъект[ДополнительныеПараметры.ОбновляемаяТаблица],
		Элементы[ДополнительныеПараметры.ОбновляемаяТаблица], НастройкиФормы["Список_" + ДополнительныеПараметры.ОбновляемаяТаблица]);
	
	Элементы[ДополнительныеПараметры.ОбновляемаяТаблица + "_ВариантГруппировки"].ТолькоПросмотр = Ложь;
	
	ИнструментыКлиент.ЗакончитьОбновлениеИнструмента(ЭтотОбъект, ДополнительныеПараметры, Данные.УИДЗамера);
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_СохранитьНастройкиФормы()
	
	СохранитьНастройкиФормы(НастройкиФормы);

КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьВидимыеСтатусы(Задача, КэшДополнительныхДанных, Группа)  
	
	Возврат РаботаСПроцессами.ПолучитьВидимыеСтатусы(Задача, КэшДополнительныхДанных, Группа);	
		
КонецФункции

&НаСервере
Функция ПолучитьНастройкиФормы()
	
	Перем ЗначениеНастройки;
		
	// Создание пустой структуры настроек
	НастройкиФормы = Новый Структура;
	НастройкиФормы.Вставить("Список_ЗадачиНаМне_ВариантГруппировки", 0);
	НастройкиФормы.Вставить("Список_ОтслеживаемыеЗадачи_ВариантГруппировки", 0);
	
	// Параметры дерева
	НастройкиДерева = Новый Структура("ВыделеннаяСтрока, РазвернутыеСтроки", Неопределено, Новый Соответствие);
	НастройкиФормы.Вставить("Список_ЗадачиНаМне", НастройкиДерева);
	
	НастройкиДерева = Новый Структура("ВыделеннаяСтрока, РазвернутыеСтроки", Неопределено, Новый Соответствие);
	НастройкиФормы.Вставить("Список_ОтслеживаемыеЗадачи", НастройкиДерева);
	
	СвойстваНастройки = СвойстваСохраняемойНастройки();
	
	// Восстановление сохраненных параметров
	СохраненныеНастройки = ОбщегоНазначенияВызовСервера.ЗагрузитьНастройкиДанныхФормы(
		СвойстваНастройки.КлючОбъекта, СвойстваНастройки.КлючНастроек);
	
	Если ТипЗнч(СохраненныеНастройки) = Тип("Структура") Тогда	
		// Перебор всех элементом структуры настроек. Если элемент найден в сохраненной
		// настройке, его значение присваивается исходному свойству. В противном случае
		// используется значение по-умолчанию.
		Для Каждого Настройка Из НастройкиФормы Цикл				
			ИмяКлюча = Настройка.Ключ;
			// Если значение сохраненной настройки не существует
			// Также если сохранен пустой список значений - не загружаем настройки.
			Если НЕ СохраненныеНастройки.Свойство(ИмяКлюча, ЗначениеНастройки) Тогда
				Продолжить;
			КонецЕсли;
			
			ТипНастройки = ТипЗнч(Настройка.Значение);
			// Если типы настроек соответствуют, присваиваем значение
			Если ТипНастройки = ТипЗнч(ЗначениеНастройки) Тогда
				Если ТипНастройки = Тип("Структура") Тогда
					ЗаполнитьЗначенияСвойств(НастройкиФормы[ИмяКлюча], ЗначениеНастройки);
				Иначе
					НастройкиФормы.Вставить(ИмяКлюча, ЗначениеНастройки);
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;		
	КонецЕсли;
	
	// Переключатель в списке моих задач.
	ВариантГруппировкиЗадачиНаМне = НастройкиФормы.Список_ЗадачиНаМне_ВариантГруппировки;
	ВариантГруппировкиОтслеживаемыеЗадачи = НастройкиФормы.Список_ОтслеживаемыеЗадачи_ВариантГруппировки;
	
	СтруктураДанныеСпринта = ПроверитьАктивныйСпринтПользователя();
	Элементы.УведомлениеАктивныйСпринт.Видимость = ЗначениеЗаполнено(СтруктураДанныеСпринта.Заголовок);
	Элементы.НадписьАктивныйСпринт.Заголовок = СтруктураДанныеСпринта.Заголовок;
	НастройкиФормы.Вставить("АктивныйСпринт", СтруктураДанныеСпринта.Спринт);

	Возврат НастройкиФормы;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПроверитьАктивныйСпринтПользователя()
	
	Результат = Новый Структура("Спринт, Заголовок", Документы.Спринт.ПустаяСсылка(), "");
		
	Запрос = Новый Запрос;
	Запрос.Текст =
	#Область ТекстЗапроса
	"ВЫБРАТЬ
	|	Спринт.Ссылка КАК Ссылка,
	|	Спринт.Номер КАК Номер,
	|	Спринт.ДатаНачала КАК ДатаНачала,
	|	Спринт.ДатаОкончания КАК ДатаОкончания,
	|	Спринт.Наименование КАК Наименование,
	|	Спринт.Филиал КАК Филиал,
	|	Спринт.Команда КАК Команда
	|ПОМЕСТИТЬ СпринтыФилиала
	|ИЗ
	|	Документ.Спринт КАК Спринт
	|ГДЕ
	|	НЕ Спринт.ПометкаУдаления
	|	И Спринт.ВидСпринта = ЗНАЧЕНИЕ(Перечисление.ВидыСпринта.IT)
	|	И Спринт.Филиал = &Филиал
	|	И &ТекущаяДата МЕЖДУ Спринт.ДатаНачала И Спринт.ДатаОкончания
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	0 КАК Приоритет,
	|	СпринтыФилиала.Ссылка КАК Ссылка,
	|	СпринтыФилиала.Номер КАК Номер,
	|	СпринтыФилиала.ДатаНачала КАК ДатаНачала,
	|	СпринтыФилиала.ДатаОкончания КАК ДатаОкончания,
	|	СпринтыФилиала.Наименование КАК Наименование,
	|	СпринтыФилиала.Филиал КАК Филиал,
	|	СпринтыФилиала.Команда КАК Команда
	|ИЗ
	|	СпринтыФилиала КАК СпринтыФилиала
	|ГДЕ
	|	СпринтыФилиала.Команда = &Команда
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	1,
	|	СпринтыФилиала.Ссылка,
	|	СпринтыФилиала.Номер,
	|	СпринтыФилиала.ДатаНачала,
	|	СпринтыФилиала.ДатаОкончания,
	|	СпринтыФилиала.Наименование,
	|	СпринтыФилиала.Филиал,
	|	СпринтыФилиала.Команда
	|ИЗ
	|	СпринтыФилиала КАК СпринтыФилиала
	|ГДЕ
	|	СпринтыФилиала.Команда = ЗНАЧЕНИЕ(Справочник.Филиалы.ПустаяСсылка)
	|
	|УПОРЯДОЧИТЬ ПО
	|	Приоритет";
	#КонецОбласти
	
	КомандаПользователя = Справочники.Филиалы.ПолучитьКомандуПользователя(ПараметрыСеанса.ТекущийПользователь);
	
	Если КомандаПользователя.КастомнаяКоманда Тогда
		Филиал = Справочники.Филиалы.КастомныеКоманды;
	Иначе
		Филиал = ПараметрыСеанса.Филиал;
	КонецЕсли;
	
	Запрос.УстановитьПараметр("Филиал", Филиал);
	Запрос.УстановитьПараметр("Команда", КомандаПользователя.Команда);
	Запрос.УстановитьПараметр("ТекущаяДата", НачалоДня(ТекущаяДатаСеанса()));
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		
		Результат.Спринт = Выборка.Ссылка;
		Результат.Заголовок = Документы.Спринт.ПолучитьПредставление(Формат(Выборка.Номер, "ЧГ=0"),
			Выборка.ДатаНачала, Выборка.ДатаОкончания, Выборка.Наименование, Выборка.Филиал, Выборка.Команда);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

&НаСервереБезКонтекста
Функция СвойстваСохраняемойНастройки()
	
	Возврат Новый Структура("КлючОбъекта, КлючНастроек", "Обработка.МоиЗадачи.Форма.ФормаОбработки", "НастройкиФормы");
	
КонецФункции

&НаКлиенте
Процедура СохранитьВыделеннуюСтрокуСписка(Знач Элемент, НастройкиСписка)
	
	ТекущиеДанные = Элемент.ТекущиеДанные;
	Если ТекущиеДанные <> Неопределено Тогда
		НастройкиСписка.ВыделеннаяСтрока = ТекущиеДанные.UID;
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура СохранитьНастройкиФормы(Знач Настройки)
	
	СвойстваНастроек = СвойстваСохраняемойНастройки();
	ОбщегоНазначенияВызовСервера.СохранитьНастройкиДанныхФормы(СвойстваНастроек.КлючОбъекта,
		СвойстваНастроек.КлючНастроек, Настройки);
		
КонецПроцедуры

#КонецОбласти
