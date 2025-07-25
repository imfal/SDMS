///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем КэшДополнительныхДанных; // Хранит кешированные данные на клиенте

&НаКлиенте
Перем НастройкиФормы Экспорт; // Дополнительные параметры, которые использует клиент

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ВремяНачалаЗамера = ИнтеграцияДополнительныхПодсистем.НачатьЗамерВремени();
	
	ИнициализацияПараметров();

	ОбновлениеПользовательскихНастроекДинамическогоСписка();

	ИнструментыСервер.ПриСозданииНаСервере(ЭтотОбъект, Элементы.Список_ТекущиеРазработкиПоЗаявкам.Имя);

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	// Единоразовое получение данных для клиента с сервера
	КэшДополнительныхДанных = ПолучитьКэшДополнительныхДанныхДляКлиента(АдресВоВременномХранилище);
	
	// Получение настроек формы с сервера
	НастройкиФормы = КэшДополнительныхДанных["НастройкиФормы"];
	КэшДополнительныхДанных.Удалить(КэшДополнительныхДанных["НастройкиФормы"]);
	ФильтрНазначена_ТекущиеРазработки = НастройкиФормы.ФильтрНазначена_ТекущиеРазработки;
	
	ИнструментыКлиент.ПриОткрытии(ЭтотОбъект);
	
	ИнтеграцияДополнительныхПодсистем.ЗакончитьЗамерВремени("ТекущиеРаботыПоЗаявкам.ОткрытиеФормы", ВремяНачалаЗамера);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	СписокСобытий = СтрРазделить(ИмяСобытия, ";");
	ЭтоМассив = СписокСобытий.Количество() > 1; 
	Счетчик = 0;
	
	Для Каждого Событие Из СписокСобытий Цикл
		
		Если СобытияОповещенияКлиент.СобытиеОбновлениеСписковИнструментов(Событие) Тогда
			ПараметрСобытия = ?(ЭтоМассив, Параметр[Счетчик], Параметр);
			
			СтандартнаяОбработка = ТипЗнч(Источник) = Тип("ДокументСсылка.ЗаявкаНаРазработку");
			
			Если СтандартнаяОбработка Тогда
				ИнструментыКлиент.УстановитьПризнакНеобходимостиОбновления(ЭтотОбъект);				
			КонецЕсли;
		КонецЕсли;
		
		Счетчик = Счетчик + 1;
	КонецЦикла;

	ИнструментыКлиент.ОбработкаОповещения(ЭтотОбъект);

КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)

	ИнструментыКлиент.ПриЗакрытии(ЗавершениеРаботы, УникальныйИдентификатор);

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура Список_ТекущиеРазработкиПоЗаявкамВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	ТекущиеДанные = Элементы.Список_ТекущиеРазработкиПоЗаявкам.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ТекущиеДанные.Заявка) Тогда
		ПараметрыОткрытия = Новый Структура("Ключ", ТекущиеДанные.Заявка);	
		ОткрытьФорму("Документ.ЗаявкаНаРазработку.Форма.ФормаДокумента", ПараметрыОткрытия);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Список_ТекущиеРазработкиПоЗаявкамПередРазворачиванием(Элемент, Строка, Отказ)
	
	УправлениеИнструментамиРазработкиКлиент.ПередРазворачиваниемУзлаДерева(Список_ТекущиеРазработкиПоЗаявкам, Строка,
		НастройкиФормы.Список_ТекущиеРазработкиПоЗаявкам.РазвернутыеСтроки);
	
КонецПроцедуры

&НаКлиенте
Процедура Список_ТекущиеРазработкиПоЗаявкамПередСворачиванием(Элемент, Строка, Отказ)
	
	УправлениеИнструментамиРазработкиКлиент.ПередСворачиваниемУзлаДерева(Список_ТекущиеРазработкиПоЗаявкам, Строка,
		НастройкиФормы.Список_ТекущиеРазработкиПоЗаявкам.РазвернутыеСтроки);
	
КонецПроцедуры

&НаКлиенте
Процедура Список_ТекущиеРазработкиПоЗаявкамПриАктивизацииСтроки(Элемент)

	УправлениеИнструментамиРазработкиКлиент.ОбработкаАктивизацииСтрокиДанныхФормы(Элемент,
		НастройкиФормы.Список_ТекущиеРазработкиПоЗаявкам.ВыделеннаяСтрока);

	ТекущиеДанные = Элементы.Список_ТекущиеРазработкиПоЗаявкам.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	Элементы.Список_ТекущиеРазработкиПоЗаявкамКонтекстноеМенюКопироватьВБуфер.Видимость = Не ТекущиеДанные.ЭтоГруппа;
	Элементы.Список_ТекущиеРазработкиПоЗаявкамКонтекстноеМенюОткрытьВариантыСсылок.Видимость = Не ТекущиеДанные.ЭтоГруппа;

КонецПроцедуры

&НаКлиенте
Процедура ФильтрНазначена_ТекущиеРазработкиПриИзменении(Элемент)
	
	НастройкиФормы.ФильтрНазначена_ТекущиеРазработки = ФильтрНазначена_ТекущиеРазработки;
	ОбновитьДанныеИнструмента();
	СохранитьНастройкиФормы(НастройкиФормы);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКоманд

&НаКлиенте
Процедура ОбновитьСписокТекущиеРазработкиПоЗаявкам(Команда)
	
	ОбновитьДанныеИнструмента();
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФормуНастроекПланирование(Команда)
	
	// Подготовка данных для выбора направлений и систем
	СписокГруппЗаказчиков = Новый Массив;
	Для Каждого Элемент Из НастройкиФормы.ДоступныеГруппыЗаказчиков Цикл
		Если Элемент.Значение.Использование Тогда
			СписокГруппЗаказчиков.Добавить(Элемент.Ключ);
		КонецЕсли;
	КонецЦикла;
	
	СписокНаправлений = Новый Массив;
	Для Каждого Элемент Из НастройкиФормы.ДоступныеНаправления Цикл
		Если Элемент.Значение.Использование Тогда
			СписокНаправлений.Добавить(Элемент.Ключ);
		КонецЕсли;
	КонецЦикла;	
	
	СписокСистем = Новый Массив;
	Для Каждого Элемент Из НастройкиФормы.ДоступныеСистемы Цикл
		Если Элемент.Значение.Использование Тогда
			СписокСистем.Добавить(Элемент.Ключ);
		КонецЕсли;
	КонецЦикла;
	
	СписокПродуктов = Новый Массив;
	Для Каждого Элемент Из НастройкиФормы.ДоступныеПродукты Цикл
		Если Элемент.Значение.Использование Тогда
			СписокПродуктов.Добавить(Элемент.Ключ);
		КонецЕсли;
	КонецЦикла;
	
	ПараметрыОткрытия = ИнтерфейсПриложенияКлиент.СформироватьПараметрыОткрытия();
	
	ПараметрыОткрытия.Направления.Значение = СписокНаправлений;
	ПараметрыОткрытия.Направления.Использование = Истина;
	
	ПараметрыОткрытия.Системы.Значение = СписокСистем;
	ПараметрыОткрытия.Системы.Использование = Истина;
	
	ПараметрыОткрытия.ГруппыЗаказчиков.Значение = СписокГруппЗаказчиков;
	ПараметрыОткрытия.ГруппыЗаказчиков.Использование = Истина;
	
	ПараметрыОткрытия.Продукты.Значение = СписокПродуктов;
	ПараметрыОткрытия.Продукты.Использование = Истина;

	ОписаниеОповещения = Новый ОписаниеОповещения("ЗавершитьВыборНастроекПланирование", ЭтотОбъект);
	ИнтерфейсПриложенияКлиент.ОткрытьФормуНастройкиИнструментов(ЭтотОбъект, ПараметрыОткрытия, ОписаниеОповещения);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Общие процедуры и функции

&НаКлиенте
Процедура КопироватьВБуфер(Команда)
	
	Если ТекущийЭлемент = Неопределено Тогда
		Возврат;
	КонецЕсли;                              
	
	Если ТекущийЭлемент.ТекущиеДанные <> Неопределено Тогда 
		
		ТекущиеДанные = ТекущийЭлемент.ТекущиеДанные;
	
		Если ТекущиеДанные.Свойство("Объект") Тогда
			ОбъектСсылка = ТекущиеДанные.Объект;
		ИначеЕсли ТекущиеДанные.Свойство("Заявка") Тогда
			ОбъектСсылка = ТекущиеДанные.Заявка; 
		ИначеЕсли ТекущиеДанные.Свойство("Задача") Тогда
			ОбъектСсылка = ТекущиеДанные.Задача;
		ИначеЕсли ТекущиеДанные.Свойство("Ссылка") Тогда
			ОбъектСсылка = ТекущиеДанные.Ссылка;
		КонецЕсли;
	КонецЕсли; 
	
	Если ЗначениеЗаполнено(ОбъектСсылка) Тогда	
		ОбщегоНазначенияКлиент.КопироватьНавигационнуюСсылкуВБуферОбмена(ОбъектСсылка);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСписокПользовательскихНастроек(Команда)
	
	ОбновлениеПользовательскихНастроекДинамическогоСписка();	
	
КонецПроцедуры
 
&НаКлиенте
Процедура ОткрытьВариантыСсылок(Команда)
	
	Если ТекущийЭлемент = Неопределено Тогда
		Возврат;
	КонецЕсли;                              
	
	Если ТекущийЭлемент.ТекущиеДанные <> Неопределено Тогда 
		
		ТекущиеДанные = ТекущийЭлемент.ТекущиеДанные;
	
		Если ТекущиеДанные.Свойство("Объект") Тогда
			ОбъектСсылка = ТекущиеДанные.Объект;
		ИначеЕсли ТекущиеДанные.Свойство("Заявка") Тогда
			ОбъектСсылка = ТекущиеДанные.Заявка;
		ИначеЕсли ТекущиеДанные.Свойство("Задача") Тогда
			ОбъектСсылка = ТекущиеДанные.Задача;
		ИначеЕсли ТекущиеДанные.Свойство("Ссылка") Тогда
			ОбъектСсылка = ТекущиеДанные.Ссылка;
		КонецЕсли;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ОбъектСсылка) Тогда
		ИнтерфейсПриложенияКлиент.ОткрытьОкноНавигационнойСсылки(ОбъектСсылка, ЭтотОбъект, КлючУникальности);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПрименитьНастройкуДинамическогоСписка(Команда)
	
	НастройкиОчередиЗаявок = ОбщегоНазначенияВызовСервера.ПолучитьНастройкиХранилищеНастроекДинамическихСписков(
		СвойстваСохраняемойНастройки().КлючОбъекта, ВариантыНастроек, Команда.Имя);	 
	
	Если НастройкиОчередиЗаявок <> Неопределено Тогда	
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, НастройкиОчередиЗаявок);
		ЗаполнитьЗначенияСвойств(НастройкиФормы, НастройкиОчередиЗаявок);  
		
		ОбновитьДанныеИнструмента();
	КонецЕсли;	
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Функция НастройкиОбновленияСпискаТекущиеРазработкиПоЗаявкам()
	
	ПередаваемыеНастройки = Новый Структура;
	ПередаваемыеНастройки.Вставить("ДоступныеНаправления", НастройкиФормы.ДоступныеНаправления);
	ПередаваемыеНастройки.Вставить("ДоступныеСистемы", НастройкиФормы.ДоступныеСистемы);
	ПередаваемыеНастройки.Вставить("ДоступныеГруппыЗаказчиков", НастройкиФормы.ДоступныеГруппыЗаказчиков);
	ПередаваемыеНастройки.Вставить("ДоступныеПродукты", НастройкиФормы.ДоступныеПродукты);
	ПередаваемыеНастройки.Вставить("Список_ТекущиеРазработкиПоЗаявкам", НастройкиФормы.Список_ТекущиеРазработкиПоЗаявкам);
	ПередаваемыеНастройки.Вставить("ФильтрНазначена_ТекущиеРазработки", НастройкиФормы.ФильтрНазначена_ТекущиеРазработки);
	
	ПараметрыФонового = Новый Массив;
	ПараметрыФонового.Добавить(ПередаваемыеНастройки);
	
	Возврат ПараметрыФонового;
	
КонецФункции

&НаКлиенте
Процедура ЗапуститьОбновлениеСписок_ТекущиеРазработкиПоЗаявкам()
	
	МетодОбновления = "Обработки.ТекущиеРаботыПоЗаявкам.ПолучитьДанныеСписок_ТекущиеРазработкиПоЗаявкам";
	
	ПараметрыФонового = НастройкиОбновленияСпискаТекущиеРазработкиПоЗаявкам();
	
	ИнструментыКлиент.НачатьОбновлениеИнструмента(ЭтотОбъект, МетодОбновления,
		ПараметрыФонового, Элементы.Список_ТекущиеРазработкиПоЗаявкам.Имя, , "ОбработатьДанныеСписок_ТекущиеРазработкиПоЗаявкам");
		
	Элементы.ГруппаНастройки.Доступность = Ложь;
	Элементы.ФильтрНазначена_ТекущиеРазработки.ТолькоПросмотр = Истина;
	
КонецПроцедуры

&НаКлиенте

&НаКлиенте
Процедура ОбработатьДанныеСписок_ТекущиеРазработкиПоЗаявкам() Экспорт
	
	ИнструментыКлиент.ОбработатьОтложенноеОбновлениеИнструмента(ЭтотОбъект, Элементы.Список_ТекущиеРазработкиПоЗаявкам.Имя, "Обработки.ТекущиеРаботыПоЗаявкам.ПолучитьДанныеСписок_ТекущиеРазработкиПоЗаявкам");
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработчикОбновленияИнструмента(Данные, ДополнительныеПараметры) Экспорт
	
	КоллекцияЭлементов = ЭтотОбъект[ДополнительныеПараметры.ОбновляемаяТаблица].ПолучитьЭлементы();

	НастройкиСписка = НастройкиФормы.Список_ТекущиеРазработкиПоЗаявкам;

	ИнструментыКлиент.ЗаполнитьДанныеИнструмента(КоллекцияЭлементов, Данные, ДополнительныеПараметры.МетодОбновления);
	
	УправлениеИнструментамиРазработкиКлиент.ВосстановитьДанныеФормыВПредыдущееСостояние(ЭтотОбъект,
		ДополнительныеПараметры.ОбновляемаяТаблица, НастройкиСписка);
	
//	УправлениеИнструментамиРазработкиКлиент.ОбработатьСуществующийСписок_Дерево(Элементы.Список_ТекущиеРазработкиПоЗаявкам, 
//		Список_ТекущиеРазработкиПоЗаявкам, НастройкиФормы.Список_ТекущиеРазработкиПоЗаявкам);
	
	Элементы.ГруппаНастройки.Доступность = Истина;
	Элементы.ФильтрНазначена_ТекущиеРазработки.ТолькоПросмотр = Ложь;
	
	ИнструментыКлиент.ЗакончитьОбновлениеИнструмента(ЭтотОбъект, ДополнительныеПараметры, Данные.УИДЗамера);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьДанныеИнструмента() Экспорт
	
	ИнструментыКлиент.ОбновлениеДанныхЗапущено(ЭтотОбъект);
	
	ЗапуститьОбновлениеСписок_ТекущиеРазработкиПоЗаявкам();
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////
// Общие процедуры и функции

&НаСервереБезКонтекста
Процедура ДобавитьГруппуЗаказчиков(Знач ГруппаЗаказчиков, Знач Заказчик, Знач Ответственный, Знач СтарыеГруппы, НовыеГруппы)
	
	НайденнаяГруппа = СтарыеГруппы.Получить(ГруппаЗаказчиков);
	
	ОписаниеСвойств = Новый Структура;
	ОписаниеСвойств.Вставить("Заказчик", Заказчик);
	ОписаниеСвойств.Вставить("Ответственный", Ответственный);
	ОписаниеСвойств.Вставить("Использование", ?(НайденнаяГруппа = Неопределено, Истина, НайденнаяГруппа.Использование));
	
	НовыеГруппы.Вставить(ГруппаЗаказчиков, ОписаниеСвойств);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьКэшДополнительныхДанныхДляКлиента(Знач АдресВоВременномХранилище = "")
	
	ДанныеДляКлиента = Новый Соответствие;

	Если ЭтоАдресВременногоХранилища(АдресВоВременномХранилище) Тогда
		Настройки = ПолучитьИзВременногоХранилища(АдресВоВременномХранилище);
		ДанныеДляКлиента.Вставить("НастройкиФормы", Настройки.НастройкиФормы);
	Иначе
		ДанныеДляКлиента.Вставить("НастройкиФормы", Неопределено);
	КонецЕсли;
	
	Возврат ДанныеДляКлиента;
	
КонецФункции

&НаКлиенте
Процедура ЗавершитьВыборНастроекПланирование(Результат, ДополнительныеНастройки) Экспорт
	
	Если ТипЗнч(Результат) <> Тип("Структура") Тогда
		Возврат;
	КонецЕсли;	
	
	Для Каждого ЭлементКоллекции Из НастройкиФормы.ДоступныеГруппыЗаказчиков Цикл
		Элемент = Результат.ВыбранныеГруппыЗаказчиков.НайтиПоЗначению(ЭлементКоллекции.Ключ);
		ЭлементКоллекции.Значение.Использование = (Элемент <> Неопределено);
	КонецЦикла; 
	
	Для Каждого ЭлементКоллекции Из НастройкиФормы.ДоступныеНаправления Цикл
		Элемент = Результат.ВыбранныеНаправления.НайтиПоЗначению(ЭлементКоллекции.Ключ);
		ЭлементКоллекции.Значение.Использование = (Элемент <> Неопределено);
	КонецЦикла;
	
	Для Каждого ЭлементКоллекции Из НастройкиФормы.ДоступныеСистемы Цикл
		Элемент = Результат.ВыбранныеСистемы.НайтиПоЗначению(ЭлементКоллекции.Ключ);
		ЭлементКоллекции.Значение.Использование = (Элемент <> Неопределено);
	КонецЦикла;
	
	Проверять = Истина;
	
	Для Каждого ЭлементКоллекции Из НастройкиФормы.ДоступныеПродукты Цикл
		Элемент = Результат.ВыбранныеПродукты.НайтиПоЗначению(ЭлементКоллекции.Ключ);
		Если Проверять И НЕ ЭлементКоллекции.Значение.Использование = (Элемент <> Неопределено) Тогда
			Проверять = Ложь;
		КонецЕсли;
		ЭлементКоллекции.Значение.Использование = (Элемент <> Неопределено); 
	КонецЦикла;
	
	ОбновитьДанныеИнструмента();
	
	СохранитьНастройкиФормы(НастройкиФормы);
	
КонецПроцедуры

&НаСервере
Процедура ИнициализацияПараметров()
	
	НастройкиФормы = СформироватьНастройкиФормы();	
		
	Настройки = Новый Структура;
	Настройки.Вставить("НастройкиФормы", НастройкиФормы);
	
	АдресВоВременномХранилище = ПоместитьВоВременноеХранилище(Настройки);

КонецПроцедуры

&НаСервереБезКонтекста
Функция СвойстваСохраняемойНастройки()
	
	Возврат Новый Структура("КлючОбъекта, КлючНастроек", "Обработка.ТекущиеРаботыПоЗаявкам", "НастройкиФормы");
	
КонецФункции

&НаСервереБезКонтекста
Процедура СохранитьНастройкиФормы(Знач Настройки)
	
	СвойстваНастроек = СвойстваСохраняемойНастройки();
	
	ОбщегоНазначенияВызовСервера.СохранитьНастройкиДанныхФормы(СвойстваНастроек.КлючОбъекта, 
		СвойстваНастроек.КлючНастроек, Настройки);
	
КонецПроцедуры

&НаСервере
Функция СформироватьНастройкиФормы()
	
	Перем ЗначениеНастройки;
	
	// Создание пустой структуры настроек
	НастройкиФормы = Новый Структура;
	НастройкиФормы.Вставить("ДоступныеГруппыЗаказчиков", Новый Соответствие);
	НастройкиФормы.Вставить("ДоступныеНаправления", Новый Соответствие);
	НастройкиФормы.Вставить("ДоступныеСистемы", Новый Соответствие);
	НастройкиФормы.Вставить("ДоступныеПродукты", Новый Соответствие);
    НастройкиФормы.Вставить("ФильтрНазначена_ТекущиеРазработки", 0);
                 
	// Общая структура настроек списков
	НастройкиСписка = Новый Структура;
	НастройкиСписка.Вставить("ВыделеннаяСтрока", Неопределено); 
	НастройкиСписка.Вставить("Направления", Новый Соответствие);
	НастройкиСписка.Вставить("РазвернутыеСтроки", Новый Соответствие);
	
	НастройкиФормы.Вставить("Список_ТекущиеРазработкиПоЗаявкам", НастройкиСписка);

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
			Если НЕ СохраненныеНастройки.Свойство(ИмяКлюча, ЗначениеНастройки) Тогда
				Продолжить;
			КонецЕсли;
			
			// Если типы настроек соответствуют, присваиваем значение
			Если ТипЗнч(Настройка.Значение) = ТипЗнч(ЗначениеНастройки) Тогда
				НастройкиФормы.Вставить(ИмяКлюча, ЗначениеНастройки);
			КонецЕсли;
		КонецЦикла;		
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	#Область ТекстЗапроса
	"ВЫБРАТЬ
	|	РолиПользователейПоНаправлениям.НаправлениеРазработки КАК Направление,
	|	РолиПользователейПоНаправлениям.Роль КАК РольПользователя
	|ПОМЕСТИТЬ РолиПользователя
	|ИЗ
	|	РегистрСведений.РолиПользователейПоНаправлениям КАК РолиПользователейПоНаправлениям
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.НаправленияРазработки КАК НаправленияРазработки
	|		ПО РолиПользователейПоНаправлениям.НаправлениеРазработки = НаправленияРазработки.Ссылка
	|ГДЕ
	|	РолиПользователейПоНаправлениям.Пользователь = &Пользователь
	|	И НаправленияРазработки.ПометкаУдаления = ЛОЖЬ
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	НаправленияРазработки.Ссылка КАК Направление,
	|	ЕСТЬNULL(РолиПользователя.РольПользователя, ЗНАЧЕНИЕ(Справочник.РолиПользователей.ПустаяСсылка)) КАК РольПользователя,
	|	ВЫБОР
	|		КОГДА НаправленияРазработкиОтветственные.Ссылка ЕСТЬ NULL
	|			ТОГДА ЛОЖЬ
	|		ИНАЧЕ ИСТИНА
	|	КОНЕЦ КАК Ответственный
	|ИЗ
	|	Справочник.НаправленияРазработки КАК НаправленияРазработки
	|		ЛЕВОЕ СОЕДИНЕНИЕ РолиПользователя КАК РолиПользователя
	|		ПО НаправленияРазработки.Ссылка = РолиПользователя.Направление
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.НаправленияРазработки.Ответственные КАК НаправленияРазработкиОтветственные
	|		ПО НаправленияРазработки.Ссылка = НаправленияРазработкиОтветственные.Ссылка
	|			И (НаправленияРазработкиОтветственные.Сотрудник = &Пользователь)
	|ГДЕ
	|	НЕ НаправленияРазработки.ПометкаУдаления
	|
	|УПОРЯДОЧИТЬ ПО
	|	НаправленияРазработки.Наименование
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ГруппыЗаказчиковНаправлений.Ссылка КАК Ссылка,
	|	ВЫБОР
	|		КОГДА ГруппыЗаказчиковНаправленийЗаказчики.Пользователь ЕСТЬ NULL
	|			ТОГДА ЛОЖЬ
	|		ИНАЧЕ ИСТИНА
	|	КОНЕЦ КАК Заказчик,
	|	ЕСТЬNULL(ГруппыЗаказчиковНаправленийЗаказчики.Ответственный, ЛОЖЬ) КАК Ответственный
	|ИЗ
	|	Справочник.ГруппыЗаказчиковНаправлений КАК ГруппыЗаказчиковНаправлений
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ГруппыЗаказчиковНаправлений.Заказчики КАК ГруппыЗаказчиковНаправленийЗаказчики
	|		ПО ГруппыЗаказчиковНаправлений.Ссылка = ГруппыЗаказчиковНаправленийЗаказчики.Ссылка
	|			И (ГруппыЗаказчиковНаправленийЗаказчики.Пользователь = &Пользователь)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	СистемыУчета.Ссылка КАК Система
	|ИЗ
	|	Справочник.СистемыУчета КАК СистемыУчета
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Продукты.Ссылка КАК Продукт,
	|	Продукты.Наименование КАК Наименование
	|ИЗ
	|	Справочник.Продукты КАК Продукты
	|ГДЕ
	|	НЕ Продукты.ПометкаУдаления";
	#КонецОбласти
	
	Запрос.УстановитьПараметр("Пользователь", ПараметрыСеанса.ТекущийПользователь);
	Пакеты = Запрос.ВыполнитьПакет();
	Направления = Пакеты[1];
	ГруппыЗаказчиков = Пакеты[2];
	СистемыУчета = Пакеты[3];
	Продукты = Пакеты[4];

	ТаблицаНаправлений = Направления.Выгрузить();	
	НовыеДоступныеНаправления = Новый Соответствие;
	
	Для Каждого СтрокаТаблицы Из ТаблицаНаправлений Цикл
		НайденноеНаправление = НастройкиФормы.ДоступныеНаправления.Получить(СтрокаТаблицы.Направление);
		ЭтоРуководитель = (СтрокаТаблицы.РольПользователя = Справочники.РолиПользователей.РуководительНаправления);
		
		ОписаниеСвойств = Новый Структура;
		ОписаниеСвойств.Вставить("Ответственный", СтрокаТаблицы.Ответственный);
		ОписаниеСвойств.Вставить("РольПользователя", СтрокаТаблицы.РольПользователя);
		ОписаниеСвойств.Вставить("Использование", ?(НайденноеНаправление = Неопределено, Истина, НайденноеНаправление.Использование));
		ОписаниеСвойств.Вставить("Руководитель", ЭтоРуководитель);
		
		НовыеДоступныеНаправления.Вставить(СтрокаТаблицы.Направление, ОписаниеСвойств);
	КонецЦикла;
	
	НастройкиФормы.Вставить("ДоступныеНаправления", НовыеДоступныеНаправления);
	
	ВыборкаГруппЗаказчиков = ГруппыЗаказчиков.Выбрать();
	НовыеДоступныеГруппы = Новый Соответствие;
	
	Пока ВыборкаГруппЗаказчиков.Следующий() Цикл
		ДобавитьГруппуЗаказчиков(ВыборкаГруппЗаказчиков.Ссылка, ВыборкаГруппЗаказчиков.Заказчик, 
			ВыборкаГруппЗаказчиков.Ответственный, НастройкиФормы.ДоступныеГруппыЗаказчиков, НовыеДоступныеГруппы);
	КонецЦикла;
	
	ГруппаПрочиеЗаказчики = Справочники.ГруппыЗаказчиковНаправлений.ПрочиеЗаказчики;
	ДобавитьГруппуЗаказчиков(ГруппаПрочиеЗаказчики, Ложь, Ложь, НастройкиФормы.ДоступныеГруппыЗаказчиков, НовыеДоступныеГруппы);
	ПустаяГруппа = Справочники.ГруппыЗаказчиковНаправлений.ПустаяСсылка();
	ДобавитьГруппуЗаказчиков(ПустаяГруппа, Ложь, Ложь, НастройкиФормы.ДоступныеГруппыЗаказчиков, НовыеДоступныеГруппы);
	
	НастройкиФормы.Вставить("ДоступныеГруппыЗаказчиков", НовыеДоступныеГруппы);
	
	ВыборкаСистем = СистемыУчета.Выбрать();
	НовыеДоступныеСистемы = Новый Соответствие;
	
	Пока ВыборкаСистем.Следующий() Цикл
		НайденнаяСистема = НастройкиФормы.ДоступныеСистемы.Получить(ВыборкаСистем.Система);
				
		ОписаниеСвойств = Новый Структура;
		ОписаниеСвойств.Вставить("Использование", ?(НайденнаяСистема = Неопределено, Истина, НайденнаяСистема.Использование));
		
		НовыеДоступныеСистемы.Вставить(ВыборкаСистем.Система, ОписаниеСвойств);
	КонецЦикла;
	
	НастройкиФормы.Вставить("ДоступныеСистемы", НовыеДоступныеСистемы);	
	ВыборкаПродукты = Продукты.Выбрать();
	НовыеДоступныеПродукты = Новый Соответствие;
	
	Пока ВыборкаПродукты.Следующий() Цикл
		НайденныйПродукт = НастройкиФормы.ДоступныеПродукты.Получить(ВыборкаПродукты.Продукт);
				
		ОписаниеСвойств = Новый Структура;
		ОписаниеСвойств.Вставить("Использование", ?(НайденныйПродукт = Неопределено, Истина, НайденныйПродукт.Использование));
		
		НовыеДоступныеПродукты.Вставить(ВыборкаПродукты.Продукт, ОписаниеСвойств);
	КонецЦикла;
	
	НастройкиФормы.Вставить("ДоступныеПродукты", НовыеДоступныеПродукты);	
	
	Возврат НастройкиФормы;
	
КонецФункции
	
#КонецОбласти

#Область ОбщиеМеханизмы_НастройкиДинамическихСписок

&НаСервере
Процедура ОбновлениеПользовательскихНастроекДинамическогоСписка()
	
	Свойства = Новый Структура("КлючНастройкиСписка, ПользовательскиеНастройкиСписка");	
	
	Свойства.КлючНастройкиСписка = Новый Массив;
	Свойства.КлючНастройкиСписка.Добавить(СвойстваСохраняемойНастройки().КлючОбъекта);
	
	Свойства.ПользовательскиеНастройкиСписка = Новый Массив;
	Свойства.ПользовательскиеНастройкиСписка.Добавить(Элементы.ПользовательскиеНастройки);

	ОбщегоНазначенияВызовСервера.ПользовательскиеНастройкиДинамическогоСписка(
		Свойства.КлючНастройкиСписка, ВариантыНастроек, ЭтотОбъект,
		Свойства.ПользовательскиеНастройкиСписка);    
		
КонецПроцедуры

&НаСервере
Процедура ПрименениеНастройкиДинамическогоСписка(Знач Свойства, Знач Идентификатор)

	ОбщегоНазначенияВызовСервера.ПрименитьНастройкуДинамическогоСпискаНаСервере(
		Свойства.КлючНастройкиСписка, ВариантыНастроек, Идентификатор,
		Свойства.ДинамическийСписок.КомпоновщикНастроек);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьСохранениеНастроек(Результат, ПараметрыОткрытия) Экспорт
	
	ОбновлениеПользовательскихНастроекДинамическогоСписка();
		
КонецПроцедуры		

&НаКлиенте
Процедура ОткрытьФормуНастроекДинамическогоСписка(Команда)

	ПользовательскиеНастройки = Новый Структура;
	ПользовательскиеНастройки.Вставить("ДоступныеГруппыЗаказчиков", НастройкиФормы.ДоступныеГруппыЗаказчиков); 
	ПользовательскиеНастройки.Вставить("ДоступныеНаправления", НастройкиФормы.ДоступныеНаправления); 
	ПользовательскиеНастройки.Вставить("ДоступныеСистемы", НастройкиФормы.ДоступныеСистемы); 
	ПользовательскиеНастройки.Вставить("ДоступныеПродукты", НастройкиФормы.ДоступныеПродукты); 
	ПользовательскиеНастройки.Вставить("ФильтрНазначена_ТекущиеРазработки", ФильтрНазначена_ТекущиеРазработки); 	
	
	ПараметрыОткрытия = Новый Структура("КлючХранилища, ПользовательскиеНастройки", 
		СвойстваСохраняемойНастройки().КлючОбъекта, ПользовательскиеНастройки); 
		
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработатьСохранениеНастроек", ЭтотОбъект);
	ОткрытьФорму("ОбщаяФорма.НастройкиДинамическогоСписка", ПараметрыОткрытия, ЭтотОбъект, , , ,
		ОписаниеОповещения, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

#КонецОбласти
