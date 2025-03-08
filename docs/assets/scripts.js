document.addEventListener('DOMContentLoaded', () => {
    const sections = document.querySelectorAll('.accordion-button');
    sections.forEach((button) => {
        button.addEventListener('click', () => {
            button.scrollIntoView({ behavior: 'smooth', block: 'center' });
        });
    });
});
