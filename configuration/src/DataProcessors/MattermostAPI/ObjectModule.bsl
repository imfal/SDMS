///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

 #Область ОписаниеПеременных

Перем НастройкиПодключения;

#КонецОбласти

#Область ПрограммныйИнтерфейс

// Отправляет сообщение в мессенджер в указанный канал.
//
// Параметры:
//  ТекстСообщения	 - Строка	 - текст сообщения, который будет отправлен.
//  Идентификатор	 - Строка	 - Идентификатор канала.
//
Процедура ОтправитьСообщение(Знач ТекстСообщения, Знач Идентификатор) Экспорт
		
	HTTPСоединение = ПолучитьHTTPСоединение();
	
	ЗаголовкиЗапроса = Новый Соответствие;
	ЗаголовкиЗапроса.Вставить("Content-type", "application/json");
	
	Данные = ПолучитьДанныеДляАвторизации();
	Если Данные = Неопределено Тогда
		Возврат;
	КонецЕсли;
		
	РезультатАвторизации = ВыполнитьАвторизацию(HTTPСоединение, ЗаголовкиЗапроса, Данные);
	
	Если РезультатАвторизации.Успешно Тогда		
		ДанныеСервера = РезультатАвторизации.Данные;		
		ЗаголовкиЗапроса.Вставить("Authorization", "Bearer " + ДанныеСервера.Токен);
		ОтправитьСообщениеЗапросом(HTTPСоединение, ЗаголовкиЗапроса, ДанныеСервера.Идентификатор, Идентификатор, ТекстСообщения);	
		ЗакрытьАвторизацию(HTTPСоединение, ЗаголовкиЗапроса);
	КонецЕсли;
	
КонецПроцедуры

// Отправляет сообщения пользователям мессенджера
//
// Параметры:
//  ТаблицаСообщений - ТаблицаЗначений	 - таблица сообщений и получателей
//		* Получатель	 - Строка	 - имя пользователя/ идентификатор мессенджера
//		* ТестСообщения	 - Строка	 - текст сообщения
//
Процедура ОтправитьСообщенияПользователям(Знач ТаблицаСообщений) Экспорт
	
	ПодстрокаЗаменыДляВебКлиента = WebОкружениеВызовСервера.АдресПубликацииИнформационнойБазы();
	
	// Получение соединения
	HTTPСоединение = ПолучитьHTTPСоединение();
	
	ЗаголовкиЗапроса = Новый Соответствие;
	ЗаголовкиЗапроса.Вставить("Content-type", "application/json");
	
	ДанныеДляАвторизации = ПолучитьДанныеДляАвторизации();
	Если ДанныеДляАвторизации = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	РезультатАвторизации = ВыполнитьАвторизацию(HTTPСоединение, ЗаголовкиЗапроса, ДанныеДляАвторизации);
	
	Если РезультатАвторизации.Успешно Тогда
		
		ДанныеСервера = РезультатАвторизации.Данные;		
		ЗаголовкиЗапроса.Вставить("Authorization", "Bearer " + ДанныеСервера.Токен);
		
		Для Каждого СтрокаТаблицы Из ТаблицаСообщений Цикл
			ТекстСообщения = СтрЗаменить(СтрокаТаблицы.ТекстСообщения, "<!-- sdms_link_prefix -->", ПодстрокаЗаменыДляВебКлиента);
			ОтправитьСообщениеЗапросом(HTTPСоединение, ЗаголовкиЗапроса, ДанныеСервера.Идентификатор, 
				СтрокаТаблицы.Получатель, ТекстСообщения);	
		КонецЦикла;   
		
		ЗакрытьАвторизацию(HTTPСоединение, ЗаголовкиЗапроса); 		
	КонецЕсли;
	
КонецПроцедуры

// Функция - Получить IDПользователя
//
// Параметры:
//  Почта	 - Строка	 - почта пользователя
// 
// Возвращаемое значение:
//  Структура - результат получения Id пользователя
//
Функция ПолучитьIDПользователя(Знач Почта) Экспорт
	
	Результат = Новый Структура("Успешно, Сообщение, Данные", Истина, "", Новый Структура);
	HTTPСоединение = ПолучитьHTTPСоединение();
	
	ЗаголовкиЗапроса = Новый Соответствие;
	ЗаголовкиЗапроса.Вставить("Content-type", "application/json");
	
	Данные = ПолучитьДанныеДляАвторизации();
	Если Данные = Неопределено Тогда
		Результат.Успешно = Ложь;			
		Возврат Результат;
	КонецЕсли;
		
	РезультатАвторизации = ВыполнитьАвторизацию(HTTPСоединение, ЗаголовкиЗапроса, Данные);
	
	Если РезультатАвторизации.Успешно Тогда
		
		ЗаголовкиЗапроса.Вставить("Content-type", "application/json");		
		ЗаголовкиЗапроса.Вставить("Authorization", "Bearer " + РезультатАвторизации.Данные.Токен);
		JSONЗапрос = СтрШаблон("{""term"":""%1""}", Почта);
		
		HTTPЗапрос = Новый HTTPЗапрос("/api/v4/users/search", ЗаголовкиЗапроса);
		HTTPЗапрос.УстановитьТелоИзСтроки(JSONЗапрос);
		
		Попытка
			HTTPОтвет = HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос); 
		Исключение
			Результат.Успешно = Ложь;			
			Результат.Сообщение = "Не удалось получить id пользователя Mattermost по причине:" + ОписаниеОшибки();
		КонецПопытки;
		
		// Если не удалось авторизоваться, алгоритм завершается
		Если Результат.Успешно И HTTPОтвет.КодСостояния <> 200 Тогда
			Результат.Успешно = Ложь;			
			Результат.Сообщение = "Не удалось получить id пользователя Mattermost. Код ответа: " + Строка(HTTPОтвет.КодСостояния);
		КонецЕсли;
		
		Если Результат.Успешно Тогда  
			Данные = ОбщегоНазначения.ПрочитатьСодержимоеJSON(HTTPОтвет.ПолучитьТелоКакСтроку());
			Если Данные.Количество() = 1 Тогда
				Результат.Данные = Новый Структура("Адрес, Идентификатор", Данные[0].username, Данные[0].id);
			КонецЕсли;
		КонецЕсли; 
		
		ЗакрытьАвторизацию(HTTPСоединение, ЗаголовкиЗапроса); 
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Обновляет идентификаторы пользователей SDMS
//
// Параметры:
//  ПочтаПользователь	 - Соответствие	 - соответствие где ключ - почта, а значение пользователь
//
Процедура ОбновитьИдентификаторыПользователейSDMS(ПочтаПользователь) Экспорт
			
	HTTPСоединение = ПолучитьHTTPСоединение();
	
	ЗаголовкиЗапроса = Новый Соответствие;
	ЗаголовкиЗапроса.Вставить("Content-type", "application/json");
	
	Данные = ПолучитьДанныеДляАвторизации();
	Если Данные = Неопределено Тогда
		Возврат;
	КонецЕсли;
		
	РезультатАвторизации = ВыполнитьАвторизацию(HTTPСоединение, ЗаголовкиЗапроса, Данные);
	
	Если РезультатАвторизации.Успешно Тогда
		
		ЗаголовкиЗапроса.Вставить("Content-type", "application/json");		
		ЗаголовкиЗапроса.Вставить("Authorization", "Bearer " + РезультатАвторизации.Данные.Токен);		
		HTTPЗапрос = Новый HTTPЗапрос("api/v4/users/stats", ЗаголовкиЗапроса);  
		
		Попытка
			HTTPОтвет = HTTPСоединение.Получить(HTTPЗапрос);
		Исключение
			Успешно = Ложь;
			ЗаписатьСобытие(УровеньЖурналаРегистрации.Ошибка,
				"Не удалось получить общее число пользователей Mattermost по причине:" + ОписаниеОшибки(), 
				"ОбновитьИдентификаторыПользователейSDMS");
			Возврат;
		КонецПопытки;	
		
		СтрокаJSON = HTTPОтвет.ПолучитьТелоКакСтроку();
		Данные = ОбщегоНазначения.ПрочитатьСодержимоеJSON(СтрокаJSON);
		Всего = Данные.total_users_count;
		
		ВыгруженыВсеЗаписи = Ложь;
		Количество = 200;
		Сдвиг = 0;    
		КоличествоВсего = 0;
		КоличествоИзмененных = 0;
		КоличествоНеудачныхПопыток = 0;
		
		Пока НЕ ВыгруженыВсеЗаписи Цикл
			Успешно = Истина;
			АдресРесурса = СтрШаблон("/api/v4/users?page=%1&per_page=%2", Формат(Сдвиг, "ЧГ=0"), Формат(Количество, "ЧГ=0"));
			HTTPЗапрос = Новый HTTPЗапрос(АдресРесурса, ЗаголовкиЗапроса);
			
			Попытка
				HTTPОтвет = HTTPСоединение.Получить(HTTPЗапрос);
			Исключение
				Успешно = Ложь;
				ЗаписатьСобытие(УровеньЖурналаРегистрации.Ошибка,
					"Не удалось авторизоваться на сервере Mattermost по причине:" + ОписаниеОшибки(), 
					"ОбновитьИдентификаторыПользователейSDMS");
				КоличествоНеудачныхПопыток = КоличествоНеудачныхПопыток + 1;
			КонецПопытки;
			
			Если Успешно И HTTPОтвет.КодСостояния <> 200 Тогда
				Успешно = Ложь;
				ЗаписатьСобытие(УровеньЖурналаРегистрации.Ошибка,
					"Не удалось авторизоваться на сервере Mattermost. Код ответа: " + Строка(HTTPОтвет.КодСостояния), 
					"ОбновитьИдентификаторыПользователейSDMS");
				КоличествоНеудачныхПопыток = КоличествоНеудачныхПопыток + 1;
			КонецЕсли;
			
			Если Успешно Тогда
				Попытка
					СтрокаJSON = HTTPОтвет.ПолучитьТелоКакСтроку();
					Данные = ОбщегоНазначения.ПрочитатьСодержимоеJSON(СтрокаJSON);
				Исключение
					Успешно = Ложь;
					ЗаписатьСобытие(УровеньЖурналаРегистрации.Ошибка,
						"Не удалось прочитать JSON.
						|СтрокаJSON: " + СтрокаJSON, "ОбновитьИдентификаторыПользователейSDMS");
					КоличествоНеудачныхПопыток = КоличествоНеудачныхПопыток + 1;
				КонецПопытки;
				
				Если Успешно Тогда
					Сдвиг = Сдвиг + 1;
					КоличествоВсего = КоличествоВсего + Данные.Количество();  
					
					Для Каждого Пользователь Из Данные Цикл
						АдресПочты = НРег(Пользователь.email);
						Адрес = Пользователь.username;
						Идентификатор = Пользователь.id;	
						ПользовательSDMS = ПочтаПользователь.Получить(АдресПочты);
						
						Если ПользовательSDMS <> Неопределено И 
							(ПользовательSDMS.Идентификатор <> Идентификатор ИЛИ ПользовательSDMS.Адрес <> Адрес) Тогда
							РегистрыСведений.АдресаПолучателей.Добавить(ПользовательSDMS.Ссылка, 
								Справочники.Мессенджеры.Mattermost, Адрес, Идентификатор);
							КоличествоИзмененных = КоличествоИзмененных + 1;
						КонецЕсли;
					КонецЦикла;
					
					ВыгруженыВсеЗаписи = (КоличествоВсего >= Всего);
				КонецЕсли;
			КонецЕсли;
			
			Если КоличествоНеудачныхПопыток = 3 Тогда
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		Если ВыгруженыВсеЗаписи Тогда
			ЗаписатьСобытие(УровеньЖурналаРегистрации.Информация,
				"Успешное завершение задания. Mattermost пользователей изменено: " + КоличествоИзмененных,
				"ОбновитьИдентификаторыПользователейSDMS");
		Иначе
			ЗаписатьСобытие(УровеньЖурналаРегистрации.Информация,
				"Выполнение задания прервано. Mattermost пользователей изменено: " + КоличествоИзмененных,
				"ОбновитьИдентификаторыПользователейSDMS");
		КонецЕсли;
		
		ЗакрытьАвторизацию(HTTPСоединение, ЗаголовкиЗапроса); 
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Выполняет попытку авторизации на сервере мессенджера и возвращает токены
//
// Параметры:
//  HTTPСоединение	 - HTTPСоединение	 - соединение, которое будет использовано для отправки запроса
//  ЗаголовкиЗапроса - Соответствие	 - заголовки запроса
//  Данные			 - Структура	 - авторизационные данные
// 
// Возвращаемое значение:
//   - Структура
//		* Успешно	 - Булево	 - признак успешности авторизации
//		* Данные	 - Структура	 - данные тела ответа
//
Функция ВыполнитьАвторизацию(Знач HTTPСоединение, Знач ЗаголовкиЗапроса, Знач Данные)
	
	Результат = Новый Структура("Успешно, Данные", Истина, Неопределено);
	
	// Подключение к серверу мессенджера и попытка авторизации
	JSONЗапрос = СтрШаблон("{""login_id"": ""%1"", ""password"": ""%2""}",
		Данные.Пользователь, Данные.Пароль);	
	HTTPЗапрос = Новый HTTPЗапрос("/api/v4/users/login", ЗаголовкиЗапроса);
	HTTPЗапрос.УстановитьТелоИзСтроки(JSONЗапрос);
	
	Попытка
		HTTPОтвет = HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос); 
	Исключение
		Результат.Успешно = Ложь;
		
		ЗаписатьСобытие(УровеньЖурналаРегистрации.Ошибка, 
			"Не удалось авторизоваться на сервере Mattermost по причине:" + ОписаниеОшибки());
	КонецПопытки;
	
	// Если не удалось авторизоваться, алгоритм завершается
	Если Результат.Успешно И HTTPОтвет.КодСостояния <> 200 Тогда
		Результат.Успешно = Ложь;
		
		ЗаписатьСобытие(УровеньЖурналаРегистрации.Ошибка, 
			"Не удалось авторизоваться на сервере Mattermost. Код ответа: " + Строка(HTTPОтвет.КодСостояния));
	КонецЕсли;
	
	Если Результат.Успешно Тогда  
		Данные = ОбщегоНазначения.ПрочитатьСодержимоеJSON(HTTPОтвет.ПолучитьТелоКакСтроку());
		Результат.Данные = Новый Структура("Токен, Идентификатор", HTTPОтвет.Заголовки["Token"], Данные.id);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Завершает авторизованную сессию
//
// Параметры:
//  HTTPСоединение	 - HTTPСоединение	 - соединение для отправки запроса
//  ЗаголовкиЗапроса - Соответствие	 - заголовки запроса
//
Процедура ЗакрытьАвторизацию(Знач HTTPСоединение, Знач ЗаголовкиЗапроса)
	
	// Отключение от сервера
	HTTPЗапрос = Новый HTTPЗапрос("/api/v4/users/logout", ЗаголовкиЗапроса);
	
	Попытка
		HTTPОтвет = HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос);
	Исключение
		ЗаписатьСобытие(УровеньЖурналаРегистрации.Ошибка, 
			"Не удалось закрыть авторизацию на сервере Mattermost по причине:" + ОписаниеОшибки());			
	КонецПопытки;
	
КонецПроцедуры

// Добавляет информацию в журнал регистрации.
//
// Параметры:
//  Уровень		 - УровеньЖурналаРегистрации - тип события.
//  Комментарий	 - Строка					 - комментарий события.
//  ИмяМетода	 - Строка					 - имя вызываемого метода
//
Процедура ЗаписатьСобытие(Знач Уровень, Знач Комментарий, Знач ИмяМетода = Неопределено)
	
	ИмяМетода = ?(ИмяМетода = Неопределено, "Обработка.MattermostAPI", СтрШаблон("Обработка.MattermostAPI.%1", ИмяМетода));
	ЗаписьЖурналаРегистрации(ИмяМетода, Уровень, , , Комментарий);
	
КонецПроцедуры

Процедура ОтправитьСообщениеЗапросом(Знач HTTPСоединение, Знач ЗаголовкиЗапроса, 
		Знач Отправитель, Знач Идентификатор, Знач ТекстСообщения)
	
	// Если личное сообщение, то нужно получить по паре id от кого и id куда
	// найти id общего канала.
	Результат = ЭтоЛичноесообщение(HTTPСоединение, ЗаголовкиЗапроса, Идентификатор);
	
	Если НЕ Результат.Успешно Тогда
		Возврат;
	КонецЕсли;
	
	Если Результат.Данные.Личное Тогда  
		Результат = ПолучитьИдентификаторЛичногоСообщения(HTTPСоединение, ЗаголовкиЗапроса, Отправитель, Идентификатор);
		
		Если НЕ Результат.Успешно Тогда
			Возврат;
		Иначе  
			Получатель = Результат.Данные.id;
		КонецЕсли;	
	Иначе
		Получатель = Идентификатор;
	КонецЕсли;	
	
	JSONЗапрос = ПолучитьТелоЗапроса(Получатель, ТекстСообщения);
	
	HTTPЗапрос = Новый HTTPЗапрос("/api/v4/posts", ЗаголовкиЗапроса);
	HTTPЗапрос.УстановитьТелоИзСтроки(JSONЗапрос);
	
	Попытка
		HTTPОтвет = HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос);
	Исключение
		Комментарий = СтрШаблон("Не удалось отправить сообщение.
		|
		|Текст сообщения: %1
		|Ошибка: %2", ТекстСообщения, ОписаниеОшибки());
		
		ЗаписатьСобытие(УровеньЖурналаРегистрации.Ошибка, Комментарий, "ОтправитьСообщение");
	КонецПопытки;
	
КонецПроцедуры

// Возвращает соединение
// 
// Возвращаемое значение:
//   - HTTPСоединение
//
Функция ПолучитьHTTPСоединение()
	
	СоединениеHTTP = Неопределено;
	
	Если ЗначениеЗаполнено(НастройкиПодключения.АдресСервера) Тогда
		СоединениеHTTP = Новый HTTPСоединение(НастройкиПодключения.АдресСервера, НастройкиПодключения.Порт, , , , 
												НастройкиПодключения.Таймаут, НастройкиПодключения.ЗащищенноеСоединение);
	Иначе
		Комментарий = "Не удалось определить адрес сервера мессенджера Mattermost.";
		ЗаписатьСобытие(УровеньЖурналаРегистрации.Ошибка, Комментарий, "ПолучитьHTTPСоединение");
	КонецЕсли;
	
	Возврат СоединениеHTTP;
	
КонецФункции

// Получает авторизационные данные из безопасного хранилища
// 
// Возвращаемое значение:
//   - Структура
//
Функция ПолучитьДанныеДляАвторизации()
	
	// Получение данных подключения из информационной базы
	УстановитьПривилегированныйРежим(Истина);
	
	Данные = РегистрыСведений.БезопасноеХранилищеДанных.ПолучитьДанные(
		Перечисления.НазначенияДанныхБезопасногоХранилища.НастройкиПодключенияКMattermost);
		
	УстановитьПривилегированныйРежим(Ложь);
		
	// Если не удалось получить параметры подключения, выполняется прерывание выполнения
	Если Данные = Неопределено Тогда
		ЗаписатьСобытие(УровеньЖурналаРегистрации.Ошибка, 
			"Не удалось получить из безопасного хранилища параметры подключения к серверу Mattermost");
	КонецЕсли;
	
	Возврат Данные;
	
КонецФункции

Функция	ПолучитьИдентификаторЛичногоСообщения(HTTPСоединение, ЗаголовкиЗапроса, Отправитель, Получатель)
	
	Результат = Новый Структура("Успешно, Данные", Истина, Неопределено);
	
	JSONЗапрос = СтрШаблон("[""%1"", ""%2""]", Отправитель, Получатель);
	
	HTTPЗапрос = Новый HTTPЗапрос("/api/v4/channels/direct", ЗаголовкиЗапроса);
	HTTPЗапрос.УстановитьТелоИзСтроки(JSONЗапрос);
	
	Попытка
		HTTPОтвет = HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос); 
	Исключение
		Результат.Успешно = Ложь;
		
		ЗаписатьСобытие(УровеньЖурналаРегистрации.Ошибка, 
			"Не удалось получить идентификатор группы для личного сообщения Mattermost по причине:" + ОписаниеОшибки());
	КонецПопытки;
	
	// Если не удалось авторизоваться, алгоритм завершается
	Если Результат.Успешно И HTTPОтвет.КодСостояния <> 201 Тогда
		Результат.Успешно = Ложь;
		
		ЗаписатьСобытие(УровеньЖурналаРегистрации.Ошибка, 
			"Не удалось получить идентификатор группы для личного сообщения Mattermost. Код ответа: " + Строка(HTTPОтвет.КодСостояния));
	КонецЕсли;
	
	Если Результат.Успешно Тогда  
		Данные = ОбщегоНазначения.ПрочитатьСодержимоеJSON(HTTPОтвет.ПолучитьТелоКакСтроку());
		Результат.Данные = Новый Структура("id", Данные.id);
	КонецЕсли;
	
	Возврат Результат;	
	
КонецФункции

// Формирует JSON-строку тела запроса
//
// Параметры:
//  Получатель		 - Строка	 - имя пользователя/ идентификатор
//  ТекстСообщения	 - Строка	 - текст сообщения
// 
// Возвращаемое значение:
//   - Строка
//
Функция ПолучитьТелоЗапроса(Знач Получатель, Знач ТекстСообщения)
	
	ТекстСообщения = ОбщегоНазначения.ЭкранироватьСимволыJSON(ТекстСообщения);
	
	Возврат СтрШаблон("{""channel_id"": ""%1"", ""message"": ""%2""}", Получатель, ТекстСообщения);
	
КонецФункции

Функция ЭтоЛичноесообщение(HTTPСоединение, ЗаголовкиЗапроса, Получатель)
	
	Результат = Новый Структура("Успешно, Данные", Истина, Неопределено);
	
	JSONЗапрос = СтрШаблон("[""%1""]", Получатель);
	
	HTTPЗапрос = Новый HTTPЗапрос("/api/v4/users/ids", ЗаголовкиЗапроса);
	HTTPЗапрос.УстановитьТелоИзСтроки(JSONЗапрос);
	
	Попытка
		HTTPОтвет = HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос); 
	Исключение
		Результат.Успешно = Ложь;
		
		ЗаписатьСобытие(УровеньЖурналаРегистрации.Ошибка, 
			"Не удалось получить признак личного сообщения Mattermost по причине:" + ОписаниеОшибки());
	КонецПопытки;
	
	Если Результат.Успешно И HTTPОтвет.КодСостояния <> 200 Тогда
		Результат.Успешно = Ложь;
		
		ЗаписатьСобытие(УровеньЖурналаРегистрации.Ошибка, 
			"Не удалосьполучить признак личного сообщения Mattermost. Код ответа: " + Строка(HTTPОтвет.КодСостояния));
	КонецЕсли;
	
	Если Результат.Успешно Тогда  
		Данные = ОбщегоНазначения.ПрочитатьСодержимоеJSON(HTTPОтвет.ПолучитьТелоКакСтроку());
		Результат.Данные = Новый Структура("Личное", Данные.Количество() > 0);
	КонецЕсли;
	
	Возврат Результат;	
	
КонецФункции
	
#КонецОбласти  

#Область Инициализация

НастройкиПодключения = Справочники.Мессенджеры.НастройкиПодключения(Справочники.Мессенджеры.Mattermost);
	
#КонецОбласти
