///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Изменяет порядок заявки в очереди
//
// Параметры:
//  ПараметрыПеремещения - Структура - дополнительные параметры перетаскивания
//  НовыйПорядок		 - Число - новый порядок в очереди 
//  Зафиксирован		 - Булево - Истина, если зафиксирован, иначе ложь
// 
// Возвращаемое значение:
//  Структура - результат выполнения
//
Функция ОчередьЗаявокИзменитьПорядок(Знач ПараметрыПеремещения, Знач НовыйПорядок, Знач Зафиксирован = Неопределено) Экспорт
	 
	Результат = Новый Структура("Успешно, ТекстОшибки", Истина, ""); 
	
	ВидОчереди = ПараметрыПеремещения.ВидОчереди;
	
	Если ВидОчереди = Перечисления.ВидыОчереди.НаправлениеСистемаГруппаЗаказчиков Тогда
		ЗначенияОчереди = Новый Структура;
		ЗначенияОчереди.Вставить("Направление", ПараметрыПеремещения.Направление);
		ЗначенияОчереди.Вставить("Система", ПараметрыПеремещения.Система);
		ЗначенияОчереди.Вставить("ГруппаЗаказчиков", ПараметрыПеремещения.ГруппаЗаказчиков);
		
	ИначеЕсли ВидОчереди = Перечисления.ВидыОчереди.Продукт Тогда	
		ЗначенияОчереди = Новый Структура("Продукт", ПараметрыПеремещения.Продукт);		
		
	ИначеЕсли ВидОчереди = Перечисления.ВидыОчереди.ПродуктСистема Тогда 
		ЗначенияОчереди = Новый Структура("Продукт, Система", ПараметрыПеремещения.Продукт, ПараметрыПеремещения.Система);		
		
	ИначеЕсли ВидОчереди = Перечисления.ВидыОчереди.Филиал Тогда
		ЗначенияОчереди = Новый Структура("Филиал", ПараметрыПеремещения.Филиал);	
		
	Иначе
		ЗначенияОчереди = Неопределено;	
	КонецЕсли; 
		
	Если ЗначенияОчереди <> Неопределено Тогда
		Результат = РегистрыСведений.ОчередиЗаявок.ИзменитьПорядок(ПараметрыПеремещения.Заявка, ВидОчереди, 
			ЗначенияОчереди, ПараметрыПеремещения.Порядок, НовыйПорядок, Зафиксирован);
	КонецЕсли;
			
	Возврат Результат;
	
КонецФункции

#КонецОбласти
