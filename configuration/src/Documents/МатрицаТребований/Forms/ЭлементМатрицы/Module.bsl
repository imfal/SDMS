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
	
	//Статус "Реализовано" доступен только если статус уже "Реализовано" или "Утверждено"
	ОтображатьСтатусРеализовано = Параметры.Свойство("Статус") И 
		(Параметры.Статус = Перечисления.СтатусыТребований.Утверждено ИЛИ Параметры.Статус = Перечисления.СтатусыТребований.Реализовано);
				
	// Так как мы установили РежимВыборкаИзСписка заполним списки выбора
	Для Каждого Значение Из Перечисления.СтатусыТребований Цикл		
		Если Значение = Перечисления.СтатусыТребований.Реализовано И НЕ ОтображатьСтатусРеализовано Тогда
			Продолжить;
		Иначе
			Элементы.Статус.СписокВыбора.Добавить(Значение);
		КонецЕсли;
	КонецЦикла;

	Для Каждого Значение Из Перечисления.КаналыПоступленияТребований Цикл
		Элементы.КаналПоступления.СписокВыбора.Добавить(Значение);
	КонецЦикла;
	
	// Установим отбор в поле Автор согласно списку Заинтересованных лиц документа основания
	ЗаполнитьСписокИнициаторов();
		
	Если Параметры.Свойство("Автор") Тогда
		Автор = Параметры.Автор;
		ДатаВыявления = Параметры.ДатаВыявления;
		Статус = Параметры.Статус;
		Комментарий = Параметры.Комментарий;
		КаналПоступления = Параметры.КаналПоступления;
		Описание = Параметры.Описание;
		Комментарий = Параметры.Комментарий;
	Иначе
		ДатаВыявления = ТекущаяДатаСеанса();
		Статус = Перечисления.СтатусыТребований.Новое;
		КаналПоступления = Перечисления.КаналыПоступленияТребований.Встреча;
	КонецЕсли;
		
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Отмена(Команда)
	
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура Сохранить(Команда)
	
	ТекстСообщения = ПроверитьЗаполнениеРеквизитов();
	
	Если ЗначениеЗаполнено(ТекстСообщения) Тогда
		Сообщить(ТекстСообщения);
		Возврат;
	КонецЕсли;
	
	ПараметрыЗакрытия = Новый Структура;
	ПараметрыЗакрытия.Вставить("Инициатор", Автор);
	ПараметрыЗакрытия.Вставить("ДатаВыявления", ДатаВыявления);
	ПараметрыЗакрытия.Вставить("Статус", Статус);
	ПараметрыЗакрытия.Вставить("КаналПоступления", КаналПоступления);
	ПараметрыЗакрытия.Вставить("Описание", Описание);
	ПараметрыЗакрытия.Вставить("Комментарий", Комментарий);
	
	Закрыть(ПараметрыЗакрытия);
		
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗаполнитьСписокИнициаторов()
	
	СписокВыбора = Элементы.Автор.СписокВыбора;
	СписокВыбора.Очистить();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	РегистрСведенийЗаинтересованныеЛица.Пользователь КАК Пользователь
	|ПОМЕСТИТЬ ИсточникиТребований
	|ИЗ
	|	РегистрСведений.ЗаинтересованныеЛица КАК РегистрСведенийЗаинтересованныеЛица
	|ГДЕ
	|	РегистрСведенийЗаинтересованныеЛица.Объект = &Объект
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	Участники.Пользователь
	|ИЗ
	|	РегистрСведений.Участники КАК Участники
	|ГДЕ
	|	Участники.Объект = &Объект
	|	И НЕ Участники.Скрытый
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ИсточникиТребований.Пользователь КАК Пользователь,
	|	Пользователи.Наименование КАК Наименование
	|ИЗ
	|	ИсточникиТребований КАК ИсточникиТребований
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Пользователи КАК Пользователи
	|		ПО ((ВЫРАЗИТЬ(ИсточникиТребований.Пользователь КАК Справочник.Пользователи)) = Пользователи.Ссылка)
	|ГДЕ
	|	ИсточникиТребований.Пользователь ССЫЛКА Справочник.Пользователи
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ИсточникиТребований.Пользователь,
	|	Подписчики.Наименование
	|ИЗ
	|	ИсточникиТребований КАК ИсточникиТребований
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Подписчики КАК Подписчики
	|		ПО ((ВЫРАЗИТЬ(ИсточникиТребований.Пользователь КАК Справочник.Подписчики)) = Подписчики.Ссылка)
	|ГДЕ
	|	ИсточникиТребований.Пользователь ССЫЛКА Справочник.Подписчики
	|
	|УПОРЯДОЧИТЬ ПО
	|	Наименование";
	
	Запрос.УстановитьПараметр("Объект", Параметры.ДокументОснование);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		
		Пока Выборка.Следующий() Цикл
			СписокВыбора.Добавить(Выборка.Пользователь, Выборка.Наименование);
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Функция ПроверитьЗаполнениеРеквизитов()
		
	ТекстСообщения = "";
	
	Если НЕ ЗначениеЗаполнено(Автор) Тогда
		ТекстСообщения = ТекстСообщения + "Поле ""Автор"" является обязательным для заполнения." + Символы.ПС;	
	ИначеЕсли НЕ ЗначениеЗаполнено(ДатаВыявления) Тогда
		ТекстСообщения = ТекстСообщения + "Поле ""ДатаВыявления"" является обязательным для заполнения." + Символы.ПС;	
	ИначеЕсли НЕ ЗначениеЗаполнено(Описание) Тогда
		ТекстСообщения = ТекстСообщения + "Поле ""Описание"" является обязательным для заполнения." + Символы.ПС;	
	КонецЕсли;
		
	Возврат СокрП(ТекстСообщения);
	
КонецФункции
	
#КонецОбласти
