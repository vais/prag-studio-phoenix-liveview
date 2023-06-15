import flatpickr from '../vendor/flatpickr'
export const Calendar = {
  mounted() {
    this.pickr = flatpickr(this.el, {
      inline: true,
      mode: 'range',
      showMonths: 2,
      onChange: selectedDates => {
        if (selectedDates.length === 2) {
          this.pushEvent('dates-picked', selectedDates);
        }
      }
    });

    this.handleEvent('add-unavailable-dates', (dates) => {
      this.pickr.set('disable', [...this.pickr.config.disable, dates]);
    });

    this.pushEvent('get-unavailable-dates', {}, ({dates}) => {
      this.pickr.set('disable', dates)
    });
  },

  destroyed() {
    console.log('DESTROY!!!');
    this.pickr.destroy();
  }
};
