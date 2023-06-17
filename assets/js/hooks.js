import flatpickr from '../vendor/flatpickr'
import {AsYouType} from '../vendor/libphonenumber-js.min';

export const CopyServerLink = {
  mounted() {
    this.el.addEventListener('click', () => {
      const content = this.el.dataset.content;
      navigator.clipboard.writeText(content);

      const innerHTML = this.el.innerHTML;
      this.el.innerHTML = 'Copied!';

      setTimeout(() => {
        this.el.innerHTML = innerHTML;
      }, 1000);
    });
  }
};

export const PhoneNumber = {
  mounted() {
    this.el.addEventListener('input',(e) => {
      this.el.value = new AsYouType('US').input(this.el.value);
    });
  }
};

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
