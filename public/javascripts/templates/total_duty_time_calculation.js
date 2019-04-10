$(function(){

	var duty_on_time;
	var duty_off_time;

	var duty_on_field = flatpickr("#duty_on_time", {
		dateFormat: 'Y-m-d H:i',
		enableTime: true,
		onChange: function(selectedDates, datestr, instance){
			duty_on_time = Date.parse(datestr);
			calculateTotalDutyHours(duty_on_time, duty_off_time);
		}
	});

	var duty_off_field = flatpickr("#duty_off_time", {
		dateFormat: 'Y-m-d H:i',
		enableTime: true,
		onChange: function(selectedDates, datestr, instance){
			duty_off_time = Date.parse(datestr);
			calculateTotalDutyHours(duty_on_time, duty_off_time);
		}
	});
});


// Calculate total duty time based on duty on and duty off time
function calculateTotalDutyHours(duty_on_time, duty_off_time){
	var total_duty_hours = (duty_off_time - duty_on_time) / 3600000
	$("#total_duty_time").val(total_duty_hours);
}