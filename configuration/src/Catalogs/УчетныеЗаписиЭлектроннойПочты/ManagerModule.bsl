///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2025, ООО ДНС Технологии
// SDMS (Software Development Management System) — это корпоративная система учета разработки и управления проектами 
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии General Public License (GNU GPL v3)
// Текст лицензии доступен по ссылке:
// https://www.gnu.org/licenses/gpl-3.0.html
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Возвращает заполненный почтовый профиль для приема сообщений
// 
// Возвращаемое значение:
//   - ИнтернетПочтовыйПрофиль
//
Функция СвойстваСлужебногоЯщикаДляПолученияПисем() Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("ПрофильЗаполнен", Истина);
	Результат.Вставить("ПочтовыйПрофиль", Новый ИнтернетПочтовыйПрофиль);
	Результат.Вставить("Отправитель", Новый Структура("Имя, Адрес",  "", ""));
		
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	УчетныеЗаписиЭлектроннойПочты.АдресЭлектроннойПочты КАК АдресОтправителя,
	|	УчетныеЗаписиЭлектроннойПочты.АдресСервераIMAP КАК АдресСервераIMAP,
	|	УчетныеЗаписиЭлектроннойПочты.ВремяОжидания КАК Таймаут,
	|	УчетныеЗаписиЭлектроннойПочты.ИспользоватьSSLIMAP КАК ИспользоватьSSLIMAP,
	|	УчетныеЗаписиЭлектроннойПочты.ИмяПользователя КАК ИмяОтправителя,
	|	УчетныеЗаписиЭлектроннойПочты.ПарольSMTP КАК Пароль,
	|	УчетныеЗаписиЭлектроннойПочты.ПользовательSMTP КАК Пользователь,
	|	УчетныеЗаписиЭлектроннойПочты.ПарольSMTP КАК ПарольIMAP,
	|	УчетныеЗаписиЭлектроннойПочты.ПользовательSMTP КАК ПользовательIMAP,
	|	УчетныеЗаписиЭлектроннойПочты.ПортIMAP КАК ПортIMAP
	|ИЗ
	|	Справочник.УчетныеЗаписиЭлектроннойПочты КАК УчетныеЗаписиЭлектроннойПочты
	|ГДЕ
	|	УчетныеЗаписиЭлектроннойПочты.ИспользоватьДляПолучения";
	
	РезультатЗапроса = Запрос.Выполнить();
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		
		// Заполняем профиль почты
		ЗаполнитьЗначенияСвойств(Результат.ПочтовыйПрофиль, Выборка);
		
		Результат.Отправитель.Имя = Выборка.ИмяОтправителя;
		Результат.Отправитель.Адрес = Выборка.АдресОтправителя;
	Иначе
		Результат.ПрофильЗаполнен = Ложь;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Возвращает заполненный почтовый профиль для отправки сообщений
// 
// Возвращаемое значение:
//   - ИнтернетПочтовыйПрофиль
//
Функция СвойстваСлужебногоЯщикаДляОтправкиПисем () Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("ПрофильЗаполнен", Истина);
	Результат.Вставить("ПочтовыйПрофиль", Новый ИнтернетПочтовыйПрофиль);
	Результат.Вставить("Отправитель", Новый Структура("Имя, Адрес",  "", ""));
		
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	УчетныеЗаписиЭлектроннойПочты.АдресЭлектроннойПочты КАК АдресОтправителя,
	|	УчетныеЗаписиЭлектроннойПочты.ВремяОжидания КАК Таймаут,
	|	УчетныеЗаписиЭлектроннойПочты.ИспользоватьЗащищенноеСоединениеДляИсходящейПочты КАК ИспользоватьSSLSMTP,
	|	УчетныеЗаписиЭлектроннойПочты.ИмяПользователя КАК ИмяОтправителя,
	|	УчетныеЗаписиЭлектроннойПочты.ПарольSMTP КАК Пароль,
	|	УчетныеЗаписиЭлектроннойПочты.ПользовательSMTP КАК Пользователь,
	|	УчетныеЗаписиЭлектроннойПочты.ПарольSMTP КАК ПарольSMTP,
	|	УчетныеЗаписиЭлектроннойПочты.ПользовательSMTP КАК ПользовательSMTP,
	|	УчетныеЗаписиЭлектроннойПочты.ПортСервераИсходящейПочты КАК ПортSMTP,
	|	УчетныеЗаписиЭлектроннойПочты.СерверИсходящейПочты КАК АдресСервераSMTP
	|ИЗ
	|	Справочник.УчетныеЗаписиЭлектроннойПочты КАК УчетныеЗаписиЭлектроннойПочты
	|ГДЕ
	|	УчетныеЗаписиЭлектроннойПочты.ИспользоватьДляОтправки";
	
	РезультатЗапроса = Запрос.Выполнить();
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		
		// Заполняем профиль почты
		ЗаполнитьЗначенияСвойств(Результат.ПочтовыйПрофиль, Выборка);	
		
		Результат.Отправитель.Имя = Выборка.ИмяОтправителя;
		Результат.Отправитель.Адрес = Выборка.АдресОтправителя;
	Иначе
		Результат.ПрофильЗаполнен = Ложь;
	КонецЕсли;
	
	Возврат Результат;

КонецФункции

#КонецОбласти
