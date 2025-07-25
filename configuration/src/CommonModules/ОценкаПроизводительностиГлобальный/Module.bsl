
#Область СлужебныеПроцедурыИФункции

// Процедура заканчивает замер времени выполнения ключевой операции.
// Вызывается из обработчика ожидания.
Процедура ЗакончитьЗамерВремениАвто() Экспорт
	
	ОценкаПроизводительностиКлиент.ЗавершитьЗамерВремениНаКлиентеАвто();
	
КонецПроцедуры

// Процедура вызывает функцию записи результатов замеров на сервере.
// Вызывается из обработчика ожидания.
Процедура ЗаписатьРезультатыАвто() Экспорт
	
	ОценкаПроизводительностиКлиент.ЗаписатьРезультатыАвтоНеГлобальный();
	
КонецПроцедуры

#КонецОбласти
