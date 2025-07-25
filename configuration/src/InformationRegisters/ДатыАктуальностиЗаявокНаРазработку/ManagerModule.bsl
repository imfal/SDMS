///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

// Основная процедура выполнения задания по актуализации "Заявок на разработку".
//
Процедура ВыполнитьАктуализацию() Экспорт
	
	ОтклонитьНеподтвержденныеЗаявки();
	
	// Поиск заявок, которые требуют актуализации
	НайтиЗаявкиНаАктуализацию();
	
	// Подготовка оповещений пользователям по текущим заявкам, которые нужно актуализировать.
	ПодготовитьОповещенияОбАктуализации();
	
КонецПроцедуры

// Выполняет действия по отклонению заявки. Заявка может быть отклонена пользователем или
// автоматически.
//
// Параметры:
//  Заявка	       - ДокументСсылка.ЗаявкаНаРазработку - заявка на разработку.
//  Автоматическое - Булево	 - признак того, что заявка отклоняется автоматически.
//
Процедура ОтклонитьЗаявку(Знач Заявка, Знач Автоматическое = Ложь) Экспорт
	
	ДокументЗаявка = Заявка.ПолучитьОбъект();
	ДокументЗаявка.Заблокировать();
	ДокументЗаявка.ФинальныйСтатус = Справочники.СтатусыОбъектов.Отклонен;
	
	// Сохранение изменений в заявке
	ДокументЗаявка.Записать();
	ДокументЗаявка.Разблокировать();
	
	// Добавление комментария к изменению состояния
	Если Автоматическое Тогда
		Комментарий = "Заявка отклонена автоматически. Пользователь не предоставил ответ об актуальности заявки.";
		Действие    = 3;
	Иначе
		Комментарий = "Заявка неактуальна.";
		Действие    = 2;
	КонецЕсли;
	
	РегистрыСведений.Комментарии.Добавить(Заявка, , , Комментарий, , Истина);

	// Удаление записи текущего регистра сведений
	Запись = СоздатьМенеджерЗаписи();
	Запись.Заявка = Заявка;
	Запись.Автор  = ДокументЗаявка.Автор;
	Запись.Удалить();
	
	// Добавление записи в историю актуализации. Фиксируется факт отклонения заявки.
	// Автоматически (если Служебный = Истина) или пользовательский.
	РегистрыСведений.ИсторияАктуализацииЗаявокНаРазработку.ДобавитьЗапись(Заявка, Действие);	
		
КонецПроцедуры

// Процедура - Подтвердить актуальность. Сдвигает дату актуальности заявки вперед.
//
// Параметры:
//  Заявка	 - ДокументСсылка.ЗаявкаНаРазработку	 - заявка на разработку
//
Процедура ПодтвердитьАктуальность(Знач Заявка) Экспорт
	
	РеквизитыЗаявки = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Заявка, "Автор, Направление");
		
	// Читаем в регистре запись по заявке
	Запись = СоздатьМенеджерЗаписи();
	Запись.Заявка = Заявка;
	Запись.Автор  = РеквизитыЗаявки.Автор;	
	Запись.Прочитать();
	
	// Если такая запись есть, то изменяем дату актуальности
	Если Запись.Выбран() Тогда
		
		Запись.ДатаАктуальности = ТекущаяДатаСеанса() + ПолучитьСмещениеДаты(Заявка);
			
		// В случае, если пользователь будет отсутствовать на рабочем месте в этот день,
		// то получим количество дней, через сколько он появится на рабочем месте
		ДополнительныеДни = ПолучитьКоличествоДнейОтсутствия(Запись.Автор, Запись.ДатаАктуальности);
			
		// Сдвигаем дату удаления записи из регистра на 1 неделю после даты актуальности + если пользователь в отпуске в этот день,
		// то количество дней до окончания отпуска
		Запись.ДатаУдаления = Запись.ДатаАктуальности + (86400 * (7 + ДополнительныеДни));
		Запись.Записать();
		
		Если ПроверитьНеобходимостьДобавленияКомментария(Заявка) Тогда
			// Добавляем комментарий при актуализации заявки
			РегистрыСведений.Комментарии.Добавить(Заявка, , , "Актуальность заявки подтверждена", , Истина);
		
			// Добавление записи в историю по актуализации заявок на разработку.
			РегистрыСведений.ИсторияАктуализацииЗаявокНаРазработку.ДобавитьЗапись(Заявка, 1);
		КонецЕсли;
	КонецЕсли;
		
КонецПроцедуры

// Функция - Получить количество заявок на актуализацю
//
// Параметры:
//  Автор	 - СправочникСсылка.Пользователи	 - автор заявок
// 
// Возвращаемое значение:
//   - Число
//
Функция ПолучитьКоличествоЗаявокНаАктуализацию(Знач Автор) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ДатыАктуальностиЗаявокНаРазработку.Заявка КАК Заявка
	|ПОМЕСТИТЬ ОтобранныеЗаявкиНаАктуализацию
	|ИЗ
	|	РегистрСведений.ДатыАктуальностиЗаявокНаРазработку КАК ДатыАктуальностиЗаявокНаРазработку
	|ГДЕ
	|	ДатыАктуальностиЗаявокНаРазработку.Автор = &ТекущийПользователь
	|	И ДатыАктуальностиЗаявокНаРазработку.ДатаАктуальности <= &ТекущаяДата
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	ДатыАктуальностиЗаявок.Заявка
	|ИЗ
	|	РегистрСведений.ДатыАктуальностиЗаявокНаРазработку КАК ДатыАктуальностиЗаявок
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ЛичныеДела.СрезПоследних(&ТекущаяДата, Событие = ЗНАЧЕНИЕ(Перечисление.СобытияПоЛичнымДелам.ПереведенВДругоеПодразделение)) КАК ЛичныеДелаСрезПоследних
	|		ПО ДатыАктуальностиЗаявок.Автор = ЛичныеДелаСрезПоследних.Сотрудник
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Филиалы КАК Филиалы
	|		ПО (ВЫРАЗИТЬ(ЛичныеДелаСрезПоследних.Данные КАК Справочник.Филиалы) = Филиалы.Ссылка)
	|			И (Филиалы.Руководитель = &ТекущийПользователь)
	|ГДЕ
	|	ДатыАктуальностиЗаявок.ДатаАктуальности <= &ТекущаяДата
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	КОЛИЧЕСТВО(ОтобранныеЗаявкиНаАктуализацию.Заявка) КАК Количество
	|ИЗ
	|	ОтобранныеЗаявкиНаАктуализацию КАК ОтобранныеЗаявкиНаАктуализацию";
	
	Запрос.УстановитьПараметр("ТекущийПользователь", Автор);
	Запрос.УстановитьПараметр("ТекущаяДата", ТекущаяДатаСеанса());
	
	РезультатЗапроса = Запрос.Выполнить();
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		
		КоличествоЗаявок = Выборка.Количество;
	Иначе
		КоличествоЗаявок = 0;
	КонецЕсли;
	
	Возврат КоличествоЗаявок;
	
КонецФункции

// Процедура - Сменить автора. Изменяет автора в регистре при делегировании заявки
//
// Параметры:
//  Заявка	 - ДокументСсылка.ЗаявкаНаРазработку	 - заявка у которую делегировали
//  Автор	 - СправочникСсылка.Пользователи	 - пользователь на которого делегировали заявку
//
Процедура СменитьАвтора(Знач Заявка, Знач Автор) Экспорт
	
	НаборЗаписей = СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Заявка.Установить(Заявка);
	НаборЗаписей.Прочитать();
	
	Если НаборЗаписей.Количество() > 0 Тогда
		НаборЗаписей.Получить(0).Автор = Автор;
		НаборЗаписей.Записать();
	КонецЕсли;
	
КонецПроцедуры

// Процедура - Удалить заявку из регистра.
//
// Параметры:
//  Заявка	 - ДокументСсылка.ЗаявкаНаРазработку	 - заявка, данные по которой требуется удалить из регистра
//
Процедура УдалитьЗаявку(Знач Заявка) Экспорт
	
	НаборЗаписей = СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Заявка.Установить(Заявка);
	НаборЗаписей.Записать();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыФункции

// Выполняет поиск "Заявок на разработку", которые находятся в статусах "Новый" от даты создания которых прошло более 180 дней. 
// И "На доработку", где время прошедшее от даты создания настраивается в карточке направления
// У выбираемых заявок отсутствуют подчиненные задачи.
//
Процедура НайтиЗаявкиНаАктуализацию()
		
	Запрос = Новый Запрос;
	Запрос.Текст =
	#Область ТекстЗапроса
	"ВЫБРАТЬ
	|	НаправленияРазработки.Ссылка КАК Направление,
	|	ЕСТЬNULL(ЗначенияДополнительныхРеквизитовОбъектов.Значение, 180) КАК СрокАктуальностиЗаявкиВСтатусеНаДоработку
	|ПОМЕСТИТЬ СрокиАктуальностиЗаявокПоНаправлениям
	|ИЗ
	|	Справочник.НаправленияРазработки КАК НаправленияРазработки
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЗначенияДополнительныхРеквизитовОбъектов КАК ЗначенияДополнительныхРеквизитовОбъектов
	|		ПО (НаправленияРазработки.Ссылка = (ВЫРАЗИТЬ(ЗначенияДополнительныхРеквизитовОбъектов.Объект КАК Справочник.НаправленияРазработки)))
	|			И (ЗначенияДополнительныхРеквизитовОбъектов.Реквизит = ЗНАЧЕНИЕ(ПланВидовХарактеристик.ВидыДополнительныхРеквизитов.СрокАктуальностиЗаявкиВСтатусеНаДоработку))
	|			И (ТИПЗНАЧЕНИЯ(ЗначенияДополнительныхРеквизитовОбъектов.Значение) = ТИП(ЧИСЛО))
	|ГДЕ
	|	НЕ НаправленияРазработки.ПометкаУдаления
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ЗаявкаНаРазработку.Ссылка КАК Заявка,
	|	ЗаявкаНаРазработку.Автор КАК Автор,
	|	ЗаявкаНаРазработку.Направление КАК Направление,
	|	ЗаявкаНаРазработку.Дата КАК Дата
	|ПОМЕСТИТЬ ЗаявкиПодходящийСтатус
	|ИЗ
	|	Документ.ЗаявкаНаРазработку КАК ЗаявкаНаРазработку
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СтатусыЗаявокПоСистемам КАК СтатусыЗаявокПоСистемам
	|		ПО ЗаявкаНаРазработку.Ссылка = СтатусыЗаявокПоСистемам.Заявка
	|			И (НЕ СтатусыЗаявокПоСистемам.Статус В (ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.Новый), ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.НаДоработку)))
	|ГДЕ
	|	НЕ ЗаявкаНаРазработку.Черновик
	|	И СтатусыЗаявокПоСистемам.Заявка ЕСТЬ NULL
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЗаявкиПодходящийСтатус.Заявка КАК Заявка,
	|	ЗаявкиПодходящийСтатус.Автор КАК Автор
	|ПОМЕСТИТЬ ЗаявкиПодходящийСрок
	|ИЗ
	|	ЗаявкиПодходящийСтатус КАК ЗаявкиПодходящийСтатус
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.МинимальныеСтатусыЗаявок КАК МинимальныеСтатусыЗаявок
	|		ПО ЗаявкиПодходящийСтатус.Заявка = МинимальныеСтатусыЗаявок.Заявка
	|			И (МинимальныеСтатусыЗаявок.Статус = ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.НаДоработку))
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ СрокиАктуальностиЗаявокПоНаправлениям КАК СрокиАктуальностиЗаявокПоНаправлениям
	|		ПО ЗаявкиПодходящийСтатус.Направление = СрокиАктуальностиЗаявокПоНаправлениям.Направление
	|			И (ДОБАВИТЬКДАТЕ(ЗаявкиПодходящийСтатус.Дата, ДЕНЬ, ВЫРАЗИТЬ(СрокиАктуальностиЗаявокПоНаправлениям.СрокАктуальностиЗаявкиВСтатусеНаДоработку КАК ЧИСЛО)) < &ТекущаяДата)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ЗаявкиПодходящийСтатус.Заявка,
	|	ЗаявкиПодходящийСтатус.Автор
	|ИЗ
	|	ЗаявкиПодходящийСтатус КАК ЗаявкиПодходящийСтатус
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.МинимальныеСтатусыЗаявок КАК МинимальныеСтатусыЗаявок
	|		ПО ЗаявкиПодходящийСтатус.Заявка = МинимальныеСтатусыЗаявок.Заявка
	|			И (МинимальныеСтатусыЗаявок.Статус = ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.Новый))
	|ГДЕ
	|	ДОБАВИТЬКДАТЕ(ЗаявкиПодходящийСтатус.Дата, ДЕНЬ, 180) < &ТекущаяДата
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЗаявкиПодходящийСрок.Заявка КАК Заявка,
	|	ЗаявкиПодходящийСрок.Автор КАК Автор
	|ПОМЕСТИТЬ ОтобранныеЗаявки
	|ИЗ
	|	ЗаявкиПодходящийСрок КАК ЗаявкиПодходящийСрок
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДатыАктуальностиЗаявокНаРазработку КАК ДатыАктуальности
	|		ПО ЗаявкиПодходящийСрок.Заявка = ДатыАктуальности.Заявка
	|			И ЗаявкиПодходящийСрок.Автор = ДатыАктуальности.Автор
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СтруктураПодчиненности КАК СтруктураПодчиненности
	|		ПО (ЗаявкиПодходящийСрок.Заявка = (ВЫРАЗИТЬ(СтруктураПодчиненности.Родитель КАК Документ.ЗаявкаНаРазработку)))
	|ГДЕ
	|	ДатыАктуальности.Заявка ЕСТЬ NULL
	|	И СтруктураПодчиненности.Родитель ЕСТЬ NULL
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ОтобранныеЗаявки.Автор КАК Автор
	|ПОМЕСТИТЬ ОтобранныеАвторы
	|ИЗ
	|	ОтобранныеЗаявки КАК ОтобранныеЗаявки
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДатыОкончания.Пользователь КАК Пользователь,
	|	РАЗНОСТЬДАТ(&ТекущаяДата, МАКСИМУМ(ДатыОкончания.ДатаОкончания), ДЕНЬ) КАК ДниОтсутствия
	|ПОМЕСТИТЬ ДниОтсутствияАвтора
	|ИЗ
	|	(ВЫБРАТЬ
	|		ГрафикОтпусков.Сотрудник КАК Пользователь,
	|		ГрафикОтпусков.ДатаОкончания КАК ДатаОкончания
	|	ИЗ
	|		РегистрСведений.ГрафикОтпусков КАК ГрафикОтпусков
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ ОтобранныеАвторы КАК ОтобранныеАвторы
	|			ПО ГрафикОтпусков.Сотрудник = ОтобранныеАвторы.Автор
	|				И (ГрафикОтпусков.Период <= &ТекущаяДата)
	|				И (ГрафикОтпусков.ДатаОкончания >= &ТекущаяДата)
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		ГрафикОтпусков.Сотрудник,
	|		ГрафикОтпусков.ДатаОкончания
	|	ИЗ
	|		РегистрСведений.ГрафикОтпусков КАК ГрафикОтпусков
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ ОтобранныеАвторы КАК ОтобранныеАвторы
	|			ПО ГрафикОтпусков.Сотрудник = ОтобранныеАвторы.Автор
	|				И (ГрафикОтпусков.Период <= &ДатаУдаления)
	|				И (ГрафикОтпусков.ДатаОкончания >= &ДатаУдаления)) КАК ДатыОкончания
	|
	|СГРУППИРОВАТЬ ПО
	|	ДатыОкончания.Пользователь
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ОтобранныеЗаявки.Автор КАК Автор,
	|	ОтобранныеЗаявки.Заявка КАК Заявка,
	|	ВЫБОР
	|		КОГДА ДниОтсутствияАвтора.Пользователь ЕСТЬ NULL
	|			ТОГДА ДОБАВИТЬКДАТЕ(&ТекущаяДата, ДЕНЬ, 7)
	|		ИНАЧЕ ДОБАВИТЬКДАТЕ(&ТекущаяДата, ДЕНЬ, 7 + ДниОтсутствияАвтора.ДниОтсутствия)
	|	КОНЕЦ КАК ДатаУдаления,
	|	&ТекущаяДата КАК ДатаАктуальности
	|ПОМЕСТИТЬ ПервичныеДатыУдаления
	|ИЗ
	|	ОтобранныеЗаявки КАК ОтобранныеЗаявки
	|		ЛЕВОЕ СОЕДИНЕНИЕ ДниОтсутствияАвтора КАК ДниОтсутствияАвтора
	|		ПО ОтобранныеЗаявки.Автор = ДниОтсутствияАвтора.Пользователь
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПервичныеДатыУдаления.Автор КАК Автор,
	|	ПервичныеДатыУдаления.Заявка КАК Заявка,
	|	ПервичныеДатыУдаления.ДатаАктуальности КАК ДатаАктуальности,
	|	МИНИМУМ(ДОБАВИТЬКДАТЕ(ПроизводственныйКалендарь.ДатаКалендаря, ДЕНЬ, 1)) КАК ДатаУдаления
	|ИЗ
	|	ПервичныеДатыУдаления КАК ПервичныеДатыУдаления
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ПроизводственныйКалендарь КАК ПроизводственныйКалендарь
	|		ПО (ДОБАВИТЬКДАТЕ(ПервичныеДатыУдаления.ДатаУдаления, ДЕНЬ, 1) < ПроизводственныйКалендарь.ДатаКалендаря)
	|			И (ПроизводственныйКалендарь.ВидДня = ЗНАЧЕНИЕ(Перечисление.ВидыДнейПроизводственногоКалендаря.Рабочий))
	|
	|СГРУППИРОВАТЬ ПО
	|	ПервичныеДатыУдаления.Автор,
	|	ПервичныеДатыУдаления.Заявка,
	|	ПервичныеДатыУдаления.ДатаАктуальности";
	#КонецОбласти
	
	ТекущаяДата = НачалоДня(ТекущаяДатаСеанса());
	СмещениеДней = 604800; // 7 дней;
	
	// Дата удаления записи из регистра = текущая дата + смещение дней
	Запрос.УстановитьПараметр("ДатаУдаления", ТекущаяДата + СмещениеДней);
	Запрос.УстановитьПараметр("ТекущаяДата", ТекущаяДата);	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат;
	КонецЕсли;
	
	РегистрИсторииАктуализации = РегистрыСведений.ИсторияАктуализацииЗаявокНаРазработку;
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		НоваяЗапись = СоздатьМенеджерЗаписи();
		ЗаполнитьЗначенияСвойств(НоваяЗапись, Выборка);
		
		НачатьТранзакцию();
		Попытка
			НоваяЗапись.Записать();
			
			// Добавление записи в историю о факте помещения заявки на актуализацию
			РегистрИсторииАктуализации.ДобавитьЗапись(Выборка.Заявка, 0);
			
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			
			ТекстОшибки = "Поиск заявок на актуализацию. Ошибка записи данных в регистр сведений ""ДатыАктуальностиЗаявокНаРазработку"":
			|" + ОписаниеОшибки();
			
			ЗаписьЖурналаРегистрации("Регламентные и фоновые задания.Актуализация заявок на разработку",
			УровеньЖурналаРегистрации.Ошибка, , , ТекстОшибки);
		КонецПопытки;
	КонецЦикла;
	
КонецПроцедуры

// Автоматическое отклонение заявок, у которых вышел срок на актуализацию пользователем.
//
Процедура ОтклонитьНеподтвержденныеЗаявки() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ДатыАктуальностиЗаявокНаРазработку.Заявка КАК Заявка,
	|	ДатыАктуальностиЗаявокНаРазработку.Автор КАК Автор,
	|	ДатыАктуальностиЗаявокНаРазработку.ДатаАктуальности КАК ДатаАктуальности,
	|	ДатыАктуальностиЗаявокНаРазработку.ДатаУдаления КАК ДатаУдаления
	|ПОМЕСТИТЬ АктуальныеЗаявки
	|ИЗ
	|	РегистрСведений.ДатыАктуальностиЗаявокНаРазработку КАК ДатыАктуальностиЗаявокНаРазработку
	|ГДЕ
	|	ДатыАктуальностиЗаявокНаРазработку.ДатаУдаления <= &ТекущаяДата
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	АктуальныеЗаявки.Заявка КАК Заявка,
	|	РАЗНОСТЬДАТ(ГрафикОтпусков.Период, ГрафикОтпусков.ДатаОкончания, ДЕНЬ) КАК КоличествоДнейОтсутствия
	|ПОМЕСТИТЬ ДниОтсутствия
	|ИЗ
	|	АктуальныеЗаявки КАК АктуальныеЗаявки
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ГрафикОтпусков КАК ГрафикОтпусков
	|		ПО АктуальныеЗаявки.Автор = ГрафикОтпусков.Сотрудник
	|			И (АктуальныеЗаявки.ДатаУдаления МЕЖДУ ГрафикОтпусков.Период И ГрафикОтпусков.ДатаОкончания)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	АктуальныеЗаявки.Заявка КАК Заявка,
	|	ДОБАВИТЬКДАТЕ(АктуальныеЗаявки.ДатаУдаления, ДЕНЬ, ЕСТЬNULL(ДниОтсутствия.КоличествоДнейОтсутствия, 0)) КАК ДатаОкончания,
	|	АктуальныеЗаявки.Автор КАК Автор,
	|	ЕСТЬNULL(ДниОтсутствия.КоличествоДнейОтсутствия, 0) КАК КоличествоДнейОтсутствия
	|ИЗ
	|	АктуальныеЗаявки КАК АктуальныеЗаявки
	|		ЛЕВОЕ СОЕДИНЕНИЕ ДниОтсутствия КАК ДниОтсутствия
	|		ПО АктуальныеЗаявки.Заявка = ДниОтсутствия.Заявка";
	
	Запрос.УстановитьПараметр("ТекущаяДата", ТекущаяДатаСеанса());
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Возврат;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
	НаборЗаписей = СоздатьНаборЗаписей();
	
	Пока Выборка.Следующий() Цикл	
		
		// Если Запись в Регистре присутствует и количество дней отсутствия сотрудника не равно 0, тогда
		// перезаписываем запись в Регистре и пропускаем транзакцию
		Если Выборка.КоличествоДнейОтсутствия > 0 Тогда	
			НаборЗаписей.Отбор.Заявка.Установить(Выборка.Заявка);
			НаборЗаписей.Отбор.Автор.Установить(Выборка.Автор);
			
			НаборЗаписей.Прочитать();
			
			Запись = НаборЗаписей[0];	
			Запись.ДатаУдаления = Выборка.ДатаОкончания;
			НаборЗаписей.Записать();
		Иначе
			// Обработка каждого элемента выборки в транзакции нужна потому, что в процедуре 
			// ОтклонитьЗаявку() выполняется запись нескольких логически связанных наборов данных.
			
			НачатьТранзакцию();
			
			Попытка
				ОтклонитьЗаявку(Выборка.Заявка, Истина);
				
				ЗафиксироватьТранзакцию();
			Исключение
				ОтменитьТранзакцию();
				
				ТекстОшибки = "Автоматическое отклонение заявки. Ошибка записи данных:
				|" + ОписаниеОшибки();
				
				ЗаписьЖурналаРегистрации("Регламентные и фоновые задания.Актуализация заявок на разработку",
				УровеньЖурналаРегистрации.Ошибка, , , ТекстОшибки);
			КонецПопытки; 
			
		КонецЕсли;	
	КонецЦикла;
	
КонецПроцедуры

Процедура ПодготовитьОповещенияОбАктуализации()
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ДатыАктуальностиЗаявок.Автор КАК Пользователь,
	|	ДатыАктуальностиЗаявок.Заявка КАК Заявка,
	|	ДокументЗаявка.Номер КАК Номер,
	|	ДокументЗаявка.Наименование КАК Наименование,
	|	ДатыАктуальностиЗаявок.ДатаУдаления КАК ДатаУдаления
	|ПОМЕСТИТЬ ОтобранныеПользователиИЗаявки
	|ИЗ
	|	РегистрСведений.ДатыАктуальностиЗаявокНаРазработку КАК ДатыАктуальностиЗаявок
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗаявкаНаРазработку КАК ДокументЗаявка
	|		ПО ДатыАктуальностиЗаявок.Заявка = ДокументЗаявка.Ссылка
	|ГДЕ
	|	ДатыАктуальностиЗаявок.ДатаАктуальности <= &ТекущаяДата
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	Филиалы.Руководитель,
	|	ДатыАктуальностиЗаявок.Заявка,
	|	ДокументЗаявка.Номер,
	|	ДокументЗаявка.Наименование,
	|	ДатыАктуальностиЗаявок.ДатаУдаления
	|ИЗ
	|	РегистрСведений.ДатыАктуальностиЗаявокНаРазработку КАК ДатыАктуальностиЗаявок
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗаявкаНаРазработку КАК ДокументЗаявка
	|		ПО ДатыАктуальностиЗаявок.Заявка = ДокументЗаявка.Ссылка
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ЛичныеДела.СрезПоследних(&ТекущаяДата, Событие = ЗНАЧЕНИЕ(Перечисление.СобытияПоЛичнымДелам.ПереведенВДругоеПодразделение)) КАК ЛичныеДелаСрезПоследних
	|		ПО ДатыАктуальностиЗаявок.Автор = ЛичныеДелаСрезПоследних.Сотрудник
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Филиалы КАК Филиалы
	|		ПО (Филиалы.Ссылка = (ВЫРАЗИТЬ(ЛичныеДелаСрезПоследних.Данные КАК Справочник.Филиалы)))
	|ГДЕ
	|	ДатыАктуальностиЗаявок.ДатаАктуальности <= &ТекущаяДата
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ОтобранныеПользователиИЗаявки.Заявка КАК Заявка,
	|	ОтобранныеПользователиИЗаявки.Номер КАК Номер,
	|	ОтобранныеПользователиИЗаявки.Наименование КАК Наименование,
	|	ОтобранныеПользователиИЗаявки.ДатаУдаления КАК ДатаУдаления,
	|	Пользователи.Почта КАК АдресЭлектроннойПочты
	|ИЗ
	|	ОтобранныеПользователиИЗаявки КАК ОтобранныеПользователиИЗаявки
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Пользователи КАК Пользователи
	|		ПО ОтобранныеПользователиИЗаявки.Пользователь = Пользователи.Ссылка
	|
	|УПОРЯДОЧИТЬ ПО
	|	ДатаУдаления
	|ИТОГИ
	|	МИНИМУМ(ДатаУдаления)
	|ПО
	|	АдресЭлектроннойПочты";
	
	Запрос.УстановитьПараметр("ТекущаяДата", НачалоДня(ТекущаяДатаСеанса()));
	
	ВыборкаПользователь = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	ШаблоныПисьма = РегистрыСведений.ОчередьОтправкиЭлектронныхПисем.ШаблоныЭлектронногоПисьма();
	
	Пока ВыборкаПользователь.Следующий() Цикл
		ЧастиСообщения = Новый Массив;
		СписокЗаявок = "";
		
		// Собираем список ссылок на заявки.
		ВыборкаЗаявки = ВыборкаПользователь.Выбрать();
		Пока ВыборкаЗаявки.Следующий() Цикл
			
			Если НЕ ПустаяСтрока(СписокЗаявок) Тогда
				СписокЗаявок = СписокЗаявок + "<br>";
			КонецЕсли;
			
			СсылкаНаОбъект = СтрЗаменить(ШаблоныПисьма.АктивнаяСсылка, "<!-- link -->", ОбщегоНазначения.ПолучитьШаблонНавигационнойСсылки(ВыборкаЗаявки.Заявка));
			СсылкаНаОбъект = СтрЗаменить(СсылкаНаОбъект, "<!-- title_link -->", ВыборкаЗаявки.Номер);
			
			СписокЗаявок = СписокЗаявок + СтрШаблон("%1. %2", СсылкаНаОбъект, ВыборкаЗаявки.Наименование); 
			
		КонецЦикла;
		
		ТекстШаблона = "До %1 необходимо определить актуальность следующих ""Заявок на разработку"":";
		ТекстШаблона = СтрШаблон(ТекстШаблона, Формат(ВыборкаПользователь.ДатаУдаления, "ДФ=dd.MM.yyyy"));
		
		ШаблонСообщения = СтрЗаменить(ШаблоныПисьма.БлокОсновногоТекста, "<!-- content -->", ТекстШаблона);
		ШаблонСообщения = СтрЗаменить(ШаблонСообщения, "<!-- font_size -->", "14px");
		
		ЧастиСообщения.Добавить(ШаблонСообщения);
		
		ШаблонСообщения = СтрЗаменить(ШаблоныПисьма.БлокДвеТаблицы, "<!-- left_table_1 -->", СписокЗаявок);
		
		ЧастиСообщения.Добавить(ШаблонСообщения);
		
		СсылкаРаздела = СтрЗаменить(ШаблоныПисьма.АктивнаяСсылка, "<!-- link -->", НавигационнаяСсылкаНаФормуАктуализацииСДМС());
		СсылкаРаздела = СтрЗаменить(СсылкаРаздела, "<!-- title_link -->", "разделе актуализации");
		
		ТекстШаблона = СтрШаблон("Если актуальность указанных заявок не будет обозначена, в указанную дату <b>они отклонятся автоматически.</b>
		|Посмотреть список и выполнить действия можно в <b>%1</b> на рабочем столе.", СсылкаРаздела);
		
		ШаблонСообщения = СтрЗаменить(ШаблоныПисьма.БлокОсновногоТекста, "<!-- content -->", ТекстШаблона);
		ШаблонСообщения = СтрЗаменить(ШаблонСообщения, "<!-- font_size -->", "14px");
		
		ЧастиСообщения.Добавить(ШаблонСообщения);
		
		ЧастиСообщения.Добавить(ШаблоныПисьма.РазделительнаяЛиния);
		
		ЧастиСообщения.Добавить(ШаблоныПисьма.ПодвалПисьма);
		
		ОбщийТекстСообщения = СтрСоединить(ЧастиСообщения, Символы.ПС);
		
		РегистрыСведений.ОчередьОтправкиЭлектронныхПисем.Добавить(ВыборкаПользователь.АдресЭлектроннойПочты, "Актуализация заявок", ОбщийТекстСообщения, 
			Перечисления.ВажностьСообщения.Высокая);
	КонецЦикла;
	
КонецПроцедуры

Функция НавигационнаяСсылкаНаФормуАктуализацииСДМС()
	
	Возврат "<!-- sdms_link_prefix -->#e1cib/command/Обработка.АктуализацияЗаявок.Команда.ОткрытьФормуАктуализации";

КонецФункции

Функция ПроверитьНеобходимостьДобавленияКомментария(Знач Заявка)
	
	Запрос = Новый Запрос;
	Запрос.Текст =  
	"ВЫБРАТЬ
	|	ИсторияАктуализацииЗаявокНаРазработкуСрезПоследних.Период КАК Период,
	|	ИсторияАктуализацииЗаявокНаРазработкуСрезПоследних.Заявка КАК Заявка,
	|	ИсторияАктуализацииЗаявокНаРазработкуСрезПоследних.Действие КАК Действие
	|ИЗ
	|	РегистрСведений.ИсторияАктуализацииЗаявокНаРазработку.СрезПоследних(, 
	|		Заявка = &Заявка) КАК ИсторияАктуализацииЗаявокНаРазработкуСрезПоследних
	|ГДЕ
	|	ИсторияАктуализацииЗаявокНаРазработкуСрезПоследних.Действие = &Действие";
	
	Запрос.УстановитьПараметр("Заявка", Заявка);
	Запрос.УстановитьПараметр("Действие", 1);
	РезультатЗапроса = Запрос.Выполнить();
	 
	Возврат РезультатЗапроса.Пустой();
	
КонецФункции

// Возвращает количество дополнительных дней, на которые необходимо сдвинуть дату отклонения заявки. 
// Дополнительные дни проверяются по регистру сведений ГрафикОтпусков.
// 
// Параметры:
//  Пользователь	       - СправочникСсылка.Пользователи - автор заявки.
//  ДатаНачалаАктуализации - Дата - плановая дата, с которой начинается отсчет актуализации заявки.
// 
// Возвращаемое значение:
//   Число. Количество дней отсутствия пользователя на рабочем месте.
//
Функция ПолучитьКоличествоДнейОтсутствия(Знач Пользователь, Знач ДатаНачалаАктуализации)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЕСТЬNULL(РАЗНОСТЬДАТ(&ДатаАктуализации, МАКСИМУМ(ЕСТЬNULL(ДатыОкончания.ДатаОкончания, &ДатаАктуализации)), ДЕНЬ), 0) КАК КоличествоДнейОтсутствия
	|ИЗ
	|	(ВЫБРАТЬ
	|		ГрафикОтпусков.ДатаОкончания КАК ДатаОкончания
	|	ИЗ
	|		РегистрСведений.ГрафикОтпусков КАК ГрафикОтпусков
	|	ГДЕ
	|		ГрафикОтпусков.Сотрудник = &Пользователь
	|		И ГрафикОтпусков.Период <= &ДатаАктуализации
	|		И ГрафикОтпусков.ДатаОкончания >= &ДатаАктуализации
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		ГрафикОтпусков.ДатаОкончания
	|	ИЗ
	|		РегистрСведений.ГрафикОтпусков КАК ГрафикОтпусков
	|	ГДЕ
	|		ГрафикОтпусков.Сотрудник = &Пользователь
	|		И ГрафикОтпусков.Период <= &ДатаУдаления
	|		И ГрафикОтпусков.ДатаОкончания >= &ДатаУдаления) КАК ДатыОкончания";
	
	Запрос.УстановитьПараметр("Пользователь", Пользователь);
	Запрос.УстановитьПараметр("ДатаАктуализации", ДатаНачалаАктуализации);
	
	// Планируемая дата отклонения заявки равна ДатеАктуальности + 7 дней
	Запрос.УстановитьПараметр("ДатаУдаления", ДатаНачалаАктуализации + 604800);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		
		КоличествоДней = Выборка.КоличествоДнейОтсутствия;
	Иначе
		КоличествоДней = 0;
	КонецЕсли;
	
	Возврат КоличествоДней;
	
КонецФункции

// Получает смещение даты актуальности в зависимости от направления заявки
// Для заявки в статусе "Новый" смещение всегда равно 180 дней.
// Для заявки в статусе "На доработку" смещение настраивается в карточке направления
//
// Параметры:
//  Заявка - ДокументСсылка.Заявка - Заявка для которой рассчитывается смещение даты 
// 
// Возвращаемое значение:
//   Число 
//
Функция ПолучитьСмещениеДаты(Знач Заявка) 
	
	// На всякий случай установим дату сдвига по умолчанию 180 дней
	Смещение = 15552000; 
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	МинимальныеСтатусыЗаявок.Заявка КАК Заявка,
	|	МинимальныеСтатусыЗаявок.Статус КАК Статус,
	|	МинимальныеСтатусыЗаявок.Заявка.Направление КАК ЗаявкаНаправление
	|ПОМЕСТИТЬ СтатусЗаявки
	|ИЗ
	|	РегистрСведений.МинимальныеСтатусыЗаявок КАК МинимальныеСтатусыЗаявок
	|ГДЕ
	|	МинимальныеСтатусыЗаявок.Заявка = &Заявка
	|	И МинимальныеСтатусыЗаявок.Статус = ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.НаДоработку)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЕСТЬNULL(ЗначенияДополнительныхРеквизитовОбъектов.Значение, 180) КАК Смещение
	|ИЗ
	|	СтатусЗаявки КАК СтатусЗаявки
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЗначенияДополнительныхРеквизитовОбъектов КАК ЗначенияДополнительныхРеквизитовОбъектов
	|		ПО (СтатусЗаявки.ЗаявкаНаправление = (ВЫРАЗИТЬ(ЗначенияДополнительныхРеквизитовОбъектов.Объект КАК Справочник.НаправленияРазработки)))
	|			И (ТИПЗНАЧЕНИЯ(ЗначенияДополнительныхРеквизитовОбъектов.Значение) = ТИП(ЧИСЛО))";
	
	Запрос.УстановитьПараметр("Заявка", Заявка);
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		Смещение = Выборка.Смещение * 86400 // Дни в секундах
	КонецЕсли;	
	
	Возврат Смещение;
	
КонецФункции

#КонецОбласти

#КонецЕсли
