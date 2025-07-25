///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер ИЛИ ТолстыйКлиентОбычноеПриложение ИЛИ ВнешнееСоединение Тогда
	
#Область ПрограммныйИнтерфейс

Функция ПолучитьСсылкуНаДолжность(Знач СтрокаИдентификатор) Экспорт
	
	Результат = Новый Структура("ДолжностьСуществует, Ссылка", Ложь, Справочники.Должности.ПустаяСсылка());
	
	// Получим ссылку на справочник Должности.
	УникальныйИдентификатор = Новый УникальныйИдентификатор(СтрокаИдентификатор);
	ИдентификаторФилиала = Справочники.Должности.ПолучитьСсылку(УникальныйИдентификатор);
	
	Результат.Ссылка = ИдентификаторФилиала;
	Результат.ДолжностьСуществует = ДолжностьСуществует(ИдентификаторФилиала);
		
	Возврат Результат;
	
КонецФункции

// Возвращает структуру проверяемых данных
// 
// Возвращаемое значение:
//   - Структура
//		* Реквизиты	 - Массив	 - названия реквизитов которые требуют проверки
//		* ТабличныеЧасти	 - Структура	 - табличные части и их реквизиты которые требуют проверки.
//			Ключ - название табличной части
//			Значение - реквизит табличной части который требуется проверить
//
Функция ПроверяемыеСвойстваОбъекта() Экспорт
	
	Результат = Новый Структура("Реквизиты, ТабличныеЧасти", Новый Массив, Новый Структура);
	
	// Названия реквизитов объекта
	Результат.Реквизиты.Добавить("Наименование");
	Результат.Реквизиты.Добавить("УровеньКвалификации");
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ДолжностьСуществует(Знач ДолжностьСсылка)
		
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Должности.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.Должности КАК Должности
	|ГДЕ
	|	Должности.Ссылка = &Ссылка";
		
	Запрос.УстановитьПараметр("Ссылка", ДолжностьСсылка);
	РезультатЗапроса = Запрос.Выполнить();
	
	// Если результат запроса пустой - значит должность еще не существует.
	Возврат (НЕ РезультатЗапроса.Пустой());
	
КонецФункции

#КонецОбласти

#КонецЕсли
