function setupCalendar (monthElementId, 
                        dayElementId, 
	                yearElementId, 
                        triggerElementId) {
  Calendar.setup({ 
    button : triggerElementId,
    weekNumbers : false,
    range : [2007, new Date().getFullYear()],
    step : 1,
    onSelect : function (calendar) { 
      if (calendar.dateClicked) {
        var date = calendar.date;
        $(yearElementId).value = date.getFullYear();
        $(monthElementId).value = date.getMonth() + 1;
        $(dayElementId).value = date.getDate();
        calendar.callCloseHandler();
      }
    }
  });
}