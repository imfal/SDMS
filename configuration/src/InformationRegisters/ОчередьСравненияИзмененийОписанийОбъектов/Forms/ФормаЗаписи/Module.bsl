///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ОчередьСравненияИзмененийОписанийОбъектов.СтароеОписание КАК СтароеОписание,
	|	ОчередьСравненияИзмененийОписанийОбъектов.НовоеОписание КАК НовоеОписание
	|ИЗ
	|	РегистрСведений.ОчередьСравненияИзмененийОписанийОбъектов КАК ОчередьСравненияИзмененийОписанийОбъектов
	|ГДЕ
	|	ОчередьСравненияИзмененийОписанийОбъектов.Обработано = &Обработано
	|	И ОчередьСравненияИзмененийОписанийОбъектов.Объект = &Объект
	|	И ОчередьСравненияИзмененийОписанийОбъектов.Дата = &Дата";
	
	Запрос.УстановитьПараметр("Обработано", Запись.Обработано);
	Запрос.УстановитьПараметр("Объект", Запись.Объект);
	Запрос.УстановитьПараметр("Дата", Запись.Дата);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	ОписаниеДо = Выборка.СтароеОписание.Получить();
	ОписаниеПосле = Выборка.НовоеОписание.Получить();
	
КонецПроцедуры
