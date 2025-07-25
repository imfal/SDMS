///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

// Хранит пользовательские настройки колонок
&НаКлиенте
Перем НастройкиКолонок;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// Установка ограничений по отбору, сортировке и группировке
	Документы.ВнутреннееЗадание.УстановитьОграниченияСписка(Список);
	
	ИнициализацияНастроекКолонок();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	// СлужебныеПодсистемы.НастройкиДинамическихСписков
	ОбщегоНазначенияКлиент.ВключитьПроверкуПользовательскихНастроекДинамическогоСписка(ЭтотОбъект);
	// Конец СлужебныеПодсистемы.НастройкиДинамическихСписков
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаСервере
Процедура СписокПриОбновленииСоставаПользовательскихНастроекНаСервере(СтандартнаяОбработка)
	
	ОбновлениеПользовательскихНастроекДинамическогоСписка();
	
КонецПроцедуры

&НаСервере
Процедура СписокПриСохраненииПользовательскихНастроекНаСервере(Элемент, Настройки)
	
	// СлужебныеПодсистемы.НастройкиДинамическихСписков
	НовыеСохраненныеНастройки = Истина;
	// Конец СлужебныеПодсистемы.НастройкиДинамическихСписков

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КопироватьВБуфер(Команда)
	
	ТекущиеДанные = Элементы.Список.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ОбщегоНазначенияКлиент.КопироватьНавигационнуюСсылкуВБуферОбмена(ТекущиеДанные.Ссылка);
	
КонецПроцедуры

&НаКлиенте
Процедура НастройкаКолонок(Команда)
	
	Ключи = ПолучитьКлючиНастроек();
	НастройкиПоУмолчанию = НастройкиКолонокПоУмолчанию();
	НастройкиКолонок = ИнтерфейсПриложенияВызовСервера.ЗаполнитьПользовательскиеНастройки(НастройкиПоУмолчанию, Ключи);
	
	ПараметрыОткрытия = Новый Структура;
	ПараметрыОткрытия.Вставить("ДоступныеНастройки", НастройкиКолонок);
	ПараметрыОткрытия.Вставить("НастройкиПоУмолчанию", НастройкиПоУмолчанию);
		
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработатьИзменениеНастроекКолонок", ЭтотОбъект);
	
	ОткрытьФорму("ОбщаяФорма.НастройкаКолонок", ПараметрыОткрытия, ЭтотОбъект,
		КлючУникальности, , , ОписаниеОповещения, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры
	
&НаКлиенте
Процедура ОткрытьВариантыСсылок(Команда)
	
	ТекущиеДанные = Элементы.Список.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ТекущиеДанные.Свойство("Ссылка") Тогда
		ИнтерфейсПриложенияКлиент.ОткрытьОкноНавигационнойСсылки(ТекущиеДанные.Ссылка, ЭтотОбъект, УникальныйИдентификатор);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФормуНастроекДинамическогоСписка(Команда)
	
	КлючХранилища = "Документ.ВнутреннееЗадание.Форма.ФормаСписка.Список";
	ПользовательскиеНастройки = Список.КомпоновщикНастроек.ПользовательскиеНастройки;
	
	ПараметрыОткрытия = Новый Структура("КлючХранилища,ПользовательскиеНастройки" , КлючХранилища, ПользовательскиеНастройки);
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработатьСохранениеНастроек", ЭтотОбъект);
	ОткрытьФорму("ОбщаяФорма.НастройкиДинамическогоСписка", ПараметрыОткрытия, ЭтотОбъект, , , ,
		ОписаниеОповещения, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);


КонецПроцедуры

&НаКлиенте
Процедура ПрименитьНастройкуДинамическогоСписка(Команда)
	
	ПрименениеНастройкиДинамическогоСписка(Команда.Имя);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ОбновлениеПользовательскихНастроекДинамическогоСписка()
	
	// СлужебныеПодсистемы.НастройкиДинамическихСписков
	ОбщегоНазначенияВызовСервера.ПользовательскиеНастройкиДинамическогоСписка(
		"Документ.ВнутреннееЗадание.Форма.ФормаСписка.Список", ВариантыНастроек, ЭтотОбъект,
		Элементы.ПользовательскиеНастройки);
	// Конец СлужебныеПодсистемы.НастройкиДинамическихСписков
	
КонецПроцедуры

// СлужебныеПодсистемы.НастройкиДинамическихСписков
&НаСервере
Процедура ПрименениеНастройкиДинамическогоСписка(Знач Идентификатор)
	
	// СлужебныеПодсистемы.НастройкиДинамическихСписков
	ОбщегоНазначенияВызовСервера.ПрименитьНастройкуДинамическогоСпискаНаСервере(
		"Документ.ВнутреннееЗадание.Форма.ФормаСписка.Список", ВариантыНастроек, Идентификатор,
		Список.КомпоновщикНастроек);
	// Конец СлужебныеПодсистемы.НастройкиДинамическихСписков
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПроверкаПользовательскихНастроекДинамическогоСписка()
	
	Если НовыеСохраненныеНастройки = Истина Тогда
		ОбновлениеПользовательскихНастроекДинамическогоСписка();
		НовыеСохраненныеНастройки = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьСохранениеНастроек(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат <> Неопределено Тогда
		ОбновлениеПользовательскихНастроекДинамическогоСписка();
	КонецЕсли;	
	
КонецПроцедуры

// Конец СлужебныеПодсистемы.НастройкиДинамическихСписков


////////////////////////////////////////////////////////////////////////////////
// Настройка колонок

&НаСервере
Процедура ИнициализацияНастроекКолонок()
	
	Ключи = ПолучитьКлючиНастроек();
	НастройкиПоУмолчанию = НастройкиКолонокПоУмолчанию();
	НастройкиКолонок = ИнтерфейсПриложенияВызовСервера.ЗаполнитьПользовательскиеНастройки(НастройкиПоУмолчанию, Ключи);
		
	ИнтерфейсПриложенияКлиентСервер.ПрименитьПользовательскиеНастройки(Элементы, НастройкиКолонок);
	ОбновитьПорядокКолонок(НастройкиКолонок.Порядок);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция НастройкиКолонокПоУмолчанию()
		
	// Порядок колонок в коде влияет на заполнение по умолчанию
	Состав = Новый СписокЗначений;
	Состав.Добавить("Дата", "Дата создания", Истина);
	Состав.Добавить("Статус", "Статус", Истина);
	Состав.Добавить("ДатаИзмененияСтатуса", "Изменение статуса", Ложь);
	Состав.Добавить("НазначениеПредставление", "Назначение", Истина);
	Состав.Добавить("Наименование", "Тема", Истина);
	Состав.Добавить("Назначена", "Назначена", Истина);
	Состав.Добавить("Автор", "Автор", Ложь);
	Состав.Добавить("Заказчик", "Заказчик", Ложь);
	Состав.Добавить("ПлановоеОкончание", "Плановое окончание", Истина);
	Состав.Добавить("ВладелецПродукта", "Владелец продукта", Ложь);	
		
	ПорядковыйНомер = 1;
	Порядок = Новый Соответствие;
	
	Для Каждого ЭлементСписка Из Состав Цикл
		СтруктураПоля = Новый Структура("Поле, Представление", ЭлементСписка.Значение, ЭлементСписка.Представление);
		Порядок.Вставить(ПорядковыйНомер, СтруктураПоля);
		
		ПорядковыйНомер = ПорядковыйНомер + 1;
	КонецЦикла;
	
	Результат = Новый Структура("Состав, Порядок", Состав, Порядок);
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Процедура ОбновитьПорядокКолонок(Знач Порядок)
	
	ИнтерфейсПриложения.ОбновитьПорядокКолонокНаСервере(Порядок, Элементы, Элементы.Список);
	
КонецПроцедуры

// Процедура для изменения таблицы формы
//
// Параметры:
//  Результат - Структура - Хранит результат выбора пользователя:
//  	* ИзменилсяПорядок - Булево - Проверка на изменения порядка
//  	* Состав - Соответсвие - Состав колонок таблицы
//  	* Порядок - СписокЗначения - Колонки для отображения
//  ДополнительныеПараметры	 - Структура - Передает сохраненные настройки
//
&НаКлиенте
Процедура ОбработатьИзменениеНастроекКолонок(Знач Результат, Знач ДополнительныеПараметры) Экспорт
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполняемыеСвойства = "Состав, Порядок";
	
	ЗаполнитьЗначенияСвойств(НастройкиКолонок, Результат, ЗаполняемыеСвойства);
	Ключи = ПолучитьКлючиНастроек();
			
	ИнтерфейсПриложенияКлиентСервер.ПрименитьПользовательскиеНастройки(Элементы, НастройкиКолонок);
	
	Если Результат.ИзменилсяПорядок Тогда
		ОбновитьПорядокКолонок(НастройкиКолонок.Порядок);
	КонецЕсли;
	
	// Сохранение пользовательских настроек
	ОбщегоНазначенияВызовСервера.СохранитьНастройкиДанныхФормы(Ключи.Объект, Ключи.Настройка, НастройкиКолонок);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ПолучитьКлючиНастроек()
	
	Ключи = Новый Структура;
	Ключи.Вставить("Объект", "Документы.ВнутреннееЗадание.ФормаСписка");
	Ключи.Вставить("Настройка", "НастройкаКолонок");
	
	Возврат Ключи;
	
КонецФункции

#КонецОбласти
