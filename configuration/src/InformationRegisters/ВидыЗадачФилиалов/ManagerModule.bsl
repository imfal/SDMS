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

// Записывает виды задач, которые будут использоваться филиалами
//
// Параметры:
//  Филиал		 - СправочникСсылка.Филиалы	 - филиал
//  ВидыЗадач	 - Массив	 - виды задач
//
Процедура ЗаписатьВидыЗадач(Знач Филиал, Знач ВидыЗадач) Экспорт
	
	НаборЗаписей = СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Филиал.Установить(Филиал);
	
	Для Каждого ВидЗадачи Из ВидыЗадач Цикл
		НоваяСтрока = НаборЗаписей.Добавить();
		НоваяСтрока.Филиал = Филиал;
		НоваяСтрока.ВидЗадачи = ВидЗадачи;
	КонецЦикла;
	
	НаборЗаписей.Записать();
	
КонецПроцедуры

// Возвращает виды задач, которые используются филиалом
//
// Параметры:
//  Филиал	 - СправочникСсылка.Филиалы	 - филиал, для которого нужно получить виды задач
// 
// Возвращаемое значение:
//  Массив - виды задач, используемые филиалом
//
Функция ПолучитьВидыЗадач(Знач Филиал) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ВидыЗадачФилиалов.ВидЗадачи КАК ВидЗадачи
	|ИЗ
	|	РегистрСведений.ВидыЗадачФилиалов КАК ВидыЗадачФилиалов
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ВидыЗадач КАК ВидыЗадач
	|		ПО ВидыЗадачФилиалов.ВидЗадачи = ВидыЗадач.Ссылка
	|ГДЕ
	|	ВидыЗадачФилиалов.Филиал = &Филиал
	|
	|УПОРЯДОЧИТЬ ПО
	|	ВидыЗадач.Наименование";
	
	Запрос.УстановитьПараметр("Филиал", Филиал);
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("ВидЗадачи");
	
КонецФункции

// Удаляет вид задачи из списка выбранных при пометке удаления вида задачи
//
// Параметры:
//  ВидЗадачи	 - СправочникСсылка.ВидыЗадач	 - вид задачи, помеченный на удаление
//
Процедура УдалитьВидЗадачиПриПометкеУдаления(Знач ВидЗадачи) Экспорт
	
	НаборЗаписей = СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.ВидЗадачи.Установить(ВидЗадачи);
	НаборЗаписей.Записать();
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
