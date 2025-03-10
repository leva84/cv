document.addEventListener('DOMContentLoaded', () => {
    const sections = document.querySelectorAll('.accordion-button');
    sections.forEach((button) => {
        button.addEventListener('click', () => {
            button.scrollIntoView({ behavior: 'smooth', block: 'center' });
        });
    });
});

document.addEventListener('scroll', () => {
    const bodyElement = document.body;
    const scrollPosition = window.scrollY;
    bodyElement.style.backgroundPositionY = `${scrollPosition * 0.3}px`;
});

document.addEventListener("DOMContentLoaded", function () {
    const startDate = new Date("2020-09-14T00:00:00"); // Дата начала карьеры
    const experienceList = document.getElementById("career-experience-list");

    // Функция для склонения слов
    function declension(num, singular, few, many) {
        const mod10 = num % 10;
        const mod100 = num % 100;

        if (mod100 >= 11 && mod100 <= 14) {
            return many;
        } else if (mod10 === 1) {
            return singular;
        } else if (mod10 >= 2 && mod10 <= 4) {
            return few;
        } else {
            return many;
        }
    }

    function updateExperience() {
        const now = new Date();
        const diffMs = now - startDate; // разница в миллисекундах

        const seconds = Math.floor(diffMs / 1000) % 60;
        const minutes = Math.floor(diffMs / (1000 * 60)) % 60;
        const hours = Math.floor(diffMs / (1000 * 60 * 60)) % 24;
        const days = Math.floor(diffMs / (1000 * 60 * 60 * 24)) % 30;
        const months = Math.floor(diffMs / (1000 * 60 * 60 * 24 * 30.44)) % 12;
        const years = Math.floor(diffMs / (1000 * 60 * 60 * 24 * 365.25));

        // Обновлять содержимое списка
        experienceList.innerHTML = `
      <li>${years} ${declension(years, 'год', 'года', 'лет')}</li>
      <li>${months} ${declension(months, 'месяц', 'месяца', 'месяцев')}</li>
      <li>${days} ${declension(days, 'день', 'дня', 'дней')}</li>
      <li>${hours} ${declension(hours, 'час', 'часа', 'часов')}</li>
      <li>${minutes} ${declension(minutes, 'минута', 'минуты', 'минут')}</li>
      <li>${seconds} ${declension(seconds, 'секунда', 'секунды', 'секунд')}</li>
    `;
    }

    // Обновлять каждую секунду
    setInterval(updateExperience, 1000);

    // Первый расчет сразу при загрузке
    updateExperience();
});
