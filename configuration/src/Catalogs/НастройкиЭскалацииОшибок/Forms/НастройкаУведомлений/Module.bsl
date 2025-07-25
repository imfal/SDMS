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
Перем КэшСерьезностиОшибок; // Хранит соответствие ссылки предопределенному имени элемента справочника СерьезностьОшибок

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	КэшСерьезностиОшибок = СоздатьЭлементыНастроекЭскалации();
	АдресХранилища = ПоместитьВоВременноеХранилище(КэшСерьезностиОшибок, УникальныйИдентификатор);
	
	ЗагрузитьПоследниеНастройкиПользователя();
	Безопасность.НастроитьФормуПослеОткрытия(ЭтотОбъект);
	
	Если ЗначениеЗаполнено(Система) И ЗначениеЗаполнено(Направление) Тогда
		ЗагрузитьНастройки();
	Иначе
		ТолькоПросмотр = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	КэшСерьезностиОшибок = ПолучитьИзВременногоХранилища(АдресХранилища);
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если НЕ ЗавершениеРаботы И Модифицированность Тогда
		Отказ = Истина;
		
		ЗаголовокВопроса = "Несохраненные изменения";
		ТекстВопроса = "Для выбранных направления и системы есть несохраненные настройки. Сохранить?";
		ОписаниеОповещения = Новый ОписаниеОповещения("ОбработатьОтветНаСохранениеПередЗакрытиемФормы", ЭтотОбъект);
		
		ПоказатьВопрос(ОписаниеОповещения, ТекстВопроса, РежимДиалогаВопрос.ДаНетОтмена, , , ЗаголовокВопроса);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	
	Если НЕ ЗавершениеРаботы И ИзменениеНастроекРазрешено И ЗначениеЗаполнено(ЭлементНастроек) Тогда
		СнятьБлокировкуДанных(ЭлементНастроек, УникальныйИдентификатор);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура НаправлениеОбработкаВыбора(ВыбранноеЗначение, СтандартнаяОбработка)
	
	ОбработкаВыбораНаправленияИлиСистемы("Направление", ВыбранноеЗначение, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура НаправлениеОчистка(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура НаправлениеПриИзменении(Элемент)
	
	ПриИзмененииСистемыИлиНаправления();
	
КонецПроцедуры

&НаКлиенте
Процедура НастройкиЭскалацииВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	ТекущиеДанные = Элемент.ТекущиеДанные;
	
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ТолькоПросмотр Тогда
		Если СтрНайти(Поле.Имя, "Удалить") > 0 Тогда
			НастройкиЭскалации.Удалить(ТекущиеДанные);
		ИначеЕсли СтрНайти(Поле.Имя, "Получатели") > 0 Тогда
			ПараметрыОткрытия = Новый Структура("ВыбранныеПолучатели", ТекущиеДанные.Получатели);
			ОткрытьФорму("Справочник.НастройкиЭскалацииОшибок.Форма.УправлениеПолучателями", ПараметрыОткрытия, Элемент);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура НастройкиЭскалацииОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Элемент.ТекущиеДанные.Получатели = ВыбранноеЗначение;
	Модифицированность = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура НастройкиЭскалацииПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	
	Если НоваяСтрока Тогда
		Серьезность = СтрЗаменить(Элемент.Имя, "НастройкиЭскалации", "");
		
		Элемент.ТекущиеДанные.ИдентификаторОчереди = Новый УникальныйИдентификатор;
		Элемент.ТекущиеДанные.СерьезностьОшибки = КэшСерьезностиОшибок.Получить(Серьезность);
		Элемент.ТекущиеДанные.Удалить = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СистемаОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	ОбработкаВыбораНаправленияИлиСистемы("Система", ВыбранноеЗначение, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура СистемаОчистка(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура СистемаПриИзменении(Элемент)
	
	ПриИзмененииСистемыИлиНаправления();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКоманд

&НаКлиенте
Процедура Записать(Команда)
	
	ЗакрытьФорму = (Команда.Имя = "ЗаписатьИЗакрыть");
	СохранитьИЗакрыть(ЗакрытьФорму);
	
КонецПроцедуры

&НаКлиенте
Процедура Справка(Команда)
	
	ПерейтиПоНавигационнойСсылке(
		ОбщегоНазначенияВызовСервера.ПолучитьКонстанту("КорневойURL") + "/docs/notifications/error-escalation-notifications/");
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗагрузитьНастройки()
	
	Если ИзменениеНастроекРазрешено И ЗначениеЗаполнено(ЭлементНастроек) Тогда
		СнятьБлокировкуДанных(ЭлементНастроек, УникальныйИдентификатор);
	КонецЕсли;
	
	Модифицированность = Ложь;
	СохранитьПользовательскиеНастройки();
	НастройкиЭскалации.Очистить();
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	НастройкиЭскалацииОшибок.Ссылка КАК Ссылка,
	|	НастройкиЭскалацииОшибокОчередьЭскалации.ИдентификаторОчереди КАК ИдентификаторОчереди,
	|	НастройкиЭскалацииОшибокОчередьЭскалации.ОтсрочкаУведомления КАК ОтсрочкаУведомления,
	|	НастройкиЭскалацииОшибокОчередьЭскалации.СерьезностьОшибки КАК СерьезностьОшибки,
	|	НастройкиЭскалацииОшибокПолучателиОповещений.Получатель КАК Получатель,
	|	ПРЕДСТАВЛЕНИЕ(НастройкиЭскалацииОшибокПолучателиОповещений.Получатель) КАК ПолучательПредставление
	|ИЗ
	|	Справочник.НастройкиЭскалацииОшибок КАК НастройкиЭскалацииОшибок
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.НастройкиЭскалацииОшибок.ОчередьЭскалации КАК НастройкиЭскалацииОшибокОчередьЭскалации
	|		ПО НастройкиЭскалацииОшибок.Ссылка = НастройкиЭскалацииОшибокОчередьЭскалации.Ссылка
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.НастройкиЭскалацииОшибок.ПолучателиОповещений КАК НастройкиЭскалацииОшибокПолучателиОповещений
	|		ПО (НастройкиЭскалацииОшибок.Ссылка = НастройкиЭскалацииОшибокПолучателиОповещений.Ссылка)
	|			И (НастройкиЭскалацииОшибокОчередьЭскалации.ИдентификаторОчереди = НастройкиЭскалацииОшибокПолучателиОповещений.ИдентификаторОчереди)
	|ГДЕ
	|	НастройкиЭскалацииОшибок.Система = &Система
	|	И НастройкиЭскалацииОшибок.Направление = &Направление
	|
	|УПОРЯДОЧИТЬ ПО
	|	ОтсрочкаУведомления
	|ИТОГИ
	|	СРЕДНЕЕ(ОтсрочкаУведомления),
	|	МАКСИМУМ(СерьезностьОшибки)
	|ПО
	|	Ссылка,
	|	ИдентификаторОчереди";
	
	Запрос.УстановитьПараметр("Система", Система);
	Запрос.УстановитьПараметр("Направление", Направление);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если НЕ РезультатЗапроса.Пустой() Тогда
		ВыборкаЭлемент = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		ВыборкаЭлемент.Следующий();
		ЭлементНастроек = ВыборкаЭлемент.Ссылка;
		
		ВыборкаОчереди = ВыборкаЭлемент.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаОчереди.Следующий() Цикл
			НоваяОчередь = НастройкиЭскалации.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяОчередь, ВыборкаОчереди);
			НоваяОчередь.Удалить = Истина;
			
			ВыборкаПолучателей = ВыборкаОчереди.Выбрать();
			Пока ВыборкаПолучателей.Следующий() Цикл
				НоваяОчередь.Получатели.Добавить(ВыборкаПолучателей.Получатель, ВыборкаПолучателей.ПолучательПредставление);
			КонецЦикла;
		КонецЦикла;
	Иначе
		ЭлементНастроек = Неопределено;
	КонецЕсли;
	
	ДанныеЗаблокированы = Истина;
	
	Если ИзменениеНастроекРазрешено И ЗначениеЗаполнено(ЭлементНастроек) Тогда
		Попытка
			ЗаблокироватьДанныеДляРедактирования(ЭлементНастроек, , УникальныйИдентификатор);
		Исключение
			ДанныеЗаблокированы = Ложь;
			БлокирующийПользователь = ОбщегоНазначения.ПолучитьБлокирующегоПользователя(ОписаниеОшибки());
		КонецПопытки;
	КонецЕсли;
	
	ТолькоПросмотр = НЕ ИзменениеНастроекРазрешено ИЛИ НЕ ДанныеЗаблокированы; 
	
	Элементы.НадписьБлокировка.Видимость = НЕ ДанныеЗаблокированы;
	
	Если НЕ ДанныеЗаблокированы Тогда
		ТекстШаблона = "В данный момент настройки редактирует пользователь ""%1"". Одновременное изменение настроек невозможно.";
		Элементы.НадписьБлокировка.Заголовок = СтрШаблон(ТекстШаблона, БлокирующийПользователь);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьПоследниеНастройкиПользователя()
	
	Ключи = ПолучитьКлючиНастроек(ИмяФормы);
	
	СохраненныеНастройки = ОбщегоНазначенияВызовСервера.ЗагрузитьНастройкиДанныхФормы(Ключи.КлючОбъекта, Ключи.КлючНастроек);
	
	Если СохраненныеНастройки <> Неопределено Тогда
		СохраненныеНастройки.Свойство("Система", Система);
		СохраненныеНастройки.Свойство("Направление", Направление);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция НастройкиЗаполненыКорректно()
	
	ЕстьОшибка = Ложь;
	ОшибкаПолучатели = "Не заполнены получатели";
	ОшибкаОтсрочка = "Отсрочка уведомления дублируется";
	ШаблонПоля = "НастройкиЭскалации[%1].%2";
	
	Выборка = Справочники.СерьезностьОшибок.Выбрать();
	Пока Выборка.Следующий() Цикл
		Отбор = Новый Структура("СерьезностьОшибки", Выборка.Ссылка);
		СтрокиСерьезности = НастройкиЭскалации.НайтиСтроки(Отбор);
		
		Для Каждого Строка Из СтрокиСерьезности Цикл
			Индекс = НастройкиЭскалации.Индекс(Строка);
			
			Если Строка.Получатели.Количество() = 0 Тогда
				Поле = СтрШаблон(ШаблонПоля, Индекс, "Получатели");
				ТекстСообщения = СтрШаблон("На вкладке %1 не заполнены получатели", Выборка.Наименование);
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , Поле, , ЕстьОшибка);
			КонецЕсли;
			
			Отбор.Вставить("ОтсрочкаУведомления", Строка.ОтсрочкаУведомления);
			Если НастройкиЭскалации.НайтиСтроки(Отбор).Количество() > 1 Тогда
				Поле = СтрШаблон(ШаблонПоля, Индекс, "ОтсрочкаУведомления");
				ТекстСообщения = СтрШаблон("На вкладке %1 отсрочка уведомления дублируется", Выборка.Наименование);
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , Поле, , ЕстьОшибка);
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	Возврат НЕ ЕстьОшибка;
	
КонецФункции

&НаКлиенте
Процедура ОбработатьОтветНаИзменениеПараметров(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ = 0 ИЛИ Ответ = 1 Тогда
		ОчиститьСообщения();
		СохранитьНастройкиИЗагрузитьНовые(Ответ, ДополнительныеПараметры);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбораНаправленияИлиСистемы(ИмяРеквизита, НовоеЗначение, СтандартнаяОбработка)
	
	Если Модифицированность Тогда
		СтандартнаяОбработка = Ложь;
		
		ДопПараметры = Новый Структура;
		ДопПараметры.Вставить("ИмяРеквизита", ИмяРеквизита);
		ДопПараметры.Вставить("НовоеЗначение", НовоеЗначение);
		
		Кнопки = Новый СписокЗначений;
		Кнопки.Добавить(0, "Сохранить");
		Кнопки.Добавить(1, "Не сохранять");
		Кнопки.Добавить(2, "Отмена");
		
		ТекстВопроса = "Для выбранных направления и системы есть несохраненные настройки.";
		
		ОписаниеОповещения = Новый ОписаниеОповещения("ОбработатьОтветНаИзменениеПараметров", ЭтотОбъект, ДопПараметры);
		ПоказатьВопрос(ОписаниеОповещения, ТекстВопроса, Кнопки, , 0, "");
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьОтветНаСохранениеПередЗакрытиемФормы(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		СохранитьИЗакрыть(Истина);
	ИначеЕсли Результат = КодВозвратаДиалога.Нет Тогда
		Модифицированность = Ложь;
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьКлючиНастроек(Знач ИмяФормы)
	
	КлючиНастроек = Новый Структура("КлючОбъекта, КлючНастроек");
	КлючиНастроек.КлючОбъекта = ИмяФормы;
	КлючиНастроек.КлючНастроек = "НастройкиПользователя";
	
	Возврат КлючиНастроек;
	
КонецФункции

&НаСервере
Функция ПолучитьБлокирующегоПользователя(Знач ТекстОшибки)
	
	МассивСтрок = СтрРазделить(СтрПолучитьСтроку(ТекстОшибки, 2), ",");
	СтрокаCПользователем = МассивСтрок[0];
	МассивПодстрокСтрокиСПользователем = СтрРазделить(СтрокаCПользователем, ":");	
	БлокирующийПользователь = МассивПодстрокСтрокиСПользователем[1];
	
	Возврат СокрЛП(БлокирующийПользователь);
	
КонецФункции

&НаКлиенте
Процедура ПриИзмененииСистемыИлиНаправления()
	
	ПараметрыЗаполнены = (ЗначениеЗаполнено(Направление) И ЗначениеЗаполнено(Система));
	
	Если ПараметрыЗаполнены Тогда
		ЗагрузитьНастройки();
	Иначе
		ТолькоПросмотр = Истина;
		НастройкиЭскалации.Очистить();
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура СнятьБлокировкуДанных(Знач ОбъектБлокировки, Знач ИдентификаторФормы)
		
	РазблокироватьДанныеДляРедактирования(ОбъектБлокировки, ИдентификаторФормы);

КонецПроцедуры

&НаСервере
Функция СоздатьЭлементыНастроекЭскалации()
	
	КэшСерьезностиОшибок = Новый Соответствие;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СерьезностьОшибок.Ссылка КАК Ссылка,
	|	СерьезностьОшибок.ИмяПредопределенныхДанных КАК ИмяПредопределенных
	|ИЗ
	|	Справочник.СерьезностьОшибок КАК СерьезностьОшибок
	|ГДЕ
	|	СерьезностьОшибок.Предопределенный";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		ИмяЭлемента = "НастройкиЭскалации" + Выборка.ИмяПредопределенных;
		Элементы[ИмяЭлемента].ОтборСтрок = Новый ФиксированнаяСтруктура("СерьезностьОшибки", Выборка.Ссылка);
		КэшСерьезностиОшибок.Вставить(Выборка.ИмяПредопределенных, Выборка.Ссылка);
	КонецЦикла;
	
	Возврат КэшСерьезностиОшибок;
	
КонецФункции

&НаКлиенте
Процедура СохранитьИЗакрыть(Знач ЗакрытьФорму)
	
	Если Модифицированность Тогда
		ОчиститьСообщения();
		НастройкиСохранены = СохранитьНастройки();
	Иначе
		НастройкиСохранены = Истина;
	КонецЕсли;
	
	Если НастройкиСохранены И ЗакрытьФорму Тогда
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция СохранитьНастройки()
	
	НастройкиСохранены = Ложь;
	
	Если НастройкиЗаполненыКорректно() Тогда
		Модифицированность = Ложь;
		
		Если ЗначениеЗаполнено(ЭлементНастроек) Тогда
			НастройкиОбъект = ЭлементНастроек.ПолучитьОбъект();
			НастройкиОбъект.ОчередьЭскалации.Очистить();
			НастройкиОбъект.ПолучателиОповещений.Очистить();
		Иначе
			НастройкиОбъект = Справочники.НастройкиЭскалацииОшибок.СоздатьЭлемент();
			НастройкиОбъект.ДатаСоздания = ТекущаяДатаСеанса();
			НастройкиОбъект.Автор = ПараметрыСеанса.ТекущийПользователь;
			НастройкиОбъект.Направление = Направление;
			НастройкиОбъект.Система = Система;
		КонецЕсли;
		
		Настройки = НастройкиЭскалации.Выгрузить(, "СерьезностьОшибки, ИдентификаторОчереди, ОтсрочкаУведомления");
		НастройкиОбъект.ОчередьЭскалации.Загрузить(Настройки);
		
		Для Каждого Строка Из НастройкиЭскалации Цикл
			Для Каждого Получатель Из Строка.Получатели Цикл
				НовыйПолучатель = НастройкиОбъект.ПолучателиОповещений.Добавить();
				НовыйПолучатель.ИдентификаторОчереди = Строка.ИдентификаторОчереди;
				НовыйПолучатель.Получатель = Получатель.Значение;
			КонецЦикла;
		КонецЦикла;
		
		НастройкиОбъект.ОчередьЭскалации.Сортировать("ОтсрочкаУведомления, СерьезностьОшибки");
		
		Попытка
			НастройкиОбъект.Записать();
			НастройкиСохранены = Истина;
		Исключение
			ТекстОшибки = ОписаниеОшибки();
			ЗаписьЖурналаРегистрации("Настройки эскалации ошибок.Сохранение настроек",
				УровеньЖурналаРегистрации.Ошибка, , , ТекстОшибки);
		КонецПопытки;
		
		Если НЕ ЗначениеЗаполнено(ЭлементНастроек) Тогда
			ЭлементНастроек = НастройкиОбъект.Ссылка;
			ЗаблокироватьДанныеДляРедактирования(ЭлементНастроек, , УникальныйИдентификатор);
		КонецЕсли;
	КонецЕсли;
	
	Возврат НастройкиСохранены;
	
КонецФункции

&НаСервере
Процедура СохранитьНастройкиИЗагрузитьНовые(Знач ОтветПользователя, Знач ДополнительныеПараметры)
	
	Если ОтветПользователя = 0 Тогда
		НастройкиСохранены = СохранитьНастройки();
	Иначе
		НастройкиСохранены = Истина;
	КонецЕсли;
	
	Если НастройкиСохранены Тогда
		ЭтотОбъект[ДополнительныеПараметры.ИмяРеквизита] = ДополнительныеПараметры.НовоеЗначение;
		ЗагрузитьНастройки();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура СохранитьПользовательскиеНастройки()
	
	СтруктураНастроек = Новый Структура;
	СтруктураНастроек.Вставить("Направление", Направление);
	СтруктураНастроек.Вставить("Система", Система);
	
	Ключи = ПолучитьКлючиНастроек(ИмяФормы);
	ОбщегоНазначенияВызовСервера.СохранитьНастройкиДанныхФормы(Ключи.КлючОбъекта, Ключи.КлючНастроек, СтруктураНастроек);
	
КонецПроцедуры

#КонецОбласти
