///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер ИЛИ ТолстыйКлиент ИЛИ ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

// Добавляет настройки доступности услуг по филиалу
//
// Параметры:
//  Филиал						 - СправочникСсылка.Филиал	 - филиал
//  НастройкиДоступностиУслуг	 - ТаблицаЗначений	 - таблица настроек доступности услуг
//		* Филиал - СправочникСсылка.Филиал
//		* ВидДеятельностиУслуги - СправочникСсылка.ВидыДеятельностиУслуг
//		* Использование - Булево
//		* Порядок - Число
//		* Автор - СправочникСсылка.Пользователи
//		* ДатаОбновления - Дата (дата и время)
//
Процедура Добавить(Знач Филиал, Знач НастройкиДоступностиУслуг) Экспорт
	
	Результат = ПроверитьДоступныеУслуги(НастройкиДоступностиУслуг, Филиал);
		
	Если Результат.Успех Тогда 
		
		НаборЗаписей = СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Филиал.Установить(Филиал);  	
		
		НаборЗаписей.Загрузить(НастройкиДоступностиУслуг);
		НаборЗаписей.Записать();                 
		
	Иначе  
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Результат.Ошибка);
	КонецЕсли;
	
КонецПроцедуры

// Удаляет настройки доступности услуг по филиалу
//
// Параметры:
//  Филиал	 - СправочникСсылка.Филиалы	 - филиал
//
Процедура Очистить(Знач Филиал) Экспорт
	
	НаборЗаписей = СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Филиал.Установить(Филиал); 
	
	НастройкиДоступностиУслуг = НаборЗаписей.Выгрузить();
	Результат = ПроверитьДоступныеУслуги(НастройкиДоступностиУслуг, Филиал);
	
	Если Результат.Успех Тогда	
		НаборЗаписей.Записать(); 
	Иначе
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Результат.Ошибка);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли   

#Область СлужебныеПроцедурыИФункции

// Проверка, что бы на каждую должность, которая есть на филиале, должна быть хотя бы одна услуга.
Функция ПроверитьДоступныеУслуги(НастройкиДоступностиУслуг, Филиал)
	
	Ответ = Новый Структура("Успех, Ошибка", Истина, "");
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	НовыеНастройки.ВидДеятельностиУслуги КАК ВидДеятельностиУслуги,
	|	НовыеНастройки.Использование КАК Использование
	|ПОМЕСТИТЬ НовыеНастройки
	|ИЗ
	|	&НовыеНастройки КАК НовыеНастройки
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ВидыДеятельностиУслуг.Ссылка КАК ВидыДеятельностиУслуг,
	|	УслугиДолжности.Должность КАК Должность,
	|	Пользователи.Ссылка КАК Сотрудник
	|ПОМЕСТИТЬ УслугиДолжности
	|ИЗ
	|	Справочник.Услуги.Должности КАК УслугиДолжности
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Пользователи КАК Пользователи
	|		ПО (Пользователи.Должность = УслугиДолжности.Должность)
	|			И (Пользователи.Филиал = &Филиал)
	|			И (НЕ Пользователи.Недействителен)
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Услуги.ВидыДеятельности КАК УслугиВидыДеятельности
	|		ПО УслугиДолжности.Ссылка = УслугиВидыДеятельности.Ссылка
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ВидыДеятельностиУслуг КАК ВидыДеятельностиУслуг
	|		ПО (ВидыДеятельностиУслуг.Услуга = УслугиВидыДеятельности.Ссылка)
	|			И (ВидыДеятельностиУслуг.ВидДеятельности = УслугиВидыДеятельности.ВидДеятельности)
	|			И (НЕ ВидыДеятельностиУслуг.ПометкаУдаления)
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Услуги КАК Услуги
	|		ПО (УслугиВидыДеятельности.Ссылка = Услуги.Ссылка)
	|			И (Услуги.Используется)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ЕСТЬNULL(НовыеНастройки.Использование, ЛОЖЬ) КАК Использование,
	|	УслугиДолжности.Должность КАК Должность,
	|	УслугиДолжности.Сотрудник КАК Сотрудник
	|ПОМЕСТИТЬ Данные
	|ИЗ
	|	УслугиДолжности КАК УслугиДолжности
	|		ЛЕВОЕ СОЕДИНЕНИЕ НовыеНастройки КАК НовыеНастройки
	|		ПО УслугиДолжности.ВидыДеятельностиУслуг = НовыеНастройки.ВидДеятельностиУслуги
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Данные.Должность КАК Должность,
	|	Данные.Сотрудник КАК Сотрудник
	|ИЗ
	|	Данные КАК Данные
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
	|			МАКСИМУМ(Данные.Использование) КАК Использование,
	|			Данные.Должность КАК Должность
	|		ИЗ
	|			Данные КАК Данные
	|		
	|		СГРУППИРОВАТЬ ПО
	|			Данные.Должность
	|		
	|		ИМЕЮЩИЕ
	|			МАКСИМУМ(Данные.Использование) = ЛОЖЬ) КАК ИспользованиеПоДолжностям
	|		ПО (ИспользованиеПоДолжностям.Должность = Данные.Должность)
	|ИТОГИ ПО
	|	Должность";  
	
	Запрос.УстановитьПараметр("НовыеНастройки", НастройкиДоступностиУслуг);
	Запрос.УстановитьПараметр("Филиал", Филиал);
	Результат = Запрос.Выполнить(); 
		
	Если НЕ Результат.Пустой() Тогда 
		
		ВыборкаДолжностей = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам); 
		МассивОшибок = Новый Массив;
		МассивОшибок.Добавить("Запись настроек невозможна");
		Шаблон = "Для должности %1 (%2) нет ни одной выбранной услуги";
		
		Пока ВыборкаДолжностей.Следующий() Цикл
			
			МассивСотрудников = Новый Массив;
			ВыборкаСотрудников = ВыборкаДолжностей.Выбрать(); 
			
			Пока ВыборкаСотрудников.Следующий() Цикл
				МассивСотрудников.Добавить(ВыборкаСотрудников.Сотрудник);
			КонецЦикла; 
			
			МассивОшибок.Добавить(СтрШаблон(Шаблон, ВыборкаДолжностей.Должность, СтрСоединить(МассивСотрудников, ", ")));
			
		КонецЦикла;	
		
		Ответ.Ошибка = СтрСоединить(МассивОшибок, Символы.ПС);
		Ответ.Успех = Ложь;
		
	КонецЕсли; 
	
	Возврат Ответ;
	
КонецФункции

#КонецОбласти
