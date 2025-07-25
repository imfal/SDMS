///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиКоманд

&НаКлиенте
Процедура ПодборЦелевогоВремени(Команда)
	
	// Попробуем найти текущую ключевою операцию. Определить ее текущий индекс апдекс. и открыть форму для подбора целевого времени
	Расшифровка = Результат.ТекущаяОбласть.Расшифровка;
	Если Расшифровка <> Неопределено Тогда
		ПоляРасшифровки = ПолучитьПоляРасшифровкиНаСервере(Расшифровка);
		
		Если ПоляРасшифровки.Свойство("КлючеваяОперация") тогда
			Попытка
				// Найдем колонку с именем АПДЕКС в табличном документе и оттуда выдернем значение
				ПоляРасшифровки.Вставить("APDEX", Число(Результат.Область(Результат.ТекущаяОбласть.Верх, Результат.НайтиТекст("APDEX").Право).Текст));
			Исключение
			КонецПопытки;
			
			ОткрытьФорму("Обработка.ОценкаПроизводительности.Форма.ПодборЦелевогоВремениКлючевойОперации", ПоляРасшифровки, ЭтотОбъект, Новый УникальныйИдентификатор);
			
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ПолучитьПоляРасшифровкиНаСервере(Расшифровка)
	
	_ДанныеРасшифровки = ПолучитьИзВременногоХранилища(ДанныеРасшифровки);

	СтруктураРасшифровки = Новый Структура;        
	РекурсивноПолучитьРодителей(_ДанныеРасшифровки, _ДанныеРасшифровки.Элементы.Получить(Расшифровка), СтруктураРасшифровки); 
	
	Возврат СтруктураРасшифровки;
	
КонецФункции

&НаСервере
Процедура РекурсивноПолучитьРодителей(_ДанныеРасшифровки, Элемент, Структура)
	
	Родители = Элемент.ПолучитьРодителей();
	Для Каждого Родитель из Родители Цикл
		Если ТипЗнч(Родитель) = Тип("ЭлементРасшифровкиКомпоновкиДанныхПоля") Тогда
			Поля = Родитель.ПолучитьПоля();
			Для Каждого Поле из Поля Цикл
				Если Не Поле.Иерархия  Тогда
					Структура.Вставить(Поле.Поле,Поле.Значение);
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		//РекурсивноПолучитьРодителей(_ДанныеРасшифровки, Родитель, Структура)
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
