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
	
	ЗагрузитьПользовательскиеНастройки();
	СформироватьНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ОбновитьВидимостьЭлементовФормы();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКоманд

&НаКлиенте
Процедура Сформировать(Команда)
	
	СформироватьНаСервере();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура ПриИзмененииВариантовПостроенияОтображения(Элемент)

	СформироватьНаСервере();
	ОбновитьВидимостьЭлементовФормы();
	
КонецПроцедуры

&НаКлиенте
Процедура СпринтыНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
		
	ПараметрыОткрытия = Новый Структура;
	ПараметрыОткрытия.Вставить("ОтмеченныеЗначения", Спринты);
	ПараметрыОткрытия.Вставить("Филиалы", Филиалы);
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработатьВыборСпискаСпринтов", ЭтотОбъект);
	
	ОткрытьФорму("Документ.Спринт.Форма.МножественныйВыбор", ПараметрыОткрытия, ЭтотОбъект, КлючУникальности, , , ОписаниеОповещения);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиОповещений

&НаКлиенте
Процедура ОбработатьВыборСпискаСпринтов(Знач Результат, Знач ДополнительныеПараметры) Экспорт
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Спринты = Результат.ВыбранныеСпринты;
	филиалы = Результат.Филиалы;	
	
	СформироватьНаСервере();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗагрузитьПользовательскиеНастройки()
	
	Ключи = ПолучитьКлючиНастроек();
	Настройки = ОбщегоНазначенияВызовСервера.ЗагрузитьНастройкиДанныхФормы(Ключи.Объект, Ключи.Настройка);
	
	Если ТипЗнч(Настройки) = Тип("Структура") Тогда
		Если Настройки.Версия = 1 Тогда
			Спринты = Настройки.Спринты;
			Филиалы = Настройки.Филиалы;
			ВариантОтображения = Настройки.ВариантОтображения;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьВидимостьЭлементовФормы()
	
	Элементы.ГруппаНижниеГрафики.Видимость = (ВариантОтображения = 0);
		
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ПолучитьКлючиНастроек()
	
	Возврат Новый Структура("Объект, Настройка", "Обработка.ОтчетСравненияСпринтов", "ПользовательскиеНастройки");
	
КонецФункции

&НаСервере
Процедура СохранитьПользовательскиеНастройки()
	
	Настройки = Новый Структура;
	Настройки.Вставить("Версия", 1);
	Настройки.Вставить("Спринты", Спринты);
	Настройки.Вставить("Филиалы", Филиалы);
	Настройки.Вставить("ВариантОтображения", ВариантОтображения);
	
	Ключи = ПолучитьКлючиНастроек();
	ОбщегоНазначенияВызовСервера.СохранитьНастройкиДанныхФормы(Ключи.Объект, Ключи.Настройка, Настройки);
	
КонецПроцедуры

&НаСервере
Процедура СформироватьНаСервере()
	
	График.Очистить();
	ГрафикЦелевые.Очистить();
	ГрафикПроцентЗавершения.Очистить();
	
	ДоступноеВремя = Документы.Спринт.ПолучитьДоступноеВремяСпринтов(Спринты);
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	#Область ТекстЗапроса
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ДокументСпринт.Ссылка КАК Спринт,
	|	ДокументСпринт.Номер КАК Номер,
	|	ДокументСпринт.Филиал КАК Филиал,
	|	ДокументСпринт.Команда КАК Команда,
	|	ДокументСпринт.ДатаНачала КАК Начало,
	|	КОНЕЦПЕРИОДА(ДокументСпринт.ДатаОкончания, ДЕНЬ) КАК Окончание
	|ПОМЕСТИТЬ ОтобранныеСпринты
	|ИЗ
	|	Документ.Спринт КАК ДокументСпринт
	|ГДЕ
	|	ДокументСпринт.Ссылка В(&СписокСпринтов)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДоступноеВремя.Спринт КАК Спринт,
	|	ДоступноеВремя.Время КАК Время
	|ПОМЕСТИТЬ ДоступноеВремяСпринтов
	|ИЗ
	|	&ДоступноеВремя КАК ДоступноеВремя
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ОтобранныеСпринты.Спринт КАК Спринт,
	|	ОтобранныеСпринты.Начало КАК Начало,
	|	ОтобранныеСпринты.Окончание КАК Окончание,
	|	ДокументЗадача.Ссылка КАК Задача,
	|	ЕСТЬNULL(ВЫРАЗИТЬ(ЗначенияДополнительныхРеквизитовОбъектов.Значение КАК БУЛЕВО), ЛОЖЬ) КАК Целевая,
	|	ВЫБОР
	|		КОГДА ВЫРАЗИТЬ(ЕСТЬNULL(НастройкиФилиалов.Значение, ЛОЖЬ) КАК БУЛЕВО)
	|			ТОГДА 0
	|		ИНАЧЕ ЕСТЬNULL(ПланируемыеТрудозатраты.Трудозатраты, 0)
	|	КОНЕЦ КАК ОценкаТрудозатрат,
	|	ВЫБОР
	|		КОГДА ВЫРАЗИТЬ(ЕСТЬNULL(НастройкиФилиалов.Значение, ЛОЖЬ) КАК БУЛЕВО)
	|			ТОГДА ДокументЗадача.ОценкаStoryPoint
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК ОценкаStoryPoint,
	|	ДокументЗадача.Заказчик КАК Заказчик
	|ПОМЕСТИТЬ ЗадачиСпринтов
	|ИЗ
	|	ОтобранныеСпринты КАК ОтобранныеСпринты
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СоставСпринтов КАК СоставСпринтов
	|		ПО ОтобранныеСпринты.Спринт = СоставСпринтов.Спринт
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.Задача КАК ДокументЗадача
	|		ПО (СоставСпринтов.Объект = ДокументЗадача.Ссылка)
	|			И ВЫБОР КОГДА ОтобранныеСпринты.Команда <> ЗНАЧЕНИЕ(Справочник.Филиалы.ПустаяСсылка) 
	|				ТОГДА ДокументЗадача.КомандаРазработчиков = ОтобранныеСпринты.Команда
	|				ИНАЧЕ ИСТИНА
	|			КОНЕЦ				
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЗначенияДополнительныхРеквизитовОбъектов КАК ЗначенияДополнительныхРеквизитовОбъектов
	|		ПО (ДокументЗадача.ОбъектОснование = ЗначенияДополнительныхРеквизитовОбъектов.Объект)
	|			И (ЗначенияДополнительныхРеквизитовОбъектов.Реквизит = ЗНАЧЕНИЕ(ПланВидовХарактеристик.ВидыДополнительныхРеквизитов.ЦелеваяЗаявка))
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.НастройкиФилиалов КАК НастройкиФилиалов
	|		ПО (ДокументЗадача.Филиал = НастройкиФилиалов.Филиал)
	|			И (НастройкиФилиалов.Настройка = ЗНАЧЕНИЕ(ПланВидовХарактеристик.ВидыНастроекФилиалов.ОцениватьЗадачиВStoryPoint))
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПланируемыеТрудозатратыПоСпринтам КАК ПланируемыеТрудозатраты
	|		ПО (ДокументЗадача.Ссылка = ПланируемыеТрудозатраты.Объект)
	|			И (ПланируемыеТрудозатраты.Спринт = ОтобранныеСпринты.Спринт)
	|			И (ПланируемыеТрудозатраты.ТипТрудозатрат = ЗНАЧЕНИЕ(Перечисление.ТипыТрудозатрат.Разработка))
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЗадачиСпринтов.Спринт КАК Спринт,
	|	СУММА(ЗадачиСпринтов.ОценкаТрудозатрат) КАК ПланТрудозатраты,
	|	СУММА(ЗадачиСпринтов.ОценкаStoryPoint) КАК ПланStoryPoint
	|ПОМЕСТИТЬ ПланПоСпринтам
	|ИЗ
	|	ЗадачиСпринтов КАК ЗадачиСпринтов
	|
	|СГРУППИРОВАТЬ ПО
	|	ЗадачиСпринтов.Спринт
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЗадачиСпринтов.Спринт КАК Спринт,
	|	ЗадачиСпринтов.Задача КАК Задача,
	|	ЗадачиСпринтов.Целевая КАК Целевая,
	|	ЗадачиСпринтов.ОценкаStoryPoint КАК ОценкаStoryPoint,
	|	ЗадачиСпринтов.Заказчик КАК Заказчик,
	|	МАКСИМУМ(СвойстваЗадач.Период) КАК Период,
	|	МАКСИМУМ(ИсторияСоставаСпринтов.Период) КАК ПериодСостав
	|ПОМЕСТИТЬ ДатыПоследнихИзмененийЗадач
	|ИЗ
	|	ЗадачиСпринтов КАК ЗадачиСпринтов
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.СвойстваЗадач КАК СвойстваЗадач
	|		ПО ЗадачиСпринтов.Окончание > СвойстваЗадач.Период
	|			И ЗадачиСпринтов.Задача = СвойстваЗадач.Объект
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ИсторияСоставаСпринтов КАК ИсторияСоставаСпринтов
	|		ПО ЗадачиСпринтов.Окончание > ИсторияСоставаСпринтов.Период
	|			И ЗадачиСпринтов.Спринт = ИсторияСоставаСпринтов.Спринт
	|			И ЗадачиСпринтов.Задача = ИсторияСоставаСпринтов.Объект
	|
	|СГРУППИРОВАТЬ ПО
	|	ЗадачиСпринтов.Спринт,
	|	ЗадачиСпринтов.Задача,
	|	ЗадачиСпринтов.ОценкаStoryPoint,
	|	ЗадачиСпринтов.Заказчик,
	|	ЗадачиСпринтов.Целевая
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДатыПоследнихИзмененийЗадач.Спринт КАК Спринт,
	|	ДатыПоследнихИзмененийЗадач.Задача КАК Задача,
	|	ДатыПоследнихИзмененийЗадач.Целевая КАК Целевая,
	|	ДатыПоследнихИзмененийЗадач.ОценкаStoryPoint КАК ОценкаStoryPoint,
	|	ДатыПоследнихИзмененийЗадач.Заказчик КАК Заказчик,
	|	ЕСТЬNULL(СвойстваЗадач.ПроцентВыполнения, 0) КАК ПроцентВыполнения,
	|	ЕСТЬNULL(ИсторияСоставаСпринтов.Статус, ЕСТЬNULL(СвойстваЗадач.Статус, ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.Новый))) КАК Статус,
	|	ЕСТЬNULL(СвойстваЗадач.Исполнитель, ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)) КАК Исполнитель
	|ПОМЕСТИТЬ ДанныеПоЗадачам
	|ИЗ
	|	ДатыПоследнихИзмененийЗадач КАК ДатыПоследнихИзмененийЗадач
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СвойстваЗадач КАК СвойстваЗадач
	|		ПО ДатыПоследнихИзмененийЗадач.Период = СвойстваЗадач.Период
	|			И ДатыПоследнихИзмененийЗадач.Задача = СвойстваЗадач.Объект
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ИсторияСоставаСпринтов КАК ИсторияСоставаСпринтов
	|		ПО ДатыПоследнихИзмененийЗадач.ПериодСостав = ИсторияСоставаСпринтов.Период
	|			И ДатыПоследнихИзмененийЗадач.Спринт = ИсторияСоставаСпринтов.Спринт
	|			И ДатыПоследнихИзмененийЗадач.Задача = ИсторияСоставаСпринтов.Объект
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДанныеПоЗадачам.Спринт КАК Спринт,
	|	СУММА(ДанныеПоЗадачам.ОценкаStoryPoint * ЕСТЬNULL(ДанныеПоЗадачам.ПроцентВыполнения, 0) / 100) КАК Факт
	|ПОМЕСТИТЬ ФактStoryPoint
	|ИЗ
	|	ДанныеПоЗадачам КАК ДанныеПоЗадачам
	|
	|СГРУППИРОВАТЬ ПО
	|	ДанныеПоЗадачам.Спринт
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЗадачиСпринтов.Спринт КАК Спринт,
	|	СУММА(ЕСТЬNULL(Трудозатраты.Затрата, 0)) КАК Факт
	|ПОМЕСТИТЬ ФактТрудозатраты
	|ИЗ
	|	ЗадачиСпринтов КАК ЗадачиСпринтов
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.Трудозатраты КАК Трудозатраты
	|		ПО (Трудозатраты.Период МЕЖДУ ЗадачиСпринтов.Начало И ЗадачиСпринтов.Окончание)
	|			И (ЗадачиСпринтов.Задача = (ВЫРАЗИТЬ(Трудозатраты.Объект КАК Документ.Задача)))
	|			И (Трудозатраты.ITСтруктура)
	|
	|СГРУППИРОВАТЬ ПО
	|	ЗадачиСпринтов.Спринт
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДанныеПоЗадачам.Спринт КАК Спринт,
	|	КОЛИЧЕСТВО(ДанныеПоЗадачам.Задача) КАК КоличествоРешенных,
	|	СУММА(ВЫБОР
	|			КОГДА ДанныеПоЗадачам.Целевая
	|				ТОГДА 1
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК КоличествоРешенныхЦелевых
	|ПОМЕСТИТЬ КоличествоРешенныхЗадач
	|ИЗ
	|	ДанныеПоЗадачам КАК ДанныеПоЗадачам
	|ГДЕ
	|	(ДанныеПоЗадачам.Статус В (ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.Протестирован), ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.Решен), ЗНАЧЕНИЕ(Справочник.СтатусыОбъектов.Тестирование)))
	|
	|СГРУППИРОВАТЬ ПО
	|	ДанныеПоЗадачам.Спринт
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЗадачиСпринтов.Спринт КАК Спринт,
	|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ЗадачиСпринтов.Задача) КАК КоличествоЗадач,
	|	СУММА(ВЫБОР
	|			КОГДА ЗадачиСпринтов.Целевая
	|				ТОГДА 1
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК КоличествоЦелевых
	|ПОМЕСТИТЬ КоличествоЗадачСпринтов
	|ИЗ
	|	ЗадачиСпринтов КАК ЗадачиСпринтов
	|
	|СГРУППИРОВАТЬ ПО
	|	ЗадачиСпринтов.Спринт
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ОтобранныеСпринты.Номер КАК Номер,
	|	ОтобранныеСпринты.Филиал КАК Филиал,
	|	ОтобранныеСпринты.Команда КАК Команда,
	|	ЕСТЬNULL(ДоступноеВремяСпринтов.Время, 0) КАК ДоступноеВремя,
	|	ЕСТЬNULL(ПланПоСпринтам.ПланТрудозатраты, 0) КАК ПланТрудозатраты,
	|	ЕСТЬNULL(ПланПоСпринтам.ПланStoryPoint, 0) КАК ПланStoryPoint,
	|	ЕСТЬNULL(ФактТрудозатраты.Факт, 0) КАК ФактТрудозатраты,
	|	ЕСТЬNULL(ФактStoryPoint.Факт, 0) КАК ФактStoryPoint,
	|	ЕСТЬNULL(КоличествоРешенныхЗадач.КоличествоРешенных, 0) КАК КоличествоРешенныхЗадач,
	|	ЕСТЬNULL(КоличествоРешенныхЗадач.КоличествоРешенныхЦелевых, 0) КАК КоличествоРешенныхЦелевых,
	|	ЕСТЬNULL(КоличествоЗадачСпринтов.КоличествоЗадач, 0) КАК КоличествоЗадач,
	|	ЕСТЬNULL(КоличествоЗадачСпринтов.КоличествоЦелевых, 0) КАК КоличествоЦелевых
	|ИЗ
	|	ОтобранныеСпринты КАК ОтобранныеСпринты
	|		ЛЕВОЕ СОЕДИНЕНИЕ ДоступноеВремяСпринтов КАК ДоступноеВремяСпринтов
	|		ПО ОтобранныеСпринты.Спринт = ДоступноеВремяСпринтов.Спринт
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПланПоСпринтам КАК ПланПоСпринтам
	|		ПО ОтобранныеСпринты.Спринт = ПланПоСпринтам.Спринт
	|		ЛЕВОЕ СОЕДИНЕНИЕ ФактТрудозатраты КАК ФактТрудозатраты
	|		ПО ОтобранныеСпринты.Спринт = ФактТрудозатраты.Спринт
	|		ЛЕВОЕ СОЕДИНЕНИЕ ФактStoryPoint КАК ФактStoryPoint
	|		ПО ОтобранныеСпринты.Спринт = ФактStoryPoint.Спринт
	|		ЛЕВОЕ СОЕДИНЕНИЕ КоличествоРешенныхЗадач КАК КоличествоРешенныхЗадач
	|		ПО ОтобранныеСпринты.Спринт = КоличествоРешенныхЗадач.Спринт
	|		ЛЕВОЕ СОЕДИНЕНИЕ КоличествоЗадачСпринтов КАК КоличествоЗадачСпринтов
	|		ПО ОтобранныеСпринты.Спринт = КоличествоЗадачСпринтов.Спринт
	|
	|УПОРЯДОЧИТЬ ПО
	|	ОтобранныеСпринты.Номер
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ОтобранныеСпринты.Номер КАК Спринт,
	|	""Начало"" КАК Показатель,
	|	ОтобранныеСпринты.Начало КАК Значение
	|ИЗ
	|	ОтобранныеСпринты КАК ОтобранныеСпринты
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ОтобранныеСпринты.Номер,
	|	""Завершение"",
	|	ОтобранныеСпринты.Окончание
	|ИЗ
	|	ОтобранныеСпринты КАК ОтобранныеСпринты
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ОтобранныеСпринты.Номер,
	|	""Доступное время"",
	|	ЕСТЬNULL(ДоступноеВремяСпринтов.Время, 0)
	|ИЗ
	|	ОтобранныеСпринты КАК ОтобранныеСпринты
	|		ЛЕВОЕ СОЕДИНЕНИЕ ДоступноеВремяСпринтов КАК ДоступноеВремяСпринтов
	|		ПО ОтобранныеСпринты.Спринт = ДоступноеВремяСпринтов.Спринт
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ОтобранныеСпринты.Номер,
	|	""Плановые трудозатраты"",
	|	ЕСТЬNULL(ПланПоСпринтам.ПланТрудозатраты, 0)
	|ИЗ
	|	ОтобранныеСпринты КАК ОтобранныеСпринты
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПланПоСпринтам КАК ПланПоСпринтам
	|		ПО ОтобранныеСпринты.Спринт = ПланПоСпринтам.Спринт
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ОтобранныеСпринты.Номер,
	|	""Фактические трудозатраты"",
	|	ЕСТЬNULL(ФактТрудозатраты.Факт, 0)
	|ИЗ
	|	ОтобранныеСпринты КАК ОтобранныеСпринты
	|		ЛЕВОЕ СОЕДИНЕНИЕ ФактТрудозатраты КАК ФактТрудозатраты
	|		ПО ОтобранныеСпринты.Спринт = ФактТрудозатраты.Спринт
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ОтобранныеСпринты.Номер,
	|	""Все задачи"",
	|	ЕСТЬNULL(КоличествоЗадачСпринтов.КоличествоЗадач, 0)
	|ИЗ
	|	ОтобранныеСпринты КАК ОтобранныеСпринты
	|		ЛЕВОЕ СОЕДИНЕНИЕ КоличествоЗадачСпринтов КАК КоличествоЗадачСпринтов
	|		ПО ОтобранныеСпринты.Спринт = КоличествоЗадачСпринтов.Спринт
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ОтобранныеСпринты.Номер,
	|	""Решенные"",
	|	ЕСТЬNULL(КоличествоРешенныхЗадач.КоличествоРешенных, 0)
	|ИЗ
	|	ОтобранныеСпринты КАК ОтобранныеСпринты
	|		ЛЕВОЕ СОЕДИНЕНИЕ КоличествоРешенныхЗадач КАК КоличествоРешенныхЗадач
	|		ПО ОтобранныеСпринты.Спринт = КоличествоРешенныхЗадач.Спринт
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ОтобранныеСпринты.Номер,
	|	""Нерешенные"",
	|	ЕСТЬNULL(КоличествоЗадачСпринтов.КоличествоЗадач, 0) - ЕСТЬNULL(КоличествоРешенныхЗадач.КоличествоРешенных, 0)
	|ИЗ
	|	ОтобранныеСпринты КАК ОтобранныеСпринты
	|		ЛЕВОЕ СОЕДИНЕНИЕ КоличествоЗадачСпринтов КАК КоличествоЗадачСпринтов
	|		ПО ОтобранныеСпринты.Спринт = КоличествоЗадачСпринтов.Спринт
	|		ЛЕВОЕ СОЕДИНЕНИЕ КоличествоРешенныхЗадач КАК КоличествоРешенныхЗадач
	|		ПО ОтобранныеСпринты.Спринт = КоличествоРешенныхЗадач.Спринт
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ОтобранныеСпринты.Номер,
	|	""% выполнения"",
	|	ВЫБОР
	|		КОГДА ЕСТЬNULL(КоличествоЗадачСпринтов.КоличествоЗадач, 0) <> 0
	|			ТОГДА ЕСТЬNULL(КоличествоРешенныхЗадач.КоличествоРешенных, 0) / ЕСТЬNULL(КоличествоЗадачСпринтов.КоличествоЗадач, 0) * 100
	|		ИНАЧЕ 0
	|	КОНЕЦ
	|ИЗ
	|	ОтобранныеСпринты КАК ОтобранныеСпринты
	|		ЛЕВОЕ СОЕДИНЕНИЕ КоличествоЗадачСпринтов КАК КоличествоЗадачСпринтов
	|		ПО ОтобранныеСпринты.Спринт = КоличествоЗадачСпринтов.Спринт
	|		ЛЕВОЕ СОЕДИНЕНИЕ КоличествоРешенныхЗадач КАК КоличествоРешенныхЗадач
	|		ПО ОтобранныеСпринты.Спринт = КоличествоРешенныхЗадач.Спринт
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ОтобранныеСпринты.Номер,
	|	""Целевые"",
	|	ЕСТЬNULL(КоличествоЗадачСпринтов.КоличествоЦелевых, 0)
	|ИЗ
	|	ОтобранныеСпринты КАК ОтобранныеСпринты
	|		ЛЕВОЕ СОЕДИНЕНИЕ КоличествоЗадачСпринтов КАК КоличествоЗадачСпринтов
	|		ПО ОтобранныеСпринты.Спринт = КоличествоЗадачСпринтов.Спринт
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ОтобранныеСпринты.Номер,
	|	""Решенные целевые"",
	|	ЕСТЬNULL(КоличествоРешенныхЗадач.КоличествоРешенныхЦелевых, 0)
	|ИЗ
	|	ОтобранныеСпринты КАК ОтобранныеСпринты
	|		ЛЕВОЕ СОЕДИНЕНИЕ КоличествоРешенныхЗадач КАК КоличествоРешенныхЗадач
	|		ПО ОтобранныеСпринты.Спринт = КоличествоРешенныхЗадач.Спринт
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ОтобранныеСпринты.Номер,
	|	""Нерешенные целевые"",
	|	ЕСТЬNULL(КоличествоЗадачСпринтов.КоличествоЦелевых, 0) - ЕСТЬNULL(КоличествоРешенныхЗадач.КоличествоРешенныхЦелевых, 0)
	|ИЗ
	|	ОтобранныеСпринты КАК ОтобранныеСпринты
	|		ЛЕВОЕ СОЕДИНЕНИЕ КоличествоЗадачСпринтов КАК КоличествоЗадачСпринтов
	|		ПО ОтобранныеСпринты.Спринт = КоличествоЗадачСпринтов.Спринт
	|		ЛЕВОЕ СОЕДИНЕНИЕ КоличествоРешенныхЗадач КАК КоличествоРешенныхЗадач
	|		ПО ОтобранныеСпринты.Спринт = КоличествоРешенныхЗадач.Спринт
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ОтобранныеСпринты.Номер,
	|	""% выполнения целевых"",
	|	ВЫБОР
	|		КОГДА ЕСТЬNULL(КоличествоЗадачСпринтов.КоличествоЦелевых, 0) <> 0
	|			ТОГДА ЕСТЬNULL(КоличествоРешенныхЗадач.КоличествоРешенныхЦелевых, 0) / ЕСТЬNULL(КоличествоЗадачСпринтов.КоличествоЦелевых, 0) * 100
	|		ИНАЧЕ 0
	|	КОНЕЦ
	|ИЗ
	|	ОтобранныеСпринты КАК ОтобранныеСпринты
	|		ЛЕВОЕ СОЕДИНЕНИЕ КоличествоЗадачСпринтов КАК КоличествоЗадачСпринтов
	|		ПО ОтобранныеСпринты.Спринт = КоличествоЗадачСпринтов.Спринт
	|		ЛЕВОЕ СОЕДИНЕНИЕ КоличествоРешенныхЗадач КАК КоличествоРешенныхЗадач
	|		ПО ОтобранныеСпринты.Спринт = КоличествоРешенныхЗадач.Спринт";

	#КонецОбласти	

	Запрос.УстановитьПараметр("СписокСпринтов", Спринты);
	Запрос.УстановитьПараметр("ДоступноеВремя", ДоступноеВремя);
	
	Пакеты = Запрос.ВыполнитьПакет();
	
	КоличествоПакетов = Пакеты.ВГраница();
	РезультатЗапроса = Пакеты[КоличествоПакетов - 1];
	
	Если НЕ РезультатЗапроса.Пустой() Тогда	
		Серия1 = График.Серии.Добавить();
		Серия2 = График.Серии.Добавить();
		
		СерияЦелевые1 = ГрафикЦелевые.Серии.Добавить();

		Если ВариантОтображения = 0 Тогда
			График.ОбластьЗаголовка.Текст = "Количество задач";
			Серия1.Текст = "Всего задач";
			Серия2.Текст = "Решено задач";
			
			ГрафикЦелевые.ОбластьЗаголовка.Текст = "Количество целевых задач";
			ГрафикЦелевые.ОбластьЛегенды.Расположение = РасположениеЛегендыДиаграммы.Право;
			СерияЦелевые2 = ГрафикЦелевые.Серии.Добавить();
			СерияЦелевые1.Текст = "Всего";
			СерияЦелевые2.Текст = "Решено";

			ГрафикПроцентЗавершения.ОбластьЗаголовка.Текст = "% завершения задач";
			СерияПроцентЗавершения1 = ГрафикПроцентЗавершения.Серии.Добавить();
			СерияПроцентЗавершения2 = ГрафикПроцентЗавершения.Серии.Добавить();
			СерияПроцентЗавершения1.Текст = "Целевые задачи";
			СерияПроцентЗавершения2.Текст = "Общее количество задач";
			
			СформироватьТаблицуПоказателей(Пакеты[КоличествоПакетов].Выгрузить());
			
		Иначе
			График.ОбластьЗаголовка.Текст = "Трудозатраты";
			Серия1.Текст = "План";
			Серия2.Текст = "Факт";
			
			Если ВариантОтображения = 1 Тогда
				Серия3 = График.Серии.Добавить();
				Серия3.Текст = "Доступные";
			КонецЕсли;
			
			ГрафикЦелевые.ОбластьЗаголовка.Текст = "Точность планирования (%)";
			ГрафикЦелевые.ОбластьЛегенды.Расположение = РасположениеЛегендыДиаграммы.Нет;
		КонецЕсли;
		
		Выборка = РезультатЗапроса.Выбрать();
		Пока Выборка.Следующий() Цикл
			Если ЗначениеЗаполнено(Выборка.Команда) Тогда
				СпринтНаименование = СтрШаблон("#%1 %2 (%3)", Выборка.Номер, Выборка.Филиал, Выборка.Команда);
			Иначе
				СпринтНаименование = СтрШаблон("#%1 %2", Выборка.Номер, Выборка.Филиал);
			КонецЕсли;
			
			Точка = График.Точки.Добавить(СпринтНаименование);
			ТочкаЦелевые = ГрафикЦелевые.Точки.Добавить(СпринтНаименование);
									
			Если ВариантОтображения = 0 Тогда
				ЗначениеСерия1 = Выборка.КоличествоЗадач;
				ЗначениеСерия2 = Выборка.КоличествоРешенныхЗадач;

				ЗначениеСерияЦелевые1 = Выборка.КоличествоЦелевых;
				ЗначениеСерияЦелевые2 = Выборка.КоличествоРешенныхЦелевых;

				ГрафикЦелевые.УстановитьЗначение(ТочкаЦелевые, СерияЦелевые1, ЗначениеСерияЦелевые1);
				ГрафикЦелевые.УстановитьЗначение(ТочкаЦелевые, СерияЦелевые2, ЗначениеСерияЦелевые2);

				ТочкаПроцентЗавершения = ГрафикПроцентЗавершения.Точки.Добавить(СпринтНаименование);
				
				Если Выборка.КоличествоЦелевых <> 0 Тогда
					ЗначениеПроцентЗавершения1 = Окр((Выборка.КоличествоРешенныхЦелевых / Выборка.КоличествоЦелевых) * 100, 2);
				Иначе 
					ЗначениеПроцентЗавершения1 = 0;
				КонецЕсли;

				Если Выборка.КоличествоЗадач <> 0 Тогда
					ЗначениеПроцентЗавершения2 = Окр((Выборка.КоличествоРешенныхЗадач / Выборка.КоличествоЗадач) * 100, 2);
				Иначе 
					ЗначениеПроцентЗавершения2 = 0;
				КонецЕсли;

				ГрафикПроцентЗавершения.УстановитьЗначение(ТочкаПроцентЗавершения, СерияПроцентЗавершения1, ЗначениеПроцентЗавершения1);
				ГрафикПроцентЗавершения.УстановитьЗначение(ТочкаПроцентЗавершения, СерияПроцентЗавершения2, ЗначениеПроцентЗавершения2);

			ИначеЕсли ВариантОтображения = 1 Тогда
				ЗначениеСерия1 = Выборка.ПланТрудозатраты;
				ЗначениеСерия2 = Выборка.ФактТрудозатраты;
				ЗначениеСерия3 = Выборка.ДоступноеВремя;
				
				Если Выборка.ПланТрудозатраты <> 0 Тогда
					ЗначениеСерияЦелевые1 = Окр((Выборка.ФактТрудозатраты / Выборка.ПланТрудозатраты) * 100, 2);
				Иначе
					ЗначениеСерияЦелевые1 = 0;
				КонецЕсли;
				
				График.УстановитьЗначение(Точка, Серия3, ЗначениеСерия3);
				ГрафикЦелевые.УстановитьЗначение(ТочкаЦелевые, СерияЦелевые1, ЗначениеСерияЦелевые1);
	
			Иначе
				ЗначениеСерия1 = Выборка.ПланStoryPoint;
				ЗначениеСерия2 = Выборка.ФактStoryPoint;
				
				Если Выборка.ПланStoryPoint <> 0 Тогда
					ЗначениеСерияЦелевые1 = Окр((Выборка.ФактStoryPoint / Выборка.ПланStoryPoint) * 100, 2);
				Иначе
					ЗначениеСерияЦелевые1 = 0;
				КонецЕсли;
				
				ГрафикЦелевые.УстановитьЗначение(ТочкаЦелевые, СерияЦелевые1, ЗначениеСерияЦелевые1);				
			КонецЕсли;
			
			График.УстановитьЗначение(Точка, Серия1, ЗначениеСерия1);
			График.УстановитьЗначение(Точка, Серия2, ЗначениеСерия2);
		КонецЦикла;
	КонецЕсли;
		
	СохранитьПользовательскиеНастройки();
	
КонецПроцедуры

Процедура СформироватьТаблицуПоказателей(Таблица)
		
	Показатели.Очистить();	
	СхемаКомпоновкиДанных = Отчеты.СравнениеСпринтов.ПолучитьМакет("ТаблицаПоказателей");
	Настройки = СхемаКомпоновкиДанных.НастройкиПоУмолчанию;
	
	ДанныеРасшифровкиКомпоновкиДанных = Новый ДанныеРасшифровкиКомпоновкиДанных;
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, Настройки, ДанныеРасшифровкиКомпоновкиДанных);
	
	ВнешниеНаборыДанных = Новый Структура("ОсновныеДанные", Таблица);
	
	ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновки, ВнешниеНаборыДанных, ДанныеРасшифровкиКомпоновкиДанных);
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(Показатели);
	ПроцессорВывода.Вывести(ПроцессорКомпоновкиДанных);	
	
КонецПроцедуры

#КонецОбласти
