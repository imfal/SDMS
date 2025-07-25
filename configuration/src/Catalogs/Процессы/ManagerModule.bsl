///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер ИЛИ ВнешнееСоединение ИЛИ ТолстыйКлиентОбычноеПриложение Тогда

#Область ПрограммныйИнтерфейс

// Добавляет обработчики обновления
//
// Параметры:
//  Обработчики	 - ТаблицаЗначений	 - см. ПриложениеВызовСервера.ПолучитьОбработчикиДанных
//
Процедура ДобавлениеОбработчиковОбновления(Обработчики) Экспорт     
	
	Обработчик = Обработчики.Добавить();
	Обработчик.Версия = "*";
	Обработчик.Процедура = "Справочники.Процессы.ПроверитьПредопределенныеЭлементы";
	
КонецПроцедуры

// Возвращает используемый процесс для филиала
//
// Параметры:
//  Филиал		 - СправочникСсылка.Филиалы	 - ссылка на филиал
//  ТипОбъекта	 - СправочникСсылка.ТипыОбъектовВладельцев - тип объекта владельца
// 
// Возвращаемое значение:
//  Справочникссылка.Процессы - используемый процесс для филиала
//
Функция ИспользуемыйПроцессФилиала(Знач Филиал, Знач ТипОбъекта) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	НастройкиФилиалов.Значение КАК Процесс
	|ИЗ
	|	Справочник.Филиалы КАК Филиалы
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.НастройкиФилиалов КАК НастройкиФилиалов
	|		ПО (НастройкиФилиалов.Филиал = Филиалы.Ссылка)
	|			И (НастройкиФилиалов.Настройка = &Настройка)
	|			И (НЕ НастройкиФилиалов.Значение = ЗНАЧЕНИЕ(Справочник.Процессы.ПустаяСсылка))
	|			И (Филиалы.Ссылка = &Филиал)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	Процессы.Ссылка
	|ИЗ
	|	Справочник.Процессы КАК Процессы
	|ГДЕ
	|	Процессы.Филиал = ЗНАЧЕНИЕ(Справочник.Филиалы.ПустаяСсылка)
	|	И Процессы.ТипОбъекта = &ТипОбъекта
	|	И Процессы.ИспользоватьОбщий";
	
	Запрос.УстановитьПараметр("Филиал", Филиал);
	Запрос.УстановитьПараметр("ТипОбъекта", ТипОбъекта);  
	Запрос.УстановитьПараметр("Настройка", ОбщегоНазначенияВызовСервера.ЗначениеРеквизитаОбъекта(ТипОбъекта, "Настройка"));  
	
	РезультатЗапроса = Запрос.Выполнить();
	Результат = Неопределено;
	
	Если  НЕ РезультатЗапроса.Пустой() Тогда 
		
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		Результат = Выборка.Процесс;  
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Возвращает действие смены исполнителя
//
// Параметры:
//  ТипОбъекта		 - СправочникСсылка.ТипыОбъектовВладельцев	 - тип объекта
//  ДанныеОбъекта	 - Структура	 - заполненная структура данных объекта: Филиал, СтарыйСтатус, НовыйСтатус
// 
// Возвращаемое значение:
//  СправочникСсылка.ДействияПриСменеСтатуса, Неопределено - ссылка на действие или Неопределено в случае отсутствия
//
Функция ПолучитьДействияСменыСтатуса(Знач ТипОбъекта, Знач ДанныеОбъекта, ВидДействия) Экспорт
		
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ДействияПриПереходахПроцесса.Действие КАК Действие
	|ИЗ
	|	Справочник.Процессы КАК Процессы
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Процессы.НастройкиСменыСтатусов КАК НастройкиСменыСтатусовПроцесса
	|		ПО Процессы.Ссылка = НастройкиСменыСтатусовПроцесса.Ссылка
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Процессы.ДействияПриПереходах КАК ДействияПриПереходахПроцесса
	|		ПО (НастройкиСменыСтатусовПроцесса.Ссылка = ДействияПриПереходахПроцесса.Ссылка)
	|			И (НастройкиСменыСтатусовПроцесса.ИдентификаторПерехода = ДействияПриПереходахПроцесса.ИдентификаторПерехода)
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ДействияПриСменеСтатуса КАК ДействияПриСменеСтатуса
	|		ПО (ДействияПриПереходахПроцесса.Действие = ДействияПриСменеСтатуса.Ссылка)
	|ГДЕ
	|	Процессы.Ссылка = &Процесс
	|	И Процессы.ТипОбъекта = &ТипОбъекта
	|	И НастройкиСменыСтатусовПроцесса.ТекущийСтатус = &СтарыйСтатус
	|	И НастройкиСменыСтатусовПроцесса.СледующийСтатус = &НовыйСтатус
	|	И ДействияПриСменеСтатуса.ВидДействия = &ВидДействия";
	
	
	Запрос.УстановитьПараметр("ВидДействия", ВидДействия);
	Запрос.УстановитьПараметр("Процесс", ИспользуемыйПроцессФилиала(ДанныеОбъекта.Филиал, ТипОбъекта));
	Запрос.УстановитьПараметр("ТипОбъекта", ТипОбъекта);
	Запрос.УстановитьПараметр("СтарыйСтатус", ДанныеОбъекта.СтарыйСтатус);
	Запрос.УстановитьПараметр("НовыйСтатус", ДанныеОбъекта.НовыйСтатус);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		
		Результат = Выборка.Действие;
	Иначе
		Результат = Неопределено;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Формирует список статусов для типа объекта, в которые возможен переход согласно процессу филиала
//
// Параметры:
//  Процесс	 - СправочникСсылка.Процессы	 - процесс
//  ТипОбъекта	 - СправочникСсылка.ТипыОбъектовВладельцев	 - тип объекта, к которому относится статус
//  ВернутьСписокЗначений	 - Булево	 - если Истина - вернет список значений, если Ложь - массив ссылок
// 
// Возвращаемое значение:
//  СписокЗначений, Массив - набор статусов процесса филиала
//
Функция ПолучитьСтатусыПроцессаФилиала(Знач Процесс, Знач ТипОбъекта, Знач ВернутьСписокЗначений = Истина) Экспорт
	
	Если ВернутьСписокЗначений Тогда
		Результат = Новый СписокЗначений;
	Иначе
		Результат = Новый Массив;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ПроцессыНастройкиСменыСтатусов.ТекущийСтатус КАК Ссылка,
	|	СтатусыОбъектов.Наименование КАК Наименование,
	|	СтатусыОбъектов.ИмяКартинкиВБиблиотеке КАК ИмяКартинки,
	|	СтатусыОбъектов.Порядок КАК Порядок
	|ИЗ
	|	Справочник.Процессы КАК Процессы
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Процессы.НастройкиСменыСтатусов КАК ПроцессыНастройкиСменыСтатусов
	|		ПО Процессы.Ссылка = ПроцессыНастройкиСменыСтатусов.Ссылка
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтатусыОбъектов КАК СтатусыОбъектов
	|		ПО (ПроцессыНастройкиСменыСтатусов.ТекущийСтатус = СтатусыОбъектов.Ссылка)
	|ГДЕ
	|	Процессы.Ссылка = &Процесс
	|	И Процессы.ТипОбъекта = &ТипОбъекта
	|
	|УПОРЯДОЧИТЬ ПО
	|	СтатусыОбъектов.Порядок";
	
	Запрос.УстановитьПараметр("Процесс", Процесс);
	Запрос.УстановитьПараметр("ТипОбъекта", ТипОбъекта);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		Пока Выборка.Следующий() Цикл
			Если ВернутьСписокЗначений Тогда
				ИмяКартинки = СтрШаблон("Статус%1", Выборка.ИмяКартинки);
				
				НовыйЭлемент = Результат.Добавить();
				НовыйЭлемент.Значение = Выборка.Ссылка;
				НовыйЭлемент.Представление = Выборка.Наименование;
				НовыйЭлемент.Картинка = БиблиотекаКартинок[ИмяКартинки];
			Иначе
				Результат.Добавить(Выборка.Ссылка);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Проверяет предопределенные настройки
//
Процедура ПроверитьПредопределенныеЭлементы() Экспорт 
	
	ЗаполнитьПроцессДляЗадачи();
	ЗаполнитьПроцессДляВнутреннегоЗадания();                                 	
	
КонецПроцедуры     

//////////////////////////////////////////
// ИСТОРИЯ ИЗМЕНЕНИЙ ОБЪЕКТА

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
	
	ПоляТабличнойЧасти = Новый Массив;
	ПоляТабличнойЧасти.Добавить("ТекущийСтатус");
	ПоляТабличнойЧасти.Добавить("СледующийСтатус");
	
	ДанныеТабличнойЧасти = Новый Структура;
	ДанныеТабличнойЧасти.Вставить("Поля", ПоляТабличнойЧасти);
	ДанныеТабличнойЧасти.Вставить("КлючевоеПоле", "ТекущийСтатус");
	
	Результат.ТабличныеЧасти.Вставить("НастройкиСменыСтатусов", ДанныеТабличнойЧасти);

	ПоляТабличнойЧасти = Новый Массив;
	ПоляТабличнойЧасти.Добавить("Метрика");
	ПоляТабличнойЧасти.Добавить("СтатусНачало");
	ПоляТабличнойЧасти.Добавить("СтатусКонец");
	
	ДанныеТабличнойЧасти = Новый Структура;
	ДанныеТабличнойЧасти.Вставить("Поля", ПоляТабличнойЧасти);
	ДанныеТабличнойЧасти.Вставить("КлючевоеПоле", "Метрика");
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ЗаполнитьПроцессДляЗадачи()        
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Процессы.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.Процессы КАК Процессы
	|ГДЕ
	|	Процессы.Филиал = ЗНАЧЕНИЕ(Справочник.Филиалы.ПустаяСсылка)
	|	И Процессы.ТипОбъекта = ЗНАЧЕНИЕ(Справочник.ТипыОбъектовВладельцев.Документ_Задача)";  
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда  
		НовыйПроцесс = Справочники.Процессы.СоздатьЭлемент();
		НовыйПроцесс.Наименование = "Общий процесс";
		НовыйПроцесс.ИспользоватьОбщий = Истина;
		НовыйПроцесс.ТипОбъекта = Справочники.ТипыОбъектовВладельцев.Документ_Задача; 
		
		НастройкиСмены = НовыйПроцесс.НастройкиСменыСтатусов;
		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Новый, Справочники.СтатусыОбъектов.ВРаботе);
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Новый, Справочники.СтатусыОбъектов.ВРеализацию);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Новый, Справочники.СтатусыОбъектов.Рассмотрение);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Новый, Справочники.СтатусыОбъектов.Отклонен);
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Новый, Справочники.СтатусыОбъектов.Решен);
		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Рассмотрение, Справочники.СтатусыОбъектов.ВРеализацию);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Рассмотрение, Справочники.СтатусыОбъектов.НаДоработку);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Рассмотрение, Справочники.СтатусыОбъектов.Отклонен);		
		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.НаДоработку, Справочники.СтатусыОбъектов.Рассмотрение);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.НаДоработку, Справочники.СтатусыОбъектов.Новый);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.НаДоработку, Справочники.СтатусыОбъектов.Отклонен);		
		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.ВРеализацию, Справочники.СтатусыОбъектов.ВРаботе);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.ВРеализацию, Справочники.СтатусыОбъектов.Отклонен);		
		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.ВРаботе, Справочники.СтатусыОбъектов.Публикация);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.ВРаботе, Справочники.СтатусыОбъектов.CodeReview);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.ВРаботе, Справочники.СтатусыОбъектов.Отклонен);	
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.ВРаботе, Справочники.СтатусыОбъектов.Приостановлен);	
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.ВРаботе, Справочники.СтатусыОбъектов.Тестирование);	
		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Публикация, Справочники.СтатусыОбъектов.CodeReview);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Публикация, Справочники.СтатусыОбъектов.ВРаботе);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Публикация, Справочники.СтатусыОбъектов.Тестирование);		
		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Приостановлен, Справочники.СтатусыОбъектов.Отклонен);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Приостановлен, Справочники.СтатусыОбъектов.ВРаботе);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Приостановлен, Справочники.СтатусыОбъектов.Тестирование);		
	
        ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Тестирование, Справочники.СтатусыОбъектов.Публикация);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Тестирование, Справочники.СтатусыОбъектов.CodeReview);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Тестирование, Справочники.СтатусыОбъектов.ВРаботе);		
	    ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Тестирование, Справочники.СтатусыОбъектов.Приостановлен);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Тестирование, Справочники.СтатусыОбъектов.Протестирован);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Тестирование, Справочники.СтатусыОбъектов.Тестирование);		
	    ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Тестирование, Справочники.СтатусыОбъектов.Решен);		
		
        ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Протестирован, Справочники.СтатусыОбъектов.Публикация);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Протестирован, Справочники.СтатусыОбъектов.Решен);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Протестирован, Справочники.СтатусыОбъектов.ВРаботе);		
	    ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Протестирован, Справочники.СтатусыОбъектов.Тестирование);		
		
        ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.CodeReview, Справочники.СтатусыОбъектов.Публикация);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.CodeReview, Справочники.СтатусыОбъектов.Тестирование);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.CodeReview, Справочники.СтатусыОбъектов.ВРаботе);
		
		НовыйПроцесс.Записать();
	КонецЕсли;
	
КонецПроцедуры 

Процедура ЗаполнитьПроцессДляВнутреннегоЗадания()        
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Процессы.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.Процессы КАК Процессы
	|ГДЕ
	|	Процессы.Филиал = ЗНАЧЕНИЕ(Справочник.Филиалы.ПустаяСсылка)
	|	И Процессы.ТипОбъекта = ЗНАЧЕНИЕ(Справочник.ТипыОбъектовВладельцев.Документ_ВнутреннееЗадание)";  
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда  
		НовыйПроцесс = Справочники.Процессы.СоздатьЭлемент();
		НовыйПроцесс.Наименование = "Общий процесс";
		НовыйПроцесс.ИспользоватьОбщий = Истина;
		НовыйПроцесс.ТипОбъекта = Справочники.ТипыОбъектовВладельцев.Документ_ВнутреннееЗадание; 
		
		НастройкиСмены = НовыйПроцесс.НастройкиСменыСтатусов;
		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Новый, Справочники.СтатусыОбъектов.ВРаботе);
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Новый, Справочники.СтатусыОбъектов.Отклонен);
		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.ВРаботе, Справочники.СтатусыОбъектов.Решен);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.ВРаботе, Справочники.СтатусыОбъектов.Приостановлен);	
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.ВРаботе, Справочники.СтатусыОбъектов.Тестирование);	
		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Приостановлен, Справочники.СтатусыОбъектов.Отклонен);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Приостановлен, Справочники.СтатусыОбъектов.ВРаботе);		
		ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Приостановлен, Справочники.СтатусыОбъектов.Решен);		
	
        ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Тестирование, Справочники.СтатусыОбъектов.ВРаботе);		
	    ДобавитьСтрокуСменыСтатусов(НастройкиСмены, Справочники.СтатусыОбъектов.Тестирование, Справочники.СтатусыОбъектов.Решен);		
		
		НовыйПроцесс.Записать();
	КонецЕсли;
	
КонецПроцедуры 

Процедура ДобавитьСтрокуСменыСтатусов(НастройкиСменыСтатусов, Текущий, Следующий)
	
	НоваяСтрока = НастройкиСменыСтатусов.Добавить();
	НоваяСтрока.ТекущийСтатус = Текущий;
	НоваяСтрока.СледующийСтатус = Следующий;
	НоваяСтрока.БыстрыйДоступ = Истина;
	НоваяСтрока.ИдентификаторПерехода = Новый УникальныйИдентификатор;
	НоваяСтрока.Роль = Справочники.РолиУчастников.ВсеРоли;

КонецПроцедуры

#КонецОбласти

#КонецЕсли
